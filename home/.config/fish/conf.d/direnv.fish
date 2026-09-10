# direnv 本身默认就遵循 XDG（配置在 $XDG_CONFIG_HOME/direnv/direnv.toml，
# 状态在 $XDG_DATA_HOME/direnv），这里只需要挂 fish 钩子；
# 新机器 direnv 尚未安装时静默跳过
command -q direnv; and direnv hook fish | source
