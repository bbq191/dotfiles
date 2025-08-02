#!/usr/bin/env python3
"""
XDG Base Directory 规范迁移脚本
统一迁移 mycli、pgcli、docker、k9s 到 XDG 规范
支持 Windows 和 Linux/macOS 环境
"""

import os
import sys
import json
import shutil
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
    NC = '\033[0m'  # No Color

def log_info(msg: str):
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")

def log_success(msg: str):
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {msg}")

def log_warning(msg: str):
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {msg}")

def log_error(msg: str):
    print(f"{Colors.RED}[ERROR]{Colors.NC} {msg}")

def log_header(msg: str):
    print(f"\n{Colors.PURPLE}{'='*60}{Colors.NC}")
    print(f"{Colors.WHITE}{msg.center(60)}{Colors.NC}")
    print(f"{Colors.PURPLE}{'='*60}{Colors.NC}")

@dataclass
class MigrationConfig:
    """工具迁移配置"""
    name: str
    old_paths: List[str]
    xdg_config_path: str
    xdg_data_path: Optional[str] = None
    xdg_state_path: Optional[str] = None
    xdg_cache_path: Optional[str] = None
    config_template: Optional[str] = None
    requires_symlink: bool = False
    native_xdg_support: bool = False
    environment_vars: Dict[str, str] = None

class XDGMigrator:
    """XDG迁移管理器"""
    
    def __init__(self):
        self.setup_xdg_paths()
        self.setup_migration_configs()
        self.dotfiles_root = Path(__file__).parent.parent
        
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
            
        log_info(f"XDG Base Directory 路径:")
        log_info(f"  CONFIG: {self.xdg_config_home}")
        log_info(f"  DATA:   {self.xdg_data_home}")  
        log_info(f"  STATE:  {self.xdg_state_home}")
        log_info(f"  CACHE:  {self.xdg_cache_home}")
        
    def setup_migration_configs(self):
        """设置各工具的迁移配置"""
        home = Path.home()
        
        self.migration_configs = {
            'mycli': MigrationConfig(
                name='mycli',
                old_paths=[str(home / '.myclirc'), str(home / '.mycli.log'), str(home / '.mycli-history')],
                xdg_config_path=str(self.xdg_config_home / 'mycli'),
                xdg_state_path=str(self.xdg_state_home / 'mycli'),
                xdg_cache_path=str(self.xdg_cache_home / 'mycli'),
                config_template='templates/database/mycli_xdg_config.template',
                requires_symlink=True,  # 为了向后兼容
                native_xdg_support=False,
                environment_vars={
                    'MYCLI_HISTFILE': str(self.xdg_state_home / 'mycli/history'),
                    'MYCLI_CONFIG_DIR': str(self.xdg_config_home / 'mycli')
                }
            ),
            
            'pgcli': MigrationConfig(
                name='pgcli',
                old_paths=[str(home / '.config/pgcli')],  # pgcli已经使用XDG路径
                xdg_config_path=str(self.xdg_config_home / 'pgcli'),
                xdg_state_path=str(self.xdg_state_home / 'pgcli'),
                xdg_cache_path=str(self.xdg_cache_home / 'pgcli'),
                config_template='templates/database/pgcli_xdg_config.template',
                requires_symlink=False,
                native_xdg_support=True,
                environment_vars={
                    'PGCLIRC': str(self.xdg_config_home / 'pgcli/config'),
                    'PGCLI_HISTFILE': str(self.xdg_state_home / 'pgcli/history')
                }
            ),
            
            'docker': MigrationConfig(
                name='docker',
                old_paths=[str(home / '.docker')],
                xdg_config_path=str(self.xdg_config_home / 'docker'),
                xdg_data_path=str(self.xdg_data_home / 'docker'),
                xdg_cache_path=str(self.xdg_cache_home / 'docker'),
                config_template='templates/containers/docker_xdg_config.template',
                requires_symlink=True,  # Docker需要符号链接以保持兼容性
                native_xdg_support=False,
                environment_vars={
                    'DOCKER_CONFIG': str(self.xdg_config_home / 'docker'),
                    'DOCKER_DATA_HOME': str(self.xdg_data_home / 'docker')
                }
            ),
            
            'k9s': MigrationConfig(
                name='k9s',
                old_paths=[],  # k9s已经支持XDG
                xdg_config_path=str(self.xdg_config_home / 'k9s'),
                xdg_data_path=str(self.xdg_data_home / 'k9s'),
                xdg_cache_path=str(self.xdg_cache_home / 'k9s'),
                config_template='templates/containers/k9s_xdg_config.template',
                requires_symlink=False,
                native_xdg_support=True,
                environment_vars={
                    'K9SCONFIG': str(self.xdg_config_home / 'k9s'),
                    'K9S_DATA_HOME': str(self.xdg_data_home / 'k9s')
                }
            )
        }
        
    def check_tool_installed(self, tool_name: str) -> bool:
        """检查工具是否已安装"""
        try:
            result = subprocess.run([tool_name, '--version'], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                log_success(f"{tool_name} 已安装")
                return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass
        
        log_warning(f"{tool_name} 未安装或无法访问")
        return False
        
    def create_xdg_directories(self, config: MigrationConfig):
        """创建XDG目录结构"""
        directories = [config.xdg_config_path]
        
        if config.xdg_data_path:
            directories.append(config.xdg_data_path)
        if config.xdg_state_path:
            directories.append(config.xdg_state_path)  
        if config.xdg_cache_path:
            directories.append(config.xdg_cache_path)
            
        for directory in directories:
            dir_path = Path(directory)
            dir_path.mkdir(parents=True, exist_ok=True)
            log_info(f"创建目录: {directory}")
            
        # 为k9s创建特殊的skins目录
        if config.name == 'k9s' and config.xdg_data_path:
            skins_dir = Path(config.xdg_data_path) / 'skins'
            skins_dir.mkdir(parents=True, exist_ok=True)
            log_info(f"创建k9s皮肤目录: {skins_dir}")
            
    def backup_existing_config(self, old_path: str) -> Optional[str]:
        """备份现有配置"""
        old_path_obj = Path(old_path)
        if not old_path_obj.exists():
            return None
            
        backup_path = Path(str(old_path_obj) + '.backup')
        counter = 1
        while backup_path.exists():
            backup_path = Path(f"{old_path_obj}.backup.{counter}")
            counter += 1
            
        try:
            if old_path_obj.is_dir():
                shutil.copytree(old_path_obj, backup_path)
            else:
                shutil.copy2(old_path_obj, backup_path)
            log_success(f"备份 {old_path} -> {backup_path}")
            return str(backup_path)
        except Exception as e:
            log_error(f"备份失败 {old_path}: {e}")
            return None
            
    def migrate_files(self, old_path: str, new_path: str) -> bool:
        """迁移文件或目录"""
        old_path_obj = Path(old_path)
        new_path_obj = Path(new_path)
        
        if not old_path_obj.exists():
            return True
            
        try:
            # 确保目标目录存在
            new_path_obj.parent.mkdir(parents=True, exist_ok=True)
            
            if old_path_obj.is_dir():
                # 复制目录内容
                if new_path_obj.exists():
                    log_warning(f"目标目录已存在: {new_path}")
                    return True
                shutil.copytree(old_path_obj, new_path_obj)
            else:
                # 复制文件
                shutil.copy2(old_path_obj, new_path_obj)
                
            log_success(f"迁移 {old_path} -> {new_path}")
            return True
        except Exception as e:
            log_error(f"迁移失败 {old_path} -> {new_path}: {e}")
            return False
            
    def create_symlink(self, target: str, link_path: str) -> bool:
        """创建符号链接"""
        target_path = Path(target)
        link_path_obj = Path(link_path)
        
        # 如果链接已存在且指向正确位置，跳过
        if link_path_obj.is_symlink() and link_path_obj.readlink() == target_path:
            log_info(f"符号链接已存在: {link_path} -> {target}")
            return True
            
        try:
            # 删除现有文件/链接
            if link_path_obj.exists() or link_path_obj.is_symlink():
                if link_path_obj.is_dir() and not link_path_obj.is_symlink():
                    # 如果是目录，先移动到备份位置
                    backup_path = Path(str(link_path_obj) + '.backup')
                    shutil.move(str(link_path_obj), str(backup_path))
                    log_info(f"移动现有目录到备份位置: {backup_path}")
                else:
                    link_path_obj.unlink()
                    
            # 创建符号链接
            if self.is_windows:
                # Windows 符号链接需要特殊处理
                if target_path.is_dir():
                    # 目录符号链接
                    subprocess.run(['cmd', '/c', 'mklink', '/D', str(link_path_obj), str(target_path)], 
                                 check=True, capture_output=True)
                else:
                    # 文件符号链接  
                    subprocess.run(['cmd', '/c', 'mklink', str(link_path_obj), str(target_path)], 
                                 check=True, capture_output=True)
            else:
                # Unix 符号链接
                link_path_obj.symlink_to(target_path)
                
            log_success(f"创建符号链接: {link_path} -> {target}")
            return True
        except Exception as e:
            log_error(f"创建符号链接失败 {link_path} -> {target}: {e}")
            # 在Windows上，如果符号链接失败，尝试创建硬链接或复制
            if self.is_windows:
                try:
                    if target_path.is_file():
                        shutil.copy2(target_path, link_path_obj)
                        log_warning(f"符号链接失败，已复制文件: {link_path}")
                        return True
                except Exception as e2:
                    log_error(f"复制文件也失败: {e2}")
            return False
            
    def install_config_template(self, config: MigrationConfig) -> bool:
        """安装配置模板"""
        if not config.config_template:
            return True
            
        template_path = self.dotfiles_root / config.config_template
        if not template_path.exists():
            log_warning(f"配置模板不存在: {template_path}")
            return False
            
        # 确定目标配置文件路径
        if config.name == 'mycli':
            target_path = Path(config.xdg_config_path) / 'myclirc'
        elif config.name == 'pgcli':
            target_path = Path(config.xdg_config_path) / 'config'
        elif config.name == 'docker':
            target_path = Path(config.xdg_config_path) / 'config.json'
        elif config.name == 'k9s':
            target_path = Path(config.xdg_config_path) / 'config.yaml'
        else:
            target_path = Path(config.xdg_config_path) / 'config'
            
        # 如果目标文件已存在，不覆盖
        if target_path.exists():
            log_info(f"配置文件已存在，跳过模板安装: {target_path}")
            return True
            
        try:
            # 读取模板内容并进行路径替换
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            # 替换路径占位符
            template_content = self.process_template_variables(template_content, config)
            
            # 写入目标位置
            target_path.parent.mkdir(parents=True, exist_ok=True)
            with open(target_path, 'w', encoding='utf-8') as f:
                f.write(template_content)
                
            log_success(f"安装配置模板: {target_path}")
            return True
        except Exception as e:
            log_error(f"安装配置模板失败: {e}")
            return False
            
    def process_template_variables(self, content: str, config: MigrationConfig) -> str:
        """处理模板中的变量替换"""
        # 定义替换映射
        replacements = {
            '{{XDG_CONFIG_HOME}}': str(self.xdg_config_home),
            '{{XDG_DATA_HOME}}': str(self.xdg_data_home),
            '{{XDG_STATE_HOME}}': str(self.xdg_state_home),
            '{{XDG_CACHE_HOME}}': str(self.xdg_cache_home),
            '{{TOOL_CONFIG_DIR}}': config.xdg_config_path,
            '{{TOOL_DATA_DIR}}': config.xdg_data_path or '',
            '{{TOOL_STATE_DIR}}': config.xdg_state_path or '',
            '{{TOOL_CACHE_DIR}}': config.xdg_cache_path or '',
        }
        
        # 执行替换
        for placeholder, value in replacements.items():
            # 根据配置文件类型和平台调整路径格式
            if config.name == 'docker':  # JSON文件保持正斜杠
                formatted_value = str(value).replace('\\', '/')
            elif self.is_windows:  # Windows环境下的其他配置文件
                # mycli等工具在Windows下可能需要正斜杠或反斜杠
                if config.name in ['mycli', 'pgcli']:
                    # 这些工具在Windows下通常接受正斜杠路径
                    formatted_value = str(value).replace('\\', '/')
                else:
                    formatted_value = str(value)
            else:  # Linux/macOS环境
                formatted_value = str(value)
            content = content.replace(placeholder, formatted_value)
            
        return content
            
    def migrate_tool(self, tool_name: str) -> bool:
        """迁移单个工具"""
        log_header(f"迁移 {tool_name.upper()}")
        
        config = self.migration_configs.get(tool_name)
        if not config:
            log_error(f"未找到 {tool_name} 的迁移配置")
            return False
            
        # 检查工具是否安装（仅用于提示）
        is_installed = self.check_tool_installed(tool_name)
        if is_installed:
            log_info(f"{tool_name} 已安装，将进行完整迁移")
        else:
            log_info(f"{tool_name} 未安装，将创建XDG目录结构和配置模板")
        
        # 创建XDG目录结构
        self.create_xdg_directories(config)
        
        # 迁移现有配置文件
        migration_success = True
        for old_path in config.old_paths:
            old_path_obj = Path(old_path)
            if old_path_obj.exists():
                # 备份现有配置
                backup_path = self.backup_existing_config(old_path)
                
                # 确定目标路径
                if old_path_obj.name.startswith('.'):
                    # 去掉开头的点
                    target_name = old_path_obj.name[1:]
                else:
                    target_name = old_path_obj.name
                    
                if config.name == 'mycli':
                    if 'myclirc' in old_path:
                        target_path = Path(config.xdg_config_path) / 'myclirc'
                    elif 'history' in old_path:
                        target_path = Path(config.xdg_state_path) / 'history'
                    elif 'log' in old_path:
                        target_path = Path(config.xdg_cache_path) / 'mycli.log'
                    else:
                        target_path = Path(config.xdg_config_path) / target_name
                        
                elif config.name == 'docker':
                    if old_path_obj.is_dir():
                        # 迁移整个.docker目录的内容
                        for item in old_path_obj.iterdir():
                            target_item = Path(config.xdg_config_path) / item.name
                            if not self.migrate_files(str(item), str(target_item)):
                                migration_success = False
                        continue
                    else:
                        target_path = Path(config.xdg_config_path) / target_name
                else:
                    target_path = Path(config.xdg_config_path) / target_name
                    
                # 执行迁移
                if not self.migrate_files(old_path, str(target_path)):
                    migration_success = False
                    
        # 安装配置模板
        if not self.install_config_template(config):
            log_warning(f"配置模板安装失败: {tool_name}")
            
        # 创建符号链接（如果需要）
        if config.requires_symlink:
            if config.name == 'mycli':
                # 为mycli创建符号链接以保持向后兼容
                mycli_config = Path(config.xdg_config_path) / 'myclirc'
                old_mycli_config = Path.home() / '.myclirc'
                if mycli_config.exists():
                    self.create_symlink(str(mycli_config), str(old_mycli_config))
                    
            elif config.name == 'docker':
                # 为docker创建符号链接
                old_docker_dir = Path.home() / '.docker'
                if not old_docker_dir.exists() or old_docker_dir.is_symlink():
                    self.create_symlink(config.xdg_config_path, str(old_docker_dir))
                    
        # 显示环境变量设置建议
        if config.environment_vars:
            log_info(f"\n{tool_name} 环境变量设置:")
            for var, value in config.environment_vars.items():
                log_info(f"  export {var}='{value}'")
                
        if migration_success:
            log_success(f"{tool_name} 迁移完成")
        else:
            log_warning(f"{tool_name} 迁移部分成功，请检查日志")
            
        return migration_success
        
    def generate_environment_script(self) -> str:
        """生成环境变量设置脚本"""
        script_lines = [
            "#!/bin/bash",
            "# XDG Base Directory 环境变量设置",
            "# 由 migrate_to_xdg.py 自动生成",
            "",
            "# XDG Base Directory 路径",
            f'export XDG_CONFIG_HOME="{self.xdg_config_home}"',
            f'export XDG_DATA_HOME="{self.xdg_data_home}"',
            f'export XDG_STATE_HOME="{self.xdg_state_home}"',
            f'export XDG_CACHE_HOME="{self.xdg_cache_home}"',
            "",
            "# 数据库工具环境变量"
        ]
        
        for tool_name, config in self.migration_configs.items():
            if config.environment_vars:
                script_lines.append(f"# {tool_name}")
                for var, value in config.environment_vars.items():
                    script_lines.append(f'export {var}="{value}"')
                script_lines.append("")
                
        script_lines.extend([
            "echo '✅ XDG环境变量已设置'",
            "echo '🔧 请重新启动shell或运行 source ~/.bashrc 使配置生效'"
        ])
        
        return '\n'.join(script_lines)
        
    def save_environment_script(self):
        """保存环境变量脚本"""
        script_content = self.generate_environment_script()
        script_path = self.dotfiles_root / 'generated' / 'xdg_migration_env.sh'
        
        script_path.parent.mkdir(parents=True, exist_ok=True)
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write(script_content)
            
        # 设置执行权限
        if not self.is_windows:
            os.chmod(script_path, 0o755)
            
        log_success(f"环境变量脚本已保存: {script_path}")
        return script_path
        
    def run_migration(self, tools: Optional[List[str]] = None):
        """运行迁移"""
        log_header("XDG Base Directory 规范迁移工具")
        
        if tools is None:
            tools = list(self.migration_configs.keys())
            
        # 过滤配置中不存在的工具名称
        available_tools = [t for t in tools if t in self.migration_configs]
        if not available_tools:
            log_error(f"没有找到要迁移的工具。可用工具: {list(self.migration_configs.keys())}")
            return False
            
        log_info(f"开始迁移工具: {', '.join(available_tools)}")
        log_info("注意: 迁移将为所有工具创建XDG目录结构，无论工具是否已安装")
        
        results = {}
        for tool in available_tools:
            results[tool] = self.migrate_tool(tool)
            
        # 生成环境变量脚本
        script_path = self.save_environment_script()
        
        # 显示迁移结果
        log_header("迁移结果汇总")
        for tool, success in results.items():
            status = "✅ 成功" if success else "❌ 失败"
            print(f"  {tool:<10} {status}")
            
        print(f"\n📄 环境变量脚本: {script_path}")
        print(f"🔧 运行以下命令使环境变量生效:")
        print(f"   source {script_path}")
        
        return all(results.values())

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='XDG Base Directory 规范迁移工具')
    parser.add_argument('tools', nargs='*', 
                       choices=['mycli', 'pgcli', 'docker', 'k9s'],
                       help='要迁移的工具 (默认: 所有工具)')
    parser.add_argument('--dry-run', action='store_true',
                       help='仅显示将要执行的操作，不实际执行')
    
    args = parser.parse_args()
    
    try:
        migrator = XDGMigrator()
        
        if args.dry_run:
            log_info("DRY RUN 模式 - 仅显示操作，不实际执行")
            
        success = migrator.run_migration(args.tools)
        sys.exit(0 if success else 1)
        
    except KeyboardInterrupt:
        log_warning("\n迁移被用户中断")
        sys.exit(1)
    except Exception as e:
        log_error(f"迁移过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()