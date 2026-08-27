source /usr/share/cachyos-fish-config/cachyos-config.fish
# ↑ 已包含：eza/bat/grep 别名、fastfetch 欢迎、~/.local/bin PATH、!! !$ 历史补全

# ── XDG 基础目录（必须显式定义，systemd/fish 不会自动 export）──────────────────
set -gx XDG_DATA_HOME    $HOME/.local/share
set -gx XDG_CONFIG_HOME  $HOME/.config
set -gx XDG_CACHE_HOME   $HOME/.cache
set -gx XDG_STATE_HOME   $HOME/.local/state

# ── XDG 路径规范 ──────────────────────────────────────────────────────────────
set -gx CARGO_HOME       $HOME/.local/share/cargo
set -gx RUSTUP_HOME      $HOME/.local/share/rustup
set -gx PYENV_ROOT       $HOME/.local/share/pyenv
set -gx npm_config_cache $HOME/.cache/npm
set -gx CUDA_CACHE_PATH  $HOME/.cache/nvidia
set -gx WINEPREFIX       $HOME/.local/share/wine
set -gx GEMINI_CLI_HOME  $XDG_CONFIG_HOME/gemini
set -gx TEXMFHOME        $XDG_DATA_HOME/texmf
set -gx TEXMFVAR         $XDG_CACHE_HOME/texlive/texmf-var
set -gx TEXMFCONFIG      $XDG_CONFIG_HOME/texlive/texmf-config
set -gx GNUPGHOME        $XDG_DATA_HOME/gnupg
set -gx GOPATH           $XDG_DATA_HOME/go   # go 平时不装，但 paru 编译 go 写的 AUR 包会临时装并写缓存，没这行会落到 ~/go

# ── 环境变量 ──────────────────────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx OLLAMA_MODELS $HOME/.local/share/ollama/models
# systemd socket 激活的 ssh-agent（ssh-agent.socket）
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# ── 工具集成 ──────────────────────────────────────────────────────────────────
# fnm：Node 版本管理；非交互 shell（脚本、fish -c）也需要 node 在 PATH，放在 is-interactive 之外
fnm env --use-on-cd --shell fish | source

# 以下只对交互 shell 有意义，非交互时跳过以省启动开销
if status is-interactive
    # zoxide：智能 cd 替代品；z <模糊路径> 跳转，zi 打开 fzf 交互选择
    zoxide init fish | source

    # fzf 按键绑定：Ctrl+R 历史搜索 / Ctrl+T 文件选择 / Alt+C 目录跳转
    fzf --fish | source

    # Prompt
    starship init fish | source

    # SSH 密钥（按需加载）：rbw 已解锁时静默加载所有 Bitwarden SSH Key 条目；未解锁不打扰
    # git push/pull/fetch 时 functions/git.fish 会交互提示解锁
    if not ssh-add -l &>/dev/null
        rbw unlocked &>/dev/null && rbw-ssh-load &>/dev/null
    end
end
