source /usr/share/cachyos-fish-config/cachyos-config.fish
# ↑ 已包含：eza/bat/grep 别名、fastfetch 欢迎、~/.local/bin PATH、!! !$ 历史补全

# ── XDG 路径规范 ──────────────────────────────────────────────────────────────
set -gx CARGO_HOME       $HOME/.local/share/cargo
set -gx RUSTUP_HOME      $HOME/.local/share/rustup
set -gx PYENV_ROOT       $HOME/.local/share/pyenv
set -gx npm_config_cache $HOME/.cache/npm
set -gx CUDA_CACHE_PATH  $HOME/.cache/nvidia
set -gx WINEPREFIX       $HOME/.local/share/wine

# ── 环境变量 ──────────────────────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx OLLAMA_MODELS $HOME/.local/share/ollama/models
# 对接 hyprland.conf exec-once 启动的 ssh-agent
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# ── 工具集成 ──────────────────────────────────────────────────────────────────
# fnm：Node 版本管理；进入含 .nvmrc / .node-version 的目录时自动切换
fnm env --use-on-cd --shell fish | source

# zoxide：智能 cd 替代品；z <模糊路径> 跳转，zi 打开 fzf 交互选择
zoxide init fish | source

# fzf 按键绑定：Ctrl+R 历史搜索 / Ctrl+T 文件选择 / Alt+C 目录跳转
fzf --fish | source

# ── Prompt ────────────────────────────────────────────────────────────────────
starship init fish | source

# ── SSH 密钥（按需加载）──────────────────────────────────────────────────────
# rbw 已解锁时静默加载密钥；未解锁不打扰——git push 时 functions/git.fish 会提示
if status is-interactive
    set -l _key_fp "SHA256:DdedK/2nU9yFpNCZOiM1De0J+Gdhr6TwS4bs1wxM2dA"
    if not ssh-add -l 2>/dev/null | grep -qF $_key_fp
        if rbw unlocked 2>/dev/null
            rbw get "3f921d39-38e5-47cb-bba0-b3920045d37a" --field "private_key" 2>/dev/null \
                | ssh-add - 2>/dev/null
        end
    end
end
