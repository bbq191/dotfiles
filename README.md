# dotfiles

CachyOS · niri · DankMaterialShell · Wayland · NVIDIA 个人配置。

- `home/`：用 stow 链接到 `$HOME` 的用户配置与脚本
- `system/`：需要 sudo 复制到 `/etc`、`/usr/local/bin` 的系统配置（含 mihomo 配置模板）
- `packages/packages.txt`：软件包清单（官方源 + AUR，paru 统一安装；支持 `pkg  # 说明` 行内注释）
- `install.sh`：一键部署脚本；`FEATURES.md`：各组件功能与键位说明

## 新机器部署

### 前提
- 已完成 CachyOS 基础安装并能进入桌面（或 TTY）
- 网络正常；AUR 与 npm 需要能访问 GitHub（首次可先手动起 mihomo）

### 一键部署

```bash
git clone https://github.com/bbq191/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

`install.sh` 依次完成（可重复执行，均为幂等操作；开头会检查 `home/` 没有未提交改动——第 4 步的 `stow --adopt` + `git restore` 会把未提交内容还原，matugen 重生成的主题文件也算，先 commit 或 stash）：

1. 安装 paru（AUR helper）和 stow
2. 通过 paru 安装 `packages/packages.txt` 中**尚未安装**的软件包（`pacman -T` 筛选；不升级已装包，升级用 `paru -Syu`）
3. fnm 安装 Node LTS（已有默认版本则跳过），全局 npm 安装 `@google/gemini-cli` 与 `@mermaid-js/mermaid-cli`（pandoc 渲染 mermaid 用；命令已存在则跳过）
4. stow 将 `home/` 链接到 `$HOME`（随后 `rime-dict-sync` 拉取 Iorest 增强词库、转简体、编译）：目标位置已有的实体文件按仓库清单逐个备份为 `*.bak-<时间戳>`（已经通过上级目录链接指向仓库的文件会跳过），旧的绝对路径链接原地重建为相对链接；随后 `dconf load` 同步 GTK 字体/主题（Thunar 等纯 GTK3 程序不读 `settings.ini`）
5. 复制 `system/etc`、`system/usr/local/bin` 到系统：resolved / ollama drop-in / NVIDIA modprobe / greetd NVIDIA 覆盖 / tmpfiles（THP、howdy 权限）/ PAM（dankshell、sudo、greetd、polkit-1）/ howdy-libguard 与 pacman 钩子 / sudoers（papirus-folders）/ NetworkManager（iwd 后端、iptables 防火墙后端）/ `.link` 网卡命名（wlan0、rmk0）/ BE200 冷开机固件崩溃自愈（wifi-fw-reset + iwl-fwdump）/ sysctl（ip_forward、min_free_kbytes）/ udev（IO 调度器、uuu）/ keyd / snapper；并 mask `NetworkManager-wait-online`
6. 启用 systemd 服务：系统级 iwd、wifi-fw-reset、keyd、linux-enable-ir-emitter（ollama 只装 override，不自启）；`dms plugins install` 拉取三个第三方启动器插件（calculator / emojiLauncher / niriWindows）；用户级 ssh-agent.socket、dms、cliphist、dcal、dsearch、remarkable-usb-share.timer、systemd-tmpfiles-setup（否则 `user-tmpfiles.d/cleanup.conf` 不生效，本机实测默认 disabled）
7. 初始化目录（wine prefix、ollama 模型、ssh ControlPath）
8. GnuPG 迁移到 XDG 路径（`~/.local/share/gnupg`），生成 gpg-agent socket 单元 drop-in
9. Maven 本地仓库迁移到 `~/.cache/maven/repository`
10. SDKMAN 官方脚本安装到 `~/.local/share/sdkman`，fish 插件文件缺失时 `fisher update` 落地
11. mihomo：从 rbw 取完整订阅链接与面板密码渲染模板，与 `/etc/mihomo/config.yaml` 不同时才写入（`640 root:用户`）并重启服务，相同则只确保服务已启用；建 `/etc/mihomo/flags/`（归当前用户，供外网开关脚本写入）。rbw 未解锁或缺条目则跳过并提示

---

## 安装后手动步骤

### 必须

| 步骤 | 命令 / 操作 |
|------|-------------|
| 字体 | 软件源没有 Maple Mono：从 [subframe7536/maple-font](https://github.com/subframe7536/maple-font/releases) 下载 `MapleMono-NF-CN-unhinted.zip`，解压到 `~/.local/share/fonts/MapleMono/`，`fc-cache -f`。终端 / 编辑器 / GTK / Qt / DMS / fcitx5 全部指向该字体，缺失会整体回退成 DejaVu |
| pandoc 字体 | `<leader>mp` 导出 PDF 依赖 `~/.local/share/fonts/remarkable-pandoc/` 下的 KF Readerly、LXGW WenKai（含 Mono）、KingHwaOldSong、NotoEmoji-Regular.ttf。`remarkable.tex` 以 `/home/afu/...` 绝对路径引用（fontspec 的 `Path=` 不展开 `~`，已实测），换用户名时改文件顶部三个 `\def` |
| Bitwarden | `rbw register`，然后 `rbw unlock`；再 `rbw add mihomo-sub-url`（完整订阅链接）、`rbw add mihomo-secret`（面板密码），重跑 `./install.sh` 或只执行其 mihomo 段生成配置 |
| SSH 密钥 | 在 Bitwarden 中存入 SSH Key 类型条目；`rbw unlock` 后执行 `rbw-ssh-load` 加载到 ssh-agent。之后 `git push/pull/fetch/clone` 会按需自动解锁并加载（`fish/functions/git.fish`） |
| 壁纸 | 将图片放入 `~/Pictures/`，DMS Settings → Wallpaper 选择（或 `dms ipc call wallpaper set <路径>`）。换壁纸会触发整条 matugen 链（见 FEATURES「动态主题」） |
| 明暗自动切换 | DMS Settings → Theme → 自动切换选 **按时间**（深色 19:30 → 07:00），并关闭"与夜间色温共用时段"。不要选"按位置"：dms-shell ≤1.5.3 的 `suncalc.go` 以 UTC 日期零点为基准算日出，东八区/东经 103° 的日出会落到 UTC 前一天，导致每天日出到 08:00 之间被判成夜间（配色跳回深色，调度循环每秒空转，上游 issue [#3179](https://github.com/AvengeMedia/DankMaterialShell/issues/3179)）。此设置存于 `~/.local/state/DankMaterialShell/session.json`，不入库 |
| 登录界面 | `dms greeter enable && dms greeter sync`：生成 `/etc/greetd/config.toml` 与 `/etc/greetd/niri/{config,dms}.kdl`（分辨率/缩放读自 `monitors.json`，壁纸/主题与锁屏同步）。改显示器配置后需重新 `dms greeter sync`；NVIDIA 环境变量在 `niri_overrides.kdl`，不受 sync 覆盖 |
| 人脸识别 | 见下方「人脸识别（howdy）」 |
| Claude Code | 官方原生安装：`curl -fsSL https://claude.ai/install.sh \| bash`（装到 `~/.local/share/claude`，`~/.local/bin/claude` 为链接），然后 `claude` 登录；`~/.claude` 不在仓库 |
| Gemini CLI | `gemini` 首次运行登录（`GEMINI_CLI_HOME=~/.config/gemini`，系统提示词 `GEMINI.md` 在仓库） |
| 网络共享 | 如需热点 / USB 直连 reMarkable，按「网络共享（mihomo）」用 `nmcli` 重建两个连接 |

### 可选

| 步骤 | 说明 |
|------|------|
| VMware | `vmware-workstation`（AUR）安装后执行 `sudo vmware-modconfig --console --install-all` 编译内核模块 |
| Ollama | 不开机自启：`sudo systemctl start ollama` 后 `ollama pull <model>`；模型在 `~/.local/share/ollama/models` |
| 蓝信（人保 e 办） | 无 AUR 包：`debtap` 转换官方 deb 后 `pacman -U`；转换包不声明依赖，需手动 `pacman -S --asexplicit gtk2`（`LxMainNew`/`libcef.so` 链接 gtk2，被当孤儿清掉就起不来）；`.desktop` 在仓库（强制 X11 + fcitx XIM） |
| Obsidian | 笔记库 `~/Documents/ikate` 为 git 仓库，`obsync` 一键 commit/pull --rebase/push |

---

## 人脸识别（howdy）

锁屏（DMS）、sudo、greetd 登录均支持 IR 人脸识别。

### 配置

`install.sh` 已自动完成：
- 授予 `video` 组对 `/etc/howdy/` 的读权限（`tmpfiles.d/howdy-permissions.conf`，DMS 锁屏以普通用户身份调用 PAM）
- 部署 PAM 配置 `system/etc/pam.d/`：`dankshell`（DMS 锁屏）、`sudo`、`greetd`（登录）、`polkit-1`（图形提权弹窗）。`sudo`/`greetd` 归 pambase / greetd 包管理，升级出现 `.pacnew` 时需合并；`polkit-1` 是对 `/usr/lib/pam.d/polkit-1` 的 `/etc` 覆盖，不会有 pacnew
- 启用 `linux-enable-ir-emitter.service`（开机/唤醒时点亮 IR 补光）
- 安装 `howdy-libguard`（`/usr/local/bin`）与 pacman `PostTransaction` 钩子：每次包事务后 `ldd` 检查 `howdy-compare`，缺共享库就自动把 `config.ini` 置 `disabled=true`（并留 marker），库补回后自动恢复。目的是防止 pam_howdy 崩溃污染 sudo/polkit 的密码回退把人锁在门外

### 新机器：配置 IR 补光

补光参数是机器专属的（存于 `/etc/linux-enable-ir-emitter/`，不在仓库），新机器需先交互式生成一次，否则摄像头画面全黑：

```bash
sudo linux-enable-ir-emitter configure
```

### 录入人脸

```bash
sudo howdy add
sudo systemd-tmpfiles --create /etc/tmpfiles.d/howdy-permissions.conf
```

建议录入 2–3 个模型（正脸、略低头看屏幕）。`howdy add`/`howdy clear` 每次都把模型文件重建为 `600 root:root`，DMS 锁屏读不到会导致锁屏识别失效（sudo/greetd 不受影响，它们在 PAM 阶段已是 root）。**每次重新录入后都必须重新执行 `systemd-tmpfiles --create`**，把权限改回 `640 root:video`。

### 关键配置项

`/etc/howdy/config.ini`（不在仓库，本机当前值）：

```ini
[core]
disabled = false               # howdy-libguard 会在缺库时自动改为 true

[video]
device_path = /dev/video2      # IR 摄像头设备路径，按实际修改

[face]
yunet_score_threshold = 0.8    # 人脸检测置信度（降低可提升角度容忍性）
sface_threshold = 0.6942       # 人脸识别相似度阈值（cosine）
```

### 故障排查：升级后识别失效（`Failure, general abort`）

`howdy-next` 若跨 OpenCV 大版本升级（如 4.x → 5.x），内置 ONNX 模型与已录入的人脸数据会失效，`journalctl` 持续出现 `Failure, general abort`。按包的 `post_upgrade` 提示手动处理：

```bash
sudo -i   # 认证若彻底失效，保留一个 root shell 防止锁死自己

rm -f /usr/share/howdy/face_detection_yunet_2023mar_int8bq.onnx
rm -f /usr/share/howdy/face_recognition_sface_2021dec_int8bq.onnx
howdy download-models          # 下载与新版 OpenCV 兼容的模型

howdy clear && howdy add       # 旧 embedding 作废，必须重新录入
systemd-tmpfiles --create /etc/tmpfiles.d/howdy-permissions.conf
howdy test
exit
```

若生成了 `/etc/howdy/config.ini.pacnew`，先 `diff` 确认没丢自定义项（摄像头路径、阈值）再删除。

`opencv` 大版本升级还会连带砸掉其他链接 OpenCV 的 AUR 包，本机遇到过 `linux-enable-ir-emitter` 一起崩：

```bash
systemctl status linux-enable-ir-emitter.service   # failed 且报 error while loading shared libraries: libopencv_*.so.4xx
```

表现是 `howdy add` 一直报 `All frames were too dark`（红外灯没点亮），容易误判为 howdy 本身的问题。若上游还没适配新版 OpenCV 的 pkg-config 名（`opencv5` 而非 `opencv4`），重建会在 meson 阶段报 `Dependency "opencv4" not found`，可临时建别名（上游适配后删掉）：

```bash
sudo ln -sf /usr/lib/pkgconfig/opencv5.pc /usr/lib/pkgconfig/opencv4.pc
paru -S linux-enable-ir-emitter --rebuild
sudo systemctl daemon-reload && sudo systemctl restart linux-enable-ir-emitter.service
```

排查思路：`ldd $(which howdy) $(which linux-enable-ir-emitter) | grep opencv`，凡是 `not found` 的都 `paru -S <pkg> --rebuild`。`howdy-libguard` 在缺库期间会自动禁用 howdy，密码登录不受影响。

另：`jack1`（提供 `libjack`）是 howdy 的间接依赖，不能删；CachyOS 无 `pipewire-jack` 可替代。

---

## 网络共享（mihomo）

### mihomo 本体

- 以**系统服务**运行：`mihomo.service`（mihomo-bin 自带），工作目录 `/etc/mihomo`。TUN（mixed 栈）+ fake-ip，混合端口 6153，API `127.0.0.1:9090`，面板 zashboard（`/etc/mihomo/ui`）
- 配置模板 `system/etc/mihomo/config.template.yaml` 与实际配置只差两处占位符：完整订阅链接（`__MIHOMO_SUB_URL__`，含机场域名与 token，整条存在 rbw 里不进仓库）与面板密码（`__MIHOMO_SECRET__`），均从 rbw 取值。**改了规则/分组请改模板**，再重跑 `install.sh` 的 mihomo 段，避免 `/etc/mihomo/config.yaml` 与仓库漂移
- `config.yaml` 权限 `640 root:afu`：文件含订阅 token 与 API secret，只让 root 与本用户可读；`hotspot-internet`/`usb-internet` 以本用户读取 `secret:` 行调用 API

### 热点 / USB 直连设备的外网开关

两条 `RULE-SET,…_direct,DIRECT` 置顶于 rules，各读一个本地 file rule-provider：

| 开关 | flag 文件 | 来源网段 | 图形入口 |
|------|-----------|----------|----------|
| `hotspot-internet [on\|off\|toggle\|status]` | `/etc/mihomo/flags/hotspot-direct.yaml` | 10.42.0.0/24（NM 共享热点） | DMS 插件 `hotspotInternet`（控制中心 / 状态栏） |
| `usb-internet [on\|off\|toggle\|status]` | `/etc/mihomo/flags/usb-direct.yaml` | 10.11.99.0/24（rmk0） | DMS 插件 `usbInternet` |

- `on`：flag 置 `payload: []`，设备走 mihomo 完整分流（可翻墙）
- `off`：flag 写入 `SRC-IP-CIDR,<网段>`，该来源全部 DIRECT——国内可用、被墙的不通，**不断网**
- 脚本改写 flag → `PUT /providers/rules/<name>` 刷新 → 删掉该来源存量连接立即生效。无需 root；状态在 flag 文件里，重启后保持
- `flags/` 目录归当前用户所有（`install.sh` 创建）；插件用 Quickshell `FileView` 监听 flag 文件变化，脚本 / CLI 切换后状态即时更新，无轮询

### 热点（Wi-Fi AP）

- Wi-Fi 网卡按永久 MAC 固定命名为 `wlan0`（`10-wlan0.link`）：iwlwifi 固件崩溃自恢复后接口会漂移成 `wlan1`，绑定 wlan0 的热点 profile 失效。换机器改文件里的 MAC
- NM 连接 `Hotspot`（含 PSK，不在仓库），重建：

```bash
nmcli con add type wifi ifname wlan0 con-name Hotspot autoconnect no ssid '大郎少喝点' \
  mode ap 802-11-wireless.band bg wifi-sec.key-mgmt wpa-psk wifi-sec.psk '<密码>' \
  ipv4.method shared ipv6.method ignore
```

### USB 直连 reMarkable

- 设备 USB 网卡（CDC，10.11.99.1）按 MAC 固定命名为 `rmk0`（`11-rmk0.link`，MAC 由设备派生，换设备改文件）
- NM 连接 `remarkable-usb` 绑定 rmk0，重建：

```bash
nmcli con add type ethernet ifname rmk0 con-name remarkable-usb \
  ipv4.method manual ipv4.addresses 10.11.99.2/24 ipv4.never-default yes ipv6.method disabled
```

- 设备端 `/etc` 是易失 overlay，重启就丢配置：`remarkable-usb-share.timer`（30s 后起，每 45s）调用 `~/.local/bin/remarkable-usb-share`，设备在线时 SSH 推送「网关/DNS 指向 10.11.99.2:1053」的 `systemd-networkd` drop-in（幂等，已配置即空转）。设备端需已放好本机公钥（`ssh root@10.11.99.1` 免密）
- mihomo `dns.listen 0.0.0.0:1053`、`allow-lan`、`bind-address "*"` 使设备可把本机当 DNS/网关；设备常在的 Wi-Fi 对明文 53 有过滤，脚本还写了公共 DoT 兜底（仅 USB 不在时用到）
- `99-firewall.conf` 把 NM 防火墙后端定为 iptables，与 ufw 同一套链，共享连接的 NAT 才能正常出网

---

## 图标主题（Papirus）

换壁纸或切明暗时，DMS（`runUserMatugenTemplates = true`）会在跑完自家模板后直接执行 matugen 默认用户配置 `~/.config/matugen/config.toml`，其中：
- `papirus-folders.sh`：把主色 HSV 色相映射到 papirus-folders 颜色名，`sudo papirus-folders -C` 同步三套 Papirus（`sudoers.d/papirus-folders` 免密）
- `zathura`：生成 `~/.config/zathura/dank-colors`

不需要任何额外的 path/service 或脚本——早期的 `dms-user-matugen.path` + `apply-user-templates.sh` 链路已删除（会让 papirus 重复跑两遍，且不感知明暗切换）。

---

## 系统配置说明

`system/` 下的文件由 `install.sh` 复制到系统。

| 文件 | 作用 |
|------|------|
| `etc/mihomo/config.template.yaml` | mihomo 配置模板（占位符见上文） |
| `etc/systemd/resolved.conf.d/no-mdns.conf` | 禁用 systemd-resolved 的 mDNS（避免与 avahi 冲突） |
| `etc/systemd/system/ollama.service.d/override.conf` | ollama 以 afu 用户运行，模型在 `~/.local/share/ollama/models`（系统单元里 `%h` 是 root 家目录，路径只能写死） |
| `etc/systemd/network/10-wlan0.link` `11-rmk0.link` | 按 MAC 固定 Wi-Fi / reMarkable USB 网卡名（wlan0 / rmk0） |
| `etc/systemd/system/wifi-fw-reset.service` `usr/local/bin/wifi-fw-reset` | BE200 冷开机固件在 `CTDP_CONFIG_CMD` 断言崩溃后 wlan0 全程 unavailable（热重启不复现）；开机延迟 8s 自检，命中则重载 iwlmld/iwlwifi，仍不行再 PCI remove/rescan。手动：`sudo wifi-fw-reset --force` |
| `etc/udev/rules.d/85-iwl-dump.rules` `usr/local/bin/iwl-fwdump` | iwlwifi 固件崩溃时把 devcoredump 落盘到 `/var/lib/iwlwifi-dumps/`（默认 5 分钟销毁），供向 kernel bugzilla 提 bug 附件 |
| `etc/modprobe.d/nvidia-local.conf` | `NVreg_EnableS0ixPowerManagement=1`：s2idle 休眠时 GPU 参与 S0ix，否则待机耗电 |
| `etc/tmpfiles.d/thp.conf` | Transparent Huge Pages 改为 `madvise`（默认 always 会周期性延迟抖动） |
| `etc/tmpfiles.d/howdy-permissions.conf` | 授予 video 组读取 howdy 配置/模型 |
| `etc/pacman.d/hooks/50-howdy-libguard.hook` + `usr/local/bin/howdy-libguard` | 包事务后校验 howdy 共享库，缺库自动禁用 / 补回自动恢复 |
| `etc/sudoers.d/papirus-folders` | wheel 免密执行 papirus-folders（matugen 主题同步） |
| `etc/pam.d/dankshell` `sudo` `greetd` `polkit-1` | howdy 人脸识别接入 DMS 锁屏 / sudo / greetd 登录 / polkit 图形提权（greetd 还接 gnome-keyring 自动解锁）；dankshell 的密码回退不带 `nullok`，空密码账户无法解锁 |
| `etc/sysctl.d/99-ip-forward.conf` | `net.ipv4.ip_forward=1`，热点 / USB 共享上网的内核转发 |
| `etc/sysctl.d/99-custom.conf` | `vm.min_free_kbytes=512M`，内存压力下减少卡顿 |
| `etc/udev/rules.d/60-ioschedulers.rules` | 覆盖 cachyos-settings：NVMe `none`、SATA SSD `mq-deadline`（本机无 HDD） |
| `etc/udev/rules.d/70-uuu.rules` | NXP uuu 刷机工具的 USB `uaccess`（reMarkable recovery 模式）；uuu 本体未装，需要时 AUR `mfgtools-uuu` |
| `etc/greetd/niri_overrides.kdl` | 登录界面 niri 的 NVIDIA 环境变量扩展点；`config.toml`、`niri/{config,dms}.kdl` 由 `dms greeter sync` 生成，不入库 |
| `etc/keyd/default.conf` | capslock ↔ leftcontrol 互换，仅作用于 DELL 外接键盘（`[ids] 0d62:9abc`，`sudo keyd list-keyboards` 查 id） |
| `etc/snapper/configs/root` | Btrfs 根分区快照策略：只做 pacman pre/post 编号快照（上限 50），不开 timeline |
| `etc/NetworkManager/conf.d/wifi-backend.conf` | Wi-Fi 后端 iwd（`wpa_supplicant` 被 disable） |
| `etc/NetworkManager/conf.d/99-firewall.conf` | NM 防火墙后端 iptables（共享连接 NAT 与 ufw 同链） |
| `dconf/interface.ini` | `org.gnome.desktop.interface` 字体/主题/光标（`dconf load`） |

### NVIDIA

用户会话的环境变量在 `niri/config.kdl` 的 `environment {}`，登录界面的在 `etc/greetd/niri_overrides.kdl`，两处需保持一致：

```
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
ELECTRON_OZONE_PLATFORM_HINT=auto   # 仅用户会话
```

内屏的 DRM connector 名会在 eDP-1/eDP-2 间漂移：面板走 NVIDIA（MUX 独显直连），但 i915 开机时会先为自己空着的 DDI A 占住 eDP-1 约 1.5s 再释放，而 eDP-N 编号是跨显卡的全局计数器，nvidia-drm 注册早于或晚于这次释放就分别得到 eDP-1 或 eDP-2（initramfs 预载 nvidia 模块也挡不住，nvidia-drm 自身初始化耗时不定）。因此 `config.kdl` 的 output 块按 `"AU Optronics 0x96B1 Unknown"`（厂商 型号 序列号）匹配，不写连接器名；DMS 生成的 `dms/outputs.kdl` 仍按连接器名写，被前者覆盖，`monitors.json` 里两个 eDP 名各留一份相同的 profile 以免 DMS 反复新建。

内核参数（`/etc/kernel/cmdline`，含根分区 UUID 故不入库）额外带 `nvidia-drm.modeset=1 nvidia-drm.fbdev=1`；initramfs 由 chwd 生成的 `mkinitcpio.conf.d/10-chwd.conf` 预载 nvidia 四个模块。新机器由 CachyOS 安装器 / chwd 自动写入，只需核对。

### GnuPG XDG

`GNUPGHOME` 通过 `environment.d/gnupg.conf`、fish config 与 `systemd/user/gpg-agent.service.d/xdg.conf` 设为 `~/.local/share/gnupg`。`install.sh` 迁移原 `~/.gnupg`，并动态生成 gpg-agent socket drop-in（socket 路径含 GNUPGHOME 的哈希，无法静态入库，每台机器生成到 `~/.config/systemd/user/gpg-agent*.socket.d/`）。

### SDKMAN XDG

不用发行版的 `sdkman-bin`（固定装在 `/usr/lib/sdkman`，程序 root 拥有、candidates 数据人工 chown，混合状态；`SDKMAN_DIR` 是 sdkman 唯一目录变量，程序和数据本就在同一棵树下，没法只搬数据）。改用官方脚本装到 `SDKMAN_DIR=~/.local/share/sdkman`，更新走 `sdk selfupdate`。

fish 集成：
- `conf.d/config_sdk.fish` 设置 `__sdkman_custom_dir`，必须先于 fisher 插件的 `conf.d/sdk.fish` 加载（conf.d 早于 config.fish 执行，此时 `$XDG_DATA_HOME` 未定义，只能 `$HOME` 硬编码）
- `fish_plugins` 声明 `reitzig/sdkman-for-fish`；插件落地文件（`conf.d/sdk.fish`、`functions/sdk.fish` 等）由 `fisher update` 生成，已 gitignore

`candidates/` 下的 SDK 版本体积大且逐机器不同，不入库；新机器 `sdk install java` / `sdk install maven`。

---

## 目录结构

```
dotfiles/
├── home/                        # stow --target=$HOME home
│   ├── .config/
│   │   ├── niri/                # 合成器主配置 + DMS 托管的 dms/*.kdl（勿手改）
│   │   ├── DankMaterialShell/   # monitors.json、插件启用记录、自研插件（hotspotInternet / usbInternet）
│   │   ├── matugen/             # config.toml + 用户模板（papirus-folders、zathura），由 DMS 直接执行
│   │   ├── systemd/user/        # remarkable-usb-share.{service,timer}、x11-clipboard-bridge.service、gpg/ssh-agent drop-in
│   │   ├── fish/                # config.fish、conf.d（sdkman、rustup）、functions（git 拦截、obsync）
│   │   ├── kitty/               # kitty.conf + matugen 生成的 dank-theme/dank-tabs
│   │   ├── nvim/                # Lazy.nvim；colors/dms.lua 为 matugen 生成的 base46 主题
│   │   ├── yazi/                # 文件管理器（gvfs 插件、SFTP vfs）
│   │   ├── zathura/             # PDF 阅读器 + matugen 配色
│   │   ├── pandoc/              # reMarkable 纸感 PDF 导出（defaults / tex 头 / lua 过滤器）
│   │   ├── mpv/                 # gpu-next + uosc（AUR mpv-uosc，script= 显式加载）+ 剪贴板播放
│   │   ├── lazygit/  satty/  btop/  fastfetch/  starship.toml
│   │   ├── fcitx5/              # Rime + wechat 主题
│   │   ├── fontconfig/  gtk-3.0/  gtk-4.0/  qt5ct/  qt6ct/   # 字体与主题
│   │   ├── environment.d/       # fcitx5 / gnupg / maven 环境变量
│   │   ├── git/  maven/  gemini/  danksearch/  dankcal/  Thunar/
│   │   └── mimeapps.list  user-dirs.dirs  user-dirs.locale  xdg-terminals.list  user-tmpfiles.d/
│   ├── .local/bin/              # hotspot-internet、usb-internet、remarkable-usb-share、x11-clipboard-bridge、rime-dict-sync、rbw-ssh-load、git-credential-rbw、wine-setup-fonts
│   ├── .local/share/            # applications/*.desktop（蓝信、nvim 在 kitty 中打开）、fcitx5/rime/（*.custom.yaml、rime_ice_ext.dict.yaml）、rustup/settings.toml
│   └── .ssh/config
├── system/
│   ├── dconf/interface.ini
│   ├── etc/                     # 见「系统配置说明」
│   └── usr/local/bin/howdy-libguard
├── packages/packages.txt
├── install.sh
├── README.md
└── FEATURES.md
```

## 不在此仓库中的内容

| 内容 | 原因 / 重建方式 |
|------|-----------------|
| `/etc/mihomo/config.yaml` | 含订阅 token 与面板密码；由模板 + rbw 生成 |
| NM 连接（`Hotspot`、`remarkable-usb`、各 Wi-Fi） | 含 PSK；`nmcli` 命令见「网络共享」 |
| `~/.config/rbw/config.json` | 含邮箱；`rbw register` 自动生成（目录本身被 stow 链进仓库，文件已 gitignore） |
| `~/.ssh/` 私钥 | 存 Bitwarden，`rbw-ssh-load` 加载 |
| `~/.claude/`、`~/.local/share/claude` | Claude Code 认证与程序本体 |
| `~/.config/gemini/` 除 GEMINI.md 外 | OAuth token |
| `~/.ollama/` | 设备密钥 |
| `/etc/howdy/` | 人脸模型；`sudo howdy add` 重录 |
| `/etc/linux-enable-ir-emitter/` | IR 补光参数（机器专属）；`sudo linux-enable-ir-emitter configure` |
| `/etc/greetd/config.toml`、`/etc/greetd/niri/` | `dms greeter enable && dms greeter sync` 生成 |
| `~/.local/share/fonts/` | Maple Mono、pandoc 字体，手动放置 |
| DMS 第三方插件（calculator、emojiLauncher、niriWindows） | `install.sh` 用 `dms plugins install` 拉取（内含 git 仓库）；`plugin_settings.json` 记录了启用状态 |
| `~/.config/DankMaterialShell/settings.json` | DMS 运行时设置，随操作频繁变化（主题、字体、通知等在 FEATURES 有记录） |
| SDKMAN candidates、fnm Node、pyenv、cargo | 体积大且逐机器不同，`sdk install` / `fnm install` 重装 |
| `~/.local/share/fcitx5/rime/` 除 `*.custom.yaml`、`rime_ice_ext.dict.yaml` 外 | 词库 userdb、build 产物、`iorest/`（由 `rime-dict-sync` 从 GitHub 克隆并转简体生成） |
| `~/.local/share/applications/claude-code-url-handler.desktop` | Claude Code 安装器生成（`mimeapps.list` 的 `claude-cli` scheme 指向它） |

## 维护提示

- 换壁纸或切明暗后 `kitty/dank-*.conf`、`nvim/colors/dms.lua`、`niri/dms/colors.kdl`、`zathura/dank-colors`、`qt5ct|qt6ct/colors/matugen.conf` 会被 matugen 重写，产生「主题重生成」差异，属正常；提交时顺手一起提交即可
- `niri/dms/*.kdl` 由 DMS Settings 写入，改布局请在 DMS 设置里改；`config.kdl` 只放 DMS 不管的项
- 升级出现 `.pacnew`（`pam.d/sudo`、`pam.d/greetd`、`howdy/config.ini` 尤其要看）用 `pacdiff` 合并，不要整文件覆盖
- 修改 mihomo 规则时改 `system/etc/mihomo/config.template.yaml`，别只改 `/etc/mihomo/config.yaml`
- 重跑 `install.sh` 是安全的：包只装缺失的，NetworkManager / mihomo / gpg-agent 只在对应配置真的变化时才重启；Node / npm 全局包 / fisher 插件也只在缺失时安装，不做升级。系统升级仍走 `paru -Syu`
- 输入法词库：增删 Iorest 分库改 `home/.local/share/fcitx5/rime/rime_ice_ext.dict.yaml` 的 `import_tables`，然后 `rime-dict-sync`（也用它拉取词库更新）；`~/.local/share/fcitx5/rime/iorest/` 是生成物，不提交
- nvim 插件切主分支或迁仓库时配置**不会报错只会静默失效**（treesitter、conform 都发生过），`Lazy update` 后看一眼 breaking changes，或在插件源码里 grep `deprecated`
