# =============================================================================
#                  增强的 PowerShell 配置文件 - 融合 ZSH 功能
# =============================================================================
# 由 dotfiles 生成器自动生成，请勿手动编辑
# 基于 Arch Linux .zshrc 的功能完全移植到 PowerShell
# 生成时间: $(Get-Date)
# 模板版本: 2.0.0 (ZSH Enhanced)

# =============================================================================
#                               1. 基础环境设置
# =============================================================================

{% if config.zsh_integration.proxy.enabled %}
# 代理设置
$env:HTTPS_PROXY = "{{ config.zsh_integration.proxy.settings.https_proxy }}"
$env:HTTP_PROXY = "{{ config.zsh_integration.proxy.settings.http_proxy }}"
$env:ALL_PROXY = "{{ config.zsh_integration.proxy.settings.all_proxy }}"
$env:NO_PROXY = "{{ config.zsh_integration.proxy.settings.no_proxy }}"
{% endif %}

# 基础系统环境变量
{% for key, value in config.shared.environment.items() %}
$env:{{ key }} = "{{ value }}"
{% endfor %}

# 用户自定义环境变量
$env:DEFAULT_USER = $env:USERNAME
$env:MANWIDTH = "999"
$env:LESSHISTFILE = "-"

# =============================================================================
#                               2. XDG 目录规范
# =============================================================================
{% if config.zsh_integration.xdg_directories.enabled %}
# 遵循 XDG Base Directory 规范

$env:XDG_CONFIG_HOME = "{{ config.zsh_integration.xdg_directories.config_home }}"
$env:XDG_DATA_HOME = "{{ config.zsh_integration.xdg_directories.data_home }}"
$env:XDG_STATE_HOME = "{{ config.zsh_integration.xdg_directories.state_home }}"
$env:XDG_CACHE_HOME = "{{ config.zsh_integration.xdg_directories.cache_home }}"
{% endif %}

# =============================================================================
#                               3. 版本管理器初始化
# =============================================================================

{% if config.zsh_integration.version_managers.fnm.enabled %}
# fnm (Node.js 版本管理)
{% for key, value in config.zsh_integration.version_managers.fnm.env_vars.items() %}
$env:{{ key }} = "{{ value }}"
{% endfor %}
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}
{% endif %}

{% if config.zsh_integration.version_managers.pyenv.enabled %}
# pyenv-win (Python 版本管理)
{% for key, value in config.zsh_integration.version_managers.pyenv.env_vars.items() %}
{% if value is mapping %}
$env:{{ key }} = "{{ value.powershell }}"
{% else %}
$env:{{ key }} = "{{ value }}"
{% endif %}
{% endfor %}
# pyenv-win 不需要初始化命令，只需要正确的 PATH 和环境变量
{% endif %}

{% if config.zsh_integration.version_managers.jabba.enabled %}
# jabba (Java 版本管理)
{% for key, value in config.zsh_integration.version_managers.jabba.env_vars.items() %}
{% if value is mapping %}
$env:{{ key }} = "{{ value.powershell }}"
{% else %}
$env:{{ key }} = "{{ value }}"
{% endif %}
{% endfor %}
# jabba-win 不需要 jabba.sh，只需要正确的 PATH
{% endif %}

{% if config.zsh_integration.version_managers.g.enabled %}
# g (Go 版本管理)
{% for key, value in config.zsh_integration.version_managers.g.env_vars.items() %}
{% if value is mapping %}
$env:{{ key }} = "{{ value.powershell }}"
{% else %}
$env:{{ key }} = "{{ value }}"
{% endif %}
{% endfor %}
{% endif %}

# =============================================================================
#                               4. 开发环境配置
# =============================================================================

# Android 开发环境
{% for key, value in config.zsh_integration.development_environments.android.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME').replace('$ANDROID_HOME', '$env:ANDROID_HOME') }}"
{% endfor %}

# Go 语言环境
{% for key, value in config.zsh_integration.development_environments.go.items() %}
$env:{{ key }} = "{{ value }}"
{% endfor %}

# Java 环境
{% for key, value in config.zsh_integration.development_environments.java.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_CONFIG_HOME', '$env:XDG_CONFIG_HOME').replace('\"', '`"') }}"
{% endfor %}

# Rust 环境
{% for key, value in config.zsh_integration.development_environments.rust.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME') }}"
{% endfor %}

# Python 环境
{% for key, value in config.zsh_integration.development_environments.python.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME') }}"
{% endfor %}

# Ruby 环境
{% for key, value in config.zsh_integration.development_environments.ruby.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME').replace('$XDG_CACHE_HOME', '$env:XDG_CACHE_HOME') }}"
{% endfor %}

# Node.js 环境
{% for key, value in config.zsh_integration.development_environments.node.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME').replace('$XDG_CONFIG_HOME', '$env:XDG_CONFIG_HOME').replace('$XDG_CACHE_HOME', '$env:XDG_CACHE_HOME') }}"
{% endfor %}

# Maven 环境
{% for key, value in config.zsh_integration.development_environments.maven.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME') }}"
{% endfor %}

# Gradle 环境
{% for key, value in config.zsh_integration.development_environments.gradle.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME') }}"
{% endfor %}

# MySQL 环境
{% for key, value in config.zsh_integration.development_environments.mysql.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME') }}"
{% endfor %}

# vscode 环境
{% for key, value in config.zsh_integration.development_environments.vscode.items() %}
$env:{{ key }} = "{{ value.replace('$XDG_DATA_HOME', '$env:XDG_DATA_HOME') }}"
{% endfor %}

# pyenv 环境
{% for key, value in config.zsh_integration.development_environments.pyenv.items() %}
$env:{{ key }} = "{{ value.powershell }}"
{% endfor %}

# miller 环境
{% for key, value in config.zsh_integration.development_environments.miller.items() %}
$env:{{ key }} = "{{ value.powershell }}"
{% endfor %}

# github cli 环境
{% for key, value in config.zsh_integration.development_environments.github_cli.items() %}
$env:{{ key }} = "{{ value.powershell }}"
{% endfor %}

# claude code 环境
{% for key, value in config.zsh_integration.development_environments.claude_code.items() %}
$env:{{ key }} = "{{ value }}"
{% endfor %}

# =============================================================================
#                               5. PATH 环境变量构建
# =============================================================================

# 构建增强的 PATH（按优先级顺序）
$pathParts = @()

# 版本管理器路径
{% if config.zsh_integration.version_managers.pyenv.enabled %}
{% for path in config.zsh_integration.version_managers.pyenv.path_additions %}
$pathParts += "{{ path.replace('$PYENV_ROOT', '$env:PYENV_ROOT') }}"
{% endfor %}
{% endif %}

{% if config.zsh_integration.version_managers.jabba.enabled %}
{% for path in config.zsh_integration.version_managers.jabba.path_additions %}
$pathParts += "{{ path.replace('$JABBA_HOME', '$env:JABBA_HOME') }}"
{% endfor %}
{% endif %}

{% if config.zsh_integration.version_managers.g.enabled %}
{% for path in config.zsh_integration.version_managers.g.path_additions %}
$pathParts += "{{ path.replace('$G_HOME', '$env:G_HOME').replace('$GOROOT', '$env:GOROOT') }}"
{% endfor %}
{% endif %}

# 开发环境路径
$pathParts += "$env:EDITOR_HOME\bin"
$pathParts += "$env:MYSQL_HOME\bin" 
$pathParts += "C:\Applications\DevEnvironment\miller\miller-6.13.0-windows-amd64"
$pathParts += "C:\Applications\DevEnvironment\github-cli"

# 合并路径
$newPath = ($pathParts + $env:PATH.Split(';')) -join ';'
$env:PATH = $newPath

# =============================================================================
#                               5. PowerShell 历史记录增强配置
# =============================================================================

# PSReadLine 配置 - PowerShell 的现代化命令行体验
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    # 历史文件位置
    Set-PSReadLineOption -HistorySavePath "{{ config.zsh_integration.history_advanced.file.replace('bash', 'powershell').replace('$HOME', '$env:USERPROFILE') }}"

    # 历史记录设置
    Set-PSReadLineOption -MaximumHistoryCount {{ config.zsh_integration.history_advanced.size }}

    # 启用历史预测（类似 ZSH autosuggestions）- 检查版本兼容性
    $psReadLineVersion = (Get-Module PSReadLine).Version
    if ($psReadLineVersion -and $psReadLineVersion -ge [Version]"2.1.0") {
        # PSReadLine 2.1.0+ 支持预测功能
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
    }

    # 历史搜索和补全选项
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -ContinuationPrompt "  "

    # 编辑模式
    Set-PSReadLineOption -EditMode Windows

    # 禁用铃声
    Set-PSReadLineOption -BellStyle None
}

# =============================================================================
#                               6. 现代化工具集成（别名）
# =============================================================================

# 现代化命令替代（智能检测和回退）- 避免内置别名冲突
{% for tool_name, tool_config in config.zsh_integration.modern_tools.replacements.items() %}
# {{ tool_name|title }} 替代
if (Get-Command {{ tool_config.tool }} -ErrorAction SilentlyContinue) {
    {% if tool_name == "ls" %}
    # ls 是内置别名，使用函数覆盖
    function ll { {{ tool_config.tool }} -l --color=auto --group-directories-first @args }
    function la { {{ tool_config.tool }} -la --color=auto --group-directories-first @args }
    function lt { {{ tool_config.tool }} --tree --color=auto @args }
    {% elif tool_name == "cat" %}
    # cat 是内置别名，使用函数覆盖
    function bat { {{ tool_config.tool }} @args }
    function catn { {{ tool_config.tool }} --style=plain @args }
    {% elif tool_name == "df" %}
    function df { {{ tool_config.tool }} @args }
    {% elif tool_name == "cd" %}
    # cd 使用 zoxide，需要特殊处理
    # 在外部工具初始化部分处理
    {% else %}
    # 其他工具设置别名
    {% for alias_name, alias_command in tool_config.aliases.items() %}
    {% if alias_name not in ["ls", "ll", "la", "lt", "cat", "catn", "bat", "df", "cd", "cls", "start"] %}
    Set-Alias -Name {{ alias_name }} -Value {{ tool_config.tool }}
    {% endif %}
    {% endfor %}
    {% endif %}
{% if tool_config.fallback is defined %}
} else {
    # 使用传统命令作为回退
    {% if tool_name == "ls" %}
    function ll { Get-ChildItem @args | Format-Table -AutoSize }
    function la { Get-ChildItem -Force @args | Format-Table -AutoSize }
    function lt { Get-ChildItem @args | Format-Wide }
    {% elif tool_name == "df" %}
    function df { Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}} }
    {% endif %}
{% endif %}
}

{% endfor %}

# =============================================================================
#                               7. FZF 集成配置
# =============================================================================
{% if config.zsh_integration.fzf_config.enabled %}

# FZF 环境变量配置
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = "{{ config.zsh_integration.fzf_config.commands.default }}"
    $env:FZF_CTRL_T_COMMAND = "{{ config.zsh_integration.fzf_config.commands.ctrl_t }}"
    $env:FZF_ALT_C_COMMAND = "{{ config.zsh_integration.fzf_config.commands.alt_c }}"
} else {
    $env:FZF_DEFAULT_COMMAND = "{{ config.zsh_integration.fzf_config.commands.fallback_default }}"
    $env:FZF_CTRL_T_COMMAND = "{{ config.zsh_integration.fzf_config.commands.fallback_ctrl_t }}"
    $env:FZF_ALT_C_COMMAND = "{{ config.zsh_integration.fzf_config.commands.fallback_alt_c }}"
}

# FZF 主题配置
$env:FZF_DEFAULT_OPTS = "{{ config.zsh_integration.fzf_config.theme.colors }} {{ config.zsh_integration.fzf_config.theme.layout }}"

# FZF 预览配置
if (Get-Command bat -ErrorAction SilentlyContinue) {
    $env:FZF_CTRL_T_OPTS = "{{ config.zsh_integration.fzf_config.preview.ctrl_t }}"
} else {
    $env:FZF_CTRL_T_OPTS = "{{ config.zsh_integration.fzf_config.preview.ctrl_t_fallback }}"
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    $env:FZF_ALT_C_OPTS = "{{ config.zsh_integration.fzf_config.preview.alt_c }}"
} elseif (Get-Command tree -ErrorAction SilentlyContinue) {
    $env:FZF_ALT_C_OPTS = "{{ config.zsh_integration.fzf_config.preview.alt_c_fallback }}"
} else {
    $env:FZF_ALT_C_OPTS = "{{ config.zsh_integration.fzf_config.preview.alt_c_final_fallback }}"
}

{% endif %}

# =============================================================================
#                               8. 别名定义
# =============================================================================

# 安全操作别名（PowerShell 版本）
function cp { Copy-Item @args -Confirm }
function mv { Move-Item @args -Confirm }
function rm { Remove-Item @args -Confirm }

# 系统信息别名
function free { Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object @{Name="FreePhysicalMemory(MB)";Expression={[math]::Round($_.FreePhysicalMemory/1KB,2)}}, @{Name="TotalPhysicalMemory(MB)";Expression={[math]::Round($_.TotalVisibleMemorySize/1KB,2)}} }
function df { Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}, @{Name="Total(GB)";Expression={[math]::Round(($_.Used+$_.Free)/1GB,2)}} }

# Git 增强别名
Set-Alias -Name g -Value git
{% for alias, command in config.aliases.git.items() %}
function {{ alias }} { git {{ command.replace('git ', '') }} @args }
{% endfor %}

# 扩展 Git 别名
function gcb { git checkout -b @args }
function gst { git stash @args }
function gsta { git stash apply @args }
function glg { git log --oneline --decorate --graph @args }
function glog { git log --oneline --decorate --graph --all @args }

# 编辑器别名
Set-Alias -Name vim -Value {{ config.shared.user.editor }}
Set-Alias -Name vi -Value {{ config.shared.user.editor }}

# Python 工具
Set-Alias -Name py -Value python
Set-Alias -Name py3 -Value python3
Set-Alias -Name pip -Value pip3

# 导航别名
{% for alias, command in config.aliases.navigation.items() %}
{% if alias == ".." %}
function .. { Set-Location .. }
{% elif alias == "..." %}
function ... { Set-Location ../.. }
{% elif alias == "...." %}
function .... { Set-Location ../../.. }
{% elif alias == "~" %}
function ~ { Set-Location $env:USERPROFILE }
{% else %}
function {{ alias }} { Set-Location "{{ command.replace('cd ', '') }}" }
{% endif %}
{% endfor %}

# 系统别名（PowerShell 版本）
Set-Alias -Name open -Value explorer
function which { Get-Command @args | Select-Object -ExpandProperty Definition }

# =============================================================================
#                               9. 高级函数定义
# =============================================================================

{% for name, func in config.advanced_functions.items() %}
# {{ func.description }}
function {{ name }} {
    {% if name == "mkcd" %}
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
    {% elif name == "extract" %}
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
        switch ($ext) {
            ".zip" { Expand-Archive -Path $FilePath -DestinationPath . }
            ".7z" { & 7z x $FilePath }
            ".rar" { & unrar x $FilePath }
            default { Write-Host "'$FilePath' 无法被 extract() 提取" }
        }
    } else {
        Write-Host "'$FilePath' 不是有效文件"
    }
    {% elif name == "killport" %}
    param([int]$Port)
    if ($Port -eq 0) {
        Write-Host "用法: killport <端口号>"
        return
    }
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force
    }
    {% elif name == "serve" %}
    param([int]$Port = 8000)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $Port
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m http.server $Port
    } else {
        Write-Host "需要安装 Python"
    }
    {% elif name == "weather" %}
    param([string]$Location = "Beijing")
    Invoke-RestMethod -Uri "wttr.in/$Location?lang=zh"
    {% elif name == "myip" %}
    (Invoke-RestMethod -Uri "http://ipinfo.io/ip").Trim()
    {% elif name == "ports" %}
    Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"} | Select-Object LocalAddress, LocalPort, State | Sort-Object LocalPort
    {% elif name == "psmem" %}
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    {% elif name == "pscpu" %}
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    {% elif name == "findfile" %}
    param([string]$Pattern)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd -t f $Pattern
    } else {
        Get-ChildItem -Recurse -File -Name "*$Pattern*" 2>$null
    }
    {% elif name == "finddir" %}
    param([string]$Pattern)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd -t d $Pattern
    } else {
        Get-ChildItem -Recurse -Directory -Name "*$Pattern*" 2>$null
    }
    {% elif name == "backup" %}
    param([string]$FilePath)
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $FilePath "$FilePath.bak.$timestamp"
    {% elif name == "gitclean" %}
    git branch --merged | Where-Object { $_ -notmatch '\*|main|master|develop' } | ForEach-Object { git branch -d $_.Trim() }
    {% elif name == "reload" %}
    . $PROFILE
    Write-Host "PowerShell 配置已重新加载"
    {% elif name == "sysinfo" %}
    Write-Host "=== 系统信息 ==="
    Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory
    Write-Host ""
    Write-Host "=== 内存使用 ==="
    free
    Write-Host ""
    Write-Host "=== 磁盘使用 ==="
    df
    {% endif %}
}

{% endfor %}

# =============================================================================
#                               10. 外部工具自动初始化
# =============================================================================

# 检查并初始化常用工具
{% for tool, init_command in config.zsh_integration.external_tools.auto_init.items() %}
if (Get-Command {{ tool.split()[0] if ' ' in tool else tool }} -ErrorAction SilentlyContinue) {
    {% if tool == "fnm" %}
    fnm env --use-on-cd | Out-String | Invoke-Expression
    {% elif tool == "zoxide" %}
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    {% elif tool == "starship" %}
    Invoke-Expression (&starship init powershell)
    {% elif tool == "atuin" %}
    Invoke-Expression (atuin init powershell --disable-up-arrow | Out-String)
    {% endif %}
}
{% endfor %}

# =============================================================================
#                               11. 按键绑定增强
# =============================================================================

# PSReadLine 键绑定
if (Get-Module -ListAvailable -Name PSReadLine) {
    # 历史搜索绑定
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # 单词导航
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function NextWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord

    # 行导航
    Set-PSReadLineKeyHandler -Key Delete -Function DeleteChar
    Set-PSReadLineKeyHandler -Key Home -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key End -Function EndOfLine

    # Tab 补全增强
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # FZF 键绑定 (如果 FZF 可用) - 使用小写语法确保兼容性
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        # Ctrl+T - 文件搜索
        Set-PSReadLineKeyHandler -Key "ctrl+t" -ScriptBlock {
            try {
                # 执行文件搜索
                if ($env:FZF_CTRL_T_COMMAND) {
                    if ($env:FZF_CTRL_T_COMMAND -like "*Get-ChildItem*") {
                        # PowerShell 方式
                        $files = Invoke-Expression $env:FZF_CTRL_T_COMMAND | Select-Object -First 1000
                    } else {
                        # fd 方式
                        $files = & cmd.exe /c $env:FZF_CTRL_T_COMMAND 2>$null
                    }

                    if ($files) {
                        # 使用 FZF 选择文件
                        $selection = $files | fzf --preview "bat --color=always --style=numbers --line-range=:500 {}" --preview-window right:50%:wrap

                        if ($selection) {
                            # 如果选择的路径包含空格，添加引号
                            if ($selection -match '\s') {
                                $selection = "`"$selection`""
                            }

                            # 插入选择的文件路径
                            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
                        }
                    }
                }
            } catch {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("# 文件搜索错误: $($_.Exception.Message)")
            }
        } -Description "FZF 文件搜索"

        # Alt+C - 目录搜索
        Set-PSReadLineKeyHandler -Key "alt+c" -ScriptBlock {
            try {
                # 执行目录搜索
                if ($env:FZF_ALT_C_COMMAND) {
                    if ($env:FZF_ALT_C_COMMAND -like "*Get-ChildItem*") {
                        # PowerShell 方式
                        $dirs = Invoke-Expression $env:FZF_ALT_C_COMMAND | Select-Object -First 1000
                    } else {
                        # fd 方式
                        $dirs = & cmd.exe /c $env:FZF_ALT_C_COMMAND 2>$null
                    }

                    if ($dirs) {
                        # 使用 FZF 选择目录
                        $selection = $dirs | fzf --preview "eza -la --color=always {}" --preview-window right:50%:wrap

                        if ($selection) {
                            # 切换到选择的目录
                            Set-Location $selection
                            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
                        }
                    }
                }
            } catch {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("# 目录搜索错误: $($_.Exception.Message)")
            }
        } -Description "FZF 目录搜索"

        # Ctrl+R - 历史搜索
        Set-PSReadLineKeyHandler -Key "ctrl+r" -ScriptBlock {
            try {
                # 获取 PowerShell 历史
                $history = Get-History | Select-Object -ExpandProperty CommandLine | Sort-Object -Unique

                if ($history) {
                    # 使用 FZF 选择历史命令
                    $selection = $history | fzf --tac --no-sort --preview "echo {}" --preview-window down:3:wrap

                    if ($selection) {
                        # 清除当前行并插入选择的命令
                        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
                    }
                }
            } catch {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("# 历史搜索错误: $($_.Exception.Message)")
            }
        } -Description "FZF 历史搜索"
    }
}

# =============================================================================
#                               12. Git 集成增强
# =============================================================================
{% if config.shared.features.git_integration %}

# Git 分支显示函数
function Get-GitBranch {
    try {
        if (!(Get-Command git -ErrorAction SilentlyContinue)) {
            return ""
        }

        if (!(git rev-parse --git-dir 2>$null)) {
            return ""
        }

        $branch = git symbolic-ref --short HEAD 2>$null
        if (!$branch) {
            $branch = git describe --tags --ezact-match 2>$null
            if (!$branch) {
                $branch = git rev-parse --short HEAD 2>$null
            }
        }

        if ($branch) {
            $status = ""
            $ahead = ""

            # 检查工作区状态
            if (git status --porcelain 2>$null) {
                $status = "*"
            }

            # 检查提交领先状态
            try {
                git rev-parse --verify '@{upstream}' 2>$null | Out-Null
                $aheadCount = git rev-list --count '@{upstream}..HEAD' 2>$null
                if ($aheadCount -and $aheadCount -gt 0) {
                    $ahead = "↑$aheadCount"
                }
            } catch {}

            return "($branch$status$ahead)"
        }
    } catch {}
    return ""
}

# 自定义提示符函数
function prompt {
    $gitBranch = Get-GitBranch
    $location = $ExecutionContext.SessionState.Path.CurrentLocation
    $userPart = "$env:USERNAME@$env:COMPUTERNAME"

    # 基础提示符
    Write-Host "$userPart" -ForegroundColor Green -NoNewline
    Write-Host ":" -NoNewline
    Write-Host "$location" -ForegroundColor Blue -NoNewline

    # Git 分支显示
    if ($gitBranch) {
        Write-Host "$gitBranch" -ForegroundColor Yellow -NoNewline
    }

    return "$ "
}

{% endif %}

# =============================================================================
#                               13. 性能优化
# =============================================================================

# 编译优化
{% if config.zsh_integration.performance.makeflags %}
$env:MAKEFLAGS = "{{ config.zsh_integration.performance.makeflags.replace('$(nproc)', '$env:NUMBER_OF_PROCESSORS') }}"
{% endif %}

# =============================================================================
#                               14. Windows 特定设置
# =============================================================================

# Windows 增强设置
$env:BROWSER = "{{ config.shared.user.browser }}.exe"

# Windows 系统别名 - 避免内置别名冲突
# start, cls 是内置别名，跳过设置
Set-Alias -Name notepad -Value notepad.exe

# Windows 特定的服务管理
function services { services.msc }
function regedit { regedit.exe }

# =============================================================================
#                               15. 启动消息和状态
# =============================================================================

# 启动消息
Write-Host "🚀 增强 PowerShell 环境已加载 - 融合 ZSH 功能" -ForegroundColor Cyan
# 显示可用功能
Write-Host ""
Write-Host "💡 增强功能:" -ForegroundColor White
Write-Host "   📂 现代文件操作: ll, la, lt" -ForegroundColor Gray
Write-Host "   🔍 智能搜索: PSReadLine 历史建议" -ForegroundColor Gray
Write-Host "   🌐 网络工具: myip, weather, ports" -ForegroundColor Gray
Write-Host "   🛠️  系统工具: sysinfo, psmem, pscpu" -ForegroundColor Gray
Write-Host "   🔧 开发工具: extract, killport, serve" -ForegroundColor Gray
Write-Host "   📦 Git 增强: 分支状态显示" -ForegroundColor Gray
Write-Host ""

# =============================================================================
#                               16. 自定义配置加载
# =============================================================================

# 加载本地自定义配置（如果存在）
$localProfile = "$env:USERPROFILE\.powershell_profile.local.ps1"
if (Test-Path $localProfile) {
    Write-Host "🔧 加载本地自定义配置..." -ForegroundColor Yellow
    . $localProfile
}

# 标记配置加载完成
$env:DOTFILES_ENHANCED_POWERSHELL_LOADED = "1"