#!/usr/bin/env python3
"""
float-persist: 记忆浮动窗口的位置和大小，每次打开时自动恢复。

修复要点：
- restore() 以 hyprctl clients 里的实际 class 为键（而非 openwindow 事件里的 class），
  避免 Telegram / TelegramDesktop 这类应用上报两种不同 class 名导致找不到记录。
- 过滤含 null 字节的垃圾 class、离屏位置（y < 0）、低于最小尺寸阈值的弹窗。
- 对 windowrule 中含 size 属性的类只恢复位置，不覆盖尺寸。
"""
import json
import os
import re
import socket
import subprocess
import threading
import time
from pathlib import Path

INSTANCE    = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
XDG_RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
SOCKET2     = f"{XDG_RUNTIME}/hypr/{INSTANCE}/.socket2.sock"
SAVE        = Path.home() / ".config/hypr/float_geometry.json"
CONF        = Path.home() / ".config/hypr/hyprland.conf"

MIN_W = 300
MIN_H = 200


def _parse_size_locked_classes(conf_path: Path) -> set:
    if not conf_path.exists():
        return set()
    text = conf_path.read_text()
    locked = set()
    for block in re.finditer(r'\bwindowrule\s*\{([^}]*)\}', text, re.DOTALL):
        content = block.group(1)
        if re.search(r'^\s*size\s*=', content, re.MULTILINE):
            m = re.search(r'match:class\s*=\s*(\S+)', content)
            if m:
                locked.add(m.group(1))
    return locked


size_locked_classes = _parse_size_locked_classes(CONF)

_lock      = threading.Lock()
_restoring = set()


def hyprctl(*args):
    return subprocess.run(["hyprctl", *args], capture_output=True, text=True).stdout


def get_clients():
    raw = hyprctl("clients", "-j")
    return json.loads(raw) if raw.strip() else []


def load():
    if SAVE.exists():
        try:
            return json.loads(SAVE.read_text())
        except Exception:
            return {}
    return {}


def dump(data):
    SAVE.write_text(json.dumps(data, indent=2))


saved = load()


def is_valid_class(cls: str) -> bool:
    """过滤 null 字节、过长、空等垃圾 class 名。"""
    return bool(cls) and "\x00" not in cls and len(cls) <= 200


def is_main_window(c) -> bool:
    w, h = c["size"][0], c["size"][1]
    return w >= MIN_W and h >= MIN_H


def is_valid_position(x: int, y: int) -> bool:
    """拒绝明显离屏的位置（负坐标超出合理范围）。"""
    return x >= -50 and y >= -50


def snapshot():
    changed = False
    for c in get_clients():
        if not c.get("floating"):
            continue
        cls = c.get("class", "")
        if not is_valid_class(cls):
            continue
        if c.get("address", "") in _restoring:
            continue
        if not is_main_window(c):
            continue
        x, y = c["at"][0], c["at"][1]
        if not is_valid_position(x, y):
            continue
        skip_size = any(re.fullmatch(pat, cls) for pat in size_locked_classes)
        geo = {"x": x, "y": y} if skip_size else {
            "x": x, "y": y, "w": c["size"][0], "h": c["size"][1],
        }
        with _lock:
            if saved.get(cls) != geo:
                saved[cls] = geo
                changed = True
    if changed:
        with _lock:
            dump(saved)


def restore(addr: str, _event_cls: str):
    """
    addr       — "0x..." 窗口地址
    _event_cls — openwindow 事件里的 class（仅作备用，优先用 hyprctl clients 里的实际 class）
    """
    # 等待窗口出现 **且** floating 标志已被 windowrule 设置
    # 最多等约 360ms，应对 windowrule float= 比 openwindow 事件略晚生效的情况
    client = None
    actual_cls = _event_cls
    for _ in range(12):
        for c in get_clients():
            if c.get("address") == addr:
                client = c
                break
        if client:
            # 以 hyprctl clients 的 class 为准（解决 Telegram 等双 class 问题）
            actual_cls = client.get("class") or _event_cls
            if client.get("floating"):
                break
            client = None  # 已找到但尚未 floating，继续等
        time.sleep(0.03)

    if not client:
        return
    if not is_main_window(client):
        return

    with _lock:
        geo = saved.get(actual_cls)
    if not geo:
        return
    if not is_valid_position(geo.get("x", 0), geo.get("y", 0)):
        return

    skip_size = any(re.fullmatch(pat, actual_cls) for pat in size_locked_classes)

    _restoring.add(addr)
    try:
        hyprctl("dispatch", "setprop", f"address:{addr} noanim 1")

        hyprctl("dispatch", "movewindowpixel",
                f"exact {geo['x']} {geo['y']},address:{addr}")
        if not skip_size and "w" in geo and "h" in geo:
            hyprctl("dispatch", "resizewindowpixel",
                    f"exact {geo['w']} {geo['h']},address:{addr}")

        time.sleep(0.05)
        hyprctl("dispatch", "setprop", f"address:{addr} noanim 0")
        time.sleep(0.5)
    finally:
        _restoring.discard(addr)


def periodic_snapshot():
    while True:
        time.sleep(1)
        try:
            snapshot()
        except Exception:
            pass


threading.Thread(target=periodic_snapshot, daemon=True).start()

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
    s.connect(SOCKET2)
    buf = ""
    while True:
        chunk = s.recv(4096).decode(errors="replace")
        if not chunk:
            break
        buf += chunk
        while "\n" in buf:
            line, buf = buf.split("\n", 1)
            if ">>" not in line:
                continue
            ev, pay = line.split(">>", 1)

            if ev == "openwindow":
                parts = pay.split(",", 3)
                if len(parts) >= 3:
                    addr = "0x" + parts[0]
                    cls  = parts[2]
                    threading.Thread(
                        target=restore, args=(addr, cls), daemon=True
                    ).start()

            elif ev == "closewindow":
                threading.Thread(target=snapshot, daemon=True).start()
