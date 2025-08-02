#!/usr/bin/env python3
"""
Phase 2 配置生成脚本
整合所有配置文件，生成包含Phase 2增强功能的shell配置
"""

import json
import os
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
import argparse

class Phase2ConfigGenerator:
    def __init__(self, dotfiles_dir: Path):
        self.dotfiles_dir = dotfiles_dir
        self.config_dir = dotfiles_dir / "config"
        self.templates_dir = dotfiles_dir / "templates"
        
        # 设置Jinja2环境
        self.jinja_env = Environment(
            loader=FileSystemLoader(str(self.templates_dir)),
            trim_blocks=True,
            lstrip_blocks=True
        )
    
    def load_config_files(self) -> dict:
        """加载所有配置文件"""
        config = {}
        
        # 加载基础配置文件
        config_files = [
            "shared.json",
            "zsh_integration.json",
            "phase2_integration.json"
        ]
        
        for config_file in config_files:
            file_path = self.config_dir / config_file
            if file_path.exists():
                with open(file_path, 'r', encoding='utf-8') as f:
                    file_config = json.load(f)
                    # 使用文件名（不含扩展名）作为键
                    config_key = config_file.replace('.json', '')
                    config[config_key] = file_config
            else:
                print(f"⚠️  配置文件不存在: {config_file}")
        
        return config
    
    def merge_configs(self, configs: dict) -> dict:
        """合并所有配置"""
        merged = {}
        
        # 基础配置
        if 'shared' in configs:
            merged['shared'] = configs['shared']
        
        # ZSH集成配置
        if 'zsh_integration' in configs:
            merged['zsh_integration'] = configs['zsh_integration']
        
        # Phase 2配置
        if 'phase2_integration' in configs:
            merged['phase2_integration'] = configs['phase2_integration']
        
        return merged
    
    def generate_bash_config(self, config: dict, output_path: Path):
        """生成Bash配置文件"""
        template = self.jinja_env.get_template('bash/enhanced_bashrc.template')
        
        # 渲染模板
        rendered = template.render(config=config)
        
        # 写入文件
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(rendered)
        
        print(f"✅ Bash配置已生成: {output_path}")
    
    def generate_powershell_config(self, config: dict, output_path: Path):
        """生成PowerShell配置文件"""
        template = self.jinja_env.get_template('powershell/enhanced_profile.template.ps1')
        
        # 渲染模板
        rendered = template.render(config=config)
        
        # 写入文件
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(rendered)
        
        print(f"✅ PowerShell配置已生成: {output_path}")
    
    def generate_shell_aliases(self, config: dict, output_path: Path):
        """生成shell别名文件"""
        aliases = []
        
        # Phase 2 别名
        if 'phase2_integration' in config:
            phase2 = config['phase2_integration']
            
            # 容器工具别名
            if 'container_tools' in phase2:
                for tool_name, tool_config in phase2['container_tools'].items():
                    if tool_config.get('enabled', False) and 'aliases' in tool_config:
                        aliases.append(f"# {tool_name.upper()} 别名")
                        for alias_name, alias_command in tool_config['aliases'].items():
                            aliases.append(f"alias {alias_name}='{alias_command}'")
                        aliases.append("")
            
            # 数据库工具别名
            if 'database_tools' in phase2:
                for tool_name, tool_config in phase2['database_tools'].items():
                    if tool_config.get('enabled', False) and 'aliases' in tool_config:
                        aliases.append(f"# {tool_name.upper()} 别名")
                        for alias_name, alias_command in tool_config['aliases'].items():
                            aliases.append(f"alias {alias_name}='{alias_command}'")
                        aliases.append("")
        
        # 写入别名文件
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("#!/bin/bash\n")
            f.write("# Phase 2 增强功能别名\n")
            f.write("# 由 generate_phase2_config.py 自动生成\n\n")
            f.write('\n'.join(aliases))
        
        print(f"✅ Shell别名文件已生成: {output_path}")
    
    def create_installation_summary(self, config: dict, output_path: Path):
        """创建安装总结文档"""
        summary_lines = [
            "# Phase 2 开发体验增强 - 安装总结",
            "",
            "## 🎯 已启用的功能",
            ""
        ]
        
        if 'phase2_integration' in config:
            phase2 = config['phase2_integration']
            
            # 容器工具
            summary_lines.append("### 🐳 容器工具")
            if 'container_tools' in phase2:
                for tool_name, tool_config in phase2['container_tools'].items():
                    status = "✅" if tool_config.get('enabled', False) else "❌"
                    summary_lines.append(f"- {status} **{tool_name}**")
                    if 'aliases' in tool_config:
                        for alias_name, alias_command in tool_config['aliases'].items():
                            summary_lines.append(f"  - `{alias_name}` → `{alias_command}`")
            summary_lines.append("")
            
            # 数据库工具
            summary_lines.append("### 🗄️ 数据库工具")
            if 'database_tools' in phase2:
                for tool_name, tool_config in phase2['database_tools'].items():
                    status = "✅" if tool_config.get('enabled', False) else "❌"
                    summary_lines.append(f"- {status} **{tool_name}**")
                    if 'connection_shortcuts' in tool_config:
                        for shortcut_name, shortcut_command in tool_config['connection_shortcuts'].items():
                            summary_lines.append(f"  - `{shortcut_name}` → 快速连接")
            summary_lines.append("")
            
            # 安全工具
            summary_lines.append("### 🔒 安全工具")
            if 'security_tools' in phase2:
                for tool_name, tool_config in phase2['security_tools'].items():
                    status = "✅" if tool_config.get('enabled', False) else "❌"
                    summary_lines.append(f"- {status} **{tool_name}**")
            summary_lines.append("")
            
            # 自定义函数
            summary_lines.append("### ⚡ 自定义函数")
            if 'shell_functions' in phase2:
                for func_name, func_config in phase2['shell_functions'].items():
                    summary_lines.append(f"- `{func_name}()` - {func_config['description']}")
        
        summary_lines.extend([
            "",
            "## 🚀 使用说明",
            "",
            "1. **重新加载配置**:",
            "   ```bash",
            "   source ~/.bashrc  # Bash用户",
            "   # 或重启PowerShell",
            "   ```",
            "",
            "2. **验证安装**:",
            "   ```bash",
            "   python install/checks/tools_check.py",
            "   ```",
            "",
            "3. **使用新功能**:",
            "   - 使用`dk`代替`docker`",
            "   - 使用`pg`连接PostgreSQL",
            "   - 使用`dev-env`启动开发环境",
            "",
            "## 📚 更多信息",
            "",
            "- 查看完整文档: `docs/`",
            "- 容器模板: `templates/containers/`", 
            "- 数据库工具: `templates/database/`",
            "- SSH管理: `templates/ssh/`"
        ])
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(summary_lines))
        
        print(f"✅ 安装总结已生成: {output_path}")
    
    def generate_all(self, output_dir: Path = None):
        """生成所有配置文件"""
        if output_dir is None:
            output_dir = self.dotfiles_dir / "generated"
        
        output_dir.mkdir(exist_ok=True)
        
        print("🔄 开始生成Phase 2增强配置...")
        
        # 加载和合并配置
        configs = self.load_config_files()
        merged_config = self.merge_configs(configs)
        
        # 生成配置文件
        self.generate_bash_config(merged_config, output_dir / "enhanced_bashrc")
        self.generate_powershell_config(merged_config, output_dir / "enhanced_profile.ps1")
        self.generate_shell_aliases(merged_config, output_dir / "phase2_aliases.sh")
        self.create_installation_summary(merged_config, output_dir / "PHASE2_SUMMARY.md")
        
        print(f"\n🎉 所有配置文件已生成到: {output_dir}")
        print("\n📋 生成的文件:")
        for file_path in output_dir.glob("*"):
            print(f"  - {file_path.name}")

def main():
    parser = argparse.ArgumentParser(description="Phase 2 配置生成脚本")
    parser.add_argument("--output", type=Path, help="输出目录")
    parser.add_argument("--dotfiles-dir", type=Path, default=Path(__file__).parent.parent,
                       help="dotfiles目录路径")
    
    args = parser.parse_args()
    
    generator = Phase2ConfigGenerator(args.dotfiles_dir)
    generator.generate_all(args.output)

if __name__ == "__main__":
    main()