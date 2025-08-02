#!/usr/bin/env python3
"""
pipx XDG Base Directory 规范配置脚本
自动配置pipx以遵循XDG Base Directory规范
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, Optional

class PipxXDGConfigurator:
    """pipx XDG配置管理器"""
    
    def __init__(self):
        self.setup_xdg_paths()
        
    def setup_xdg_paths(self):
        """设置XDG路径"""
        # 获取XDG环境变量，提供合理默认值
        home = Path.home()
        
        # Windows 平台XDG路径映射
        if os.name == 'nt':
            self.xdg_data_home = Path(os.environ.get('XDG_DATA_HOME', home / 'AppData/Local'))
            self.xdg_config_home = Path(os.environ.get('XDG_CONFIG_HOME', home / 'AppData/Local'))
            self.xdg_cache_home = Path(os.environ.get('XDG_CACHE_HOME', home / 'AppData/Local/Temp'))
            self.xdg_state_home = Path(os.environ.get('XDG_STATE_HOME', home / 'AppData/Local/State'))
        else:
            # Linux/macOS 标准XDG路径
            self.xdg_data_home = Path(os.environ.get('XDG_DATA_HOME', home / '.local/share'))
            self.xdg_config_home = Path(os.environ.get('XDG_CONFIG_HOME', home / '.config'))
            self.xdg_cache_home = Path(os.environ.get('XDG_CACHE_HOME', home / '.cache'))
            self.xdg_state_home = Path(os.environ.get('XDG_STATE_HOME', home / '.local/state'))
        
    def get_pipx_xdg_config(self) -> Dict[str, str]:
        """获取pipx的XDG配置"""
        return {
            'PIPX_HOME': str(self.xdg_data_home / 'pipx'),
            'PIPX_BIN_DIR': str(self.xdg_data_home / 'pipx' / 'bin'),
            'PIPX_MAN_DIR': str(self.xdg_data_home / 'man'),
        }
    
    def check_pipx_installation(self) -> bool:
        """检查pipx是否已安装"""
        try:
            result = subprocess.run(['pipx', '--version'], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ pipx已安装: {result.stdout.strip()}")
                return True
            else:
                print("❌ pipx未安装或无法访问")
                return False
        except FileNotFoundError:
            print("❌ pipx未安装")
            return False
    
    def create_directories(self):
        """创建必要的XDG目录"""
        config = self.get_pipx_xdg_config()
        
        print("📁 创建pipx XDG目录结构...")
        for key, path in config.items():
            dir_path = Path(path)
            dir_path.mkdir(parents=True, exist_ok=True)
            print(f"   {key}: {path}")
    
    def get_current_pipx_config(self) -> Optional[Dict]:
        """获取当前pipx配置"""
        try:
            result = subprocess.run(['pipx', 'environment'], capture_output=True, text=True)
            if result.returncode == 0:
                return {'environment': result.stdout}
            else:
                print("⚠️  无法获取pipx环境配置")
                return None
        except Exception as e:
            print(f"⚠️  获取pipx配置时出错: {e}")
            return None
    
    def migrate_existing_pipx(self) -> bool:
        """迁移现有的pipx安装"""
        # 检查常见的pipx安装路径
        old_paths = [
            Path.home() / '.local' / 'pipx',  # 旧版本默认路径
        ]
        
        if os.name == 'nt':
            old_paths.extend([
                Path.home() / 'pipx',  # Windows默认路径
                Path.home() / 'AppData' / 'Local' / 'pipx',
            ])
        
        new_pipx_home = Path(self.get_pipx_xdg_config()['PIPX_HOME'])
        
        for old_path in old_paths:
            if old_path.exists() and old_path != new_pipx_home:
                print(f"🔄 发现现有pipx安装: {old_path}")
                response = input(f"是否将其迁移到XDG位置 {new_pipx_home}? (y/N): ")
                
                if response.lower() == 'y':
                    try:
                        import shutil
                        if new_pipx_home.exists():
                            print(f"⚠️  目标目录已存在: {new_pipx_home}")
                            backup_path = new_pipx_home.with_suffix('.backup')
                            shutil.move(str(new_pipx_home), str(backup_path))
                            print(f"📦 已备份到: {backup_path}")
                        
                        shutil.move(str(old_path), str(new_pipx_home))
                        print(f"✅ 成功迁移pipx安装从 {old_path} 到 {new_pipx_home}")
                        return True
                    except Exception as e:
                        print(f"❌ 迁移失败: {e}")
                        return False
        
        return True
    
    def generate_environment_script(self) -> str:
        """生成环境变量设置脚本"""
        config = self.get_pipx_xdg_config()
        
        script_content = """#!/bin/bash
# pipx XDG Base Directory 配置
# 由 setup_pipx_xdg.py 自动生成

"""
        
        for key, value in config.items():
            script_content += f'export {key}="{value}"\n'
        
        script_content += '\n# 确保目录存在\n'
        for key, value in config.items():
            script_content += f'mkdir -p "{value}"\n'
        
        script_content += '\necho "✅ pipx XDG环境变量已设置"\n'
        
        return script_content
    
    def save_environment_script(self, output_path: Optional[Path] = None):
        """保存环境变量脚本"""
        if output_path is None:
            output_path = Path(__file__).parent.parent / 'generated' / 'pipx_xdg_env.sh'
        
        script_content = self.generate_environment_script()
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(script_content)
        
        # 设置执行权限（Unix系统）
        if os.name != 'nt':
            os.chmod(output_path, 0o755)
        
        print(f"📄 环境变量脚本已保存到: {output_path}")
        return output_path
    
    def verify_configuration(self):
        """验证配置是否正确"""
        print("\n🔍 验证pipx XDG配置...")
        
        config = self.get_pipx_xdg_config()
        
        # 检查目录是否存在
        for key, path in config.items():
            if Path(path).exists():
                print(f"✅ {key}: {path}")
            else:
                print(f"❌ {key}: {path} (不存在)")
        
        # 获取当前pipx环境
        current_config = self.get_current_pipx_config()
        if current_config:
            print("\n📋 当前pipx环境:")
            print(current_config['environment'])
    
    def show_usage_instructions(self):
        """显示使用说明"""
        config = self.get_pipx_xdg_config()
        
        print(f"""
🚀 pipx XDG配置使用说明

1. 设置环境变量（在你的shell配置文件中添加）:
""")
        
        for key, value in config.items():
            print(f"   export {key}='{value}'")
        
        print(f"""
2. 或者直接加载生成的脚本:
   source generated/pipx_xdg_env.sh

3. 重新加载shell配置:
   source ~/.bashrc  # 或 ~/.zshrc

4. 验证配置:
   pipx environment

5. 现在pipx将使用XDG标准路径:
   • 虚拟环境: {config['PIPX_HOME']}
   • 可执行文件: {config['PIPX_BIN_DIR']}  
   • 手册页: {config['PIPX_MAN_DIR']}

⚠️  重要提醒:
• 确保 {config['PIPX_BIN_DIR']} 已添加到 PATH 环境变量
• 重新安装的应用程序将位于新的XDG位置
• 现有安装的应用可能需要重新安装或迁移
""")

def main():
    """主函数"""
    print("🔧 pipx XDG Base Directory 规范配置工具")
    print("=" * 50)
    
    configurator = PipxXDGConfigurator()
    
    # 检查pipx安装
    if not configurator.check_pipx_installation():
        print("\n请先安装pipx:")
        print("  pip install --user pipx")
        print("  或")
        print("  python -m pip install --user pipx")
        sys.exit(1)
    
    # 创建目录
    configurator.create_directories()
    
    # 迁移现有安装（可选）
    configurator.migrate_existing_pipx()
    
    # 生成环境变量脚本
    script_path = configurator.save_environment_script()
    
    # 验证配置
    configurator.verify_configuration()
    
    # 显示使用说明
    configurator.show_usage_instructions()
    
    print("\n🎉 pipx XDG配置完成！")
    print(f"📄 请检查生成的环境变量脚本: {script_path}")

if __name__ == "__main__":
    main()