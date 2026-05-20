# dotfiles

CachyOS · Hyprland · DankMaterialShell · Wayland 个人配置。

## 新机器部署

### 前提
- 已完成 CachyOS 基础安装并能进入桌面
- 网络正常

### 一键部署

```bash
git clone https://github.com/bbq191/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

`install.sh` 会自动完成：
1. 安装 paru（AUR helper）和 stow
2. 通过 paru 安装所有软件包（`packages/packages.txt`，含官方源和 AUR）
3. 配置 fnm + Node LTS，安装 gemini-cli
4. 通过 stow 将 `home/` 下所有配置符号链接到 `$HOME`
5. 将系统配置复制到 `/etc/`（需要 sudo）
6. 启用 ollama、dms、ssh-agent.socket systemd 服务
7. 迁移 GnuPG 到 XDG 路径（`~/.local/share/gnupg`），生成 gpg-agent socket 单元 drop-in

---

## 安装后手动步骤

### 必须

| 步骤 | 命令/操作 |
|------|-----------|
| 代理配置 | 将配置文件放入 `~/.config/mihomo/config.yaml` |
| Bitwarden | `rbw register`，然后 `rbw unlock` |
| SSH 密钥 | 在 Bitwarden 中存入 SSH Key 类型条目；`rbw unlock` 后执行 `rbw-ssh-load` 加载到 ssh-agent。后续 `git push/pull/fetch/clone` 会按需自动解锁并加载，无需手动操作 |
| 壁纸 | 将图片放入 `~/Pictures/`，在 DMS 设置中选择壁纸 |
| 人脸识别 | 见下方"人脸识别（howdy）"章节 |

### 可选

| 步骤 | 说明 |
|------|------|
| VMware | 重新安装 `vmware-workstation`（AUR），执行 `vmware-installer -i` |
| Ollama 模型 | `ollama pull <model>` 重新拉取所需模型 |
| Gemini / Claude | 重新登录：`gemini auth`、`claude /login` |
| Waydroid | `sudo waydroid init` 重新初始化 |

---

## 人脸识别（howdy）

锁屏（DMS）和 sudo 均支持 IR 人脸识别解锁。

### 配置

`install.sh` 已自动完成：
- 授予 `video` 组对 `/etc/howdy/` 的读权限（允许用户空间 PAM 调用）
- 配置 PAM 服务 `/etc/pam.d/dankshell`（DMS 锁屏）

### 录入人脸

```bash
sudo howdy add
```

建议录入 2–3 个模型，分别覆盖不同角度（正脸、略低头看屏幕的姿势）。

### 关键配置项

配置文件：`/etc/howdy/config.ini`

```ini
[video]
device_path = /dev/video2    # IR 摄像头设备路径，按实际修改

[face]
yunet_score_threshold = 0.75  # 人脸检测置信度（降低可提升角度容忍性）
sface_threshold = 0.6942      # 人脸识别相似度阈值（cosine）
```

---

## 图标主题（Papirus）

已配置 matugen 用户模板，换壁纸时自动将 Papirus 文件夹颜色同步为当前主题的主色调。

模板位于 `~/.config/matugen/templates/papirus-folders.sh`，由
`~/.config/DankMaterialShell/matugen-config-papirus.toml` 注册。

---

## 系统配置说明

以下配置位于 `system/` 目录，`install.sh` 会自动应用。

| 文件 | 作用 |
|------|------|
| `etc/systemd/resolved.conf.d/no-mdns.conf` | 禁用 systemd-resolved 的 mDNS（避免与 avahi 冲突） |
| `etc/systemd/system/ollama.service.d/override.conf` | ollama 以当前用户运行，模型存储在 `~/.local/share/ollama/models` |
| `etc/modprobe.d/nvidia-local.conf` | NVIDIA 内核模块参数 |
| `etc/tmpfiles.d/thp.conf` | 禁用 Transparent Huge Pages（降低延迟） |
| `etc/tmpfiles.d/howdy-permissions.conf` | 授予 video 组读取 howdy 配置/模型的权限 |
| `etc/sudoers.d/papirus-folders` | 允许 wheel 组免密码执行 papirus-folders（matugen 主题同步所需） |

### NVIDIA

`~/.config/environment.d/` 中包含必要的环境变量：

```
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
ELECTRON_OZONE_PLATFORM_HINT=auto
```

### GnuPG XDG

`GNUPGHOME` 已通过 `environment.d/gnupg.conf` 和 fish config 设置为 `~/.local/share/gnupg`。

`install.sh` 会自动迁移原有的 `~/.gnupg` 数据，并动态生成 gpg-agent socket 单元 drop-in（socket 路径含 GNUPGHOME 的哈希，因此无法静态跟踪在仓库中，每台机器单独生成到 `~/.config/systemd/user/gpg-agent*.socket.d/`）。

---

## 目录结构

```
dotfiles/
├── home/                    # stow --target=$HOME home
│   └── .config/
│       ├── fish/            # shell 配置
│       ├── hypr/            # Hyprland + DMS + hyprpaper
│       ├── kitty/           # 终端
│       ├── nvim/            # Neovim（Lazy.nvim，LSP/which-key/yazi.nvim，含 DMS matugen 主题）
│       ├── yazi/            # 文件管理器（e 键打开 nvim，C-g 打开 lazygit）
│       ├── starship.toml    # prompt
│       ├── lazygit/         # Git TUI
│       ├── mpv/             # 视频播放器
│       ├── satty/           # 截图标注
│       ├── fcitx5/          # 输入法（wechat 主题）
│       ├── fontconfig/      # 字体配置（Maple Mono 为默认字体）
│       ├── git/             # git 全局配置（含代理设置）
│       ├── qt5ct/ qt6ct/    # Qt 图标主题
│       ├── mimeapps.list    # 默认应用关联
│       ├── user-dirs.dirs   # XDG 用户目录（含 Projects）
│       ├── DankMaterialShell/  # DMS 设置 + matugen 用户配置
│       ├── environment.d/   # 用户级环境变量（NVIDIA、GnuPG XDG 等）
│       ├── matugen/         # matugen 用户模板（Papirus 自动换色）
│       ├── systemd/user/    # gpg-agent.service drop-in（GNUPGHOME 传递）
│       └── Code - Insiders/User/  # VSCode 设置和快捷键
├── system/                  # 需要 sudo 应用的系统配置
│   └── etc/
│       ├── modprobe.d/nvidia-local.conf
│       ├── sudoers.d/papirus-folders
│       ├── systemd/resolved.conf.d/no-mdns.conf
│       ├── systemd/system/ollama.service.d/override.conf
│       └── tmpfiles.d/
│           ├── howdy-permissions.conf
│           └── thp.conf
├── packages/
│   └── packages.txt         # 软件包列表（官方源 + AUR，由 paru 统一安装）
├── install.sh               # 一键部署脚本
└── README.md
```

## 不在此仓库中的内容

| 内容 | 原因 |
|------|------|
| `~/.config/mihomo/` | 含代理订阅链接（敏感） |
| `~/.config/rbw/` | 含邮箱地址；新机器需重新 `rbw register` 自动生成 |
| `~/.ssh/` | 私钥 |
| `~/.claude/` / `.claude.json` | Claude Code 认证，硬编码路径 |
| `~/.gemini/` | Gemini CLI OAuth token，硬编码路径 |
| `~/.ollama/` | Ollama 设备密钥，硬编码路径 |
| `/etc/howdy/` | 人脸模型（`models/*.dat`）；新机器需重新 `sudo howdy add` 录入 |
