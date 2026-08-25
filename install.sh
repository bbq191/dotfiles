#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第 4 步会 stow --adopt 后 git restore home/，任何未提交的 home/ 改动都会被还原，先拦住
if [[ -n "$(git -C "$DOTFILES" status --porcelain -- home/)" ]]; then
    echo "home/ 有未提交的改动，先 commit 或 stash 再运行（stow --adopt + git restore 会把它们还原）" >&2
    exit 1
fi

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
# 清单支持整行注释与行内注释（pkg  # 说明），先剥掉再交给 paru。
# 必须用数组传参而不是 `paru -S -` 读管道：管道会占住 stdin，pacman 的 [Y/n] 确认读到 EOF 就直接取消
mapfile -t PKGS < <(sed -e 's/\s*#.*//' -e '/^\s*$/d' "$DOTFILES/packages/packages.txt")
# 只装缺失的：pacman -T 列出未安装项。直接把整份清单交给 paru 会顺带升级/对齐已装包
# （等于半次 paru -Sua），重跑时噪音大且有副作用；升级请用 paru -Syu
mapfile -t MISSING < <(pacman -T "${PKGS[@]}" || true)
if (( ${#MISSING[@]} )); then
    paru -S --needed "${MISSING[@]}"
else
    echo "    清单中的软件包均已安装"
fi

# ── 3. 安装 Node（fnm）和全局 npm 包 ─────────────────────────────────────────
echo "[+] 配置 fnm + Node..."
export FNM_DIR="$HOME/.local/share/fnm"
eval "$(fnm env --shell bash)"
# 已有默认 Node 就不再联网装 LTS（想升级：fnm install --lts && fnm default lts-latest）
if [[ ! -e "$FNM_DIR/aliases/default" ]]; then
    fnm install --lts
    fnm default lts-latest
fi
eval "$(fnm env --shell bash)"   # 让 default 别名进 PATH
# gemini-cli：Gemini CLI；mermaid-cli：pandoc filters.lua 用 mmdc 把 mermaid 代码块渲染成图
NPM_MISSING=()
command -v gemini >/dev/null || NPM_MISSING+=(@google/gemini-cli)
command -v mmdc   >/dev/null || NPM_MISSING+=(@mermaid-js/mermaid-cli)
(( ${#NPM_MISSING[@]} )) && npm install -g "${NPM_MISSING[@]}"

# ── 4. 应用配置文件（stow） ───────────────────────────────────────────────────
echo "[+] 应用 dotfiles..."

backup_if_exists() {
    local target="$HOME/$1"
    [[ -e "$target" && ! -L "$target" ]] || return 0
    # 上级目录已是指向仓库的链接（如 ~/.config/fish → 仓库）时，target 实际就是仓库文件，不能搬走
    [[ "$(realpath -- "$target")" == "$DOTFILES"/* ]] && return 0
    mv "$target" "${target}.bak-$(date +%s)"
    echo "    备份: $target"
}

# 备份目标位置已存在的实体文件（非符号链接）：按仓库文件清单逐个检查，
# 新增配置无需再手动登记；目录不整体搬走，stow 会在已有目录内逐文件建链
while IFS= read -r rel; do
    backup_if_exists "$rel"
done < <(git -C "$DOTFILES" ls-files home | sed 's|^home/||')

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

# Rime 增强词库：克隆 Iorest/rime-dict → opencc 转简体 → 编译（见 ~/.local/bin/rime-dict-sync）
rime-dict-sync --no-restart || echo "    rime-dict-sync 失败（网络？），稍后手动执行"

# dconf：niri 下没有 xsettings daemon，纯 GTK3 程序（如 Thunar）不读 gtk-3.0/settings.ini，
# 而是直接吃 org.gnome.desktop.interface 这份 dconf 状态，必须单独同步字号/主题
echo "[+] 应用 dconf 设置..."
dconf load /org/gnome/desktop/interface/ < "$DOTFILES/system/dconf/interface.ini"

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
sudo mkdir -p /etc/greetd
# config.toml 本身由 `dms greeter enable`/`dms greeter sync` 生成管理（见下方手动步骤），
# 这里只放 wrapper 每次启动都会 include、且不受 sync 覆盖的 NVIDIA 环境变量扩展点
sudo cp "$DOTFILES/system/etc/greetd/niri_overrides.kdl" \
        /etc/greetd/
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
# polkit 图形提权走 howdy（Arch 默认 PAM 在 /usr/lib/pam.d，这里是 /etc 覆盖）
sudo cp "$DOTFILES/system/etc/pam.d/polkit-1" /etc/pam.d/
# howdy 守护：pacman 事务后若 howdy-compare 缺共享库，自动禁用 howdy，
# 防止 pam_howdy 崩溃污染 sudo/polkit 密码回退把人锁在门外（库补回后自动恢复）
sudo install -Dm755 "$DOTFILES/system/usr/local/bin/howdy-libguard" \
        /usr/local/bin/howdy-libguard
sudo install -Dm644 "$DOTFILES/system/etc/pacman.d/hooks/50-howdy-libguard.hook" \
        /etc/pacman.d/hooks/50-howdy-libguard.hook
sudo mkdir -p /etc/sudoers.d
sudo cp "$DOTFILES/system/etc/sudoers.d/papirus-folders" \
        /etc/sudoers.d/
sudo chmod 0440 /etc/sudoers.d/papirus-folders
sudo mkdir -p /etc/NetworkManager/conf.d
NM_CHANGED=0
for f in wifi-backend.conf 99-firewall.conf; do
    cmp -s "$DOTFILES/system/etc/NetworkManager/conf.d/$f" "/etc/NetworkManager/conf.d/$f" || NM_CHANGED=1
done
sudo cp "$DOTFILES/system/etc/NetworkManager/conf.d/wifi-backend.conf" \
        "$DOTFILES/system/etc/NetworkManager/conf.d/99-firewall.conf" \
        /etc/NetworkManager/conf.d/
# 固定 Wi-Fi 网卡名为 wlan0（iwlwifi 固件崩溃恢复后接口名会漂移成 wlan1）
sudo mkdir -p /etc/systemd/network
sudo cp "$DOTFILES/system/etc/systemd/network/10-wlan0.link" \
        /etc/systemd/network/
# 固定 reMarkable USB 网卡名为 rmk0（NM profile remarkable-usb 按此名绑定）；MAC 随设备而变，见文件注释
sudo cp "$DOTFILES/system/etc/systemd/network/11-rmk0.link" \
        /etc/systemd/network/
# sysctl：ip_forward（热点/USB 共享）、min_free_kbytes；udev：IO 调度器覆盖、uuu 刷机 USB 权限
sudo mkdir -p /etc/sysctl.d /etc/udev/rules.d
sudo cp "$DOTFILES/system/etc/sysctl.d/"*.conf /etc/sysctl.d/
sudo sysctl -q --system
sudo cp "$DOTFILES/system/etc/udev/rules.d/"*.rules /etc/udev/rules.d/
sudo udevadm control --reload
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
# ollama 只部署 override（用户身份 + XDG 模型路径），不开机自启；需要时 systemctl start ollama
sudo systemctl disable --now wpa_supplicant 2>/dev/null || true
sudo systemctl enable --now iwd
sudo systemctl enable --now keyd
# IR 补光服务（howdy 人脸识别依赖）；新机器需先 sudo linux-enable-ir-emitter configure
sudo systemctl enable linux-enable-ir-emitter.service
# 只有 NM 配置真的变了才重启（重启会让 Wi-Fi 断几秒）
(( NM_CHANGED )) && sudo systemctl restart NetworkManager
systemctl --user enable --now ssh-agent.socket
systemctl --user enable --now dms.service 2>/dev/null || true
# DMS 第三方启动器插件（plugin_settings.json 里已启用，但插件本体由 dms CLI 克隆，不在仓库）
for plugin in calculator emojiLauncher niriWindows; do
    [[ -d "$HOME/.config/DankMaterialShell/plugins/$plugin" ]] || dms plugins install "$plugin" || true
done
# DMS 后端：剪贴板历史 / 日历 / Spotlight 文件索引（包自带单元）
systemctl --user enable --now cliphist.service dcal.service dsearch.service 2>/dev/null || true
# 用户级 tmpfiles：user-tmpfiles.d/cleanup.conf 靠它执行（preset 写着 enable，但本机实测默认是 disabled）
systemctl --user enable --now systemd-tmpfiles-setup.service systemd-tmpfiles-clean.timer
# USB 直连 reMarkable 时周期推送「网关/DNS 指向本机」配置（设备端不持久，靠定时器自愈）
systemctl --user enable --now remarkable-usb-share.timer

# ── 7. 目录初始化 ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.local/share/wine"
mkdir -p "$HOME/.local/share/ollama/models"
mkdir -p "$HOME/.cache/ssh"
chmod 700 "$HOME/.cache/ssh"

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
GPG_CHANGED=0
for unit in "${!_SOCKET_MAP[@]}"; do
    dropin_dir="$HOME/.config/systemd/user/${unit}.d"
    mkdir -p "$dropin_dir"
    content=$(printf '[Socket]\nListenStream=\nListenStream=%s/%s\n' "$SOCKETDIR" "${_SOCKET_MAP[$unit]}")
    if [[ "$(cat "$dropin_dir/socket-path.conf" 2>/dev/null)" != "$content" ]]; then
        printf '%s\n' "$content" > "$dropin_dir/socket-path.conf"
        GPG_CHANGED=1
    fi
done
systemctl --user daemon-reload
# 只有 socket 路径变了才重启 agent（重启会清掉已缓存的口令）
(( GPG_CHANGED )) && { systemctl --user restart gpg-agent.service 2>/dev/null || true; }

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

# ── 10. SDKMAN ────────────────────────────────────────────────────────────────
# 官方安装脚本直接装到 XDG_DATA_HOME 下（SDKMAN_DIR 是 sdkman 自身唯一的目录变量，
# 程序本体和 candidates 数据混在一起，没法只迁移数据部分，因此不用发行版包）。
# fish 端集成见 home/.config/fish/conf.d/config_sdk.fish（__sdkman_custom_dir）
# 和 fish_plugins（reitzig/sdkman-for-fish），由 stow + fisher update 落地。
echo "[+] 配置 SDKMAN..."
SDKMAN_DIR_NEW="$HOME/.local/share/sdkman"
if [[ ! -f "$SDKMAN_DIR_NEW/bin/sdkman-init.sh" ]]; then
    curl -s "https://get.sdkman.io" | SDKMAN_DIR="$SDKMAN_DIR_NEW" bash
    echo "    已安装 SDKMAN 到 $SDKMAN_DIR_NEW"
fi
# fisher 插件落地文件缺失时才拉取（fish_plugins 已锁定版本，重复 update 只是重复下载）
[[ -f "$HOME/.config/fish/functions/sdk.fish" ]] || fish -c "fisher update" 2>/dev/null || true

# ── 11. mihomo 配置 ───────────────────────────────────────────────────────────
# mihomo 以系统服务运行（mihomo-bin 自带 mihomo.service，-d /etc/mihomo）。
# 模板 system/etc/mihomo/config.template.yaml 只缺订阅 token 和面板密码，
# 两者从 rbw 取出后 sed 填入；flags/ 目录归本用户所有，供 hotspot-internet /
# usb-internet 脚本（无 root）改写外网开关标志，mihomo 以 file rule-provider 读取。
echo "[+] 生成 mihomo 配置..."
sudo mkdir -p /etc/mihomo/flags
sudo chown "$USER:$USER" /etc/mihomo/flags
for flag in hotspot-direct usb-direct; do
    [[ -f "/etc/mihomo/flags/$flag.yaml" ]] || printf 'payload: []\n' > "/etc/mihomo/flags/$flag.yaml"
done
if rbw get mihomo-proxy-token &>/dev/null && rbw get mihomo-secret &>/dev/null; then
    MIHOMO_TOKEN=$(rbw get mihomo-proxy-token)
    MIHOMO_SECRET=$(rbw get mihomo-secret)
    TOKEN_ESC=$(printf '%s\n' "$MIHOMO_TOKEN" | sed 's/[\/&]/\\&/g')
    SECRET_ESC=$(printf '%s\n' "$MIHOMO_SECRET" | sed 's/[\/&]/\\&/g')
    RENDERED=$(sed -e "s/__MIHOMO_TOKEN__/${TOKEN_ESC}/" \
        -e "s/__MIHOMO_SECRET__/${SECRET_ESC}/" \
        "$DOTFILES/system/etc/mihomo/config.template.yaml")
    if [[ "$RENDERED" != "$(cat /etc/mihomo/config.yaml 2>/dev/null)" ]]; then
        printf '%s\n' "$RENDERED" | sudo tee /etc/mihomo/config.yaml >/dev/null
        # 含订阅 token 与 API secret：只让 root 和本用户读（hotspot-internet/usb-internet 要读 secret 调 API）
        sudo chown "root:$USER" /etc/mihomo/config.yaml
        sudo chmod 640 /etc/mihomo/config.yaml
        sudo systemctl enable --now mihomo
        sudo systemctl restart mihomo   # 配置变了才重启（代理会断 1-2 秒）
        echo "    /etc/mihomo/config.yaml 已更新，mihomo 已重启"
    else
        sudo systemctl enable --now mihomo
        echo "    /etc/mihomo/config.yaml 无变化，跳过"
    fi
else
    echo "    跳过：rbw 中未找到 mihomo-proxy-token 或 mihomo-secret，请手动添加后重新运行"
fi

echo ""
echo "完成。手动步骤："
echo "  - mihomo：rbw add mihomo-proxy-token（订阅 token）和 rbw add mihomo-secret（面板密码）"
echo "  - rbw：执行 'rbw register' 登录 Bitwarden"
echo "  - SSH：将 SSH 私钥存入 Bitwarden（SSH Key 类型），rbw 解锁后执行 rbw-ssh-load 加载"
echo "  - 字体：Maple Mono NF CN 与 pandoc 字体不在软件源，需手动放入 ~/.local/share/fonts（见 README）"
echo "  - 壁纸：DMS Settings → Wallpaper 中设置（或 dms ipc call wallpaper set <路径>）"
echo "  - 登录界面：dms greeter enable && dms greeter sync"
echo "  - 人脸识别：sudo linux-enable-ir-emitter configure，然后 sudo howdy add（见 README）"
echo "  - 热点/USB 共享：nmcli 重建 Hotspot / remarkable-usb 连接（见 README「网络共享」）"
