# ⚡ 快速设置指南

> 5 分钟内配置完成统一的 PowerShell/Bash 环境

## 🚀 立即开始

### 1. 重新生成配置（必需）
```bash
python ~/dotfiles/scripts/generate.py
```

### 2. 重新加载配置
```bash
# Bash
source ~/.bash_profile

# PowerShell  
. $PROFILE
```

### 3. 验证安装
```bash
ll          # 测试文件列表
gs          # 测试 Git 状态
mkcd test   # 测试创建目录函数
```

## 📝 快速自定义

### 修改用户信息
编辑 `config/shared.json`：
```json
{
  "user": {
    "name": "YourName",
    "email": "your@email.com",
    "editor": "code",
    "browser": "chrome"
  }
}
```

### 添加新别名
编辑 `config/aliases.json`：
```json
{
  "my_aliases": {
    "mycommand": "echo hello"
  }
}
```

### 添加新函数
编辑 `config/functions.json`：
```json
{
  "myfunc": {
    "description": "我的函数",
    "bash": "myfunc() { echo \"Hello $1\"; }",
    "powershell": "function myfunc($name) { Write-Host \"Hello $name\" }"
  }
}
```

## 🔄 更新流程

1. **编辑配置** → `config/*.json`
2. **重新生成** → `python ~/dotfiles/scripts/generate.py` 
3. **重新加载** → `reload`

## 🆘 故障排除

**配置不生效？**
```bash
# 检查文件是否生成
ls ~/dotfiles/generated/bash/bashrc
ls ~/dotfiles/generated/powershell/Profile.ps1

# 手动重新加载
source ~/.bash_profile    # Bash
. $PROFILE               # PowerShell
```

**Python 错误？**
```bash
# 安装依赖
python -m pip install --user jinja2

# 检查 Python 版本
python --version  # 需要 3.7+
```

**PowerShell 报错？**
```powershell
# 检查执行策略
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📋 可用命令一览

| 分类 | 命令 | 说明 |
|------|------|------|
| **导航** | `..`, `...`, `~` | 快速目录切换 |
| | `projects`, `dotfiles` | 跳转常用目录 |
| **文件** | `ll`, `la`, `l` | 文件列表 |
| **Git** | `gs`, `ga`, `gc`, `gp` | Git 快捷操作 |
| **开发** | `py`, `pip`, `serve` | Python 工具 |
| **函数** | `mkcd`, `weather`, `ports` | 实用函数 |
| **系统** | `open`, `reload` | 系统操作 |

## 🎯 下一步

- 阅读完整文档：`README.md`
- 查看注释版本：`scripts/generate_commented.py`
- 自定义模板：`templates/`

---
**提示**: 使用 `reload` 命令快速重新加载配置！