#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 1. 依赖检查 ───────────────────────────────────────────────────────────────
if ! command -v paru &>/dev/null; then
    echo "[+] 安装 paru..."
    sudo pacman -S --needed base-devel git
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    (cd "$tmp/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

if ! command -v stow &>/dev/null; then
    sudo pacman -S --needed stow
fi

# ── 2. 安装软件包 ─────────────────────────────────────────────────────────────
echo "[+] 安装软件包..."
paru -S --needed - < "$DOTFILES/packages/packages.txt"

# ── 3. 安装 Node（fnm）和全局 npm 包 ─────────────────────────────────────────
echo "[+] 配置 fnm + Node..."
export FNM_DIR="$HOME/.local/share/fnm"
eval "$(fnm env --shell bash)"
fnm install --lts
fnm default lts-latest
npm install -g @google/gemini-cli

# ── 4. 应用配置文件（stow） ───────────────────────────────────────────────────
echo "[+] 应用 dotfiles..."

backup_if_exists() {
    local target="$HOME/$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mv "$target" "${target}.bak-$(date +%s)"
        echo "    备份: $target"
    fi
}

# 手动备份已知冲突目标
for item in \
    .config/fish \
    .config/hypr \
    .config/kitty \
    .config/nvim \
    .config/yazi \
    .config/starship.toml \
    .config/lazygit \
    .config/mpv \
    .config/satty \
    .config/fcitx5 \
    .config/environment.d \
    .config/git \
    .config/fontconfig \
    .config/qt5ct \
    .config/qt6ct \
    .config/mimeapps.list \
    .config/user-dirs.dirs \
    .config/DankMaterialShell \
    ".config/Code - Insiders/User/settings.json" \
    ".config/Code - Insiders/User/keybindings.json"
do
    backup_if_exists "$item"
done

# --adopt 处理运行中进程（如 Hyprland）在 stow 执行期间重建的文件
# git restore 将被 --adopt 吸入的系统文件还原为仓库版本
stow --adopt --target="$HOME" home
git -C "$DOTFILES" restore home/

# ── 5. 应用系统配置（需要 sudo）────────────────────────────────────────────────
echo "[+] 应用系统配置..."
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo cp "$DOTFILES/system/etc/systemd/resolved.conf.d/no-mdns.conf" \
        /etc/systemd/resolved.conf.d/
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo cp "$DOTFILES/system/etc/systemd/system/ollama.service.d/override.conf" \
        /etc/systemd/system/ollama.service.d/
sudo mkdir -p /etc/modprobe.d
sudo cp "$DOTFILES/system/etc/modprobe.d/nvidia-local.conf" \
        /etc/modprobe.d/
sudo mkdir -p /etc/tmpfiles.d
sudo cp "$DOTFILES/system/etc/tmpfiles.d/thp.conf" \
        /etc/tmpfiles.d/
sudo systemctl mask NetworkManager-wait-online.service

# ── 6. systemd 服务 ───────────────────────────────────────────────────────────
echo "[+] 启用 systemd 服务..."
sudo systemctl daemon-reload
sudo systemctl enable --now ollama
systemctl --user enable --now dms.service 2>/dev/null || true

# ── 7. 目录初始化 ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.local/share/wine"
mkdir -p "$HOME/.local/share/ollama/models"

echo ""
echo "完成。手动步骤："
echo "  - mihomo：将代理配置放入 ~/.config/mihomo/config.yaml"
echo "  - rbw：执行 'rbw register' 登录 Bitwarden"
echo "  - SSH：将私钥放入 ~/.ssh/ 并 'chmod 600'"
echo "  - 壁纸：将图片放入 ~/Pictures/ 并更新 hyprpaper.conf 路径"
echo "  - NVIDIA：参考 README 中的已知问题"
