# dotfiles

CachyOS · Hyprland · Wayland 个人配置。

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
4. 配置 fnm + Node LTS，安装 gemini-cli
5. 通过 stow 将 `home/` 下所有配置符号链接到 `$HOME`
6. 将系统配置复制到 `/etc/`（需要 sudo）
7. 启用 ollama、dms systemd 服务

---

## 安装后手动步骤

### 必须

| 步骤 | 命令/操作 |
|------|-----------|
| 代理配置 | 将配置文件放入 `~/.config/mihomo/config.yaml` |
| Bitwarden | `rbw register` |
| SSH 密钥 | 将私钥放入 `~/.ssh/`，`chmod 600 ~/.ssh/id_*` |
| 壁纸 | 将图片放入 `~/Pictures/`，更新 `~/.config/hypr/hyprpaper.conf` 中的路径 |

### 可选

| 步骤 | 说明 |
|------|------|
| VMware | 重新安装 `vmware-workstation`（AUR），执行 `vmware-installer -i` |
| Ollama 模型 | `ollama pull <model>` 重新拉取所需模型 |
| Gemini / Claude | 重新登录：`gemini auth`、`claude /login` |
| Waydroid | `sudo waydroid init` 重新初始化 |

---

## 系统配置说明

以下配置已包含在 `system/` 目录，`install.sh` 会自动应用。若需手动应用：

```bash
# 禁用 systemd-resolved 的 mDNS（避免与 avahi 冲突）
sudo cp system/etc/systemd/resolved.conf.d/no-mdns.conf /etc/systemd/resolved.conf.d/

# ollama 服务以当前用户运行，模型存储在 ~/.local/share/ollama/models
sudo cp system/etc/systemd/system/ollama.service.d/override.conf \
        /etc/systemd/system/ollama.service.d/
sudo systemctl daemon-reload && sudo systemctl enable --now ollama
```

### NVIDIA 必要配置

在 `~/.config/environment.d/`（已包含在 dotfiles 中）中包含以下变量：

```
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
ELECTRON_OZONE_PLATFORM_HINT=auto
```

NVIDIA 已知问题：必须在 `hyprland.conf` 中设置 `no_hardware_cursors = true`，否则光标消失。

---

## 目录结构

```
dotfiles/
├── home/                    # stow --target=$HOME home
│   └── .config/
│       ├── fish/            # shell 配置
│       ├── hypr/            # Hyprland + DMS + hyprpaper
│       ├── kitty/           # 终端
│       ├── nvim/            # Neovim（Lazy.nvim）
│       ├── yazi/            # 文件管理器
│       ├── starship.toml    # prompt
│       ├── lazygit/         # Git TUI
│       ├── mpv/             # 视频播放器
│       ├── satty/           # 截图标注
│       ├── fcitx5/          # 输入法
│       ├── fontconfig/      # 字体配置（Maple Mono 为默认字体）
│       ├── environment.d/   # 用户级环境变量（NVIDIA、XDG 路径等）
│       ├── git/             # git 全局配置（含代理设置）
│       ├── qt5ct/           # Qt5 图标主题
│       ├── qt6ct/           # Qt6 图标主题
│       ├── mimeapps.list    # 默认应用关联
│       ├── user-dirs.dirs   # XDG 用户目录（含 Projects）
│       ├── DankMaterialShell/
│       └── Code - Insiders/User/  # VSCode 设置和快捷键
├── system/                  # 需要 sudo 应用的系统配置
│   └── etc/systemd/
│       ├── resolved.conf.d/no-mdns.conf
│       └── system/ollama.service.d/override.conf
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
