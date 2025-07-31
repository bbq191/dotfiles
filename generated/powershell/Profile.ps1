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


# 代理设置
$env:HTTPS_PROXY = "http://127.0.0.1:6153"
$env:HTTP_PROXY = "http://127.0.0.1:6153"
$env:ALL_PROXY = "socks5://127.0.0.1:6153"
$env:NO_PROXY = "localhost,127.*,192.168.*,10.*,30.*,40.*,172.16.*,172.17.*,172.18.*,172.19.*,172.20.*,172.21.*,172.22.*,172.23.*,172.24.*,172.25.*,172.26.*,172.27.*,172.28.*,172.29.*,172.30.*,172.31.*"


# 基础系统环境变量

$env:EDITOR = "code-insiders"

$env:BROWSER = "brave"

$env:LANG = "zh_CN.UTF-8"

$env:XDG_CONFIG_HOME = "${HOME}/AppData/Local"


# 用户自定义环境变量
$env:DEFAULT_USER = $env:USERNAME
$env:MANWIDTH = "999"
$env:LESSHISTFILE = "-"

# =============================================================================
#                               2. XDG 目录规范
# =============================================================================

# 遵循 XDG Base Directory 规范

$env:XDG_CONFIG_HOME = "$HOME/AppData/Local"
$env:XDG_DATA_HOME = "$HOME/AppData/Local"
$env:XDG_STATE_HOME = "$HOME/AppData/Local"
$env:XDG_CACHE_HOME = "$HOME/AppData/Local/Temp"


# =============================================================================
#                               3. 开发环境配置
# =============================================================================

# Android 开发环境

$env:ANDROID_HOME = "$env:XDG_DATA_HOME/android"

$env:ANDROID_USER_HOME = "$env:XDG_DATA_HOME/android"

$env:ANDROID_SDK_ROOT = "$env:ANDROID_HOME"


# Go 语言环境

$env:GOPATH = "$env:XDG_DATA_HOME/go"

$env:GOMODCACHE = "$env:XDG_CACHE_HOME/go/mod"

$env:GOPROXY = "https://goproxy.cn,direct"


# Java 环境

$env:_JAVA_OPTIONS = "-Djava.util.prefs.userRoot=`"$env:XDG_CONFIG_HOME`"/java"


# Rust 环境

$env:CARGO_HOME = "$env:XDG_DATA_HOME/cargo"

$env:RUSTUP_HOME = "$env:XDG_DATA_HOME/rustup"


# Python 环境

$env:PYTHONPATH = "$env:XDG_DATA_HOME/python"

$env:PYTHONUSERBASE = "$env:XDG_DATA_HOME/python"

$env:PIPENV_VENV_IN_PROJECT = "1"


# Ruby 环境

$env:GEM_HOME = "$env:XDG_DATA_HOME/gem"

$env:GEM_SPEC_CACHE = "$env:XDG_CACHE_HOME/gem"


# Node.js 环境

$env:FNM_HOME = "$env:XDG_DATA_HOME/fnm"

$env:NPM_CONFIG_USERCONFIG = "$env:XDG_CONFIG_HOME/npm/config"

$env:NPM_CONFIG_CACHE = "$env:XDG_CACHE_HOME/npm"

$env:NPM_CONFIG_PREFIX = "$env:XDG_DATA_HOME/npm"

$env:PNPM_HOME = "$env:XDG_DATA_HOME/pnpm"

$env:YARN_CACHE_FOLDER = "$env:XDG_CACHE_HOME/yarn"


# Maven 环境

$env:MAVEN_OPTS = "-Dmaven.repo.local=$env:XDG_DATA_HOME/maven/repository"


# Gradle 环境

$env:GRADLE_USER_HOME = "$env:XDG_DATA_HOME/gradle"


# =============================================================================
#                               4. PATH 环境变量构建
# =============================================================================

# fnm (Fast Node Manager) 用于管理多个 Node.js 版本
$env:PATH = "C:\Users\afu\AppData\Local\fnm_multishells\23984_1753425089543;$env:PATH"
$env:FNM_MULTISHELL_PATH = "C:\Users\afu\AppData\Local\fnm_multishells\23984_1753425089543"
$env:FNM_VERSION_FILE_STRATEGY = "local"    # 使用本地 .node-version 文件
$env:FNM_DIR = "C:\Users\afu\AppData\Roaming\fnm"      # fnm 安装目录
$env:FNM_LOGLEVEL = "info"                  # 日志级别
$env:FNM_NODE_DIST_MIRROR = "https://nodejs.org/dist"       # Node.js 下载镜像
$env:FNM_COREPACK_ENABLED = "false"         # 禁用 Corepack
$env:FNM_RESOLVE_ENGINES = "true"           # 自动解析 engines 字段
$env:FNM_ARCH = "x64"                       # 系统架构

# Claude Code 工具的 Git Bash 路径配置
$env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Applications\DevEnvironment\Git\bin\bash.exe"

# MySQL 命令行工具路径
$env:MYSQL = "C:\Program Files\MySQL\MySQL Server 8.0\bin"

# 构建增强的 PATH（按优先级顺序）
$env:PATH = "$env:MYSQL;$env:PATH"

# =============================================================================
#                               5. PowerShell 历史记录增强配置
# =============================================================================

# PSReadLine 配置 - PowerShell 的现代化命令行体验
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    # 历史文件位置
    Set-PSReadLineOption -HistorySavePath "$env:USERPROFILE/dotfiles/generated/powershell/history"

    # 历史记录设置
    Set-PSReadLineOption -MaximumHistoryCount 10000

    # 启用历史预测（类似 ZSH autosuggestions）- 检查版本兼容性
    try {
        # PSReadLine 2.1.0+ 支持预测功能
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
    } catch {
        # 旧版本回退到基础历史搜索
        Write-Host "PSReadLine 版本较旧，启用基础历史功能" -ForegroundColor Yellow
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

# Ls 替代
if (Get-Command eza -ErrorAction SilentlyContinue) {
    
    # ls 是内置别名，使用函数覆盖
    function ll { eza -l --color=auto --group-directories-first @args }
    function la { eza -la --color=auto --group-directories-first @args }
    function lt { eza --tree --color=auto @args }
    

} else {
    # 使用传统命令作为回退
    
    function ll { Get-ChildItem @args | Format-Table -AutoSize }
    function la { Get-ChildItem -Force @args | Format-Table -AutoSize }
    function lt { Get-ChildItem @args | Format-Wide }
    

}


# Cat 替代
if (Get-Command bat -ErrorAction SilentlyContinue) {
    
    # cat 是内置别名，使用函数覆盖
    function bat { bat @args }
    function catn { bat --style=plain @args }
    

}


# Grep 替代
if (Get-Command rg -ErrorAction SilentlyContinue) {
    
    # 其他工具设置别名
    
    
    Set-Alias -Name grep -Value rg
    
    
    

}


# Find 替代
if (Get-Command fd -ErrorAction SilentlyContinue) {
    
    # 其他工具设置别名
    
    
    Set-Alias -Name find -Value fd
    
    
    

}


# Du 替代
if (Get-Command dust -ErrorAction SilentlyContinue) {
    
    # 其他工具设置别名
    
    
    Set-Alias -Name du -Value dust
    
    
    

}


# Df 替代
if (Get-Command duf -ErrorAction SilentlyContinue) {
    
    function df { duf @args }
    

} else {
    # 使用传统命令作为回退
    
    function df { Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}} }
    

}


# Ps 替代
if (Get-Command procs -ErrorAction SilentlyContinue) {
    
    # 其他工具设置别名
    
    
    Set-Alias -Name ps -Value procs
    
    
    

}


# Top 替代
if (Get-Command htop -ErrorAction SilentlyContinue) {
    
    # 其他工具设置别名
    
    
    Set-Alias -Name top -Value htop
    
    
    

}


# Cd 替代
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    
    # cd 使用 zoxide，需要特殊处理
    # 在外部工具初始化部分处理
    

}



# =============================================================================
#                               7. FZF 集成配置
# =============================================================================


# FZF 环境变量配置
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
    $env:FZF_CTRL_T_COMMAND = "fd --type f --hidden --follow --exclude .git"
    $env:FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git"
} else {
    $env:FZF_DEFAULT_COMMAND = "find . -type f -not -path '*/\.git/*'"
    $env:FZF_CTRL_T_COMMAND = "find . -type f -not -path '*/\.git/*'"
    $env:FZF_ALT_C_COMMAND = "find . -type d -not -path '*/\.git/*'"
}

# FZF 主题配置
$env:FZF_DEFAULT_OPTS = "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#8be9fd,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --height=60% --layout=reverse --border --margin=1 --padding=1"

# FZF 预览配置
if (Get-Command bat -ErrorAction SilentlyContinue) {
    $env:FZF_CTRL_T_OPTS = "--preview 'bat -n --color=always --line-range :500 {}'"
} else {
    $env:FZF_CTRL_T_OPTS = "--preview 'cat {}'"
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    $env:FZF_ALT_C_OPTS = "--preview 'eza --tree --color=always {} | head -200'"
} elseif (Get-Command tree -ErrorAction SilentlyContinue) {
    $env:FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'"
} else {
    $env:FZF_ALT_C_OPTS = "--preview 'ls -la {}'"
}



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

function gs { git status @args }

function ga { git add @args }

function gaa { git add --all @args }

function gc { git commit -m @args }

function gca { git commit --amend @args }

function gp { git push @args }

function gl { git log --oneline @args }

function gco { git checkout @args }

function gb { git branch @args }

function gd { git diff @args }

function gds { git diff --staged @args }


# 扩展 Git 别名
function gcb { git checkout -b @args }
function gst { git stash @args }
function gsta { git stash apply @args }
function glg { git log --oneline --decorate --graph @args }
function glog { git log --oneline --decorate --graph --all @args }

# 编辑器别名
Set-Alias -Name vim -Value code-insiders
Set-Alias -Name vi -Value code-insiders

# Python 工具
Set-Alias -Name py -Value python
Set-Alias -Name py3 -Value python3
Set-Alias -Name pip -Value pip3

# 导航别名


function .. { Set-Location .. }



function ... { Set-Location ../.. }



function .... { Set-Location ../../.. }



function ~ { Set-Location $env:USERPROFILE }



function projects { Set-Location "~/Projects" }



function dotfiles { Set-Location "~/dotfiles" }



# 系统别名（PowerShell 版本）
Set-Alias -Name open -Value explorer
function which { Get-Command @args | Select-Object -ExpandProperty Definition }

# =============================================================================
#                               9. 高级函数定义
# =============================================================================


# 创建目录并进入
function mkcd {
    
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
    
}


# 智能提取各种压缩格式
function extract {
    
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
    
}


# 杀死占用指定端口的进程
function killport {
    
    param([int]$Port)
    if ($Port -eq 0) {
        Write-Host "用法: killport <端口号>"
        return
    }
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force
    }
    
}


# 快速启动 HTTP 服务器
function serve {
    
    param([int]$Port = 8000)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $Port
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m http.server $Port
    } else {
        Write-Host "需要安装 Python"
    }
    
}


# 获取天气信息
function weather {
    
    param([string]$Location = "Beijing")
    Invoke-RestMethod -Uri "wttr.in/$Location?lang=zh"
    
}


# 获取公网 IP 地址
function myip {
    
    (Invoke-RestMethod -Uri "http://ipinfo.io/ip").Trim()
    
}


# 显示端口使用情况
function ports {
    
    Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"} | Select-Object LocalAddress, LocalPort, State | Sort-Object LocalPort
    
}


# 显示内存占用最高的进程
function psmem {
    
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    
}


# 显示 CPU 占用最高的进程
function pscpu {
    
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    
}


# 快速查找文件
function findfile {
    
    param([string]$Pattern)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd -t f $Pattern
    } else {
        Get-ChildItem -Recurse -File -Name "*$Pattern*" 2>$null
    }
    
}


# 快速查找目录
function finddir {
    
    param([string]$Pattern)
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd -t d $Pattern
    } else {
        Get-ChildItem -Recurse -Directory -Name "*$Pattern*" 2>$null
    }
    
}


# 备份文件
function backup {
    
    param([string]$FilePath)
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $FilePath "$FilePath.bak.$timestamp"
    
}


# 清理已合并的 Git 分支
function gitclean {
    
    git branch --merged | Where-Object { $_ -notmatch '\*|main|master|develop' } | ForEach-Object { git branch -d $_.Trim() }
    
}


# 重新加载 shell 配置
function reload {
    
    . $PROFILE
    Write-Host "PowerShell 配置已重新加载"
    
}


# 显示系统信息
function sysinfo {
    
    Write-Host "=== 系统信息 ==="
    Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory
    Write-Host ""
    Write-Host "=== 内存使用 ==="
    free
    Write-Host ""
    Write-Host "=== 磁盘使用 ==="
    df
    
}



# =============================================================================
#                               10. 外部工具自动初始化
# =============================================================================

# 检查并初始化常用工具

if (Get-Command thefuck -ErrorAction SilentlyContinue) {
    
}

if (Get-Command gh_copilot -ErrorAction SilentlyContinue) {
    
}

if (Get-Command fnm -ErrorAction SilentlyContinue) {
    
    fnm env --use-on-cd | Out-String | Invoke-Expression
    
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    
    Invoke-Expression (&starship init powershell)
    
}

if (Get-Command atuin -ErrorAction SilentlyContinue) {
    
    Invoke-Expression (atuin init powershell --disable-up-arrow | Out-String)
    
}


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



# =============================================================================
#                               13. 性能优化
# =============================================================================

# 编译优化

$env:MAKEFLAGS = "-j$env:NUMBER_OF_PROCESSORS"


# =============================================================================
#                               14. Windows 特定设置
# =============================================================================

# Windows 增强设置
$env:BROWSER = "brave.exe"

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
Write-Host "📁 项目目录: ~/Projects" -ForegroundColor Green
Write-Host "⚡ 编辑器: code-insiders" -ForegroundColor Yellow
$modernTools = @()
if (Get-Command eza -ErrorAction SilentlyContinue) { $modernTools += "eza" } else { $modernTools += "ls" }
if (Get-Command bat -ErrorAction SilentlyContinue) { $modernTools += "bat" } else { $modernTools += "cat" }
if (Get-Command fd -ErrorAction SilentlyContinue) { $modernTools += "fd" } else { $modernTools += "find" }
Write-Host "🔧 现代工具: $($modernTools -join ', ')" -ForegroundColor Magenta

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