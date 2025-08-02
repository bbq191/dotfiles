#!/usr/bin/env python3
"""
工具健康检查脚本
检查必需工具是否正确安装和配置
"""

import subprocess
import json
import shutil
import os
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import sys

class ToolsHealthCheck:
    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self.results = {"passed": [], "failed": [], "warnings": []}
        self.detailed_results = {}
        
    def check_command(self, command: str, args: List[str] = ["--version"], 
                     timeout: int = 10) -> Tuple[bool, str]:
        """检查命令是否可用并获取版本信息"""
        try:
            result = subprocess.run([command] + args, 
                                  capture_output=True, text=True, timeout=timeout)
            if result.returncode == 0:
                # 清理输出，只保留第一行版本信息
                output = result.stdout.strip().split('\n')[0]
                return True, output
            else:
                return False, result.stderr.strip() or "命令执行失败"
        except subprocess.TimeoutExpired:
            return False, "命令执行超时"
        except FileNotFoundError:
            return False, "命令未找到"
        except Exception as e:
            return False, str(e)
    
    def check_git_config(self) -> List[Tuple[str, bool, str]]:
        """检查 Git 配置"""
        git_checks = []
        
        configs_to_check = {
            "core.pager": {"expected": "delta", "description": "Git diff 分页器"},
            "delta.navigate": {"expected": "true", "description": "Delta 导航支持"},
            "delta.side-by-side": {"expected": "true", "description": "Delta 并排显示"},
            "user.name": {"required": True, "description": "Git 用户名"},
            "user.email": {"required": True, "description": "Git 邮箱"}
        }
        
        for config_key, config_info in configs_to_check.items():
            try:
                result = subprocess.run(["git", "config", "--global", config_key],
                                      capture_output=True, text=True, timeout=5)
                
                if result.returncode == 0:
                    current_value = result.stdout.strip()
                    
                    if "expected" in config_info:
                        if config_info["expected"] in current_value:
                            git_checks.append((config_key, True, f"✅ {current_value}"))
                        else:
                            git_checks.append((config_key, False, 
                                             f"❌ 期望: {config_info['expected']}, 实际: {current_value}"))
                    elif "required" in config_info and config_info["required"]:
                        if current_value:
                            git_checks.append((config_key, True, f"✅ {current_value}"))
                        else:
                            git_checks.append((config_key, False, "❌ 未设置"))
                    else:
                        git_checks.append((config_key, True, f"✅ {current_value}"))
                else:
                    git_checks.append((config_key, False, "❌ 未设置"))
                    
            except Exception as e:
                git_checks.append((config_key, False, f"❌ 检查失败: {str(e)}"))
        
        return git_checks
    
    def check_version_managers(self) -> List[Tuple[str, bool, str]]:
        """检查版本管理器"""
        managers = [
            ("fnm", ["--version"], "Node.js 版本管理器"),
            ("pyenv", ["--version"], "Python 版本管理器"),
            ("jabba", ["--version"], "Java 版本管理器"),
            ("g", ["--version"], "Go 版本管理器"),
        ]
        
        results = []
        for manager, args, description in managers:
            success, output = self.check_command(manager, args)
            
            # 特殊处理自定义路径的版本管理器
            if not success:
                custom_paths = {
                    "pyenv": [
                        r"C:\Applications\DevEnvironment\pyenv\pyenv-win\bin\pyenv.bat",
                        r"C:\Applications\DevEnvironment\pyenv\pyenv-win\bin\pyenv"
                    ],
                    "jabba": [
                        r"C:\Applications\DevEnvironment\jabba\bin\jabba.exe"
                    ],
                    "g": [
                        r"C:\Applications\DevEnvironment\g\bin\g.exe",
                        r"C:\Applications\DevEnvironment\g\bin\g",
                        r"C:\Applications\DevEnvironment\g\g.exe",
                        r"C:\Applications\DevEnvironment\g\g"
                    ]
                }
                
                if manager in custom_paths:
                    for custom_path in custom_paths[manager]:
                        if os.path.exists(custom_path):
                            if custom_path.endswith('.bat'):
                                # 通过cmd运行bat文件
                                success, output = self.check_command('cmd', ['/c', custom_path] + args)
                            else:
                                success, output = self.check_command(custom_path, args)
                            if success:
                                break
            
            if success:
                results.append((manager, True, f"✅ {output} - {description}"))
            else:
                results.append((manager, False, f"❌ {output} - {description}"))
        
        return results
    
    def check_modern_tools(self) -> List[Tuple[str, bool, str]]:
        """检查现代化工具"""
        tools = [
            ("delta", ["--version"], "Git diff 增强工具"),
            ("lazygit", ["--version"], "Git TUI 界面"),
            ("zoxide", ["--version"], "智能目录跳转"),
            ("btop", ["--version"], "系统监控工具"),
            ("jq", ["--version"], "JSON 处理器"),
            ("yq", ["--version"], "YAML 处理器"),
            ("gh", ["--version"], "GitHub CLI"),
            ("dog", ["--version"], "DNS 查询工具"),
            ("mlr", ["--version"], "Miller 数据处理工具"),
        ]
        
        results = []
        for tool, args, description in tools:
            success, output = self.check_command(tool, args)
            
            # 特殊处理自定义路径的工具
            if not success:
                custom_paths = {
                    "gh": [r"C:\Applications\DevEnvironment\github-cli\gh.exe"],
                    "mlr": [r"C:\Applications\DevEnvironment\miller\miller-6.13.0-windows-amd64\mlr.exe"]
                }
                
                if tool in custom_paths:
                    for custom_path in custom_paths[tool]:
                        if os.path.exists(custom_path):
                            success, output = self.check_command(custom_path, args)
                            if success:
                                break
            
            if success:
                results.append((tool, True, f"✅ {output} - {description}"))
            else:
                results.append((tool, False, f"❌ {output} - {description}"))
        
        return results
    
    def check_package_managers(self) -> List[Tuple[str, bool, str]]:
        """检查包管理器"""
        managers = [
            ("winget", ["--version"], "Windows 包管理器"),
            ("scoop", ["--version"], "轻量级包管理器"),
            ("choco", ["--version"], "Chocolatey 包管理器"),
            ("pipx", ["--version"], "Python 工具管理器"),
        ]
        
        results = []
        for manager, args, description in managers:
            success, output = self.check_command(manager, args)
            if success:
                results.append((manager, True, f"✅ {output} - {description}"))
            else:
                results.append((manager, False, f"❌ {output} - {description}"))
        
        return results
    
    def check_shell_integration(self) -> List[Tuple[str, bool, str]]:
        """检查 Shell 集成"""
        checks = []
        
        # 检查环境变量
        import os
        
        env_vars = {
            "FNM_DIR": "fnm 数据目录",
            "PYENV_ROOT": "pyenv 根目录", 
            "ZOXIDE_DATA_DIR": "zoxide 数据目录"
        }
        
        for var, description in env_vars.items():
            value = os.environ.get(var)
            if value:
                checks.append((var, True, f"✅ {value} - {description}"))
            else:
                checks.append((var, False, f"❌ 未设置 - {description}"))
        
        return checks
    
    def check_file_permissions(self) -> List[Tuple[str, bool, str]]:
        """检查关键文件权限"""
        checks = []
        
        # 检查配置文件是否存在且可读
        config_files = [
            (Path.home() / ".gitconfig", "Git 全局配置"),
            (Path.home() / ".config" / "git" / "config", "Git 用户配置"),
        ]
        
        for file_path, description in config_files:
            if file_path.exists():
                if file_path.is_file() and os.access(file_path, os.R_OK):
                    checks.append((str(file_path), True, f"✅ 可读 - {description}"))
                else:
                    checks.append((str(file_path), False, f"❌ 权限问题 - {description}"))
            else:
                checks.append((str(file_path), False, f"⚠️  不存在 - {description}"))
        
        return checks
    
    def generate_summary_report(self) -> str:
        """生成总结报告"""
        total_passed = len(self.results["passed"])
        total_failed = len(self.results["failed"])
        total_warnings = len(self.results["warnings"])
        total_checked = total_passed + total_failed + total_warnings
        
        if total_checked == 0:
            return "❌ 没有进行任何检查"
        
        success_rate = (total_passed / total_checked) * 100
        
        report = f"""
📊 健康检查总结报告
{'=' * 50}
总检查项目: {total_checked}
✅ 通过: {total_passed} ({success_rate:.1f}%)
❌ 失败: {total_failed}
⚠️  警告: {total_warnings}

"""
        
        if success_rate >= 90:
            report += "🎉 优秀！您的开发环境配置得很好！"
        elif success_rate >= 70:
            report += "👍 良好！大部分工具都正常工作，建议修复失败的项目。"
        elif success_rate >= 50:
            report += "⚠️  一般。建议安装缺失的工具以获得更好的开发体验。"
        else:
            report += "❌ 需要改进。许多重要工具缺失或配置不正确。"
        
        return report
    
    def run_all_checks(self) -> Dict:
        """运行所有健康检查"""
        print("🔍 开始运行全面的健康检查...\n")
        
        # 检查包管理器
        print("📦 包管理器检查:")
        pm_results = self.check_package_managers()
        for name, success, output in pm_results:
            print(f"  {output}")
            if success:
                self.results["passed"].append(f"package_manager_{name}")
            else:
                self.results["failed"].append(f"package_manager_{name}")
        
        # 检查版本管理器
        print("\n🔄 版本管理器检查:")
        vm_results = self.check_version_managers()
        for name, success, output in vm_results:
            print(f"  {output}")
            if success:
                self.results["passed"].append(f"version_manager_{name}")
            else:
                self.results["failed"].append(f"version_manager_{name}")
        
        # 检查现代化工具
        print("\n🛠️  现代化工具检查:")
        tool_results = self.check_modern_tools()
        for name, success, output in tool_results:
            print(f"  {output}")
            if success:
                self.results["passed"].append(f"tool_{name}")
            else:
                self.results["failed"].append(f"tool_{name}")
        
        # 检查 Git 配置
        print("\n⚙️  Git 配置检查:")
        git_results = self.check_git_config()
        for name, success, output in git_results:
            print(f"  {name}: {output}")
            if success:
                self.results["passed"].append(f"git_config_{name}")
            else:
                self.results["warnings"].append(f"git_config_{name}")
        
        # 检查 Shell 集成
        print("\n🐚 Shell 集成检查:")
        shell_results = self.check_shell_integration()
        for name, success, output in shell_results:
            print(f"  {output}")
            if success:
                self.results["passed"].append(f"shell_{name}")
            else:
                self.results["warnings"].append(f"shell_{name}")
        
        # 检查文件权限
        print("\n📁 文件权限检查:")
        file_results = self.check_file_permissions()
        for name, success, output in file_results:
            print(f"  {output}")
            if success:
                self.results["passed"].append(f"file_{Path(name).name}")
            else:
                self.results["warnings"].append(f"file_{Path(name).name}")
        
        # 生成总结报告
        summary = self.generate_summary_report()
        print(summary)
        
        # 提供修复建议
        if self.results["failed"]:
            print("\n🔧 修复建议:")
            print("运行以下命令安装缺失的工具:")
            print("  python install/install.py --categories modern_tools development")
        
        if any("git_config" in item for item in self.results["warnings"]):
            print("\n⚙️  Git 配置建议:")
            print("运行以下命令配置 Git:")
            print("  git config --global core.pager delta")
            print("  git config --global delta.navigate true")
            print("  git config --global delta.side-by-side true")
        
        return self.results

def main():
    """主函数"""
    config_dir = Path(__file__).parent.parent
    
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        print("""
工具健康检查脚本

用法:
  python tools_check.py          # 运行完整的健康检查
  python tools_check.py --help   # 显示帮助信息

检查项目:
  - 包管理器可用性 (winget, scoop, choco, pipx)
  - 版本管理器 (fnm, pyenv, jabba)
  - 现代化工具 (delta, lazygit, zoxide, btop, jq, yq, gh)
  - Git 配置完整性
  - Shell 环境变量集成
  - 配置文件权限
""")
        return
    
    try:
        checker = ToolsHealthCheck(config_dir)
        results = checker.run_all_checks()
        
        # 返回适当的退出码
        if results["failed"]:
            print("\n❌ 检查发现严重问题，建议修复后重新运行检查")
            sys.exit(1)
        elif results["warnings"]:
            print("\n⚠️  检查发现一些警告，建议优化配置")
            sys.exit(2)
        else:
            print("\n✅ 所有检查都通过了！")
            sys.exit(0)
            
    except KeyboardInterrupt:
        print("\n\n⏹️  用户取消检查")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")
        if "--debug" in sys.argv:
            import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()