# dotfiles

CachyOS · niri · DankMaterialShell · Wayland 个人配置。

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
- 部署 PAM 配置 `system/etc/pam.d/`：`dankshell`（DMS 锁屏）、`sudo`、`greetd`（登录）
- 启用 `linux-enable-ir-emitter.service`（开机/唤醒时点亮 IR 补光）

### 新机器：配置 IR 补光

IR 摄像头的补光参数是机器专属的（存于 `/etc/linux-enable-ir-emitter/`，不在仓库中），新机器需先交互式生成一次，否则摄像头画面全黑：

```bash
sudo linux-enable-ir-emitter configure
```

### 录入人脸

```bash
sudo howdy add
sudo systemd-tmpfiles --create /etc/tmpfiles.d/howdy-permissions.conf
```

建议录入 2–3 个模型，分别覆盖不同角度（正脸、略低头看屏幕的姿势）。

`howdy add`/`howdy clear` 每次都会把模型文件重建为 `600 root:root`，DMS 锁屏（`dankshell` PAM 服务）是以普通用户身份读取该文件的，权限不对会导致锁屏识别失效（但 `sudo`/`greetd` 不受影响，因为它们在 PAM 认证阶段已经是 root）。**每次重新录入后都必须重新执行上面的 `systemd-tmpfiles --create`**，让 `howdy-permissions.conf` 里的规则把权限改回 `640 root:video`。

### 关键配置项

配置文件：`/etc/howdy/config.ini`

```ini
[video]
device_path = /dev/video2    # IR 摄像头设备路径，按实际修改

[face]
yunet_score_threshold = 0.75  # 人脸检测置信度（降低可提升角度容忍性）
sface_threshold = 0.6942      # 人脸识别相似度阈值（cosine）
```

### 故障排查：升级后识别失效（`Failure, general abort`）

`howdy-next` 若跨 OpenCV 大版本升级（如 4.x → 5.x），内置的 ONNX 检测/识别模型与已录入的人脸数据会失效，`journalctl` 中表现为持续的 `Failure, general abort`。升级后按包自带的 `post_upgrade` 提示手动执行：

```bash
sudo -i   # 认证若彻底失效，保留一个 root shell 防止锁死自己

# 删除过期内置模型，下载与新版 OpenCV 兼容的模型
rm -f /usr/share/howdy/face_detection_yunet_2023mar_int8bq.onnx
rm -f /usr/share/howdy/face_recognition_sface_2021dec_int8bq.onnx
howdy download-models

# 旧人脸数据是用旧模型算的 embedding，必须重新录入
howdy clear
howdy add

# 重新录入后模型文件权限会变成 600 root:root，DMS 锁屏读不到，必须修回去
systemd-tmpfiles --create /etc/tmpfiles.d/howdy-permissions.conf

howdy test
exit
```

若 `pacman`/`paru` 生成了 `/etc/howdy/config.ini.pacnew`，先 `diff` 确认没有丢失自定义项（摄像头路径、阈值等）再删除。

`opencv` 是系统级依赖，大版本升级（如 4.x → 5.x）不止影响 `howdy-next`，还会连带砸掉其他链接 OpenCV 的 AUR 包——本机遇到过 `linux-enable-ir-emitter`（负责开机/唤醒时点亮 IR 补光）随 opencv 一起崩掉：

```bash
systemctl status linux-enable-ir-emitter.service   # Active: failed 且报 error while loading shared libraries: libopencv_*.so.4xx
```

IR 补光服务挂掉的表现是 `howdy add` 一直报 `All frames were too dark`（摄像头拍到的画面全黑，因为红外灯没点亮），容易被误判为 howdy 本身的问题。若该包的上游还没适配新版 OpenCV 的 pkg-config 包名（如 `opencv5` 而非 `opencv4`），重建会在 meson 阶段报 `Dependency "opencv4" not found`，可临时建一个别名骗过依赖检测（上游适配后记得删掉）：

```bash
sudo ln -sf /usr/lib/pkgconfig/opencv5.pc /usr/lib/pkgconfig/opencv4.pc
paru -S linux-enable-ir-emitter --rebuild
sudo systemctl daemon-reload
sudo systemctl restart linux-enable-ir-emitter.service
```

排查思路：`opencv` 升级后但凡人脸识别异常，先用 `ldd $(which howdy) $(which linux-enable-ir-emitter) | grep opencv` 逐个检查依赖 OpenCV 的二进制是否还挂着旧版本的 `.so`，凡是显示 `not found` 的都需要 `paru -S <pkg> --rebuild`。

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
| `etc/systemd/system/ollama.service.d/override.conf` | ollama 以 afu 用户运行，模型存储在 `~/.local/share/ollama/models` |
| `etc/modprobe.d/nvidia-local.conf` | NVIDIA 内核模块参数 |
| `etc/tmpfiles.d/thp.conf` | 禁用 Transparent Huge Pages（降低延迟） |
| `etc/tmpfiles.d/howdy-permissions.conf` | 授予 video 组读取 howdy 配置/模型的权限 |
| `etc/sudoers.d/papirus-folders` | 允许 wheel 组免密码执行 papirus-folders（matugen 主题同步所需） |
| `etc/pam.d/dankshell` `sudo` `greetd` | howdy 人脸识别接入 DMS 锁屏 / sudo / greetd 登录界面 |
| `etc/greetd/config.toml` | 登录界面 niri 附加 NVIDIA 环境变量前缀（`GBM_BACKEND` 等），避免登录界面与登录后会话的 eDP connector 命名（分辨率/刷新率）不一致 |
| `etc/keyd/default.conf` | capslock ↔ ctrl 互换 |
| `etc/snapper/configs/root` | Btrfs 根分区快照策略 |
| `etc/NetworkManager/conf.d/wifi-backend.conf` | Wi-Fi 后端切换为 iwd |

### NVIDIA

必要的环境变量在 `niri/config.kdl` 的 `environment {}` 中设置：

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
│       ├── niri/            # niri 合成器 + DMS 托管配置（dms/*.kdl）
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
│       ├── keyd/default.conf
│       ├── modprobe.d/nvidia-local.conf
│       ├── NetworkManager/conf.d/wifi-backend.conf
│       ├── pam.d/           # howdy 人脸识别 PAM（dankshell / sudo / greetd）
│       ├── snapper/configs/root
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
| `/etc/linux-enable-ir-emitter/` | IR 摄像头补光参数（机器专属）；新机器需 `sudo linux-enable-ir-emitter configure` 生成 |
