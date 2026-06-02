#!/usr/bin/env bash
# 监听 DMS session.json 的壁纸路径变化，提取颜色并执行用户 matugen 模板

SESSION_FILE="$HOME/.local/state/DankMaterialShell/session.json"
CACHE_FILE="$HOME/.local/state/DankMaterialShell/last-wallpaper-color.txt"
STATE_DIR="$HOME/.local/state/DankMaterialShell"
SHELL_DIR="/usr/share/quickshell/dms"
CONFIG_DIR="$HOME/.config/DankMaterialShell"

wallpaper=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)
print(d.get('wallpaperPath', ''))
" "$SESSION_FILE" 2>/dev/null)

[[ -z "$wallpaper" || ! -f "$wallpaper" ]] && exit 1

last=$(cat "$CACHE_FILE" 2>/dev/null)
[[ "$wallpaper" == "$last" ]] && exit 0

# 用 DMS 生成新配色（更新 dms-colors.json 等内置模板）
dms matugen generate \
    --kind image --value "$wallpaper" \
    --state-dir "$STATE_DIR" \
    --shell-dir "$SHELL_DIR" \
    --config-dir "$CONFIG_DIR" \
    --run-user-templates 2>/dev/null

# 读取提取出的 source_color 执行用户模板（papirus-folders 等）
source_color=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)
print(d['colors']['dark']['source_color'])
" "$STATE_DIR/dms-colors.json" 2>/dev/null)

[[ -z "$source_color" ]] && exit 1

matugen color hex "$source_color" -c "$HOME/.config/matugen/config.toml" -q

echo "$wallpaper" > "$CACHE_FILE"
