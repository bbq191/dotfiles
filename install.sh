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
grep -v '^\s*#' "$DOTFILES/packages/packages.txt" | grep -v '^\s*$' | paru -S --needed -

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
    .config/niri \
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
    .config/user-dirs.locale \
    .config/xdg-terminals.list \
    .config/danksearch \
    .config/dankcal \
    .config/rbw \
    .config/Thunar/uca.xml \
    .config/DankMaterialShell \
    .config/matugen \
    ".config/Code - Insiders/User/settings.json" \
    ".config/Code - Insiders/User/keybindings.json" \
    ".config/gtk-3.0/settings.ini" \
    ".config/gtk-4.0/settings.ini" \
    .ssh/config \
    .config/btop/btop.conf \
    .config/fastfetch/config.jsonc \
    .config/gemini/GEMINI.md \
    .local/share/rustup/settings.toml \
    .config/maven/settings.xml
do
    backup_if_exists "$item"
done

# 清理指向仓库的旧绝对路径符号链接：stow 只认自己创建的相对链接，
# 绝对链接会被判定为冲突导致中止（链接目标不变，stow 会原地重建为相对链接）
while IFS= read -r -d '' src; do
    tgt="$HOME/${src#"$DOTFILES/home/"}"
    if [[ -L "$tgt" && "$(readlink "$tgt")" == "$src" ]]; then
        rm "$tgt"
    fi
done < <(find "$DOTFILES/home" -mindepth 1 -print0)

# --adopt 处理运行中进程（如 niri/DMS）在 stow 执行期间重建的文件
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
sudo cp "$DOTFILES/system/etc/tmpfiles.d/howdy-permissions.conf" \
        /etc/tmpfiles.d/
sudo systemd-tmpfiles --create /etc/tmpfiles.d/howdy-permissions.conf
# PAM：howdy 人脸识别接入 DMS 锁屏/sudo/greetd 登录。
# sudo 归 pambase 包管理，覆盖后上游更新会生成 .pacnew，需留意合并
sudo cp "$DOTFILES/system/etc/pam.d/dankshell" /etc/pam.d/
sudo cp "$DOTFILES/system/etc/pam.d/sudo" /etc/pam.d/
# greetd 归 greetd 包管理，覆盖后上游更新会生成 .pacnew，需留意合并
sudo cp "$DOTFILES/system/etc/pam.d/greetd" /etc/pam.d/
sudo mkdir -p /etc/sudoers.d
sudo cp "$DOTFILES/system/etc/sudoers.d/papirus-folders" \
        /etc/sudoers.d/
sudo chmod 0440 /etc/sudoers.d/papirus-folders
sudo mkdir -p /etc/NetworkManager/conf.d
sudo cp "$DOTFILES/system/etc/NetworkManager/conf.d/wifi-backend.conf" \
        /etc/NetworkManager/conf.d/
sudo mkdir -p /etc/keyd
sudo cp "$DOTFILES/system/etc/keyd/default.conf" \
        /etc/keyd/
sudo mkdir -p /etc/snapper/configs
sudo cp "$DOTFILES/system/etc/snapper/configs/root" \
        /etc/snapper/configs/
sudo systemctl mask NetworkManager-wait-online.service

# ── 6. systemd 服务 ───────────────────────────────────────────────────────────
echo "[+] 启用 systemd 服务..."
sudo systemctl daemon-reload
sudo systemctl enable --now ollama
sudo systemctl disable --now wpa_supplicant 2>/dev/null || true
sudo systemctl enable --now iwd
sudo systemctl enable --now keyd
# IR 补光服务（howdy 人脸识别依赖）；新机器需先 sudo linux-enable-ir-emitter configure
sudo systemctl enable linux-enable-ir-emitter.service
sudo systemctl restart NetworkManager
systemctl --user enable --now ssh-agent.socket
systemctl --user enable --now dms.service 2>/dev/null || true

# ── 7. 目录初始化 ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.local/share/wine"
mkdir -p "$HOME/.local/share/ollama/models"
mkdir -p "$HOME/.cache/ssh"
chmod 700 "$HOME/.cache/ssh"

# VSCode Insiders：VSCODE_PORTABLE 路径下的 user-data 软链接
# settings/keybindings 源文件由 stow 管理在 ~/.config/Code - Insiders/User/
VSCODE_USER="$HOME/.local/share/vscode-insiders/user-data/User"
mkdir -p "$VSCODE_USER"
for f in settings.json keybindings.json; do
    src="$HOME/.config/Code - Insiders/User/$f"
    dst="$VSCODE_USER/$f"
    if [[ -f "$src" && ! -L "$dst" ]]; then
        [[ -e "$dst" ]] && mv "$dst" "${dst}.bak-$(date +%s)"
        ln -sf "$src" "$dst"
        echo "    VSCode: 链接 $f → VSCODE_PORTABLE/user-data/User/"
    elif [[ ! -e "$dst" ]]; then
        ln -sf "$src" "$dst"
        echo "    VSCode: 链接 $f → VSCODE_PORTABLE/user-data/User/"
    fi
done

# ── 8. GnuPG XDG 迁移 ────────────────────────────────────────────────────────
echo "[+] 配置 GnuPG XDG 路径..."
GNUPGHOME_NEW="$HOME/.local/share/gnupg"
mkdir -p "$GNUPGHOME_NEW"
chmod 700 "$GNUPGHOME_NEW"

if [[ -d "$HOME/.gnupg" && ! -L "$HOME/.gnupg" ]]; then
    cp -rn "$HOME/.gnupg/." "$GNUPGHOME_NEW/"
    mv "$HOME/.gnupg" "$HOME/.gnupg.bak-$(date +%s)"
    echo "    已迁移 ~/.gnupg → $GNUPGHOME_NEW"
fi

# socket 路径由 GNUPGHOME 的哈希决定，需动态生成 drop-in
SOCKETDIR=$(GNUPGHOME="$GNUPGHOME_NEW" gpgconf --list-dirs socketdir)
declare -A _SOCKET_MAP=(
    [gpg-agent.socket]="S.gpg-agent"
    [gpg-agent-ssh.socket]="S.gpg-agent.ssh"
    [gpg-agent-browser.socket]="S.gpg-agent.browser"
    [gpg-agent-extra.socket]="S.gpg-agent.extra"
)
for unit in "${!_SOCKET_MAP[@]}"; do
    dropin_dir="$HOME/.config/systemd/user/${unit}.d"
    mkdir -p "$dropin_dir"
    cat > "$dropin_dir/socket-path.conf" << EOF
[Socket]
ListenStream=
ListenStream=${SOCKETDIR}/${_SOCKET_MAP[$unit]}
EOF
done
systemctl --user daemon-reload
systemctl --user restart gpg-agent.service 2>/dev/null || true

# ── 9. Maven XDG 迁移 ────────────────────────────────────────────────────────
echo "[+] 配置 Maven XDG 路径..."
MAVEN_CACHE="$HOME/.cache/maven"
mkdir -p "$MAVEN_CACHE"

if [[ -d "$HOME/.m2/repository" && ! -L "$HOME/.m2/repository" ]]; then
    mv "$HOME/.m2/repository" "$MAVEN_CACHE/repository"
    echo "    已迁移 ~/.m2/repository → $MAVEN_CACHE/repository"
fi

if [[ -d "$HOME/.m2" && ! -L "$HOME/.m2" ]]; then
    rmdir "$HOME/.m2" 2>/dev/null \
        || mv "$HOME/.m2" "$HOME/.m2.bak-$(date +%s)"
fi

# ── 10. mihomo 配置 ───────────────────────────────────────────────────────────
echo "[+] 生成 mihomo 配置..."
mkdir -p "$HOME/.config/mihomo"
if rbw get mihomo-proxy-token &>/dev/null && rbw get mihomo-secret &>/dev/null; then
    MIHOMO_TOKEN=$(rbw get mihomo-proxy-token)
    MIHOMO_SECRET=$(rbw get mihomo-secret)
    TOKEN_ESC=$(printf '%s\n' "$MIHOMO_TOKEN" | sed 's/[\/&]/\\&/g')
    SECRET_ESC=$(printf '%s\n' "$MIHOMO_SECRET" | sed 's/[\/&]/\\&/g')
    sed -e "s/__MIHOMO_TOKEN__/${TOKEN_ESC}/" \
        -e "s/__MIHOMO_SECRET__/${SECRET_ESC}/" \
        "$DOTFILES/home/.config/mihomo/config.template.yaml" \
        > "$HOME/.config/mihomo/config.yaml"
    chmod 600 "$HOME/.config/mihomo/config.yaml"
    echo "    mihomo config.yaml 已生成"
else
    echo "    跳过：rbw 中未找到 mihomo-proxy-token 或 mihomo-secret，请手动添加后重新运行"
fi

echo ""
echo "完成。手动步骤："
echo "  - mihomo：rbw add mihomo-proxy-token（订阅 token）和 rbw add mihomo-secret（面板密码）"
echo "  - rbw：执行 'rbw register' 登录 Bitwarden"
echo "  - SSH：将 SSH 私钥存入 Bitwarden（SSH Key 类型），rbw 解锁后执行 rbw-ssh-load 加载"
echo "  - 壁纸：DMS Settings → Wallpaper 中设置（或 dms ipc call wallpaper set <路径>）"
echo "  - NVIDIA：参考 README 中的已知问题"
