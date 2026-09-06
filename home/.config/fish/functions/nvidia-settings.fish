# nvidia-settings 每次运行都会把 rc 写到 ~/.nvidia-settings-rc，用 --config 改到 XDG 目录
function nvidia-settings --wraps nvidia-settings --description 'nvidia-settings with XDG config path'
    mkdir -p $XDG_CONFIG_HOME/nvidia
    command nvidia-settings --config=$XDG_CONFIG_HOME/nvidia/settings $argv
end
