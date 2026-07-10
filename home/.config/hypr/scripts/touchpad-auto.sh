#!/usr/bin/env bash
# 插入外接鼠标时自动禁用触摸板，拔出后自动恢复
# 判断依据是 udev 属性（ID_INPUT_MOUSE + USB/蓝牙总线），与鼠标品牌/名字无关
# 用法: touchpad-auto.sh check  一次性检测并应用
#       touchpad-auto.sh watch  常驻监听 input 热插拔事件（exec-once 启动）
set -uo pipefail

TOUCHPAD="ven_06cb:00-06cb:cff2-touchpad"

# 外接鼠标 = 指针设备 且 走 USB/蓝牙总线；排除触摸板自身（内置走 I2C，双保险）
has_external_mouse() {
    local dev props
    for dev in /dev/input/event*; do
        props=$(udevadm info -q property "$dev" 2>/dev/null) || continue
        grep -qx  'ID_INPUT_MOUSE=1'         <<<"$props" || continue
        grep -qx  'ID_INPUT_TOUCHPAD=1'      <<<"$props" && continue
        grep -qxE 'ID_BUS=(usb|bluetooth)'   <<<"$props" && return 0
    done
    return 1
}

check() {
    if has_external_mouse; then
        hyprctl keyword "device[$TOUCHPAD]:enabled" false >/dev/null
    else
        hyprctl keyword "device[$TOUCHPAD]:enabled" true >/dev/null
    fi
}

case "${1:-check}" in
check)
    check
    ;;
watch)
    # 单实例：重复启动（手动调试/hyprctl dispatch exec）时静默退出
    exec 9>"${XDG_RUNTIME_DIR:-/tmp}/touchpad-auto.lock"
    flock -n 9 || exit 0
    check
    udevadm monitor --udev --subsystem-match=input | while read -r _; do
        # 去抖：一次热插拔会连发多条事件，静默 0.5s 后只处理一次
        while read -r -t 0.5 _; do :; done
        check
    done
    ;;
*)
    echo "用法: $0 {check|watch}" >&2
    exit 1
    ;;
esac
