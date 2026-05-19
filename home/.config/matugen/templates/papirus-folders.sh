#!/usr/bin/env bash
HEX="{{colors.primary.default.hex}}"
HEX="${HEX#\#}"

COLOR=$(python3 -c "
import colorsys
h = '$HEX'
r, g, b = int(h[0:2], 16)/255, int(h[2:4], 16)/255, int(h[4:6], 16)/255
hue, s, _ = colorsys.rgb_to_hsv(r, g, b)
hue *= 360; s *= 100
if   s < 15:           name = 'grey'
elif hue < 15:         name = 'red'
elif hue < 25:         name = 'deeporange'
elif hue < 45:         name = 'orange'
elif hue < 65:         name = 'yellow'
elif hue < 150:        name = 'green'
elif hue < 175:        name = 'teal'
elif hue < 195:        name = 'cyan'
elif hue < 220:        name = 'blue'
elif hue < 235:        name = 'bluegrey'
elif hue < 255:        name = 'indigo'
elif hue < 285:        name = 'violet'
elif hue < 315:        name = 'magenta'
elif hue < 345:        name = 'pink'
else:                  name = 'red'
print(name)
")

command -v papirus-folders &>/dev/null || exit 0
sudo papirus-folders -C "$COLOR" --theme Papirus-Dark
sudo papirus-folders -C "$COLOR" --theme Papirus
sudo papirus-folders -C "$COLOR" --theme Papirus-Light
