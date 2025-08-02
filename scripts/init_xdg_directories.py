#!/usr/bin/env python3
"""
XDG Base Directory 规范目录初始化脚本
自动创建和配置XDG标准目录结构
"""

import os
import json
import platform
from pathlib import Path
from typing import Dict, List

class XDGDirectoryInitializer:
    def __init__(self, dotfiles_dir: Path):
        self.dotfiles_dir = dotfiles_dir
        self.config_dir = dotfiles_dir / "config"
        self.platform = self.detect_platform()
        
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
            return "linux"  # 默认
    
    def load_xdg_config(self) -> Dict:
        """加载XDG配置"""
        config_file = self.config_dir / "zsh_integration.json"
        if not config_file.exists():
            raise FileNotFoundError(f"配置文件不存在: {config_file}")
        
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        return config.get("xdg_directories", {})
    
    def expand_path(self, path_template: str) -> Path:
        """展开路径模板"""
        # 处理平台特定的路径
        if isinstance(path_template, dict):
            path_template = path_template.get(self.platform, path_template.get("linux", ""))
        
        # 展开环境变量
        expanded = os.path.expandvars(path_template)
        expanded = os.path.expanduser(expanded)
        
        return Path(expanded)
    
    def get_xdg_directories(self) -> Dict[str, Path]:
        """获取XDG目录路径"""
        xdg_config = self.load_xdg_config()
        
        directories = {}
        
        # 基础XDG目录
        xdg_keys = ["config_home", "data_home", "state_home", "cache_home", "runtime_dir", "user_bin"]
        
        for key in xdg_keys:
            if key in xdg_config:
                directories[key] = self.expand_path(xdg_config[key])
        
        return directories
    
    def create_directory_structure(self, base_dirs: Dict[str, Path]):
        """创建XDG目录结构"""
        print("🏗️  创建XDG Base Directory 结构...")
        
        # 创建基础目录
        for dir_name, dir_path in base_dirs.items():
            if dir_name == "runtime_dir" and self.platform == "windows":
                continue  # Windows不需要runtime目录
            
            try:
                dir_path.mkdir(parents=True, exist_ok=True)
                print(f"✅ 创建目录: {dir_name} -> {dir_path}")
            except Exception as e:
                print(f"❌ 创建目录失败 {dir_name}: {e}")
        
        # 创建应用特定子目录
        app_subdirs = {
            "config_home": [
                "bash", "zsh", "git", "ssh", "dotfiles",
                "pgcli", "mycli", "gpg"
            ],
            "data_home": [
                "bash", "zsh", "dotfiles", "gnupg",
                "dotfiles/history_backup", "dotfiles/gpg_backup"
            ],
            "state_home": [
                "bash", "zsh", "dotfiles",
                "pgcli", "mycli", "ssh"
            ],
            "cache_home": [
                "bash", "zsh", "dotfiles"
            ]
        }
        
        print("\n📁 创建应用特定子目录...")
        for base_dir, subdirs in app_subdirs.items():
            if base_dir not in base_dirs:
                continue
                
            base_path = base_dirs[base_dir]
            for subdir in subdirs:
                subdir_path = base_path / subdir
                try:
                    subdir_path.mkdir(parents=True, exist_ok=True)
                    print(f"  ✅ {base_dir}/{subdir}")
                except Exception as e:
                    print(f"  ❌ {base_dir}/{subdir}: {e}")
    
    def set_environment_variables(self, base_dirs: Dict[str, Path]):
        """设置XDG环境变量"""
        print("\n🌍 设置XDG环境变量...")
        
        env_mapping = {
            "config_home": "XDG_CONFIG_HOME",
            "data_home": "XDG_DATA_HOME", 
            "state_home": "XDG_STATE_HOME",
            "cache_home": "XDG_CACHE_HOME",
            "runtime_dir": "XDG_RUNTIME_DIR"
        }
        
        env_vars = []
        for dir_key, env_var in env_mapping.items():
            if dir_key in base_dirs:
                path = str(base_dirs[dir_key])
                os.environ[env_var] = path
                env_vars.append(f'export {env_var}="{path}"')
                print(f"  ✅ {env_var} = {path}")
        
        # 生成环境变量设置脚本
        env_script_path = self.dotfiles_dir / "generated" / "xdg_env.sh"
        env_script_path.parent.mkdir(exist_ok=True)
        
        with open(env_script_path, 'w', encoding='utf-8') as f:
            f.write("#!/bin/bash\n")
            f.write("# XDG Base Directory 环境变量\n")
            f.write("# 由 init_xdg_directories.py 自动生成\n\n")
            f.write('\n'.join(env_vars))
            f.write('\n')
        
        print(f"  📝 环境变量脚本已生成: {env_script_path}")
    
    def create_xdg_config_files(self, base_dirs: Dict[str, Path]):
        """创建XDG合规的配置文件"""
        print("\n⚙️  创建XDG合规配置文件...")
        
        config_home = base_dirs.get("config_home")
        if not config_home:
            return
        
        # pgcli 配置
        pgcli_config = config_home / "pgcli" / "config"
        if not pgcli_config.exists():
            pgcli_config_content = """[main]
# Multi-line mode allows breaking up the sql statement into multiple lines.
multi_line = False

# Destructive warning mode will alert you before executing a sql statement
# that may cause harm to the database such as "drop table", "drop database" 
# or "shutdown".
destructive_warning = True

# log_file location.
log_file = {state_home}/pgcli/log

# keyword casing preference. Possible values "lower", "upper", "auto"
keyword_casing = auto

# Setting this to True will cause FunctionInspection to be slower but more thorough.
slower_function_inspection = False

# When True, Replication connection is used
replication = False

# log_level, possible values: CRITICAL, FATAL, ERROR, WARN, WARNING, INFO, DEBUG
log_level = INFO
""".format(state_home=base_dirs.get("state_home", ""))
            
            try:
                with open(pgcli_config, 'w', encoding='utf-8') as f:
                    f.write(pgcli_config_content)
                print(f"  ✅ pgcli 配置: {pgcli_config}")
            except Exception as e:
                print(f"  ❌ pgcli 配置失败: {e}")
        
        # mycli 配置
        mycli_config = config_home / "mycli" / "myclirc"
        if not mycli_config.exists():
            mycli_config_content = """[main]
# Multi-line mode allows breaking up the sql statement into multiple lines.
multi_line = False

# Destructive warning mode will alert you before executing a sql statement
# that may cause harm to the database such as "drop table", "drop database".
destructive_warning = True

# log_file location.
log_file = {state_home}/mycli/log

# Default log level. Possible values: "CRITICAL", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG"
log_level = INFO

# keyword casing preference. Possible values "lower", "upper", "auto"
keyword_casing = auto

# When True, table comments are shown
show_table_comments = True
""".format(state_home=base_dirs.get("state_home", ""))
            
            try:
                with open(mycli_config, 'w', encoding='utf-8') as f:
                    f.write(mycli_config_content)
                print(f"  ✅ mycli 配置: {mycli_config}")
            except Exception as e:
                print(f"  ❌ mycli 配置失败: {e}")
    
    def validate_xdg_compliance(self, base_dirs: Dict[str, Path]) -> Dict:
        """验证XDG合规性"""
        print("\n🔍 验证XDG合规性...")
        
        results = {
            "directories": {"passed": [], "failed": []},
            "env_vars": {"passed": [], "failed": []},
            "config_files": {"passed": [], "failed": []}
        }
        
        # 检查目录
        for dir_name, dir_path in base_dirs.items():
            if dir_path.exists():
                results["directories"]["passed"].append(dir_name)
                print(f"  ✅ 目录存在: {dir_name}")
            else:
                results["directories"]["failed"].append(dir_name)
                print(f"  ❌ 目录缺失: {dir_name}")
        
        # 检查环境变量
        env_vars = ["XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME", "XDG_CACHE_HOME"]
        for env_var in env_vars:
            if os.environ.get(env_var):
                results["env_vars"]["passed"].append(env_var)
                print(f"  ✅ 环境变量: {env_var}")
            else:
                results["env_vars"]["failed"].append(env_var)
                print(f"  ❌ 环境变量缺失: {env_var}")
        
        return results
    
    def generate_summary_report(self, validation_results: Dict):
        """生成XDG合规性总结报告"""
        report_path = self.dotfiles_dir / "generated" / "XDG_COMPLIANCE_REPORT.md"
        
        total_dirs = len(validation_results["directories"]["passed"]) + len(validation_results["directories"]["failed"])
        passed_dirs = len(validation_results["directories"]["passed"])
        dir_compliance = (passed_dirs / total_dirs * 100) if total_dirs > 0 else 0
        
        total_env = len(validation_results["env_vars"]["passed"]) + len(validation_results["env_vars"]["failed"])
        passed_env = len(validation_results["env_vars"]["passed"])
        env_compliance = (passed_env / total_env * 100) if total_env > 0 else 0
        
        report_content = f"""# XDG Base Directory 合规性报告

## 📊 总体评分

| 类别 | 通过/总数 | 合规率 | 状态 |
|------|-----------|--------|------|
| 目录结构 | {passed_dirs}/{total_dirs} | {dir_compliance:.1f}% | {"✅" if dir_compliance >= 90 else "⚠️" if dir_compliance >= 70 else "❌"} |
| 环境变量 | {passed_env}/{total_env} | {env_compliance:.1f}% | {"✅" if env_compliance >= 90 else "⚠️" if env_compliance >= 70 else "❌"} |

## 📁 目录结构检查

### ✅ 通过的目录
{chr(10).join(f"- {dir_name}" for dir_name in validation_results["directories"]["passed"])}

### ❌ 失败的目录
{chr(10).join(f"- {dir_name}" for dir_name in validation_results["directories"]["failed"]) if validation_results["directories"]["failed"] else "无"}

## 🌍 环境变量检查

### ✅ 设置的环境变量
{chr(10).join(f"- {env_var} = {os.environ.get(env_var, 'N/A')}" for env_var in validation_results["env_vars"]["passed"])}

### ❌ 缺失的环境变量
{chr(10).join(f"- {env_var}" for env_var in validation_results["env_vars"]["failed"]) if validation_results["env_vars"]["failed"] else "无"}

## 📋 使用说明

1. **加载XDG环境变量**:
   ```bash
   source generated/xdg_env.sh
   ```

2. **验证配置**:
   ```bash
   echo $XDG_CONFIG_HOME
   echo $XDG_DATA_HOME
   echo $XDG_STATE_HOME
   echo $XDG_CACHE_HOME
   ```

3. **重新生成配置文件**:
   ```bash
   python scripts/enhanced_generate.py
   ```

---
**生成时间**: {import datetime; datetime.datetime.now().isoformat()}
**平台**: {self.platform}
**总体合规率**: {(dir_compliance + env_compliance) / 2:.1f}%
"""
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(report_content)
        
        print(f"\n📋 XDG合规性报告已生成: {report_path}")
    
    def initialize_all(self):
        """初始化所有XDG目录和配置"""
        print("🚀 开始XDG Base Directory 初始化...")
        print(f"平台: {self.platform}")
        
        try:
            # 获取XDG目录配置
            xdg_dirs = self.get_xdg_directories()
            
            # 创建目录结构
            self.create_directory_structure(xdg_dirs)
            
            # 设置环境变量
            self.set_environment_variables(xdg_dirs)
            
            # 创建配置文件
            self.create_xdg_config_files(xdg_dirs)
            
            # 验证合规性
            validation_results = self.validate_xdg_compliance(xdg_dirs)
            
            # 生成报告
            self.generate_summary_report(validation_results)
            
            print("\n🎉 XDG初始化完成！")
            print("💡 请运行 'source generated/xdg_env.sh' 来加载环境变量")
            
        except Exception as e:
            print(f"❌ XDG初始化失败: {e}")
            raise

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="XDG Base Directory 初始化脚本")
    parser.add_argument("--dotfiles-dir", type=Path, default=Path(__file__).parent.parent,
                       help="dotfiles目录路径")
    
    args = parser.parse_args()
    
    initializer = XDGDirectoryInitializer(args.dotfiles_dir)
    initializer.initialize_all()

if __name__ == "__main__":
    main()