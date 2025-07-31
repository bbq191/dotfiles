# 🚀 统一 Dotfiles 管理系统

> Windows 11 + Git Bash 环境下的跨 Shell 配置管理方案

## 📋 目录

- [系统概述](#系统概述)
- [快速开始](#快速开始)
- [配置文件说明](#配置文件说明)
- [自定义配置](#自定义配置)
- [日常使用](#日常使用)
- [故障排除](#故障排除)
- [高级用法](#高级用法)

## 🎯 系统概述

本系统基于以下核心理念：

- **单一数据源**：所有配置统一存储在 JSON 文件中
- **模板驱动**：使用 Jinja2 模板引擎生成各 shell 配置
- **跨平台一致性**：PowerShell 和 Bash 提供相同的用户体验
- **自动化管理**：一键生成和同步所有配置文件

### 目录结构

```
~/dotfiles/
├── config/              # 配置数据源（JSON 格式）
│   ├── shared.json     # 共享配置（用户信息、环境变量等）
│   ├── aliases.json    # 别名定义
│   └── functions.json  # 函数定义
├── templates/          # 配置模板
│   ├── bash/
│   │   └── bashrc.template
│   └── powershell/
│       └── Profile.template.ps1
├── generated/          # 生成的配置文件
│   ├── bash/
│   │   └── bashrc
│   └── powershell/
│       └── Profile.ps1
├── scripts/            # 管理脚本
│   ├── generate.py     # 配置生成器
│   ├── bootstrap.ps1   # PowerShell 安装脚本
│   └── bootstrap.bash  # Bash 安装脚本
├── backups/            # 配置备份
└── README.md           # 本文档
```

## 🚀 快速开始

### 1. 重新生成配置

```bash
# 在任何时候重新生成配置
python ~/dotfiles/scripts/generate.py
```

### 2. 重新加载配置

**Bash:**
```bash
source ~/.bash_profile
# 或使用别名
reload
```

**PowerShell:**
```powershell
. $PROFILE
# 或使用别名
reload
```

### 3. 验证安装

```bash
# 测试别名
ll
gs
py

# 测试函数
mkcd test_folder
weather beijing  # 如果有网络连接
```

## 📝 配置文件说明

### shared.json - 共享配置

```json
{
  "user": {
    "name": "your_name",        // Git 用户名
    "email": "your@email.com",  // Git 邮箱
    "editor": "code-insiders",  // 默认编辑器
    "browser": "chrome"         // 默认浏览器
  },
  "paths": {
    "projects": "~/Projects",   // 项目目录
    "dotfiles": "~/dotfiles",   // dotfiles 目录
    "tools": "~/tools"          // 工具目录
  },
  "environment": {
    "EDITOR": "code-insiders",  // 环境变量：编辑器
    "BROWSER": "chrome",        // 环境变量：浏览器
    "LANG": "zh_CN.UTF-8"       // 环境变量：语言
  },
  "features": {
    "git_integration": true,    // 启用 Git 分支显示
    "nodejs_management": true,  // 启用 Node.js 管理
    "python_management": true,  // 启用 Python 管理
    "docker_support": true      // 启用 Docker 支持
  }
}
```

### aliases.json - 别名配置

```json
{
  "navigation": {
    "..": "cd ..",              // 上级目录
    "projects": "cd ~/Projects" // 跳转到项目目录
  },
  "file_operations": {
    "bash": {
      "ll": "ls -alF"           // Bash 版本的详细列表
    },
    "powershell": {
      "ll": "Get-ChildItem -Force" // PowerShell 版本的详细列表
    }
  },
  "git": {
    "gs": "git status",         // Git 状态
    "ga": "git add",            // Git 添加
    "gc": "git commit -m"       // Git 提交
  }
}
```

### functions.json - 函数配置

```json
{
  "mkcd": {
    "description": "创建目录并进入",
    "bash": "mkcd() { mkdir -p \"$1\" && cd \"$1\"; }",
    "powershell": "function mkcd($dir) { New-Item -ItemType Directory -Force -Path $dir | Set-Location }"
  }
}
```

## ⚙️ 自定义配置

### 添加新的别名

1. 编辑 `config/aliases.json`：

```json
{
  "custom": {
    "myalias": "your_command_here"
  }
}
```

2. 在模板中使用：

```bash
# 在 templates/bash/bashrc.template 中添加
{% for alias, command in config.aliases.custom.items() %}
alias {{ alias }}='{{ command }}'
{% endfor %}
```

3. 重新生成配置：

```bash
python ~/dotfiles/scripts/generate.py
```

### 添加新的函数

1. 编辑 `config/functions.json`：

```json
{
  "myfunction": {
    "description": "我的自定义函数",
    "bash": "myfunction() { echo \"Hello from Bash: $1\"; }",
    "powershell": "function myfunction($param) { Write-Host \"Hello from PowerShell: $param\" }"
  }
}
```

2. 重新生成配置。

### 修改用户信息

编辑 `config/shared.json` 中的 `user` 部分：

```json
{
  "user": {
    "name": "YourName",
    "email": "your.email@example.com",
    "editor": "vim",  // 或 "code", "nano" 等
    "browser": "firefox"
  }
}
```

### 添加环境变量

在 `config/shared.json` 的 `environment` 部分添加：

```json
{
  "environment": {
    "MY_CUSTOM_VAR": "my_value",
    "PATH_ADDITION": "/my/custom/path"
  }
}
```

## 🔄 日常使用

### 可用的别名

**导航别名：**
- `..` - 上一级目录
- `...` - 上两级目录
- `~` - 家目录
- `projects` - 项目目录
- `dotfiles` - dotfiles 目录

**文件操作：**
- `ll` - 详细列表（等价于 `ls -alF` 或 `Get-ChildItem -Force`）
- `la` - 显示隐藏文件
- `l` - 简单列表

**Git 别名：**
- `gs` - `git status`
- `ga` - `git add`
- `gaa` - `git add --all`
- `gc` - `git commit -m`
- `gp` - `git push`
- `gl` - `git log --oneline`
- `gco` - `git checkout`
- `gb` - `git branch`
- `gd` - `git diff`

**开发工具：**
- `py` - `python`
- `pip` - `python -m pip`
- `serve` - `python -m http.server 8000`

**系统工具：**
- `open` - 打开文件/目录（`explorer` 或 `Invoke-Item`）
- `which` - 查找命令位置
- `reload` - 重新加载配置

### 可用的函数

**文件操作：**
- `mkcd <dir>` - 创建目录并进入
- `extract <file>` - 智能解压缩文件
- `findfile <pattern>` - 查找文件

**Git 工具：**
- `gitclean` - 清理已合并的分支

**系统信息：**
- `weather <city>` - 获取天气信息（需要网络）
- `ports` - 查看端口占用情况

### 配置更新流程

1. **修改配置文件**（`config/*.json`）
2. **重新生成配置**：
   ```bash
   python ~/dotfiles/scripts/generate.py
   ```
3. **重新加载配置**：
   - Bash: `source ~/.bash_profile` 或 `reload`
   - PowerShell: `. $PROFILE` 或 `reload`

## 🔧 故障排除

### 常见问题

**Q: 配置不生效怎么办？**

A: 按以下步骤检查：
1. 确认生成器运行成功：`python ~/dotfiles/scripts/generate.py`
2. 检查生成的文件是否存在：`ls ~/dotfiles/generated/bash/bashrc`
3. 手动重新加载：`source ~/.bash_profile`

**Q: Python 依赖缺失？**

A: 安装必要的依赖：
```bash
python -m pip install --user jinja2
```

**Q: PowerShell 配置报错？**

A: 检查 PowerShell 执行策略：
```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: 某些别名不工作？**

A: 检查配置文件语法：
1. 验证 JSON 格式：使用在线 JSON 验证器
2. 检查模板语法：确认 Jinja2 模板格式正确
3. 查看生成的文件：检查 `generated/` 目录下的文件

### 调试方法

**启用详细输出：**
```bash
# 调试 Bash 配置加载
bash -x ~/.bash_profile

# 调试 Python 生成器
python -u ~/dotfiles/scripts/generate.py
```

**检查生成的配置：**
```bash
# 验证 Bash 语法
bash -n ~/dotfiles/generated/bash/bashrc

# 检查 PowerShell 语法
powershell -Command "Get-Content ~/dotfiles/generated/powershell/Profile.ps1 | Out-Null"
```

### 备份和恢复

**创建备份：**
```bash
# 自动备份在配置更新时创建
ls ~/dotfiles/backups/

# 手动备份
cp ~/.bash_profile ~/.bash_profile.backup.$(date +%Y%m%d_%H%M%S)
```

**恢复配置：**
```bash
# 恢复到之前的配置
cp ~/dotfiles/backups/20240731_140000/.bash_profile ~/.bash_profile
```

## 🚀 高级用法

### 条件配置

在模板中使用条件语句：

```bash
# 在 bashrc.template 中
{% if config.shared.features.git_integration %}
# Git 集成功能
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
{% endif %}
```

### 动态路径

使用环境变量和动态路径：

```json
{
  "paths": {
    "projects": "${HOME}/Projects",
    "config": "${XDG_CONFIG_HOME}/myapp"
  }
}
```

### 模块化配置

创建专门的配置模块：

```bash
# 创建 config/development.json
{
  "nodejs": {
    "version_manager": "fnm",
    "default_version": "18"
  },
  "python": {
    "version_manager": "pyenv",
    "default_version": "3.11"
  }
}
```

### 自定义生成器

扩展 `scripts/generate.py` 以支持更多功能：

```python
def generate_custom_config(self, config):
    """生成自定义配置文件"""
    # 添加你的自定义逻辑
    pass
```

### 集成其他工具

在配置中集成其他开发工具：

```json
{
  "tools": {
    "docker": {
      "compose_version": "v2",
      "default_network": "bridge"
    },
    "kubernetes": {
      "default_context": "local",
      "namespace": "default"
    }
  }
}
```

## 📚 参考资源

- [Jinja2 模板语法](https://jinja.palletsprojects.com/en/3.0.x/templates/)
- [Bash 脚本指南](https://www.gnu.org/software/bash/manual/)
- [PowerShell 文档](https://docs.microsoft.com/en-us/powershell/)
- [Git Bash 在 Windows 上的使用](https://git-scm.com/docs)

## 🤝 贡献

欢迎提交问题和改进建议！

---

**最后更新**: 2025-07-31  
**版本**: 1.0.0  
**兼容性**: Windows 11 + Git Bash + PowerShell 5.1+