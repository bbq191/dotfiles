# 📝 配置文件说明

> 本目录包含所有 dotfiles 的配置数据，采用 JSON 格式便于编辑和版本控制

## 📋 文件概述

| 文件 | 用途 | 包含内容 |
|------|------|----------|
| `shared.json` | 共享配置 | 用户信息、环境变量、路径、功能开关 |
| `aliases.json` | 别名定义 | 各种快捷命令别名，按 shell 分类 |
| `functions.json` | 函数定义 | 跨 shell 的自定义函数 |

## 🔧 shared.json 详解

### 用户信息 (user)
```json
{
  "user": {
    "name": "你的姓名",           // Git 提交时使用
    "email": "your@email.com",   // Git 提交邮箱  
    "editor": "code-insiders",   // 默认编辑器命令
    "browser": "chrome"          // 默认浏览器命令
  }
}
```

### 路径配置 (paths)
```json
{
  "paths": {
    "projects": "~/Projects",    // 项目根目录
    "dotfiles": "~/dotfiles",    // dotfiles 位置
    "tools": "~/tools"           // 工具目录
  }
}
```
这些路径会被导出为 `PATH_PROJECTS`, `PATH_DOTFILES` 等环境变量。

### 环境变量 (environment)
```json
{
  "environment": {
    "EDITOR": "code-insiders",         // 系统默认编辑器
    "BROWSER": "chrome",               // 系统默认浏览器
    "LANG": "zh_CN.UTF-8",             // 语言设置
    "XDG_CONFIG_HOME": "${HOME}/AppData/Local"  // 配置目录
  }
}
```

### 功能开关 (features)
```json
{
  "features": {
    "git_integration": true,     // 启用 Git 分支显示
    "nodejs_management": true,   // 启用 Node.js 版本管理
    "python_management": true,   // 启用 Python 环境管理
    "docker_support": true       // 启用 Docker 集成
  }
}
```

## ⚡ aliases.json 详解

### 结构说明
```json
{
  "category_name": {
    "alias_name": "command"
  },
  
  "shell_specific": {
    "bash": {
      "alias_name": "bash_command"
    },
    "powershell": {
      "alias_name": "powershell_command"  
    }
  }
}
```

### 示例配置
```json
{
  "navigation": {
    "..": "cd ..",                    // 上级目录
    "home": "cd ~",                   // 家目录
    "projects": "cd ~/Projects"       // 项目目录
  },
  
  "file_operations": {
    "bash": {
      "ll": "ls -alF",                // Bash: 详细列表
      "la": "ls -A"                   // Bash: 显示隐藏文件
    },
    "powershell": {
      "ll": "Get-ChildItem -Force",   // PowerShell: 详细列表
      "la": "Get-ChildItem -Force"    // PowerShell: 显示隐藏文件
    }
  }
}
```

## 🔨 functions.json 详解

### 结构说明
```json
{
  "function_name": {
    "description": "函数描述",
    "bash": "bash 版本的函数定义",
    "powershell": "PowerShell 版本的函数定义"
  }
}
```

### 示例配置
```json
{
  "mkcd": {
    "description": "创建目录并进入",
    "bash": "mkcd() { mkdir -p \"$1\" && cd \"$1\"; }",
    "powershell": "function mkcd($dir) { New-Item -ItemType Directory -Force -Path $dir | Set-Location }"
  },
  
  "backup": {
    "description": "备份文件",
    "bash": "backup() { cp \"$1\" \"$1.bak.$(date +%Y%m%d_%H%M%S)\"; }",
    "powershell": "function backup($file) { Copy-Item $file \"$file.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')\" }"
  }
}
```

## 🎨 自定义示例

### 添加开发环境别名
在 `aliases.json` 中添加：
```json
{
  "development": {
    "bash": {
      "gpp": "g++ -std=c++17 -Wall -Wextra",
      "serve8080": "python -m http.server 8080"
    },
    "powershell": {
      "gpp": "g++ -std=c++17 -Wall -Wextra", 
      "serve8080": "python -m http.server 8080"
    }
  }
}
```

### 添加网络工具函数
在 `functions.json` 中添加：
```json
{
  "myip": {
    "description": "获取公网 IP 地址",
    "bash": "myip() { curl -s ifconfig.me; }",
    "powershell": "function myip { (Invoke-WebRequest -Uri 'ifconfig.me').Content }"
  },
  
  "speedtest": {
    "description": "网络速度测试",
    "bash": "speedtest() { curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -; }",
    "powershell": "function speedtest { Invoke-WebRequest 'https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py' | python - }"  
  }
}
```

### 添加系统信息功能
在 `shared.json` 的 `features` 中添加：
```json
{
  "features": {
    "system_info": true,
    "network_tools": true,
    "backup_tools": true
  }
}
```

然后在模板中使用：
```bash
{% if config.shared.features.system_info %}
# 系统信息功能
sysinfo() {
    echo "系统: $(uname -a)"
    echo "内存: $(free -h)"
}
{% endif %}
```

## 📚 最佳实践

### 1. 命名规范
- 使用小写字母和下划线
- 别名保持简短（2-4 个字符）
- 函数使用描述性名称

### 2. 分类组织
- 按功能分类（navigation, git, development 等）
- 相关功能放在同一分类下
- 使用清晰的分类名称

### 3. 跨平台兼容
- 为不同 shell 提供等效的命令
- 考虑 Windows/Unix 路径差异
- 测试在两个环境中的表现

### 4. 文档化
- 为每个函数添加 description
- 使用注释说明复杂的配置
- 保持配置文件的可读性

## ⚠️ 注意事项

1. **JSON 格式**: 确保 JSON 语法正确，使用在线验证器检查
2. **字符转义**: 在 JSON 字符串中正确转义特殊字符
3. **路径分隔符**: 使用正斜杠 `/` 作为路径分隔符
4. **编码**: 使用 UTF-8 编码保存文件

## 🔄 更新流程

1. 编辑配置文件
2. 运行 `python ~/dotfiles/scripts/generate.py`
3. 重新加载配置 `reload`
4. 测试新配置

---
**提示**: 修改配置后别忘了重新生成和重新加载！