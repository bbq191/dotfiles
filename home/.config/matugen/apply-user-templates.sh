#!/usr/bin/env bash
# 从 DMS 颜色状态文件提取 source_color，用 matugen 执行用户模板
COLORS_FILE="$HOME/.local/state/DankMaterialShell/dms-colors.json"

source_color=$(python3 -c "
import json, sys
with open('$COLORS_FILE') as f:
    d = json.load(f)
print(d['colors']['dark']['source_color'])
" 2>/dev/null)

[[ -z "$source_color" ]] && exit 1

matugen color hex "$source_color" -c "$HOME/.config/matugen/config.toml" -q
