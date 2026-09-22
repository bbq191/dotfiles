#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat <<'EOF'
即将撤销 install.sh 对本机做的改动：
  - 停用/移除本仓库添加的 systemd 服务与自定义脚本
  - 删除本仓库覆盖/新增的系统配置文件（/etc 下的纯附加项）
  - 取消 stow（home/ 下由本仓库创建的符号链接）

不会自动处理（各有原因，见脚本末尾提示）：
  - packages/packages.txt 里的软件包不会卸载
  - 被 pacman 包管理的 PAM 文件（sudo/greetd）不会还原，避免误操作锁死 sudo/登录
  - GnuPG/Maven/SDKMAN 的 XDG 目录迁移不会回滚，那是数据迁移，不是配置
EOF
read -rp "确认继续？[y/N] " reply
[[ "$reply" == [yY] ]] || { echo "已取消"; exit 0; }

drop() {
    [[ -e "$1" ]] || return 0
    sudo rm -f "$1"
    echo "    删除: $1"
}

# ── 1. systemd 服务 ───────────────────────────────────────────────────────────
echo "[+] 停用 systemd 服务..."
systemctl --user disable --now x11-clipboard-bridge.service 2>/dev/null || true
systemctl --user disable --now remarkable-usb-share.service 2>/dev/null || true
sudo systemctl disable --now wifi-fw-reset.service 2>/dev/null || true
sudo systemctl disable --now mihomo 2>/dev/null || true
sudo systemctl unmask NetworkManager-wait-online.service 2>/dev/null || true

# GPG socket drop-in：只删本仓库生成的 drop-in，不动 gpg-agent 本体
for unit in gpg-agent.socket gpg-agent-ssh.socket gpg-agent-browser.socket gpg-agent-extra.socket; do
    rm -f "$HOME/.config/systemd/user/${unit}.d/socket-path.conf"
    rmdir --ignore-fail-on-non-empty "$HOME/.config/systemd/user/${unit}.d" 2>/dev/null || true
done
systemctl --user daemon-reload

# ── 2. 系统配置覆盖（纯附加项，可安全删除）───────────────────────────────────────
echo "[+] 删除系统配置覆盖..."
drop /etc/systemd/resolved.conf.d/no-mdns.conf
drop /etc/systemd/system/ollama.service.d/override.conf
drop /etc/modprobe.d/nvidia-local.conf
drop /etc/greetd/niri_overrides.kdl
drop /etc/tmpfiles.d/thp.conf
drop /etc/tmpfiles.d/howdy-permissions.conf
drop /usr/local/bin/howdy-libguard
drop /etc/pacman.d/hooks/50-howdy-libguard.hook
drop /etc/sudoers.d/papirus-folders
drop /etc/NetworkManager/conf.d/wifi-backend.conf
drop /etc/NetworkManager/conf.d/99-firewall.conf
drop /etc/systemd/network/10-wlan0.link
drop /etc/systemd/network/11-rmk0.link
drop /usr/local/bin/wifi-fw-reset
drop /usr/local/bin/iwl-fwdump
drop /etc/systemd/system/wifi-fw-reset.service
for f in "$DOTFILES"/system/etc/sysctl.d/*.conf; do
    drop "/etc/sysctl.d/$(basename "$f")"
done
for f in "$DOTFILES"/system/etc/udev/rules.d/*.rules; do
    drop "/etc/udev/rules.d/$(basename "$f")"
done
drop /etc/keyd/default.conf
drop /etc/snapper/configs/root
drop /etc/mihomo/config.yaml
sudo rm -rf /etc/mihomo/flags

sudo systemctl daemon-reload
sudo sysctl -q --system 2>/dev/null || true
sudo udevadm control --reload 2>/dev/null || true

# ── 3. dotfiles（stow）─────────────────────────────────────────────────────────
echo "[+] 取消 stow..."
stow -D --target="$HOME" home

echo ""
echo "完成。以下需要手动决定，未自动处理："
echo "  - PAM：/etc/pam.d/{sudo,greetd} 被本仓库覆盖过，还原用"
echo "        sudo pacman -S pambase --overwrite '/etc/pam.d/sudo'"
echo "        sudo pacman -S greetd   --overwrite '/etc/pam.d/greetd'"
echo "    /etc/pam.d/polkit-1 是 /etc 覆盖 /usr/lib/pam.d 默认值，直接 sudo rm /etc/pam.d/polkit-1 即可回落"
echo "    /etc/pam.d/dankshell 是本仓库独有文件，非包管理覆盖：sudo rm /etc/pam.d/dankshell"
echo "  - 软件包：packages/packages.txt 里的包未卸载（多数是通用工具，批量卸载影响面不可控）"
echo "  - XDG 数据迁移（~/.local/share/{gnupg,maven,sdkman}）未回滚，避免误删密钥/缓存"
echo "  - DMS 插件（calculator/emojiLauncher/niriWindows）未卸载：dms plugins uninstall <name>"
echo "  - iwd/keyd/linux-enable-ir-emitter 等被 install.sh 启用的系统服务未禁用，"
echo "    它们通常是日常还要用的功能（键盘重映射/人脸补光），不属于\"卸载 dotfiles\"范畴，如需关闭请手动 systemctl disable"
