#!/usr/bin/env python3
"""
XDG Base Directory 规范合规性验证脚本
检查 mycli、pgcli、docker、k9s 是否正确遵循 XDG 规范
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass

# 颜色定义
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'

def log_info(msg: str):
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")

def log_success(msg: str):
    print(f"{Colors.GREEN}[✅ PASS]{Colors.NC} {msg}")

def log_warning(msg: str):
    print(f"{Colors.YELLOW}[⚠️  WARN]{Colors.NC} {msg}")

def log_error(msg: str):
    print(f"{Colors.RED}[❌ FAIL]{Colors.NC} {msg}")

def log_header(msg: str):
    print(f"\n{Colors.PURPLE}{'='*60}{Colors.NC}")  
    print(f"{Colors.WHITE}{msg.center(60)}{Colors.NC}")
    print(f"{Colors.PURPLE}{'='*60}{Colors.NC}")

@dataclass
class ComplianceCheck:
    """合规性检查结果"""
    tool: str
    check_name: str
    status: str  # 'pass', 'fail', 'warn', 'skip'
    message: str
    details: Optional[str] = None

class XDGComplianceVerifier:
    """XDG合规性验证器"""
    
    def __init__(self):
        self.setup_xdg_paths()
        self.checks: List[ComplianceCheck] = []
        
    def setup_xdg_paths(self):
        """设置XDG路径"""
        home = Path.home()
        
        # Windows 平台 XDG 路径映射
        if os.name == 'nt' or sys.platform.startswith('win') or 'MSYS' in os.environ.get('MSYSTEM', ''):
            self.xdg_config_home = Path(os.environ.get('XDG_CONFIG_HOME', home / 'AppData/Local'))
            self.xdg_data_home = Path(os.environ.get('XDG_DATA_HOME', home / 'AppData/Local'))
            self.xdg_state_home = Path(os.environ.get('XDG_STATE_HOME', home / 'AppData/Local/State'))
            self.xdg_cache_home = Path(os.environ.get('XDG_CACHE_HOME', home / 'AppData/Local/Temp'))
            self.is_windows = True
        else:
            # Linux/macOS 标准 XDG 路径
            self.xdg_config_home = Path(os.environ.get('XDG_CONFIG_HOME', home / '.config'))
            self.xdg_data_home = Path(os.environ.get('XDG_DATA_HOME', home / '.local/share'))
            self.xdg_state_home = Path(os.environ.get('XDG_STATE_HOME', home / '.local/state'))
            self.xdg_cache_home = Path(os.environ.get('XDG_CACHE_HOME', home / '.cache'))
            self.is_windows = False
            
    def check_tool_installed(self, tool: str) -> bool:
        """检查工具是否已安装"""
        try:
            result = subprocess.run([tool, '--version'], 
                                  capture_output=True, text=True, timeout=5)
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False
            
    def check_environment_variables(self) -> List[ComplianceCheck]:
        """检查XDG环境变量设置"""
        checks = []
        
        xdg_vars = {
            'XDG_CONFIG_HOME': str(self.xdg_config_home),
            'XDG_DATA_HOME': str(self.xdg_data_home), 
            'XDG_STATE_HOME': str(self.xdg_state_home),
            'XDG_CACHE_HOME': str(self.xdg_cache_home)
        }
        
        for var, expected in xdg_vars.items():
            actual = os.environ.get(var)
            if actual:
                if Path(actual) == Path(expected):
                    checks.append(ComplianceCheck(
                        'system', f'{var} 环境变量', 'pass',
                        f'{var}={actual}'
                    ))
                else:
                    checks.append(ComplianceCheck(
                        'system', f'{var} 环境变量', 'warn',
                        f'{var}={actual} (预期: {expected})'
                    ))
            else:
                checks.append(ComplianceCheck(
                    'system', f'{var} 环境变量', 'fail',
                    f'{var} 未设置 (建议: {expected})'
                ))
                
        return checks
        
    def check_mycli_compliance(self) -> List[ComplianceCheck]:
        """检查mycli XDG合规性"""
        checks = []
        
        if not self.check_tool_installed('mycli'):
            checks.append(ComplianceCheck(
                'mycli', '工具安装', 'skip', 'mycli 未安装'
            ))
            return checks
            
        # 检查配置文件位置
        xdg_config = self.xdg_config_home / 'mycli' / 'myclirc'
        old_config = Path.home() / '.myclirc'
        
        if xdg_config.exists():
            checks.append(ComplianceCheck(
                'mycli', '配置文件位置', 'pass',
                f'配置文件位于XDG路径: {xdg_config}'
            ))
        elif old_config.exists():
            if old_config.is_symlink() and old_config.readlink() == xdg_config:
                checks.append(ComplianceCheck(
                    'mycli', '配置文件位置', 'pass',
                    f'通过符号链接使用XDG路径: {old_config} -> {xdg_config}'
                ))
            else:
                checks.append(ComplianceCheck(
                    'mycli', '配置文件位置', 'fail',
                    f'配置文件仍在旧位置: {old_config}'
                ))
        else:
            checks.append(ComplianceCheck(
                'mycli', '配置文件位置', 'warn',
                '未找到配置文件'
            ))
            
        # 检查环境变量
        histfile = os.environ.get('MYCLI_HISTFILE')
        expected_histfile = str(self.xdg_state_home / 'mycli' / 'history')
        
        if histfile == expected_histfile:
            checks.append(ComplianceCheck(
                'mycli', '历史文件环境变量', 'pass',
                f'MYCLI_HISTFILE={histfile}'
            ))
        else:
            checks.append(ComplianceCheck(
                'mycli', '历史文件环境变量', 'fail',
                f'MYCLI_HISTFILE 未正确设置 (当前: {histfile}, 期望: {expected_histfile})'
            ))
            
        return checks
        
    def check_pgcli_compliance(self) -> List[ComplianceCheck]:
        """检查pgcli XDG合规性"""
        checks = []
        
        if not self.check_tool_installed('pgcli'):
            checks.append(ComplianceCheck(
                'pgcli', '工具安装', 'skip', 'pgcli 未安装'
            ))
            return checks
            
        # pgcli 原生支持XDG，检查配置目录
        xdg_config_dir = self.xdg_config_home / 'pgcli'
        
        if xdg_config_dir.exists():
            checks.append(ComplianceCheck(
                'pgcli', '配置目录', 'pass',
                f'配置目录位于XDG路径: {xdg_config_dir}'
            ))
        else:
            checks.append(ComplianceCheck(
                'pgcli', '配置目录', 'warn',
                f'XDG配置目录不存在: {xdg_config_dir}'
            ))
            
        # 检查环境变量
        pgclirc = os.environ.get('PGCLIRC')
        expected_pgclirc = str(self.xdg_config_home / 'pgcli' / 'config')
        
        if pgclirc == expected_pgclirc:
            checks.append(ComplianceCheck(
                'pgcli', '配置文件环境变量', 'pass',
                f'PGCLIRC={pgclirc}'
            ))
        else:
            checks.append(ComplianceCheck(
                'pgcli', '配置文件环境变量', 'warn',
                f'PGCLIRC 未设置或不正确 (当前: {pgclirc}, 建议: {expected_pgclirc})'
            ))
            
        return checks
        
    def check_docker_compliance(self) -> List[ComplianceCheck]:
        """检查docker XDG合规性"""
        checks = []
        
        if not self.check_tool_installed('docker'):
            checks.append(ComplianceCheck(
                'docker', '工具安装', 'skip', 'docker 未安装'
            ))
            return checks
            
        # 检查DOCKER_CONFIG环境变量
        docker_config = os.environ.get('DOCKER_CONFIG')
        expected_docker_config = str(self.xdg_config_home / 'docker')
        
        if docker_config == expected_docker_config:
            checks.append(ComplianceCheck(
                'docker', 'DOCKER_CONFIG环境变量', 'pass',
                f'DOCKER_CONFIG={docker_config}'
            ))
        else:
            checks.append(ComplianceCheck(
                'docker', 'DOCKER_CONFIG环境变量', 'fail',
                f'DOCKER_CONFIG 未正确设置 (当前: {docker_config}, 期望: {expected_docker_config})'
            ))
            
        # 检查配置目录
        xdg_config_dir = Path(expected_docker_config)
        old_config_dir = Path.home() / '.docker'
        
        if xdg_config_dir.exists():
            checks.append(ComplianceCheck(
                'docker', '配置目录位置', 'pass',
                f'配置目录位于XDG路径: {xdg_config_dir}'
            ))
        elif old_config_dir.exists():
            if old_config_dir.is_symlink() and old_config_dir.readlink() == xdg_config_dir:
                checks.append(ComplianceCheck(
                    'docker', '配置目录位置', 'pass',
                    f'通过符号链接使用XDG路径: {old_config_dir} -> {xdg_config_dir}'
                ))
            else:
                checks.append(ComplianceCheck(
                    'docker', '配置目录位置', 'fail',
                    f'配置目录仍在旧位置: {old_config_dir}'
                ))
        else:
            checks.append(ComplianceCheck(
                'docker', '配置目录位置', 'warn',
                '未找到配置目录'
            ))
            
        return checks
        
    def check_k9s_compliance(self) -> List[ComplianceCheck]:
        """检查k9s XDG合规性"""
        checks = []
        
        if not self.check_tool_installed('k9s'):
            checks.append(ComplianceCheck(
                'k9s', '工具安装', 'skip', 'k9s 未安装'
            ))
            return checks
            
        # k9s 原生支持XDG，检查环境变量
        k9s_config = os.environ.get('K9SCONFIG')
        expected_k9s_config = str(self.xdg_config_home / 'k9s')
        
        if k9s_config == expected_k9s_config:
            checks.append(ComplianceCheck(
                'k9s', 'K9SCONFIG环境变量', 'pass',
                f'K9SCONFIG={k9s_config}'
            ))
        else:
            checks.append(ComplianceCheck(
                'k9s', 'K9SCONFIG环境变量', 'warn',
                f'K9SCONFIG 未设置或不正确 (当前: {k9s_config}, 建议: {expected_k9s_config})'
            ))
            
        # 检查配置目录
        xdg_config_dir = Path(expected_k9s_config)
        
        if xdg_config_dir.exists():
            checks.append(ComplianceCheck(
                'k9s', '配置目录', 'pass',
                f'配置目录位于XDG路径: {xdg_config_dir}'
            ))
        else:
            checks.append(ComplianceCheck(
                'k9s', '配置目录', 'warn',
                f'XDG配置目录不存在: {xdg_config_dir}'
            ))
            
        return checks
        
    def run_all_checks(self) -> bool:
        """运行所有合规性检查"""
        log_header("XDG Base Directory 规范合规性验证")
        
        log_info(f"XDG_CONFIG_HOME: {self.xdg_config_home}")
        log_info(f"XDG_DATA_HOME:   {self.xdg_data_home}")
        log_info(f"XDG_STATE_HOME:  {self.xdg_state_home}")
        log_info(f"XDG_CACHE_HOME:  {self.xdg_cache_home}")
        
        # 运行各项检查
        self.checks.extend(self.check_environment_variables())
        self.checks.extend(self.check_mycli_compliance())
        self.checks.extend(self.check_pgcli_compliance())
        self.checks.extend(self.check_docker_compliance())
        self.checks.extend(self.check_k9s_compliance())
        
        # 按工具分组显示结果
        tools = set(check.tool for check in self.checks)
        
        for tool in sorted(tools):
            tool_checks = [c for c in self.checks if c.tool == tool]
            log_header(f"{tool.upper()} 合规性检查")
            
            for check in tool_checks:
                if check.status == 'pass':
                    log_success(f"{check.check_name}: {check.message}")
                elif check.status == 'warn':
                    log_warning(f"{check.check_name}: {check.message}")
                elif check.status == 'fail':
                    log_error(f"{check.check_name}: {check.message}")
                else:  # skip
                    log_info(f"{check.check_name}: {check.message}")
                    
        # 生成摘要报告
        self.generate_summary_report()
        
        # 返回是否有严重问题
        has_failures = any(check.status == 'fail' for check in self.checks)
        return not has_failures
        
    def generate_summary_report(self):
        """生成摘要报告"""
        log_header("合规性检查摘要")
        
        pass_count = sum(1 for c in self.checks if c.status == 'pass')
        warn_count = sum(1 for c in self.checks if c.status == 'warn')
        fail_count = sum(1 for c in self.checks if c.status == 'fail')
        skip_count = sum(1 for c in self.checks if c.status == 'skip')
        
        print(f"✅ 通过: {pass_count}")
        print(f"⚠️  警告: {warn_count}")
        print(f"❌ 失败: {fail_count}")
        print(f"⏭️  跳过: {skip_count}")
        
        if fail_count > 0:
            print(f"\n❌ 发现 {fail_count} 个合规性问题，建议运行迁移脚本:")
            print("   python scripts/migrate_to_xdg.py")
        elif warn_count > 0:
            print(f"\n⚠️  发现 {warn_count} 个警告，可以考虑优化配置")
        else:
            print(f"\n🎉 所有检查通过！您的工具完全符合XDG Base Directory规范")
            
    def export_report(self, output_file: str):
        """导出详细报告"""
        report_data = {
            'xdg_paths': {
                'config': str(self.xdg_config_home),
                'data': str(self.xdg_data_home),
                'state': str(self.xdg_state_home),
                'cache': str(self.xdg_cache_home)
            },
            'checks': [
                {
                    'tool': check.tool,
                    'check_name': check.check_name,
                    'status': check.status,
                    'message': check.message,
                    'details': check.details
                }
                for check in self.checks
            ],
            'summary': {
                'total': len(self.checks),
                'pass': sum(1 for c in self.checks if c.status == 'pass'),
                'warn': sum(1 for c in self.checks if c.status == 'warn'),
                'fail': sum(1 for c in self.checks if c.status == 'fail'),
                'skip': sum(1 for c in self.checks if c.status == 'skip')
            }
        }
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
            
        log_info(f"详细报告已导出到: {output_file}")

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='XDG Base Directory 规范合规性验证工具')
    parser.add_argument('--export', metavar='FILE',
                       help='导出详细报告到JSON文件')
    parser.add_argument('--tools', nargs='+',
                       choices=['mycli', 'pgcli', 'docker', 'k9s'],
                       help='只检查指定的工具')
    
    args = parser.parse_args()
    
    try:
        verifier = XDGComplianceVerifier()
        success = verifier.run_all_checks()
        
        if args.export:
            verifier.export_report(args.export)
            
        sys.exit(0 if success else 1)
        
    except KeyboardInterrupt:
        log_warning("\n验证被用户中断")
        sys.exit(1)
    except Exception as e:
        log_error(f"验证过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()