# 系统功能说明

> CachyOS · linux-cachyos · niri 26.04 · DankMaterialShell 1.5 · Wayland · NVIDIA
> 与配置文件同步维护；键位以仓库内配置为准，DMS 运行时设置（`settings.json` 不入库）按本机当前值记录。

---

## 目录

- [系统基础](#系统基础)
- [桌面环境（niri）](#桌面环境niri)
- [状态栏与 Shell（DankMaterialShell）](#状态栏与-shelldankmaterialshell)
- [动态主题系统（Matugen）](#动态主题系统matugen)
- [终端（Kitty）](#终端kitty)
- [Shell（Fish）](#shellfish)
- [编辑器（Neovim）](#编辑器neovim)
- [文件管理](#文件管理)
- [输入法（Fcitx5 + Rime）](#输入法fcitx5--rime)
- [密钥与身份验证](#密钥与身份验证)
- [多媒体](#多媒体)
- [截图与标注](#截图与标注)
- [Git 工作流](#git-工作流)
- [网络与代理](#网络与代理)
- [reMarkable 工作流](#remarkable-工作流)
- [AI 与开发工具](#ai-与开发工具)
- [游戏与兼容层](#游戏与兼容层)
- [人脸识别解锁](#人脸识别解锁)
- [系统优化](#系统优化)

---

## 系统基础

| 项目 | 内容 |
|------|------|
| 发行版 | CachyOS（Arch-based，BORE 调度器优化） |
| 内核 | linux-cachyos / linux-cachyos-lts（双内核，各带 nvidia-open 模块） |
| 引导 | Limine（`limine-snapper-sync` 把 Snapper 快照挂进启动菜单；`/usr/local/bin/mkinitcpio` 是 limine-mkinitcpio-hook 的包装） |
| 文件系统 | Btrfs + snapper（pacman 前后快照），btrfs-assistant 图形管理 |
| 显示 | 内屏 2560×1600 @ 300Hz，scale 1，VRR 按需；按厂商/型号匹配（连接器名在 eDP-1/eDP-2 间漂移） |
| GPU | NVIDIA（nvidia-open 内核驱动 + libva-nvidia-driver 硬解），Intel 核显作为混合显卡副卡（`nvidia-prime`、`switcheroo-control`） |
| 音频 | PipeWire + WirePlumber |
| 蓝牙 | BlueZ（DMS 控制中心管理） |
| 网络 | NetworkManager + iwd 后端；mihomo TUN 代理 |
| 字体 | **Maple Mono NF CN**（手动安装到 `~/.local/share/fonts/MapleMono`）全系统统一 11pt：终端 / 编辑器 / GTK / Qt / DMS / fcitx5 / fontconfig 三大族别名 |
| 浏览器 | Brave Nightly（`mimeapps.list` 默认，`Mod+B` 启动） |
| 图标 | Papirus（文件夹色随壁纸） |

---

## 桌面环境（niri）

### 窗口管理

- **滚动平铺**（列式无限横向画布）。边框 / 焦点环宽 4、圆角 5、窗口间距由 DMS 托管（`dms/layout.kdl`，DMS Settings → Compositor & Layout 调整）；屏幕边缘留白 `struts 6`（`config.kdl`）
- 预设列宽 1/3 → 1/2 → 2/3，默认 1/2；背景透明（DMS 壁纸绘制在 backdrop 层）
- 壁纸 / 锁屏 / 空闲管理 / polkit / 通知 / Alt+Tab 样式全部由 DMS 接管（`dms.service` 随 graphical-session 自启）
- 触摸板：tap、自然滚动、flat 加速，外接鼠标插入自动禁用（niri 内置 `disabled-on-external-mouse`）；鼠标自然滚动 + flat
- VRR `on-demand`：仅 mpv / Steam 游戏窗口显示时启用，避免桌面场景 NVIDIA VRR 光标卡顿
- XWayland 由 xwayland-satellite 透明支持
- 独立便签工作区 `scratch`，`workspace-auto-back-and-forth` 使 `Mod+S` 再按返回
- 客户端不画标题栏（`prefer-no-csd`）；热键浮层启动时不弹

### 环境变量（`environment {}`）

```
LIBVA_DRIVER_NAME=nvidia            # VA-API 硬解
GBM_BACKEND=nvidia-drm              # Wayland 渲染后端
__GLX_VENDOR_LIBRARY_NAME=nvidia
ELECTRON_OZONE_PLATFORM_HINT=auto   # Electron 应用走 Wayland
SAL_USE_VCLPLUGIN=gtk3              # LibreOffice 用 GTK3 前端，吃 adw-gtk3 + matugen 配色
QT_QPA_PLATFORMTHEME=qt5ct:qt6ct    # Qt 应用读 qt5ct/qt6ct 的字体与配色
```
fcitx5 的 `XMODIFIERS` / `QT_IM_MODULE` / `SDL_IM_MODULE` 在 `environment.d/fcitx5.conf`。

### 启动项

`fcitx5 -d --replace`。剪贴板历史由用户单元 `cliphist.service` 提供（`wl-paste --watch cliphist store`）。

### 键位（`Mod = Super`）

| 快捷键 | 功能 |
|--------|------|
| `Super + Shift + /` | 热键浮层 |
| `Super + Q` / `E` / `R` / `B` | Kitty / Thunar / DMS 启动器 / 默认浏览器（`xdg-open https://`） |
| `Super + C` | 关闭窗口 |
| `Super + V` / `Super + Shift + V` | 切换浮动 / 在浮动与平铺层间切焦点 |
| `Super + P` | 循环预设列宽 |
| `Super + -` / `=` | 列宽 ±10%；加 `Shift` 调窗口高度 |
| `Super + F` / `Super + M` / `Super + Shift + F` | 列最大化 / 传统最大化（贴边）/ 全屏 |
| `Super + ,` / `.` | 窗口并入当前列 / 移出成独立列 |
| `Super + H/J/K/L` | 焦点左右列 / 上下窗口或工作区 |
| `Super + Ctrl + H/J/K/L` | 移动列 / 移动窗口或跨工作区 |
| `Super + O` | Overview（DMS 集成） |
| `Alt + Tab` | 最近两个窗口互切（跨工作区，样式 `dms/alttab.kdl`） |
| `Super + 1–0` / `Super + Shift + 1–0` | 切换 / 移动到工作区 1–10 |
| `Super + S` / `Super + Shift + S` | 切换 / 移动到 scratch 工作区 |
| `Super + 滚轮` | 切换工作区（150ms 冷却） |
| `Super + 左键拖` / `右键拖` | 移动 / 缩放窗口（niri 内置） |
| `Super + A` | 框选截图 → 剪贴板 → Satty 标注 |
| `Super + Shift + A` | 当前窗口截图（`~/Pictures/Screenshots` + 剪贴板） |
| `Super + Ctrl + A` | 全屏截图 → Satty |
| `Super + Alt + A` | 区域录屏（wf-recorder，再按停止，存 `~/Downloads`） |
| `Print` | niri 内置交互式截图 |
| `Super + Shift + L` | 锁屏（DMS） |
| `Super + Shift + E` | 退出 niri |
| 多媒体键 | wpctl 音量/静音/麦克风、brightnessctl 亮度、playerctl 播放控制（锁屏时可用） |
| 三指纵扫 | 切换工作区（工作区纵向排列） |

### 窗口规则

- 自动浮动：thunar、nautilus、blueman-manager、blueberry、nm-connection-editor、wechat、蓝信、Telegram、satty、quickshell（DMS 设置窗）、steam_app_default、dankcalendar、Lutris
- mpv：浮动，默认 800×450，VRR 触发
- `steam_app_*`：VRR 触发
- kitty：打开即列最大化
- 浮动窗口默认居中（niri 原生）
- DMS 图层：`quickshell`、`dms:blurwallpaper` 放入 backdrop；bar / frame 命名空间不做背景穿透

---

## 状态栏与 Shell（DankMaterialShell）

### 顶部状态栏（`barConfigs[default]`）

| 左侧 | 中央 | 右侧 |
|------|------|------|
| 启动器、工作区切换器、当前窗口标题（带图标）、运行中应用（紧凑、仅当前工作区） | 媒体、时钟（24h，`yyyy-MM-dd`）、天气 | 托盘（图标按主色调染色）、剪贴板、CPU、内存、通知、电池、控制中心 |

字号缩放 0.92，组件描边用主色，无阴影，不自动隐藏；滚轮：横向切列、纵向切工作区。

### 启动器（Launcher V2，micro 尺寸）与插件

| 触发 | 插件 |
|------|------|
| `!` | niriWindows：列出并切换 niri 窗口 |
| `=` | calculator：算式求值，结果进剪贴板 |
| `:e` | emojiLauncher：emoji / Unicode 搜索 |
| `?` / `cb` | 内置：设置搜索 / 剪贴板搜索 |
| — | **hotspotInternet**、**usbInternet**（自研，控制中心开关 + 状态栏胶囊；`FileView` 监听 flag 文件，脚本或 CLI 改动即时反映，见「网络与代理」） |

第三方插件由 `dms plugins install` 安装（install.sh 已包含；含独立 git 仓库，不入库），自研两个在仓库 `DankMaterialShell/plugins/`。后端：`dsearch`（Spotlight 文件索引，`danksearch/config.toml` 索引 `~` 深度 6）、`dcal`（日历，`dankcal/ui-settings.json`）。

### 控制中心

音量 / 亮度滑块；网络、蓝牙、音频、VPN、屏幕共享图标；夜间模式 / 暗色模式；自研两个翻墙开关。

### OSD / 通知

- OSD：音量、亮度、麦克风静音、Caps Lock、电源档位、音频输出切换
- 通知：低 / 普通 5s，紧急不自动消失；紧凑模式、去重、进度条、阴影；历史最多 10 条、保存 7 天
- 声音：系统音效主题，新通知 / 音量变化 / 充电接入有提示音，播放媒体时静音

### 锁屏

时钟、日期、头像、媒体播放器、电源操作；howdy 人脸识别（PAM `dankshell`）；淡入过渡 5s；`loginctl lock-session` 联动；不在开机 / 休眠前自动锁。

### 主题

`currentThemeName = dynamic`，matugen `scheme-content`，随壁纸；图标 Papirus；字体 Maple Mono NF CN（UI 与等宽同一字体，权重 400）。

---

## 动态主题系统（Matugen）

换壁纸 → 整个桌面配色跟随。DMS 内置模板（`settings.json` 中 `matugenTemplate*`）当前开启：

| 目标 | 产物 |
|------|------|
| DMS 自身 | 状态栏 / 锁屏 / 通知 |
| niri | `niri/dms/colors.kdl`（边框、焦点环、阴影、插入提示） |
| GTK 3/4 | `gtk-3.0/dank-colors.css`（`gtk.css` 链接到它），配合 adw-gtk3 主题 |
| Qt5ct / Qt6ct + KColorScheme | `~/.local/share/color-schemes/DankMatugen.colors`（qt5ct/qt6ct.conf 引用） |
| Kitty | `kitty/dank-theme.conf`、`dank-tabs.conf` |
| Neovim | `nvim/colors/dms.lua`（base46：github_light/dark 向壁纸主色调和 0.5，设背景） |
| dgop | DMS 系统监控 |

关闭的：Alacritty、Foot、Ghostty、WezTerm、Emacs、Zed、VS Code、Vesktop/Equibop/Vencord、Firefox 原生、Hyprland、Zen、MangoWC。Pywalfox 已关（只支持 Firefox 系，LibreWolf 已卸载）；默认浏览器 Brave 没有 matugen 通道，浏览器是桌面里唯一不跟随壁纸配色的部分。

**用户模板**（`runUserMatugenTemplates = true`，`~/.config/matugen/config.toml`）：

- `papirus-folders.sh`：主色 HSV 色相映射到 papirus-folders 颜色名，`sudo papirus-folders -C` 同步 Papirus / Dark / Light 三套（sudoers 免密）
- `zathura`：生成 `zathura/dank-colors`，含重染色板

**触发链路**：DMS 换壁纸 / 切明暗 → `dms matugen generate --run-user-templates`（`Theme.qml`，`regenSystemThemes`）→ 渲染 DMS 内置模板后，直接执行 `~/.config/matugen/config.toml` 里的用户模板，明暗模式随 DMS 当前值。实测：换壁纸后 5 秒内 zathura 配色与 Papirus 文件夹色即更新，无需任何 systemd path/service。

`nvim/colors/dms.lua` 自带 `uv.fs_event` 监听自身与 `settings.json`，文件变化即热重载主题。

---

## 终端（Kitty）

### 性能（2560×1600 @ 300Hz）

`repaint_delay 4`（≈250fps 上限）、`input_delay 2`、`sync_to_monitor yes`；强制 Wayland 后端（`linux_display_server wayland`），标题栏色随背景防 NVIDIA 条带。

### 字体 / 外观

- Maple Mono NF CN 11pt，四种字重
- 透明度 0.85（`Ctrl+Shift+A m/l` 运行时调），无标题栏，内边距 10，光标块状不闪烁
- 配色 **matugen 动态生成**（`dank-theme.conf` / `dank-tabs.conf`，随壁纸与明暗）
- 标签栏 powerline（≥2 个标签才显示）
- 选中即复制到系统剪贴板；Ctrl+点击开 URL；右键粘贴选区已禁用（误触频发）
- `scrollback_lines 10000`，`Ctrl+Shift+H` 用 bat 渲染历史
- Shell 集成：光标形状跟随 Vim 模式，`Ctrl+Shift+Z` 跳上一个 prompt

### 键位（修饰键分工：niri=Super / Neovim=Ctrl,Leader / Kitty=Alt）

| 快捷键 | 功能 |
|--------|------|
| `Alt+T` / `Alt+W` | 新建（继承 cwd）/ 关闭标签 |
| `Alt+Shift+]` / `[` | 下一 / 上一标签；`Alt+1–5` 直跳 |
| `Alt+Enter` / `Alt+Q` | 新建 / 关闭分屏 |
| `Alt+]` / `[` | 下一 / 上一分屏 |
| `Alt+Space` | 布局循环 splits → stack → tall → fat |
| `Alt+=` / `-` / `0` | 字体放大 / 缩小 / 重置 |
| `Alt+E` | 滚动历史送进 Neovim（overlay，v/V 选、y 复制、:q 退出） |
| `Ctrl+V` | 粘贴 |

---

## Shell（Fish）

基于 `cachyos-fish-config`（eza / bat / grep 彩色别名、fastfetch 欢迎、`~/.local/bin` PATH、`!!`/`!$` 展开）。

### 追加工具

| 工具 | 功能 |
|------|------|
| **Starship** | 目录（截 3 层）、Git 分支/状态、Python / Rust / Node / Java 版本、耗时 ≥2s、右侧时钟（Tokyo Night 配色，静态） |
| **zoxide** | `z <模糊路径>`，`zi` fzf 交互 |
| **fzf** | `Ctrl+R` 历史 / `Ctrl+T` 文件 / `Alt+C` 目录 |
| **fnm** | Node 版本管理，进入含 `.nvmrc` / `.node-version` 目录自动切换 |
| **SDKMAN** | `sdk` 命令（fisher 插件 `reitzig/sdkman-for-fish`），装在 `~/.local/share/sdkman` |
| **rustup / cargo** | `conf.d/rustup.fish` 加载 `$CARGO_HOME/env.fish`（minimal profile） |

### 环境变量（XDG）

`config.fish` 中 fnm 对非交互 shell 也生效（脚本要找 node），zoxide / fzf / starship / SSH 密钥加载只在 `status is-interactive` 时初始化。`XDG_{DATA,CONFIG,CACHE,STATE}_HOME` 显式 export（systemd/fish 不会自动给）；Cargo、Rustup、Pyenv、npm cache、CUDA cache、Wine prefix、Gemini CLI、TeX（TEXMFHOME/VAR/CONFIG）、GnuPG 全部映射到 XDG 路径；`EDITOR=nvim`；`SSH_AUTH_SOCK` 指向 systemd socket 激活的 `ssh-agent.socket`；`OLLAMA_MODELS` 在 `~/.local/share/ollama/models`。

`user-tmpfiles.d/cleanup.conf` 每次登录清掉程序无视 XDG 又写回 `$HOME` 的 `.nv`、`.pycorrector`、`.dotnet`（依赖用户级 `systemd-tmpfiles-setup.service`，install.sh 已启用）。

### 函数

- `git`（`functions/git.fish`）：拦截 `push/pull/fetch/clone`，ssh-agent 无密钥时提示解锁 rbw 并加载 Bitwarden SSH Key
- `obsync`：Obsidian 笔记库 `~/Documents/ikate` 一键 add / commit / pull --rebase / push
- 启动时若 rbw 已解锁则静默加载 SSH 密钥

---

## 编辑器（Neovim）

`neovim-nightly-bin`（0.13-dev）+ **Lazy.nvim**；luarocks 关闭；fnm 的 node 注入 PATH 供 Mason 用。

### 主题

`AvengeMedia/base46` + matugen 生成的 `colors/dms.lua`：github_light/dark 向壁纸主色调和，透明背景透出 kitty 0.85；lualine 主题 `_base46("dms")`；nvim-notify 背景动态取 base00 兜底。文件变化自动热重载。

### LSP（Mason 自动安装，配置在 `lsp/*.lua`，Neovim 0.11+ 机制）

| 语言 | 服务器 |
|------|--------|
| Python | `basedpyright`（standard 模式，仅打开文件）+ `ruff`（lint，hover 让给 basedpyright） |
| TS / JS | `ts_ls`（相对路径 import） |
| Tailwind | `tailwindcss`（`className=` 正则） |
| JSON / HTML | `jsonls` / `html` |

诊断：`●` 内联、圆角浮窗、插入模式不更新。`gr*` 系列用 Neovim 内置（grr / gra / grn / gri）。

### 格式化（conform，保存触发，3s 超时）

Python → `ruff_format` + `ruff_organize_imports`；TS/JS/TSX/JSX/JSON/YAML/HTML/CSS/Markdown → Prettier。

### 补全（nvim-cmp）

LSP → LuaSnip（friendly-snippets）→ 路径 → buffer（≥3 字符）。`Ctrl+K/J` 选择，`Tab`/`S-Tab` 选择或跳 snippet，`CR` 确认（不自动选中），`Ctrl+E` 关闭，`Ctrl+Space` 手动触发。

### 插件

| 插件 | 功能 |
|------|------|
| nvim-autopairs / nvim-ts-autotag | 括号、TSX/HTML 标签自动补全 |
| nvim-surround | `ys` / `ds` / `cs` |
| flash.nvim | `s` 跳转，`S` Treesitter 跳转 |
| grug-far | `<leader>rf` 跨文件替换，`<leader>rw` 替换光标词 / 选区（预览 + 逐个确认） |
| neo-tree | `<leader>e`，宽 30，显示隐藏与 gitignored 文件，跟随当前文件 |
| which-key | `<leader>b/c/d/f/h/m/r/t/y` 分组 |
| yazi.nvim | `<leader>yy` 当前文件 / `<leader>yw` 工作区 |
| toggleterm | `<leader>tt` 浮动 / `<leader>th` 水平 / `<leader>tg` LazyGit，`Esc Esc` 退出终端模式 |
| Treesitter（`main` 分支）+ rainbow-delimiters | 18 个 parser 由插件按需编译（需 `tree-sitter-cli`）；高亮与缩进在 `FileType` 时用内置 `vim.treesitter.start()` 启用；彩虹括号。`main` 分支已移除增量选择，`<C-Space>` 不再有该功能 |
| Telescope（fzf-native） | `<leader>ff/fg/fb/fr/fs/fd`（含隐藏文件） |
| gitsigns | `]h` / `[h`，`<leader>hs/hr/hS/hp/hb/hd` |
| lualine / bufferline / indent-blankline / nvim-notify / colorizer / mini.icons | UI |

### 核心键位（`<leader> = Space`）

| 键位 | 功能 |
|------|------|
| `<leader>w` / `q` / `Q` | 保存 / 退出 / 全部强退 |
| `<leader>fm` | 格式化 |
| `<leader>ca` / `rn` | Code Action / 重命名 |
| `K` / `gd` / `gD` | Hover / 定义 / 类型定义 |
| `[d` / `]d` / `<leader>de` | 诊断跳转 / 浮窗 |
| `<leader>s` / `<leader>S` | 光标词全文件替换（直接 / 逐个确认） |
| `<S-h>` / `<S-l>` / `<leader>bd` / `<leader>bo` | Buffer 切换 / 关闭 / 关闭其他 |
| `Ctrl+H/J/K/L` / `Ctrl+方向` | 窗口跳转 / 调整大小 |
| `v` 模式 `<` `>` / `J` `K` | 缩进保持选中 / 移动行 |
| `<leader>p` | 粘贴不覆盖寄存器 |
| `<A-z>` | 切换自动换行 |
| `<Esc>` | 清除搜索高亮 |
| `<leader>mp` | Markdown → PDF（见下） |

### Markdown → PDF（reMarkable 纸感）

`<leader>mp` 先保存，再 `pandoc <file> -d ~/.config/pandoc/remarkable.yaml -o <file>.pdf`（xelatex）：
- `remarkable.tex`：纸色底、KF Readerly 拉丁 + 霞鹜文楷中文 + 京華老宋标题、A4 2.2cm 边距、行距 1.32、代码块/引用块卡片化、长行折行、宽表缩字、中文删除线用 `\CJKsout`（soul 对 CJK 报错）、符号/emoji 映射到 Noto 单色
- `filters.lua`：内联代码在 `/ . : _ -` 处插入断点；mermaid 代码块有 `mmdc` 就渲染成 PDF 内嵌（缓存 `~/.cache/pandoc-mermaid`），否则占位卡片；正文 emoji 包进单色 Noto Emoji

---

## 文件管理

### Yazi

- 面板 1:2:4；图片预览 lanczos3、512MB 缓存；目录优先、自然排序、显示软链目标、size 行模式
- 打开规则：文本 / JSON → nvim（`org.neovim.nvim.desktop` 覆盖版在 kitty 里启动，供 xdg-open / Thunar 用）；图片 → satty（可直接标注）→ xdg-open；视频 → mpv；音频 → xdg-open；PDF → xdg-open（zathura）；压缩包 → 7z / unzip 解压；兜底先 nvim
- 配色 `theme.toml` 为静态 Tokyo Night（不随 matugen）

| 键位 | 功能 |
|------|------|
| `e` | Neovim 编辑（阻塞） |
| `Ctrl+G` | 当前目录 lazygit |
| `Ctrl+T` | 当前目录开新 kitty 窗口 |
| `Y` / `y y` / `y n` / `y d` | 复制完整路径到剪贴板 / yank / 复制文件名 / 复制目录 |
| `g h` `/` `c` `d` `D` `p` | 跳 ~ / / ~/.config / ~/Downloads / ~/Documents / ~/Projects |
| `g S` | SFTP（内置 vfs，`vfs.toml` 配服务，走 ssh-agent） |
| `g r` / `g u` / `g n` / `g m` / ``` `` ``` | gvfs 插件：挂载并跳转 / 卸载 / 添加挂载 / 跳到已挂载 / 跳回挂载前目录（FTP/SMB/MTP 等，密码存 gnome-keyring；`gvfs.private` 不入库） |
| 任务面板 `Esc` / `x` | 关闭 / 取消 |

### Thunar

浮动窗口；归档插件；缩略图已在偏好里关掉（`misc-thumbnail-mode=NEVER`，tumbler 装着但不出图）；自定义动作「Open Terminal Here」（`exo-open`，终端由 `xdg-terminals.list` 指向 kitty）。xfconf 的 `thunar.xml` 随窗口几何频繁改写，不入库。

### Zathura

默认 PDF / 漫画阅读器：matugen 配色、`y` 复制到系统剪贴板、best-fit、`Ctrl+R` 按主题重染（暗色下读白底 PDF）。

---

## 输入法（Fcitx5 + Rime）

- Fcitx5 走 Wayland Input Method 协议；XWayland / Qt / SDL 通过 `environment.d/fcitx5.conf`
- 方案：**Rime**，日常用 `double_pinyin_flypy`（小鹤双拼），底座 `rime-ice` 雾凇拼音 + `rime-wanxiang-gram-zh-hans` 万象语法模型。用户补丁 `~/.local/share/fcitx5/rime/*.custom.yaml`（已入库）：`default.custom.yaml` 引入雾凇预设；`rime_ice` / `double_pinyin_flypy` 两个方案把 `grammar/language` 指到 `wanxiang-lts-zh-hans`（没有这一行万象模型不会生效）、中英开关每次部署重置为英文、词典指向 `rime_ice_ext`
- **增强词库**：`rime_ice_ext.dict.yaml`（已入库）= 雾凇原生五库（8105 字表 / base / ext / tencent / others）+ [Iorest/rime-dict](https://github.com/Iorest/rime-dict) 17 个分库（基础、日常、实用、汉语、成语、饮食、历史、古文、诗词、网络、聊天、计算机、网站、人名、影视、音乐、游戏；未收 sougou / 粤语 / moba / 表情 / 动漫）。Iorest 原文件六到八成是繁体且大多不带拼音，`~/.local/bin/rime-dict-sync` 负责克隆 → `opencc t2s` 转简体 → 靠 8105 字表自动编码 → `rime_deployer` 编译 → 重启 fcitx5；权重全为 1，只在雾凇没有该词时补位，不改变常用词排序。编译后 table 85M，约 15s
- **自动调频**：`translator/user_dict` 钉在 `rime_ice`，用户词库 `rime_ice.userdb` 跨方案共用、换词典不丢；选词后权重累积，同一输入下次前置。词库 userdb / build 产物 / `iorest/` 不入库
- 外观：wechat-light / wechat-dark 主题、跟随系统强调色、横排候选、Maple Mono NF CN 11、Wayland 分数缩放
- 蓝信等 X11-only 应用用 `GTK_IM_MODULE=xim` 兜底（`.desktop` 里指定）

---

## 密钥与身份验证

### Bitwarden（rbw）+ SSH Agent

```
Bitwarden Vault ─(rbw-ssh-load：启动时 / git 操作时按需)─▶ ssh-agent（systemd socket，$XDG_RUNTIME_DIR/ssh-agent.socket，密钥 8h 过期）
                                                              └▶ git push / pull / fetch / clone
```

- 启动时：fish 检查 agent 无密钥且 rbw 已解锁则静默加载
- 按需：`git push/pull/fetch/clone` 时 `functions/git.fish` 提示解锁并加载
- `ssh-agent.service.d/rbw-load.conf` 把 `SSH_AUTH_SOCK` 传给 agent 单元；`.ssh/config` 开 ControlMaster（`~/.cache/ssh/%C`，10 分钟）

### Git Credential

`credential.helper = rbw`（`~/.local/bin/git-credential-rbw`：按主机名取 rbw 条目，跳过 SSH Key 类型）。HTTPS 认证自动取自 Bitwarden。

### GnuPG

`GNUPGHOME=~/.local/share/gnupg`；gpg-agent socket 路径靠 install.sh 生成的 drop-in。

### Polkit / Keyring

DMS 内置 polkit 代理；gnome-keyring 由 PAM `greetd` 自动解锁。本机 login keyring 设为空密码——howdy 人脸登录拿不到密码，keyring 无法用登录密码解锁；且 `gnome-keyring` 的 ChangeWithPrompt 会让 daemon 崩，改密码只能靠空密码方案。

---

## 多媒体

### MPV + uosc

- `vo=gpu-next` + Vulkan，`hwdec=nvdec-copy`，`profile=high-quality`，自动 ICC，窗口自适应 60%，退出记忆进度
- 语言优先中文 → 日文 → 英文，字幕模糊匹配
- uosc 接管 UI（时间轴、控制栏、菜单、缓冲指示、音量），右键菜单。来自 AUR `mpv-uosc`（`/usr/share/mpv/scripts/uosc`，非 mpv 自动加载目录，`mpv.conf` 用 `script=` + `sub-fonts-dir=` 指定）；仓库只保留 `script-opts/uosc.conf`，不再 vendor 整套脚本与字体
- `Ctrl+V` 粘贴 URL / 路径直接播放（`clipboard-paste.lua`，wl-paste）
- 键位：空格暂停、Enter 全屏、←→ 5s、↑↓ 60s、滚轮音量、`m` 静音、`q` 退出

### 音频

PipeWire + WirePlumber；多媒体键 → `wpctl`；播放控制 → `playerctl`；pavucontrol 图形混音；cava 可视化。

### 其他

yt-dlp 下载；VLC 插件全集（GStreamer 解码链，含 VA-API）。

---

## 截图与标注

`Super + A`：`slurp` 框选 → `grim` 截到 `$XDG_RUNTIME_DIR/niri-ss-*.png` → `wl-copy` → `satty --fullscreen` 标注。

Satty：箭头 / 矩形 / 圆 / 文本 / 马赛克 / 荧光笔；右键即复制到剪贴板；`Alt+方向` 平移步长 200px（看长图）；焦点切换工具栏。

`Super + Shift + A` 窗口截图存 `~/Pictures/Screenshots`；`Super + Ctrl + A` 全屏截图；`Super + Alt + A` 区域录屏（wf-recorder）。图片默认打开方式也是 satty（`mimeapps.list`）。

---

## Git 工作流

- **LazyGit**：Neovim `<leader>tg`、Yazi `Ctrl+G`；Tokyo Night 配色（静态），Nerd Font v3，delta 分页
- **git-delta**：`core.pager=delta`、`interactive.diffFilter`，`git diff/log/show/blame` 语法高亮 + 行号，`n`/`N` 跨文件跳转；`merge.conflictStyle=zdiff3`、`diff.colorMoved`。需要并排时 `git -c delta.side-by-side=true diff`
- **Meld**：图形化 diff / merge
- 全局 `git/ignore`：`.claude/`、`CLAUDE.md`、`GEMINI.md`、`.gitignore`（AI 辅助文件不进项目仓库）
- `user.name/email`、delta/merge/diff 选项都在仓库 `git/config`

---

## 网络与代理

| 项目 | 内容 |
|------|------|
| 网络管理 | NetworkManager（iwd 后端、OpenVPN 插件）；`NetworkManager-wait-online` 已 mask |
| 网卡命名 | `10-wlan0.link` 按 MAC 固定 Wi-Fi 为 wlan0；`11-rmk0.link` 固定 reMarkable USB 网卡为 rmk0 |
| 代理 | **mihomo**（Clash Meta）系统服务，`/etc/mihomo`：TUN mixed + fake-ip、mixed-port 6153、API 9090 + zashboard；规则集 MetaCubeX mrs（AI / GitHub / YouTube / Google / Apple / Microsoft / Telegram / 游戏 / 巴哈 / 广告 REJECT / 国内直连）；地区分组香港 / 台湾 / 日本 / 美国 / 新加坡；工作内网网段与 `iam.picc.com` 走内网 DNS 并排除路由 |
| 热点 / USB 翻墙开关 | `hotspot-internet` / `usb-internet` 脚本 + DMS 插件：on = 设备走 mihomo 分流；off = 强制直连不断网（改 flag 文件 + API 刷新 provider + 断存量连接，无需 root）。详见 README「网络共享」 |
| DNS | systemd-resolved（mDNS 关闭防与 avahi 冲突）；mihomo DNS 监听 `0.0.0.0:1053` 供共享设备使用 |
| 防火墙 | UFW；NM 防火墙后端 iptables（共享连接 NAT 同链）；`sysctl net.ipv4.ip_forward=1` |
| 远程 | ssh ControlMaster；旧设备 `40.10.1.53` 显式允许 ssh-rsa |

---

## reMarkable 工作流

- **USB 直连共享上网**：设备插上 → NM `remarkable-usb`（rmk0，10.11.99.2/24，不抢默认路由）→ `remarkable-usb-share.timer` 每 45s 检查设备在线并 SSH 推送网关/DNS 配置（设备 `/etc` 易失，重启自愈）→ 设备经本机 mihomo 出网；`usb-internet` 开关决定是否翻墙
- **remanager**：reMarkable 文件管理器（AUR `remanager-bin`）
- **纸感 PDF**：Neovim `<leader>mp` → pandoc reMarkable 配置（见编辑器一节）
- **recovery 刷机**：`udev/rules.d/70-uuu.rules` 给 NXP uuu 工具 USB 权限（设备 recovery 模式下以 NXP VID 出现）；uuu 本体按需装
- 墨香（微信读书桥接 `moxiang-bridge.service`）属另一项目，不在本仓库

---

## AI 与开发工具

| 工具 | 说明 |
|------|------|
| **Claude Code** | 官方原生安装（`~/.local/share/claude`，`~/.local/bin/claude`）；`~/.claude` 不入库；`git/ignore` 全局忽略 `.claude/` 与 `CLAUDE.md` |
| **Gemini CLI** | npm 全局；`GEMINI_CLI_HOME=~/.config/gemini`，系统提示词 `GEMINI.md` 入库 |
| **Ollama** | `ollama-cuda`，以用户身份运行，模型 `~/.local/share/ollama/models`；不开机自启（install.sh 只装 override），`systemctl start ollama` 按需拉起 |
| mermaid-cli | npm 全局 `mmdc`，pandoc 过滤器渲染 mermaid |
| Python | pyenv（`~/.local/share/pyenv`）、uv、basedpyright / ruff |
| Node | fnm（自动切换）+ Prettier / ts_ls（Mason） |
| Rust | rustup minimal profile，`CARGO_HOME`/`RUSTUP_HOME` 在 XDG |
| Java | SDKMAN（XDG 路径）；Maven 本地仓库 `~/.cache/maven/repository`（`MAVEN_ARGS` 指向 `~/.config/maven/settings.xml`） |
| 其他 | github-cli、lazysql、reqable、radare2、nmap、ffuf、cmake / ninja、aarch64 交叉工具链、android-tools |

---

## 游戏与兼容层

| 工具 | 说明 |
|------|------|
| Wine Staging + gecko / mono | Windows 应用；`WINEPREFIX=~/.local/share/wine` |
| `wine-setup-fonts` | 为任意 prefix 写入系统字体目录与中文字体替换（SimHei/YaHei → Noto Sans CJK，SimSun/KaiTi → Noto Serif CJK） |
| Winetricks / Lutris | 环境配置 / 游戏管理 |
| GameMode（含 lib32） | 性能模式 |
| ProtonUp-Qt | 安装 / 更新 Proton-GE |
| VMware Workstation | 虚拟机（AUR，`vmware-keymaps`） |
| Steam 游戏窗口 | niri VRR 按需触发 |

---

## 人脸识别解锁

**howdy-next**（IR 摄像头 `/dev/video2`，`yunet 0.8` / `sface 0.6942`）：

- PAM 接入 DMS 锁屏（`dankshell`）、`sudo`、`greetd` 登录、`polkit-1` 图形提权
- `tmpfiles.d` 给 video 组读取权限（每次 `howdy add` 后需重新 `systemd-tmpfiles --create`）
- `linux-enable-ir-emitter.service` 开机点亮 IR 补光（参数机器专属）
- `howdy-libguard` pacman 钩子：缺共享库自动禁用 howdy，防 pam_howdy 崩溃锁死密码回退
- 详细排障见 README

---

## 系统优化

| 优化项 | 方式 |
|--------|------|
| 电源档位 | `power-profiles-daemon`（DMS OSD 切换）；`auto-cpufreq` 与之冲突，未装 |
| NVIDIA 待机 | `NVreg_EnableS0ixPowerManagement=1`，s2idle 时 GPU 进入 S0ix |
| Transparent Huge Pages | `madvise`（`tmpfiles.d/thp.conf`） |
| Btrfs 快照 | snapper 仅 pacman 前后编号快照（上限 50，重要 15），timeline 关闭；`snapper-cleanup.timer` 清理；`limine-snapper-sync` 进启动菜单 |
| 键盘 | keyd：capslock ↔ leftcontrol，仅 DELL 外接键盘（内置键盘不换） |
| 网络启动 | mask `NetworkManager-wait-online`；Wi-Fi 后端 iwd |
| 日志 / 固件 / 镜像 | logrotate、fwupd、cachyos-rate-mirrors |
| $HOME 清洁 | XDG 环境变量 + `user-tmpfiles.d/cleanup.conf` |
| 硬盘 | `fstrim.timer`；IO 调度器 NVMe `none` / SATA SSD `mq-deadline`（udev 覆盖） |
| 内存 | `vm.min_free_kbytes=512M` |
| 内核参数 | `nvidia-drm.modeset=1 nvidia-drm.fbdev=1`，initramfs 预载 nvidia 模块（chwd） |
