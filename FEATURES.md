# 系统功能说明

> CachyOS · linux-cachyos · niri · DankMaterialShell · Wayland · NVIDIA

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
- [AI 与开发工具](#ai-与开发工具)
- [游戏与兼容层](#游戏与兼容层)
- [Android 虚拟化](#android-虚拟化)
- [人脸识别解锁](#人脸识别解锁)
- [系统优化](#系统优化)

---

## 系统基础

| 项目 | 内容 |
|------|------|
| 发行版 | CachyOS（Arch-based，BORE 调度器优化） |
| 内核 | linux-cachyos / linux-cachyos-lts（双内核，随时切换） |
| 引导 | Limine（支持 Snapper 快照启动回滚） |
| 文件系统 | Btrfs（自动快照，支持 btrfs-assistant 图形管理） |
| GPU | NVIDIA（nvidia-open 开源内核驱动 + libva-nvidia-driver 硬件视频解码） |
| 音频 | PipeWire + WirePlumber |
| 蓝牙 | BlueZ + blueman |
| 字体 | **Maple Mono NF CN**（全系统统一：终端 / 编辑器 / DMS）；Nerd Font 图标、中文、连字一体 |

---

## 桌面环境（niri）

### 窗口管理

- 布局：**滚动平铺**（列式无限横向画布），边框 2px，窗口间距 `gaps 10` + 屏幕边缘 `struts 10`
- 壁纸 / 锁屏 / 空闲管理 / polkit / Alt+Tab 全部由 DMS 接管（壁纸绘制在 backdrop 层，overview 联动）
- 外接鼠标插入自动禁用触摸板（niri 内置 `disabled-on-external-mouse`，替代原 udev 脚本）
- VRR 按需启用（仅 mpv / Steam 游戏窗口触发，防桌面光标卡顿）
- XWayland 应用由 xwayland-satellite 透明支持（niri 自动拉起）

### 键位（`Mod = Super`）

| 快捷键 | 功能 |
|--------|------|
| `Super + Q` | 打开终端（Kitty） |
| `Super + E` | 打开文件管理器（Thunar） |
| `Super + R` | 打开应用启动器（DMS Launcher） |
| `Super + C` | 关闭当前窗口 |
| `Super + V` | 切换浮动/平铺（`Shift` 在浮动/平铺层间切焦点） |
| `Super + P` | 循环预设列宽（1/3 → 1/2 → 2/3） |
| `Super + -/=` | 列宽微调 ±10%（加 `Shift` 调窗口高度） |
| `Super + F` | 列最大化；`Super + Shift + F` 全屏 |
| `Super + ,/.` | 窗口并入当前列 / 移出成独立列 |
| `Super + A` | 框选截图 → 复制到剪贴板 → 在 Satty 中标注 |
| `Super + Shift + A` | 当前窗口截图（存 `~/Pictures/Screenshots` + 剪贴板） |
| `Super + Ctrl + A` | 全屏截图 → Satty 标注 |
| `Super + Alt + A` | 区域录屏（再按停止，存 `~/Downloads`） |
| `Print` | niri 内置交互式截图 UI |
| `Super + Shift + L` | 锁屏（DMS lock） |
| `Super + H/J/K/L` | 焦点移动（Vim 方向） |
| `Super + Ctrl + H/J/K/L` | 移动窗口/列 |
| `Super + O` | 总览（overview，DMS 集成） |
| `Super + 1–0` | 切换工作区 1–10 |
| `Super + Shift + 1–0` | 移动窗口到工作区 |
| `Super + S` | scratch 便签工作区（再按返回） |
| `Super + 鼠标滚轮` | 切换工作区 |
| `Super + 左键拖拽` | 移动窗口 |
| `Super + 右键拖拽` | 缩放窗口 |
| `Alt + Tab` | 窗口切换（DMS，`dms/alttab.kdl` 托管） |
| `Super + Shift + E` | 退出 niri 会话 |
| 多媒体键 | 音量、亮度、播放控制（playerctl） |
| 三指纵扫 | 切换工作区（niri 工作区为纵向排列） |

### 窗口规则（自动应用）

- 浮动窗口默认居中打开（niri 原生行为，文件对话框无需单独规则）
- satty、mpv、thunar、Telegram、WeChat、蓝信、nm-connection-editor、蓝牙管理器、DMS 设置窗口 → 自动浮动
- VS Code Insiders → 透明度 0.85（与 Kitty 一致）
- mpv 浮动默认 800×450

### NVIDIA Wayland 适配

```
LIBVA_DRIVER_NAME=nvidia       # VA-API 视频硬解
GBM_BACKEND=nvidia-drm         # Wayland 渲染后端
__GLX_VENDOR_LIBRARY_NAME=nvidia
ELECTRON_OZONE_PLATFORM_HINT=auto  # Electron 应用防闪烁
```

---

## 状态栏与 Shell（DankMaterialShell）

### 顶部状态栏布局

| 左侧 | 中央 | 右侧 |
|------|------|------|
| 启动器按钮、工作区切换器、当前窗口名、运行中应用（当前工作区） | 媒体播放、时钟、天气 | 系统托盘、剪贴板、CPU 用量、内存用量、通知按钮、电池、控制中心 |

### 控制中心功能

- 音量 / 亮度滑块
- Wi-Fi / 蓝牙 / 音频输出输入 / VPN 快速开关
- 夜间模式 / 暗色模式切换

### OSD 提示

音量变化、媒体音量、屏幕亮度、麦克风静音、大写锁定、电源配置档位、音频输出切换均有浮层提示。

### 通知系统

- 低/普通/紧急优先级独立超时（5s / 5s / 永不消失）
- 历史记录最多保留 50 条，保存 7 天
- 淡入淡出动画 + 阴影

### 锁屏

- 显示时钟、日期、用户头像、媒体播放器、电源操作
- 支持人脸识别解锁（howdy）
- 淡入过渡动画（grace period 5s）、DPMS 联动

### 其他

- **动态主题**：`currentThemeName = "dynamic"`，完全跟随壁纸色彩（Matugen scheme-content）
- 图标主题：Papirus
- 字体：Maple Mono NF CN（全局）
- 音效：系统音效主题，新通知/音量变化/充电接入有提示音
- tmux 集成（MUX 类型）

---

## 动态主题系统（Matugen）

换壁纸时，整个桌面的配色自动跟随更新，覆盖范围：

| 覆盖目标 | 说明 |
|----------|------|
| DMS（状态栏/锁屏/通知） | 主题核心 |
| niri | 边框色（`niri/dms/colors.kdl` 托管） |
| GTK 3/4 | 所有 GTK 应用 |
| Qt5ct / Qt6ct | Qt 应用 |
| Kitty | 终端配色 |
| VS Code Insiders | 编辑器主题 |
| LibreWolf / Firefox | 浏览器主题（Pywalfox） |
| Vesktop / Equibop | Discord 客户端 |
| Ghostty / Foot / Alacritty / WezTerm | 备用终端 |
| Emacs / Zed | 备用编辑器 |
| Papirus 文件夹颜色 | 自动同步为主色调（papirus-folders + sudoers 免密） |
| Neovim | **主动排除**（由 dankcolors.lua 固定配色方案，防止 Matugen 覆盖） |

**触发链路**：DMS 换壁纸 → 写入 `~/.local/state/DankMaterialShell/session.json` → systemd path unit 检测到文件变化 → 触发 `dms-user-matugen.service` → 执行 `apply-user-templates.sh` → matugen 渲染用户模板 → papirus-folders 更新图标颜色。

---

## 终端（Kitty）

### 性能（针对 2560×1600 @ 300Hz 内屏优化）

- `repaint_delay = 4ms`（≈ 250fps 上限）、`input_delay = 2ms`、`sync_to_monitor = yes`

### 字体

- Maple Mono NF CN 11pt，覆盖正常/粗体/斜体/粗斜体四种字重

### 功能

- **透明度 0.85**，支持运行时 `Ctrl+Shift+A m/l` 动态调节
- 选中即复制到系统剪贴板（Wayland clipboard）
- Ctrl+点击打开 URL
- `scrollback_lines = 10000`，`bat` 渲染历史（保留颜色）
- Shell 集成：光标形状跟随 Vim Normal/Insert 模式；`Ctrl+Shift+Z` 跳转上一个 prompt
- 多标签（Alt+T 新建，Alt+W 关闭，Alt+1–5 直跳）
- 多分屏（Alt+Enter 水平分屏，Alt+]/[ 切换）
- 布局循环（Alt+Space）：splits → stack → tall → fat

### 键位（修饰键分工：niri=Super / Neovim=Ctrl,Leader / Kitty=Alt）

| 快捷键 | 功能 |
|--------|------|
| `Alt+T` | 新建标签 |
| `Alt+W` | 关闭标签 |
| `Alt+Enter` | 新建分屏 |
| `Alt+Q` | 关闭分屏 |
| `Alt+]/[` | 切换分屏/上一分屏 |
| `Alt+Shift+]/[` | 下一标签/上一标签 |
| `Alt+Space` | 切换布局 |
| `Alt+=/-` | 字体放大/缩小 |
| `Alt+0` | 重置字体大小 |
| `Alt+E` | 在 Neovim 中浏览终端滚动历史 |
| `Ctrl+V` | 粘贴 |

### 配色

Tokyo Night（与合成器边框色 `#33ccff` / `#00ff99` 风格统一）。

---

## Shell（Fish）

基于 `cachyos-fish-config`，在此之上添加：

### 内置增强（cachyos 提供）

- `eza` / `bat` / `grep` 彩色别名
- `fastfetch` 欢迎信息
- `!!` / `!$` 历史展开补全

### 追加工具

| 工具 | 功能 |
|------|------|
| **Starship** | Prompt：显示目录（缩短至 3 层）、Git 分支/状态、Python/Rust/Node 版本 |
| **zoxide** | 智能 `cd`；`z <模糊路径>` 跳转，`zi` fzf 交互选择 |
| **fzf** | `Ctrl+R` 历史搜索 / `Ctrl+T` 文件选择 / `Alt+C` 目录跳转 |
| **fnm** | Node 版本管理；进入含 `.nvmrc`/`.node-version` 目录自动切换版本 |

### 环境变量（XDG 规范）

Cargo、Rustup、Pyenv、npm cache、CUDA cache、Wine prefix、GNUPG、TeX 等全部映射到 XDG 标准路径，保持 `$HOME` 干净。

### Git 集成（`functions/git.fish`）

拦截 `git push/pull/fetch/clone`：ssh-agent 无密钥时自动检查 rbw 状态并提示解锁，然后加载 Bitwarden SSH 密钥，再执行原始命令。

---

## 编辑器（Neovim）

使用 `neovim-nightly-bin` + **Lazy.nvim** 插件管理。

### LSP（语言服务器）

通过 Mason 自动安装和管理：

| 语言 | 服务器 |
|------|--------|
| Python | `basedpyright`（类型检查）+ `ruff`（lint） |
| TypeScript / JavaScript | `ts_ls` |
| Tailwind CSS | `tailwindcss` |
| JSON | `jsonls` |
| HTML | `html` |

诊断：`●` 前缀内联显示，圆角浮窗，保存时不更新（防止跳动）。

### 格式化（conform.nvim，保存时自动触发）

| 语言 | 格式化工具 |
|------|-----------|
| Python | ruff_format + ruff_organize_imports |
| TS/JS/TSX/JSX | Prettier |
| JSON / YAML / HTML / CSS / Markdown | Prettier |

### 补全（nvim-cmp）

来源：LSP → LuaSnip（含 friendly-snippets 内置代码片段）→ 路径 → 当前 buffer（≥3 字符触发）。

键位：`Ctrl+K/J` 上下选择，`Tab`/`S-Tab` 选择或跳转 snippet，`CR` 确认（不自动选中），`Ctrl+E` 关闭。

### 编辑器功能

| 插件 | 功能 |
|------|------|
| nvim-autopairs | 括号自动补全，与 cmp 集成 |
| nvim-ts-autotag | TSX/HTML 标签自动补全/重命名 |
| Comment.nvim | `gcc` 行注释，`gc<motion>` 块注释 |
| nvim-surround | `ys`/`ds`/`cs` 包裹操作 |
| flash.nvim | `s` 跳转，`S` Treesitter 跳转 |
| neo-tree | 文件树（宽 30，显示隐藏文件和 gitignored 文件，跟随当前文件） |
| which-key | 快捷键提示（`<leader>b/c/d/f/h/m/t/y` 分组） |
| yazi.nvim | `<leader>yy` 打开 yazi（当前文件），`<leader>yw` 打开（工作区） |
| toggleterm | `<leader>tt` 浮动终端，`<leader>th` 水平终端，`<leader>tg` LazyGit |

### Treesitter

语法高亮、增量选择、自动缩进。

### Telescope

模糊搜索（fzf-native 加速，半透明背景与 Kitty 协同）：

| 快捷键 | 功能 |
|--------|------|
| `<leader>ff` | 查找文件（含隐藏文件） |
| `<leader>fg` | 全局文本搜索（含隐藏文件） |
| `<leader>fb` | 打开的 Buffer |
| `<leader>fr` | 最近文件 |
| `<leader>fs` | 文档符号 |
| `<leader>fd` | 诊断 |

### Git（gitsigns）

行级 diff 标记（▎ 新增/修改，删除标记），快捷键：`]h`/`[h` 跳转 hunk，`<leader>hs/hr/hS/hp/hb/hd` 暂存/重置/预览/blame/diff。

### UI

- lualine 状态栏（全局，显示模式/分支/diff/诊断/文件名/编码/进度/位置）
- bufferline 标签栏（LSP 诊断标记，Neotree offset）
- indent-blankline 缩进参考线（`│` 字符，scope 高亮）
- nvim-notify 通知浮窗（2500ms 超时，紧凑风格）
- nvim-colorizer 颜色码内联预览（支持 Tailwind / CSS）
- mini.icons 图标集

### 固定配色方案（dankcolors.lua）

Neovim 使用独立的 base16 配色（深蓝底 `#121318` + 粉/绿/紫高亮），**不被 Matugen 覆盖**。配色文件被 `uv.fs_event` 监听，文件变化时自动热重载主题（用于 Matugen 手动同步场景）。

### Markdown → PDF

`<leader>mp`：调用 pandoc + xelatex 将当前 Markdown 文件导出为 PDF，使用 Maple Mono NF CN 字体，2.5cm 页边距。

### 核心键位（`<leader> = Space`）

| 键位 | 功能 |
|------|------|
| `<leader>e` | 文件树 |
| `<leader>w` / `<leader>q` | 保存 / 退出 |
| `<leader>fm` | 格式化 |
| `<leader>ca` / `<leader>rn` | Code Action / 重命名 |
| `K` | Hover 文档 |
| `gd` / `gD` | 跳转定义 / 类型定义 |
| `[d` / `]d` | 上/下一个诊断 |
| `<leader>de` | 诊断浮窗 |
| `<S-h>` / `<S-l>` | 上/下一个 Buffer |
| `<leader>bd` / `<leader>bo` | 关闭当前 / 关闭其他 Buffer |
| `<Esc>` | 清除搜索高亮 |
| `Ctrl+H/J/K/L` | 窗口跳转 |
| `Ctrl+方向键` | 调整窗口大小 |
| `v` 模式 `<` / `>` | 缩进（保持选中） |
| `v` 模式 `J` / `K` | 移动选中行 |
| `<leader>p` | 粘贴不覆盖寄存器 |

---

## 文件管理

### Yazi（终端文件管理器）

- 面板比例 1:2:4（预览区更宽）
- 图片预览（kitty 图形协议，Lanczos3 滤镜，512MB 图片缓存）
- 目录优先，自然排序，显示软链接目标
- 视频缩略图（ffmpegthumbnailer）

**打开规则**：

| 文件类型 | 打开方式 |
|----------|----------|
| 文本/代码/JSON | Neovim |
| 图片 | Satty（可直接标注）→ 备选 xdg-open |
| 视频 | mpv |
| 音频 | xdg-open |
| PDF | LibreWolf |
| 压缩包 | 7-Zip / unzip 解压 |

**GVFS 插件**：支持 SMB/NFS/MTP 等网络文件系统挂载（gnome-keyring 认证）。

### Thunar（图形文件管理器）

浮动窗口模式，支持归档插件（file-roller）、缩略图（tumbler）、压缩包操作。

---

## 输入法（Fcitx5 + Rime）

- 框架：Fcitx5（Wayland Input Method Protocol 原生支持，不需要设置 `GTK_IM_MODULE`）
- 输入方案：**Rime**
  - `rime-ice`（雾凇拼音，词库全面）
  - `rime-wanxiang-gram-zh-hans`（万象语法模型，AI 纠错加持）
- 主题：微信风格（fcitx5-theme-wechat）
- XWayland 应用通过 `XMODIFIERS=@im=fcitx` 支持

---

## 密钥与身份验证

### Bitwarden（rbw）+ SSH Agent

```
Bitwarden Vault
      │
      ▼ rbw-ssh-load（启动时 / git 操作时按需触发）
ssh-agent（systemd socket 激活：$XDG_RUNTIME_DIR/ssh-agent.socket）
      │
      ▼ git push / pull / fetch / clone
```

- **启动时**：fish 配置检查 ssh-agent 是否有密钥，若无则在 rbw 已解锁的前提下静默加载（不打断用户）
- **按需**：执行 `git push/pull/fetch/clone` 时，`functions/git.fish` 检测 agent 状态，若无密钥则提示解锁 rbw 并加载，全程交互引导

### Git Credential

`git config credential.helper = rbw`，HTTPS 认证自动从 Bitwarden 取用。

### GnuPG

`GNUPGHOME` 指向 `~/.local/share/gnupg`（XDG 规范），gpg-agent socket 通过 systemd drop-in 传递正确路径。

### Polkit

DMS 内置 polkit 代理提供图形认证弹窗（sudo 提权场景）。

---

## 多媒体

### MPV + uosc

- uosc：现代化 UI（时间轴、控制栏、顶部菜单栏、缓冲指示器、音量控制）
- 剪贴板粘贴脚本（`clipboard-paste.lua`）：直接粘贴 URL/路径播放
- 支持 VA-API 硬件视频解码（NVIDIA）

### 音频控制

- PipeWire + WirePlumber 后端
- `wpctl` 控制音量/静音（多媒体键绑定）
- `playerctl` 控制媒体播放（上一曲/暂停/下一曲）
- pavucontrol 图形混音器

### yt-dlp

视频/音频下载工具，支持各大平台。

---

## 截图与标注

**完整流程（一键）**：`Super + A`

```
slurp（框选区域）
    │
    ▼
grim（截取 Wayland 帧）→ 保存到 $XDG_RUNTIME_DIR/niri-ss-*.png
    │
    ├── wl-copy（复制到剪贴板）
    │
    └── satty（打开标注工具）
```

Satty 支持：箭头、矩形、圆形、文本、马赛克、荧光笔标注，完成后可直接复制/保存。

---

## Git 工作流

### LazyGit

- 在 Kitty 内：`<leader>tg`（Neovim toggleterm 浮动）或 `<leader>lg`（直接启动）
- 在 Yazi 内：`Ctrl+G` 打开（yazi 插件集成）

### git-delta

`diff` 输出增强：语法高亮、行号显示、side-by-side 对比。

### Meld

图形化 diff/merge 工具（复杂合并冲突备用）。

---

## 网络与代理

- 网络管理：NetworkManager（含 OpenVPN 支持）
- 代理：**mihomo**（Clash Meta 核心），配置文件 `~/.config/mihomo/config.yaml`（不在仓库中）
- Git 代理：`http.proxy = http://127.0.0.1:6153`（已写入 git config）
- DNS：systemd-resolved（关闭 mDNS，防止与 avahi 冲突）
- 防火墙：UFW

---

## AI 与开发工具

| 工具 | 说明 |
|------|------|
| **Ollama** | 本地 LLM 推理（CUDA 加速，模型存于 `~/.local/share/ollama/models`），以用户身份运行 |
| **Claude Code** | Anthropic CLI（`~/.claude/`，不在仓库中） |
| **Gemini CLI** | Google CLI（`~/.config/gemini/`） |
| VS Code Insiders | 透明度 0.75，Wayland 原生运行，配置与快捷键同步 |
| pyenv | Python 版本管理 |
| fnm | Node.js 版本管理（自动切换） |
| Rust / Cargo | 工具链（路径遵循 XDG） |

---

## 游戏与兼容层

| 工具 | 说明 |
|------|------|
| Wine Staging | Windows 应用兼容层（wine-gecko + wine-mono） |
| Winetricks | Wine 环境配置助手 |
| Lutris | 游戏管理器（支持 Wine/Steam/GOG 等多后端） |
| GameMode | CPU/GPU 游戏性能模式（lib32 支持） |
| Proton-GE | Steam 自定义 Proton，提升 Linux 游戏兼容性 |
| VMware Workstation | 虚拟机（内核模块已配置） |

---

## Android 虚拟化

**Waydroid**：基于 LXC 的 Android 容器，以 1280×720 浮动窗口运行，从启动器（`Super + R`）启动。

---

## 人脸识别解锁

**howdy**（IR 摄像头）：

- DMS 锁屏支持人脸识别（PAM 服务 `dankshell` 已配置）
- `/dev/video2`（IR 摄像头），`yunet_score_threshold = 0.75`，`sface_threshold = 0.6942`
- `tmpfiles.d` 自动赋予 `video` 组读取 howdy 配置/模型的权限

---

## 系统优化

| 优化项 | 方式 |
|--------|------|
| CPU 频率调度 | `auto-cpufreq`，按负载自动切换省电/性能模式 |
| 电源配置档位 | `power-profiles-daemon`（DMS OSD 显示切换） |
| Transparent Huge Pages | 通过 `tmpfiles.d/thp.conf` 禁用（降低延迟抖动） |
| Btrfs 快照 | `snapper` 自动快照，`btrfs-assistant` 图形管理 |
| NVIDIA 内核参数 | `modprobe.d/nvidia-local.conf`（持久化模式等） |
| 系统日志 | `logrotate` 定期清理 |
| 固件更新 | `fwupd` |
| 镜像源 | `cachyos-rate-mirrors` 自动选速 |
| 用户临时文件清理 | `user-tmpfiles.d/cleanup.conf` |
