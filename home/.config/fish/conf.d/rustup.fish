# rustup 生成的 env.fish 把 $CARGO_HOME/bin 加进 PATH（路径与 config.fish 的 CARGO_HOME 一致）；
# 新机器 rustup 尚未安装时静默跳过
set -l cargo_env $HOME/.local/share/cargo/env.fish
test -f $cargo_env; and source $cargo_env
