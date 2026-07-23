# SDKMAN 安装在 $XDG_DATA_HOME/sdkman 而非默认的 ~/.sdkman。
# 必须在 conf.d/sdk.fish（reitzig/sdkman-for-fish 插件）之前加载，
# 而 config.fish 此时还没跑，$XDG_DATA_HOME 未定义，故这里用 $HOME 硬编码。
set -g __sdkman_custom_dir $HOME/.local/share/sdkman
