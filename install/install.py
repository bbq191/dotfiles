#!/usr/bin/env python3
"""
Dotfiles 自动安装脚本
支持 Windows, macOS, Linux 平台
包含 XDG Base Directory 规范支持
"""

import sys
import json
import platform
import subprocess
import argparse
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# 导入XDG迁移器
sys.path.append(str(Path(__file__).parent.parent / 'scripts'))
try:
    from migrate_to_xdg import XDGMigrator
    XDG_AVAILABLE = True
except ImportError:
    print("⚠️  XDG迁移模块不可用")
    XDG_AVAILABLE = False

class DotfilesInstaller:
    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self.platform = self.detect_platform()
        self.packages_config = self.load_packages_config()
        self.installed_tools = []
        self.failed_tools = []
        
    def detect_platform(self) -> str:
        """检测操作系统平台"""
        system = platform.system().lower()
        if system == "windows":
            return "windows"
        elif system == "darwin":
            return "macos"
        elif system == "linux":
            return "linux"
        else:
            raise ValueError(f"Unsupported platform: {system}")
    
    def load_packages_config(self) -> Dict:
        """加载包配置文件"""
        config_file = self.config_dir / "packages" / f"{self.platform}.json"
        if not config_file.exists():
            raise FileNotFoundError(f"Config file not found: {config_file}")
        
        with open(config_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def check_package_manager(self, manager: str) -> bool:
        """检查包管理器是否可用"""
        try:
            if manager == "winget":
                result = subprocess.run(["winget", "--version"], 
                                      capture_output=True, check=True, text=True)
                return True
            elif manager == "scoop":
                result = subprocess.run(["scoop", "--version"], 
                                      capture_output=True, check=True, text=True)
                return True
            elif manager == "chocolatey" or manager == "choco":
                result = subprocess.run(["choco", "--version"], 
                                      capture_output=True, check=True, text=True)
                return True
            elif manager == "pipx":
                result = subprocess.run(["pipx", "--version"], 
                                      capture_output=True, check=True, text=True)
                return True
            elif manager == "brew":
                result = subprocess.run(["brew", "--version"], 
                                      capture_output=True, check=True, text=True)
                return True
            return False
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def is_tool_installed(self, tool_name: str) -> bool:
        """检查工具是否已安装"""
        return shutil.which(tool_name) is not None
    
    def install_package(self, package_name: str, package_info: Dict, force: bool = False) -> bool:
        """安装单个包"""
        # 检查是否已安装
        if not force and self.is_tool_installed(package_name):
            print(f"✅ {package_name} 已安装，跳过")
            self.installed_tools.append(package_name)
            return True
            
        managers = self.packages_config["package_managers"]
        
        # 按优先级尝试不同的包管理器
        for manager_name in sorted(managers.keys(), key=lambda x: managers[x]["priority"]):
            if not self.check_package_manager(manager_name):
                continue
                
            if manager_name not in package_info:
                continue
            
            package_id = package_info[manager_name]
            install_cmd = managers[manager_name]["command"]
            
            try:
                if manager_name == "winget":
                    cmd = ["winget", "install", "--id", package_id, "--silent"]
                elif manager_name == "scoop":
                    cmd = ["scoop", "install", package_id]
                elif manager_name == "chocolatey" or manager_name == "choco":
                    cmd = ["choco", "install", "-y", package_id]
                elif manager_name == "pipx":
                    cmd = ["pipx", "install", package_id]
                else:
                    cmd = f"{install_cmd} {package_id}".split()
                
                print(f"📦 正在通过 {manager_name} 安装 {package_name}...")
                
                result = subprocess.run(cmd, check=True, capture_output=True, text=True)
                print(f"✅ {package_name} 安装成功")
                
                # 执行安装后操作
                if "post_install" in package_info:
                    print(f"📝 {package_name} 安装后配置:")
                    for step in package_info["post_install"]:
                        print(f"   • {step}")
                
                self.installed_tools.append(package_name)
                return True
                
            except subprocess.CalledProcessError as e:
                print(f"❌ 通过 {manager_name} 安装 {package_name} 失败: {e}")
                if e.stderr:
                    print(f"   错误详情: {e.stderr.strip()}")
                continue
        
        print(f"❌ 无法安装 {package_name}，所有包管理器都失败")
        self.failed_tools.append(package_name)
        return False
    
    def install_category(self, category_name: str, category_info: Dict, 
                        interactive: bool = True, force: bool = False) -> Tuple[List[str], List[str]]:
        """安装一个类别的所有包"""
        installed = []
        failed = []
        
        print(f"\n📦 安装 {category_name} 工具...")
        print(f"📋 {category_info['description']}")
        print(f"🎯 优先级: {category_info['priority']}")
        
        for package_name, package_info in category_info["packages"].items():
            status = package_info.get("status", "optional")
            
            if interactive and status == "optional":
                response = input(f"安装 {package_name}? ({package_info['description']}) [y/N]: ")
                if response.lower() not in ['y', 'yes']:
                    continue
            elif interactive and status == "missing":
                response = input(f"安装缺失的 {package_name}? ({package_info['description']}) [Y/n]: ")
                if response.lower() in ['n', 'no']:
                    continue
            elif status == "installed" and not force:
                print(f"✅ {package_name} 已安装且已验证")
                installed.append(package_name) 
                continue
            
            if self.install_package(package_name, package_info, force):
                installed.append(package_name)
            else:
                failed.append(package_name)
        
        return installed, failed
    
    def configure_git_delta(self):
        """配置 Git Delta"""
        if not self.is_tool_installed("delta"):
            return
            
        print("🔧 配置 Git Delta...")
        git_configs = {
            "core.pager": "delta",
            "delta.navigate": "true", 
            "delta.side-by-side": "true",
            "delta.line-numbers": "true",
            "merge.conflictstyle": "diff3",
            "diff.colorMoved": "default"
        }
        
        for key, value in git_configs.items():
            try:
                subprocess.run(["git", "config", "--global", key, value], check=True)
                print(f"   ✅ {key} = {value}")
            except subprocess.CalledProcessError:
                print(f"   ❌ 设置 {key} 失败")
    
    def setup_xdg_compliance(self, tools: Optional[List[str]] = None) -> bool:
        """设置XDG Base Directory规范合规性"""
        if not XDG_AVAILABLE:
            print("❌ XDG迁移模块不可用，跳过XDG设置")
            return False
            
        print("\n🏗️  设置 XDG Base Directory 规范合规性...")
        
        try:
            migrator = XDGMigrator()
            
            # 如果没有指定工具，使用默认列表
            if tools is None:
                tools = ['mycli', 'pgcli', 'docker', 'k9s']
            
            # 过滤只处理已安装的工具
            installed_tools = []
            for tool in tools:
                if self.is_tool_installed(tool):
                    installed_tools.append(tool)
                else:
                    print(f"⏭️  跳过未安装的工具: {tool}")
            
            if not installed_tools:
                print("ℹ️  没有找到要迁移的工具")
                return True
                
            print(f"🔧 开始为以下工具设置XDG规范: {', '.join(installed_tools)}")
            
            # 执行迁移
            success = migrator.run_migration(installed_tools)
            
            if success:
                print("✅ XDG Base Directory 规范设置完成")
                print("📝 请重新启动shell或运行 source ~/.bashrc 使环境变量生效")
            else:
                print("⚠️  XDG设置过程中遇到一些问题")
                
            return success
            
        except Exception as e:
            print(f"❌ XDG设置失败: {e}")
            return False
    
    def run_health_check(self) -> bool:
        """运行健康检查"""
        print("\n🔍 运行健康检查...")
        
        health_config = self.packages_config.get("health_checks", {})
        required_tools = health_config.get("required_tools", [])
        optional_tools = health_config.get("optional_tools", [])
        
        working_tools = []
        missing_required = []
        missing_optional = []
        
        # 检查必需工具
        for tool in required_tools:
            if self.is_tool_installed(tool):
                working_tools.append(tool)
                print(f"✅ {tool} (必需)")
            else:
                missing_required.append(tool)
                print(f"❌ {tool} (必需，缺失)")
        
        # 检查可选工具
        for tool in optional_tools:
            if self.is_tool_installed(tool):
                working_tools.append(tool)
                print(f"✅ {tool} (可选)")
            else:
                missing_optional.append(tool)
                print(f"⚠️  {tool} (可选，缺失)")
        
        # 检查 Git 配置
        if "git_config_checks" in health_config:
            print("\n🔧 检查 Git 配置:")
            for check in health_config["git_config_checks"]:
                print(f"   📝 {check}")
        
        print(f"\n📊 健康检查总结:")
        print(f"   ✅ 正常工具: {len(working_tools)}")
        print(f"   ❌ 缺失必需工具: {len(missing_required)}")  
        print(f"   ⚠️  缺失可选工具: {len(missing_optional)}")
        
        if missing_required:
            print(f"   🚨 缺失的必需工具: {', '.join(missing_required)}")
        
        return len(missing_required) == 0
    
    def install_all(self, interactive: bool = True, categories: List[str] = None, 
                   force: bool = False):
        """安装所有或指定类别的工具"""
        print(f"🚀 开始为 {self.platform} 平台安装 dotfiles 工具")
        print(f"📦 配置版本: {self.packages_config.get('version', 'unknown')}")
        print(f"📝 {self.packages_config.get('description', '')}")
        
        all_installed = []
        all_failed = []
        
        # 选择要安装的类别
        categories_to_install = self.packages_config["categories"]
        if categories:
            categories_to_install = {k: v for k, v in categories_to_install.items() 
                                   if k in categories}
        
        # 按安装顺序处理
        install_order = self.packages_config.get("install_order", categories_to_install.keys())
        
        for category_name in install_order:
            if category_name not in categories_to_install:
                continue
                
            category_info = categories_to_install[category_name]
            installed, failed = self.install_category(category_name, category_info, interactive, force)
            all_installed.extend(installed)
            all_failed.extend(failed)
        
        # 配置工具
        print("\n🔧 配置已安装的工具...")
        self.configure_git_delta()
        
        # 安装完成总结
        print(f"\n🎉 安装完成!")
        print(f"   ✅ 成功安装: {len(all_installed)} 个工具")
        print(f"   ❌ 安装失败: {len(all_failed)} 个工具")
        
        if all_installed:
            print(f"   成功安装的工具: {', '.join(all_installed)}")
        
        if all_failed:
            print(f"   安装失败的工具: {', '.join(all_failed)}")
        
        # 运行健康检查
        health_ok = self.run_health_check()
        
        if health_ok:
            print("\n🎯 所有必需工具都已正确安装！")
        else:
            print("\n⚠️  存在缺失的必需工具，请检查安装状态")
        
        return health_ok

def main():
    parser = argparse.ArgumentParser(description="Dotfiles 自动安装脚本", 
                                   formatter_class=argparse.RawDescriptionHelpFormatter,
                                   epilog="""
示例用法:
  python install.py                          # 交互式安装所有工具
  python install.py --non-interactive        # 非交互式安装（跳过可选工具）
  python install.py --categories modern_tools development  # 只安装指定类别
  python install.py --health-check           # 只运行健康检查
  python install.py --force                  # 强制重新安装已有工具
""")
    
    parser.add_argument("--non-interactive", action="store_true",
                       help="非交互模式运行")
    parser.add_argument("--categories", nargs="+",
                       help="安装指定类别的工具")
    parser.add_argument("--health-check", action="store_true",
                       help="只运行健康检查")
    parser.add_argument("--force", action="store_true",
                       help="强制重新安装已有工具")
    parser.add_argument("--list-categories", action="store_true",
                       help="列出所有可用的工具类别")
    parser.add_argument("--setup-xdg", action="store_true",
                       help="设置XDG Base Directory规范合规性")
    parser.add_argument("--xdg-tools", nargs="+",
                       choices=['mycli', 'pgcli', 'docker', 'k9s'],
                       help="指定要设置XDG规范的工具")
    parser.add_argument("--skip-xdg", action="store_true",
                       help="跳过XDG Base Directory规范设置")
    
    args = parser.parse_args()
    
    # 获取配置目录
    config_dir = Path(__file__).parent
    
    try:
        installer = DotfilesInstaller(config_dir)
        
        if args.list_categories:
            print("📋 可用的工具类别:")
            for category, info in installer.packages_config["categories"].items():
                print(f"  • {category}: {info['description']} (优先级: {info['priority']})")
            return
        
        if args.health_check:
            success = installer.run_health_check()
            sys.exit(0 if success else 1)
            
        elif args.setup_xdg:
            # 仅运行XDG设置
            success = installer.setup_xdg_compliance(args.xdg_tools)
            sys.exit(0 if success else 1)
            
        else:
            # 正常安装流程
            success = installer.install_all(
                interactive=not args.non_interactive,
                categories=args.categories,
                force=args.force
            )
            
            if success:
                print("\n🎊 恭喜！所有工具安装完成！")
                
                # 根据参数决定是否设置XDG规范
                if not args.skip_xdg and XDG_AVAILABLE:
                    print("\n🔧 正在设置 XDG Base Directory 规范...")
                    xdg_success = installer.setup_xdg_compliance(args.xdg_tools)
                    if xdg_success:
                        print("✅ XDG规范设置完成")
                    else:
                        print("⚠️  XDG规范设置遇到一些问题")
                elif args.skip_xdg:
                    print("⏭️  跳过XDG Base Directory规范设置")
                    
                print("\n🚀 您的开发环境已准备就绪！")
            else:
                print("\n⚠️  安装过程中遇到一些问题，请检查上述错误信息")
                sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n\n⏹️  用户取消安装")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 安装失败: {e}")
        if "--debug" in sys.argv:
            import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()