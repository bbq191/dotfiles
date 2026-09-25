#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第 4 步会 stow --adopt 后 git restore home/，任何未提交的 home/ 改动都会被还原，先拦住
# matugen 主题产物：DMS 每次换壁纸/明暗切换都会重写，不算"手改"。既不拦截，第 4 步也不 restore
# （restore 会把正在用的配色倒回旧提交，直到下次重生成才恢复）；积攒够了单独提交"主题重生成"即可
GENERATED=(
    ':!home/.config/kitty/dank-*.conf'
    ':!home/.config/niri/dms/colors.kdl'
    ':!home/.config/nvim/colors/dms.lua'
    ':!home/.config/qt5ct/colors/matugen.conf'
    ':!home/.config/qt6ct/colors/matugen.conf'
)
DIRTY=$(git -C "$DOTFILES" status --porcelain -- home/ "${GENERATED[@]}")
if [[ -n "$DIRTY" ]]; then
    echo "home/ 有未提交的改动，先 commit 或 stash 再运行（stow --adopt + git restore 会把它们还原）：" >&2
    echo "$DIRTY" >&2
    echo "（stow 链接的配置常被应用自己回写，如 dankcal/ui-settings.json、mimeapps.list；确认是想要的设置就直接提交。matugen 主题产物已自动豁免）" >&2
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
git -C "$DOTFILES" restore -- home/ "${GENERATED[@]}"

# Rime 增强词库：克隆 Iorest/rime-dict → opencc 转简体 → 编译（见 ~/.local/bin/rime-dict-sync）
rime-dict-sync --no-restart || echo "    rime-dict-sync 失败（网络？），稍后手动执行"

# dconf：niri 下没有 xsettings daemon，纯 GTK3 程序不读 gtk-3.0/settings.ini，
# 而是直接吃 org.gnome.desktop.interface 这份 dconf 状态，必须单独同步字号/主题
echo "[+] 应用 dconf 设置..."
dconf load /org/gnome/desktop/interface/ < "$DOTFILES/system/dconf/interface.ini"
# Nautilus 不用配置文件，偏好（默认列表视图/窗口尺寸）全存在自己的 dconf 路径下
dconf load /org/gnome/nautilus/ < "$DOTFILES/system/dconf/nautilus.ini"

# ── 5. 应用系统配置（需要 sudo）────────────────────────────────────────────────
echo "[+] 应用系统配置..."
# 部署单个文件到系统路径：install -D 自动建父目录，免去每处重复 mkdir -p；
# 内容未变时跳过写入。总是返回 0——大多数调用处是裸调用，"没变化"是正常结果，
# 不能让它在 set -e 下当成命令失败把整个脚本退出（踩过这个坑：重跑时几乎所有
# 文件都没变化，第一个裸调用一 return 1 脚本就静默退出，跟没跑一样）。
# 少数几处（NM、mihomo override）需要知道有没有变化，看 DEPLOY_CHANGED。
deploy() {
    local src="$DOTFILES/$1" dest="$2" mode="${3:-644}"
    if sudo cmp -s "$src" "$dest" 2>/dev/null; then
        DEPLOY_CHANGED=0
    else
        sudo install -Dm"$mode" "$src" "$dest"
        DEPLOY_CHANGED=1
    fi
}

deploy system/etc/systemd/resolved.conf.d/no-mdns.conf /etc/systemd/resolved.conf.d/no-mdns.conf
deploy system/etc/systemd/system/ollama.service.d/override.conf /etc/systemd/system/ollama.service.d/override.conf
# mihomo-bin 自带单元的 CapabilityBoundingSet 比实际需要的宽（见文件内注释），
# 用 drop-in 收紧；只有变了才在下面步骤 11 重启（改能力集不重启不生效）
deploy system/etc/systemd/system/mihomo.service.d/override.conf /etc/systemd/system/mihomo.service.d/override.conf
MIHOMO_OVERRIDE_CHANGED=$DEPLOY_CHANGED
deploy system/etc/modprobe.d/nvidia-local.conf /etc/modprobe.d/nvidia-local.conf
# config.toml 本身由 `dms-greeter enable`/`dms-greeter sync` 生成管理（见下方手动步骤），
# 这里只放 wrapper 每次启动都会 include、且不受 sync 覆盖的 NVIDIA 环境变量扩展点
deploy system/etc/greetd/niri_overrides.kdl /etc/greetd/niri_overrides.kdl
deploy system/etc/tmpfiles.d/thp.conf /etc/tmpfiles.d/thp.conf
deploy system/etc/tmpfiles.d/howdy-permissions.conf /etc/tmpfiles.d/howdy-permissions.conf
sudo systemd-tmpfiles --create /etc/tmpfiles.d/howdy-permissions.conf
# PAM：howdy 人脸识别接入 DMS 锁屏/sudo/greetd 登录。
# sudo/greetd 分别归 pambase/greetd 包管理，覆盖后上游更新会生成 .pacnew，需留意合并
deploy system/etc/pam.d/dankshell /etc/pam.d/dankshell
deploy system/etc/pam.d/sudo /etc/pam.d/sudo
deploy system/etc/pam.d/greetd /etc/pam.d/greetd
# polkit 图形提权走 howdy（Arch 默认 PAM 在 /usr/lib/pam.d，这里是 /etc 覆盖）
deploy system/etc/pam.d/polkit-1 /etc/pam.d/polkit-1
# howdy 守护：pacman 事务后若 howdy-compare 缺共享库，自动禁用 howdy，
# 防止 pam_howdy 崩溃污染 sudo/polkit 密码回退把人锁在门外（库补回后自动恢复）
deploy system/usr/local/bin/howdy-libguard /usr/local/bin/howdy-libguard 755
deploy system/etc/pacman.d/hooks/50-howdy-libguard.hook /etc/pacman.d/hooks/50-howdy-libguard.hook
deploy system/etc/sudoers.d/papirus-folders /etc/sudoers.d/papirus-folders 440

NM_CHANGED=0
for f in wifi-backend.conf 99-firewall.conf; do
    deploy "system/etc/NetworkManager/conf.d/$f" "/etc/NetworkManager/conf.d/$f"
    if (( DEPLOY_CHANGED )); then NM_CHANGED=1; fi
done
# 清理旧版部署的 iwd override（After=cachyos-iw-set-regdomain.service）：实测顺序已满足，
# 内核 nl80211_get_reg_do WARN 照样出现（自管理 regdom 的 BE200 在固件上报前被查询），
# 该 drop-in 无效，已从仓库删除；下面的 daemon-reload 使删除生效
sudo rm -f /etc/systemd/system/iwd.service.d/override.conf
sudo rmdir /etc/systemd/system/iwd.service.d 2>/dev/null || true
# 固定 Wi-Fi 网卡名为 wlan0（iwlwifi 固件崩溃恢复后接口名会漂移成 wlan1）
deploy system/etc/systemd/network/10-wlan0.link /etc/systemd/network/10-wlan0.link
# 固定 reMarkable USB 网卡名为 rmk0（NM profile remarkable-usb 按此名绑定）；MAC 随设备而变，见文件注释
deploy system/etc/systemd/network/11-rmk0.link /etc/systemd/network/11-rmk0.link
# BE200 冷开机固件崩溃（CTDP_CONFIG_CMD 断言）自愈：开机延迟自检 + 就地复位；devcoredump 落盘供提 bug
deploy system/usr/local/bin/wifi-fw-reset /usr/local/bin/wifi-fw-reset 755
deploy system/usr/local/bin/iwl-fwdump /usr/local/bin/iwl-fwdump 755
deploy system/etc/systemd/system/wifi-fw-reset.service /etc/systemd/system/wifi-fw-reset.service
# sysctl：ip_forward（热点/USB 共享）、min_free_kbytes；udev：IO 调度器覆盖、uuu 刷机 USB 权限
for f in "$DOTFILES"/system/etc/sysctl.d/*.conf; do
    deploy "system/etc/sysctl.d/$(basename "$f")" "/etc/sysctl.d/$(basename "$f")"
done
sudo sysctl -q --system
for f in "$DOTFILES"/system/etc/udev/rules.d/*.rules; do
    deploy "system/etc/udev/rules.d/$(basename "$f")" "/etc/udev/rules.d/$(basename "$f")"
done
sudo udevadm control --reload
deploy system/etc/keyd/default.conf /etc/keyd/default.conf
deploy system/etc/snapper/configs/root /etc/snapper/configs/root
# 磁盘健康监控：smartmontools 已在软件包清单里，之前只装了没启用，等于零监控
deploy system/etc/smartd.conf /etc/smartd.conf
SMARTD_CHANGED=$DEPLOY_CHANGED
# SMART 告警桌面通知插件（sudo -u afu 打到 DMS 会话总线，见文件内注释）
deploy system/usr/share/smartmontools/smartd_warning.d/notify-desktop \
    /usr/share/smartmontools/smartd_warning.d/notify-desktop 755
(( DEPLOY_CHANGED )) && SMARTD_CHANGED=1
sudo systemctl mask NetworkManager-wait-online.service

# ── 6. systemd 服务 ───────────────────────────────────────────────────────────
echo "[+] 启用 systemd 服务..."
sudo systemctl daemon-reload
# ollama 只部署 override（用户身份 + XDG 模型路径），不开机自启；需要时 systemctl start ollama
sudo systemctl disable --now wpa_supplicant 2>/dev/null || true
sudo systemctl enable --now iwd
sudo systemctl enable wifi-fw-reset.service
sudo systemctl enable --now keyd
sudo systemctl enable --now smartd
# 例行维护：paccache 每周清旧包缓存；btrfs scrub 每月校验（/ 和 /home 是两个独立的 btrfs，各一个定时器）。
# 单盘 scrub 只能发现坏块不能自修复，发现后靠 backup-home 的备份恢复
sudo systemctl enable --now paccache.timer 'btrfs-scrub@-.timer' btrfs-scrub@home.timer
(( SMARTD_CHANGED )) && sudo systemctl restart smartd   # 配置变了才重启，重载配置生效
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
# X11↔Wayland 文本剪贴板桥接：xwayland-satellite 0.8.2 自带桥接会卡死（上游 #485），VMware 等 X11 应用靠它复制粘贴
systemctl --user enable --now x11-clipboard-bridge.service
# 用户级 tmpfiles：user-tmpfiles.d/cleanup.conf 靠它执行（preset 写着 enable，但本机实测默认是 disabled）
systemctl --user enable --now systemd-tmpfiles-setup.service systemd-tmpfiles-clean.timer
# USB 直连 reMarkable 时推送「网关/DNS 指向本机」配置（设备端 /etc 不持久）。事件驱动：常驻服务阻塞在
# `ip monitor` 上，设备重启/重插拔（rmk0 链路/地址事件）才推送，不再每 45s 轮询。旧版是 .timer，顺手停掉。
systemctl --user disable --now remarkable-usb-share.timer 2>/dev/null || true
systemctl --user enable --now remarkable-usb-share.service
# 备份提醒：backup-home 需要手动插盘，超过 14 天没成功就弹通知（时间戳由 backup-home 成功后写入）
systemctl --user enable --now backup-reminder.timer

# ── 6b. 启动调优（limine）─────────────────────────────────────────────────────
# 只在识别到预期格式时才改，格式对不上就原样跳过，不会硬改引导配置。
echo "[+] 检查启动调优..."
LIMINE_DEFAULT=/etc/default/limine
# plymouth 退出动画占关键路径约 3 秒（greetd 排在 plymouth-quit-wait 之后）；本机没有加密盘，
# 启动画面纯属装饰。plymouth.enable=0 让 plymouth 各单元直接跳过，不需要重建 initrd
# （想恢复：把 plymouth.enable=0 改回 splash，再 sudo limine-update）
if [[ -f "$LIMINE_DEFAULT" ]] && grep -qE '^KERNEL_CMDLINE\[default\].*\bsplash\b' "$LIMINE_DEFAULT"; then
    sudo sed -i -E '/^KERNEL_CMDLINE\[default\]/ s/\bsplash\b/plymouth.enable=0/' "$LIMINE_DEFAULT"
    sudo limine-update
    echo "    已在内核参数里关闭 plymouth（下次开机生效）"
fi
# limine 菜单默认要等几秒才进系统；要选快照/旧内核时开机后按住任意键即可停住倒计时。
# ESP 上先留一份 .bak-dotfiles 再改
if sudo grep -qE '^timeout: *([2-9]|[1-9][0-9]+) *$' /boot/limine.conf 2>/dev/null; then
    sudo cp -n /boot/limine.conf /boot/limine.conf.bak-dotfiles
    sudo sed -i -E 's/^timeout:.*/timeout: 1/' /boot/limine.conf
    echo "    limine 菜单等待改为 1 秒（原文件备份在 /boot/limine.conf.bak-dotfiles）"
fi

# ── 7. 目录初始化 ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.local/share/wine"
mkdir -p "$HOME/.local/share/ollama/models"
mkdir -p "$HOME/.cache/ssh"
chmod 700 "$HOME/.cache/ssh"
# 部分工具不会自己创建缺失的父目录（gdb/sqlite3 历史文件、npm/readline 配置文件），提前建好
mkdir -p "$HOME/.local/state/gdb" "$HOME/.config/npm" "$HOME/.config/readline" "$HOME/.config/java"

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
# 模板 system/etc/mihomo/config.template.yaml 只缺完整订阅链接和面板密码，
# 两者从 rbw 取出后 sed 填入（订阅链接含机场域名与 token，整条不进仓库）；flags/ 目录归本用户所有，供 hotspot-internet /
# usb-internet 脚本（无 root）改写外网开关标志，mihomo 以 file rule-provider 读取。
echo "[+] 生成 mihomo 配置..."
sudo mkdir -p /etc/mihomo/flags
sudo chown "$USER:$USER" /etc/mihomo/flags
for flag in hotspot-direct usb-direct; do
    [[ -f "/etc/mihomo/flags/$flag.yaml" ]] || printf 'payload: []\n' > "/etc/mihomo/flags/$flag.yaml"
done
if rbw get mihomo-sub-url &>/dev/null && rbw get mihomo-secret &>/dev/null; then
    MIHOMO_SUB_URL=$(rbw get mihomo-sub-url)
    MIHOMO_SECRET=$(rbw get mihomo-secret)
    SUB_URL_ESC=$(printf '%s\n' "$MIHOMO_SUB_URL" | sed 's/[\/&]/\\&/g')
    SECRET_ESC=$(printf '%s\n' "$MIHOMO_SECRET" | sed 's/[\/&]/\\&/g')
    RENDERED=$(sed -e "s/__MIHOMO_SUB_URL__/${SUB_URL_ESC}/" \
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
    elif (( MIHOMO_OVERRIDE_CHANGED )); then
        sudo systemctl enable --now mihomo
        sudo systemctl restart mihomo   # 收紧能力集的 override 变了，重启才生效
        echo "    /etc/mihomo/config.yaml 无变化，但权限收紧的 override 变了，mihomo 已重启——请确认代理仍正常"
    else
        sudo systemctl enable --now mihomo
        echo "    /etc/mihomo/config.yaml 无变化，跳过"
    fi
else
    echo "    跳过：rbw 中未找到 mihomo-sub-url 或 mihomo-secret，请手动添加后重新运行"
fi

echo ""
echo "完成。手动步骤："
echo "  - mihomo：rbw add mihomo-sub-url（完整订阅链接）和 rbw add mihomo-secret（面板密码）"
echo "  - rbw：执行 'rbw register' 登录 Bitwarden"
echo "  - SSH：将 SSH 私钥存入 Bitwarden（SSH Key 类型），rbw 解锁后执行 rbw-ssh-load 加载"
echo "  - 字体：Maple Mono NF CN 与 pandoc 字体不在软件源，需手动放入 ~/.local/share/fonts（见 README）"
echo "  - 壁纸：DMS Settings → Wallpaper 中设置（或 dms ipc call wallpaper set <路径>）"
echo "  - 登录界面：dms-greeter enable && dms-greeter sync"
echo "  - 人脸识别：sudo linux-enable-ir-emitter configure，然后 sudo howdy add（见 README）"
echo "  - 热点/USB 共享：nmcli 重建 Hotspot / remarkable-usb 连接（见 README「网络共享」）"
