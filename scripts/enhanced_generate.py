#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
增强的 Dotfiles 配置生成器 - 融合 ZSH 功能

基于原始的 ZSH 配置，这个增强版生成器支持:
- 现代化工具集成 (exa, bat, fd, rg, etc.)
- 跨平台开发环境配置
- FZF 集成和主题
- 高级历史管理
- 外部工具自动初始化
- 增强的 Git 集成
- 性能优化设置

作者: Claude AI  
版本: 2.0.0 (ZSH Enhanced)
兼容性: Python 3.7+, Windows 11, Git Bash, PowerShell 5.1+
"""

import json
import os
import shutil
import subprocess
from pathlib import Path
from jinja2 import Template
from datetime import datetime

class EnhancedDotfilesGenerator:
    """
    增强的 Dotfiles 配置生成器
    
    融合了 ZSH 的所有高级功能，提供跨 Shell 的一致体验。
    """
    
    def __init__(self, dotfiles_root):
        """
        初始化增强生成器
        
        Args:
            dotfiles_root (str): dotfiles 根目录路径
        """
        self.root = Path(dotfiles_root)
        self.config_dir = self.root / "config"
        self.templates_dir = self.root / "templates"
        self.generated_dir = self.root / "generated"
        
        # 支持的配置文件
        self.config_files = [
            'shared.json',
            'aliases.json', 
            'functions.json',
            'advanced_functions.json',
            'zsh_integration.json'
        ]
    
    def resolve_path_for_shell(self, path_config, shell_type):
        """
        解析针对特定 shell 类型的路径
        
        Args:
            path_config: 路径配置（可能是字符串或字典）
            shell_type: shell 类型 ('bash', 'powershell', 'zsh')
            
        Returns:
            str: 针对特定 shell 的路径
        """
        if isinstance(path_config, str):
            return path_config
        elif isinstance(path_config, dict):
            return path_config.get(shell_type, path_config.get('bash', ''))
        else:
            return str(path_config)
    
    def process_development_environments(self, config, shell_type):
        """
        处理开发环境配置，解析多路径格式
        
        Args:
            config: 配置字典
            shell_type: shell 类型
            
        Returns:
            dict: 处理后的开发环境配置
        """
        import copy
        
        if 'zsh_integration' not in config or 'development_environments' not in config['zsh_integration']:
            return {}
            
        dev_envs = copy.deepcopy(config['zsh_integration']['development_environments'])
        processed_envs = {}
        
        for env_name, env_config in dev_envs.items():
            processed_env = {}
            for var_name, var_value in env_config.items():
                processed_env[var_name] = self.resolve_path_for_shell(var_value, shell_type)
            processed_envs[env_name] = processed_env
            
        return processed_envs
    
    def get_powershell_profile_path(self):
        """
        获取 PowerShell 默认配置文件路径
        
        Returns:
            Path: PowerShell 配置文件路径
        """
        # 直接使用 PowerShell 7+ 的正确路径
        user_home = Path.home()
        return user_home / "Documents" / "PowerShell" / "Microsoft.PowerShell_profile.ps1"
    
    def backup_existing_profile(self, profile_path):
        """
        备份现有的 PowerShell 配置文件
        
        Args:
            profile_path (Path): 配置文件路径
            
        Returns:
            bool: 是否备份成功
        """
        if not profile_path.exists():
            return True
            
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_path = profile_path.with_suffix(f".backup.{timestamp}.ps1")
            shutil.copy2(profile_path, backup_path)
            print(f"✅ 已备份现有配置: {backup_path.name}")
            return True
        except Exception as e:
            print(f"❌ 备份配置失败: {e}")
            return False
    
    def deploy_powershell_profile(self, source_path):
        """
        将生成的 PowerShell 配置部署到默认位置
        
        Args:
            source_path (Path): 生成的配置文件路径
            
        Returns:
            bool: 是否部署成功
        """
        try:
            profile_path = self.get_powershell_profile_path()
            
            # 确保目录存在
            profile_path.parent.mkdir(parents=True, exist_ok=True)
            
            # 备份现有配置
            if not self.backup_existing_profile(profile_path):
                return False
            
            # 复制新配置
            shutil.copy2(source_path, profile_path)
            print(f"✅ PowerShell 配置已部署到: {profile_path}")
            return True
            
        except Exception as e:
            print(f"❌ 部署 PowerShell 配置失败: {e}")
            return False
        
    def load_config(self):
        """
        加载所有配置文件，包括新的增强配置
        
        Returns:
            dict: 完整的配置字典
        """
        config = {}
        loaded_count = 0
        
        try:
            # 加载所有配置文件
            for config_file_name in self.config_files:
                config_file = self.config_dir / config_file_name
                if config_file.exists():
                    with open(config_file, 'r', encoding='utf-8') as f:
                        config_data = json.load(f)
                        config[config_file.stem] = config_data
                        loaded_count += 1
                        print(f"✅ 已加载: {config_file_name}")
                else:
                    print(f"⚠️  配置文件不存在: {config_file_name}")
            
            print(f"✅ 总共加载 {loaded_count} 个配置文件")
            
            # 验证必需的配置
            required_configs = ['shared', 'aliases']
            missing_configs = [cfg for cfg in required_configs if cfg not in config]
            
            if missing_configs:
                print(f"❌ 缺少必需的配置文件: {missing_configs}")
                return {}
                
            return config
            
        except json.JSONDecodeError as e:
            print(f"❌ JSON 格式错误: {e}")
            return {}
        except Exception as e:
            print(f"❌ 加载配置失败: {e}")
            return {}
    
    def generate_bash_config(self, config):
        """
        生成增强的 Bash 配置文件
        
        Args:
            config (dict): 完整的配置字典
        """
        try:
            bash_dir = self.generated_dir / "bash"
            bash_dir.mkdir(parents=True, exist_ok=True)
            
            # 选择模板文件
            if 'zsh_integration' in config:
                template_file = self.templates_dir / "bash" / "enhanced_bashrc.template"
                output_name = "enhanced_bashrc"
                print("🔧 使用增强模板生成 Bash 配置")
            else:
                template_file = self.templates_dir / "bash" / "bashrc.template"
                output_name = "bashrc"
                print("🔧 使用标准模板生成 Bash 配置")
            
            if template_file.exists():
                with open(template_file, 'r', encoding='utf-8') as f:
                    template = Template(f.read())
                
                # 处理开发环境路径
                import copy
                processed_config = copy.deepcopy(config)
                if 'zsh_integration' in processed_config:
                    processed_config['zsh_integration']['development_environments'] = self.process_development_environments(config, 'bash')
                
                # 渲染模板
                bashrc_content = template.render(
                    config=processed_config,
                    shell='bash'
                )
                
                # 只写入enhanced版本文件
                if output_name == "enhanced_bashrc":
                    output_file = bash_dir / "enhanced_bashrc"
                else:
                    output_file = bash_dir / "bashrc"
                
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(bashrc_content)
                
                print("✅ Bash 配置文件已生成")
            else:
                print(f"⚠️  Bash 模板文件未找到: {template_file}")
                
        except Exception as e:
            print(f"❌ 生成 Bash 配置失败: {e}")
    
    def generate_powershell_config(self, config):
        """
        生成增强的 PowerShell 配置文件
        
        Args:
            config (dict): 完整的配置字典
        """
        try:
            ps_dir = self.generated_dir / "powershell"
            ps_dir.mkdir(parents=True, exist_ok=True)
            
            # 选择模板文件
            if 'zsh_integration' in config:
                template_file = self.templates_dir / "powershell" / "enhanced_profile.template.ps1"
                output_name = "enhanced_Profile.ps1"
                print("🔧 使用增强模板生成 PowerShell 配置")
            else:
                template_file = self.templates_dir / "powershell" / "Profile.template.ps1" 
                output_name = "Profile.ps1"
                print("🔧 使用标准模板生成 PowerShell 配置")
            
            if template_file.exists():
                with open(template_file, 'r', encoding='utf-8') as f:
                    template = Template(f.read())
                
                # 处理开发环境路径
                import copy
                processed_config = copy.deepcopy(config)
                if 'zsh_integration' in processed_config:
                    processed_config['zsh_integration']['development_environments'] = self.process_development_environments(config, 'powershell')
                
                # 渲染模板
                profile_content = template.render(
                    config=processed_config,
                    shell='powershell'
                )
                
                # 只写入enhanced版本文件
                if output_name == "enhanced_Profile.ps1":
                    output_file = ps_dir / "enhanced_Profile.ps1"
                    enhanced_file = output_file  # 用于后续部署引用
                else:
                    output_file = ps_dir / "Profile.ps1"
                    enhanced_file = output_file
                
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(profile_content)
                
                print("✅ PowerShell 配置文件已生成")
                
                # 自动部署到 PowerShell 默认位置
                print("🔄 正在部署 PowerShell 配置到默认位置...")
                deploy_source = enhanced_file if output_name == "enhanced_Profile.ps1" else output_file
                if self.deploy_powershell_profile(deploy_source):
                    print("🎉 PowerShell 配置已自动部署！")
                else:
                    print("⚠️ 自动部署失败，请手动复制配置文件")
                    
            else:
                print(f"⚠️  PowerShell 模板文件未找到: {template_file}")
                
        except Exception as e:
            print(f"❌ 生成 PowerShell 配置失败: {e}")
    
    def generate_zsh_config(self, config):
        """
        生成 ZSH 配置文件（如果需要）
        
        Args:
            config (dict): 完整的配置字典
        """
        if 'zsh_integration' not in config:
            return
            
        try:
            zsh_dir = self.generated_dir / "zsh"
            zsh_dir.mkdir(parents=True, exist_ok=True)
            
            # 创建基于配置的 .zshrc
            zsh_template = """#!/bin/zsh
# 由 dotfiles 生成器生成的 ZSH 配置

# 基础环境变量
{% for key, value in config.shared.environment.items() %}
export {{ key }}="{{ value }}"
{% endfor %}

# 现代工具别名
{% for tool_name, tool_config in config.zsh_integration.modern_tools.replacements.items() %}
if command -v {{ tool_config.tool }} > /dev/null; then
    {% for alias_name, alias_command in tool_config.aliases.items() %}
    alias {{ alias_name }}='{{ alias_command }}'
    {% endfor %}
fi
{% endfor %}

# 高级函数
{% for name, func in config.advanced_functions.items() %}
# {{ func.description }}
{{ func.zsh if 'zsh' in func else func.bash }}

{% endfor %}

# 外部工具初始化
{% for tool, init_command in config.zsh_integration.external_tools.auto_init.items() %}
command -v {{ tool.split()[0] if ' ' in tool else tool }} > /dev/null && {{ init_command.replace('{shell}', 'zsh') }}
{% endfor %}

echo "🚀 ZSH 环境已加载 - dotfiles 系统"
"""
            
            # 处理开发环境路径
            import copy
            processed_config = copy.deepcopy(config)
            if 'zsh_integration' in processed_config:
                processed_config['zsh_integration']['development_environments'] = self.process_development_environments(config, 'zsh')
            
            template = Template(zsh_template)
            zshrc_content = template.render(config=processed_config, shell='zsh')
            
            output_file = zsh_dir / "zshrc"
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(zshrc_content)
            
            print("✅ ZSH 配置文件已生成")
            
        except Exception as e:
            print(f"❌ 生成 ZSH 配置失败: {e}")
    
    def generate_config_summary(self, config):
        """
        生成配置摘要文件
        
        Args:
            config (dict): 完整的配置字典
        """
        try:
            summary_file = self.generated_dir / "config_summary.md"
            
            summary_content = f"""# Dotfiles 配置摘要

## 生成时间
{os.popen('date').read().strip()}

## 加载的配置文件
"""
            
            for config_name in config.keys():
                summary_content += f"- {config_name}.json\n"
            
            summary_content += "\n## 启用的功能\n"
            
            if 'shared' in config and 'features' in config['shared']:
                for feature, enabled in config['shared']['features'].items():
                    status = "✅" if enabled else "❌"
                    summary_content += f"{status} {feature}\n"
            
            if 'zsh_integration' in config:
                summary_content += "\n## ZSH 集成功能\n"
                summary_content += "✅ 现代化工具替代\n"
                summary_content += "✅ 增强历史管理\n"
                summary_content += "✅ FZF 集成\n"
                summary_content += "✅ 开发环境配置\n"
                summary_content += "✅ 外部工具自动初始化\n"
            
            summary_content += f"\n## 配置统计\n"
            summary_content += f"- 别名数量: {len(config.get('aliases', {}).get('git', {})) if 'aliases' in config else 0}\n"
            summary_content += f"- 函数数量: {len(config.get('functions', {})) + len(config.get('advanced_functions', {}))}\n"
            
            with open(summary_file, 'w', encoding='utf-8') as f:
                f.write(summary_content)
            
            print("✅ 配置摘要已生成")
            
        except Exception as e:
            print(f"❌ 生成配置摘要失败: {e}")
    
    def validate_generated_configs(self):
        """
        验证生成的配置文件
        
        Returns:
            bool: 验证是否通过
        """
        try:
            validation_results = []
            
            # 检查 Bash 配置（优先检查enhanced版本）
            bash_enhanced = self.generated_dir / "bash" / "enhanced_bashrc"
            bash_standard = self.generated_dir / "bash" / "bashrc"
            if bash_enhanced.exists():
                size = bash_enhanced.stat().st_size
                validation_results.append(f"✅ Bash 配置: {size} 字节")
            elif bash_standard.exists():
                size = bash_standard.stat().st_size
                validation_results.append(f"✅ Bash 配置: {size} 字节")
            else:
                validation_results.append("❌ Bash 配置文件不存在")
            
            # 检查 PowerShell 配置（优先检查enhanced版本）
            ps_enhanced = self.generated_dir / "powershell" / "enhanced_Profile.ps1"
            ps_standard = self.generated_dir / "powershell" / "Profile.ps1"
            if ps_enhanced.exists():
                size = ps_enhanced.stat().st_size
                validation_results.append(f"✅ PowerShell 配置: {size} 字节")
            elif ps_standard.exists():
                size = ps_standard.stat().st_size
                validation_results.append(f"✅ PowerShell 配置: {size} 字节")
            else:
                validation_results.append("❌ PowerShell 配置文件不存在")
            
            # 检查 ZSH 配置（如果存在）
            zsh_config = self.generated_dir / "zsh" / "zshrc"
            if zsh_config.exists():
                size = zsh_config.stat().st_size
                validation_results.append(f"✅ ZSH 配置: {size} 字节")
            
            print("\n📋 配置验证结果:")
            for result in validation_results:
                print(f"   {result}")
            
            return all("✅" in result for result in validation_results)
            
        except Exception as e:
            print(f"❌ 配置验证失败: {e}")
            return False
    
    def generate_all(self):
        """
        生成所有配置文件的主方法
        
        Returns:
            bool: 生成是否成功
        """
        print("🚀 启动增强的 dotfiles 配置生成器...")
        print("📋 支持的功能:")
        print("   - 现代化工具集成 (exa, bat, fd, rg)")
        print("   - 跨平台开发环境")
        print("   - FZF 模糊搜索集成")
        print("   - 增强的历史记录管理")
        print("   - Git 状态增强显示")
        print("   - 外部工具自动初始化")
        print("")
        
        # 加载配置
        config = self.load_config()
        if not config:
            print("❌ 配置加载失败，无法继续")
            return False
        
        # 生成各种 Shell 配置
        print("\n🔧 开始生成配置文件...")
        self.generate_bash_config(config)
        self.generate_powershell_config(config)
        self.generate_zsh_config(config)
        self.generate_config_summary(config)
        
        # 验证生成的配置
        print("\n🔍 验证生成的配置...")
        validation_passed = self.validate_generated_configs()
        
        if validation_passed:
            print("\n🎉 所有配置文件已成功生成！")
            print(f"📁 生成的文件位于: {self.generated_dir}")
            print("\n🔄 下一步:")
            print("   - Bash: source ~/.bash_profile")
            print("   - PowerShell: . $PROFILE")
            print("   - 或使用 'reload' 别名")
            print("\n💡 提示:")
            print("   - 查看配置摘要: generated/config_summary.md")
            print("   - 增强版本已启用现代化工具支持")
            print("   - 支持 FZF 模糊搜索和 Git 状态显示")
            return True
        else:
            print("\n⚠️  配置生成完成，但验证中发现问题")
            print("请检查生成的文件并手动验证")
            return False

def main():
    """
    主函数 - 增强版本
    """
    dotfiles_root = "C:/Users/afu/dotfiles"
    
    # 验证环境
    if not os.path.exists(dotfiles_root):
        print(f"❌ dotfiles 目录不存在: {dotfiles_root}")
        print("\n💡 请确保目录结构正确:")
        print("   ~/dotfiles/")
        print("   ├── config/")
        print("   │   ├── shared.json")
        print("   │   ├── aliases.json")
        print("   │   ├── functions.json")
        print("   │   ├── advanced_functions.json")
        print("   │   └── zsh_integration.json")
        print("   ├── templates/")
        print("   └── scripts/")
        exit(1)
    
    try:
        # 创建并运行增强生成器
        generator = EnhancedDotfilesGenerator(dotfiles_root)
        success = generator.generate_all()
        
        if not success:
            exit(1)
            
    except KeyboardInterrupt:
        print("\n\n⚠️  用户中断操作")
        exit(130)
    except Exception as e:
        print(f"\n❌ 意外错误: {e}")
        print("💡 请检查以下项目:")
        print("   - Python 依赖: pip install jinja2")
        print("   - 配置文件格式是否正确")
        print("   - 文件权限是否正确")
        exit(1)

if __name__ == "__main__":
    main()