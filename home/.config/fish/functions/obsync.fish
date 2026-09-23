function obsync --description "Sync Obsidian vault via git"
    set -l vault ~/Documents/ikate
    git -C $vault add -A
    git -C $vault diff --cached --quiet; or git -C $vault commit -m "sync "(date +%H:%M)
    git -C $vault pull --rebase || return 1
    git -C $vault push || begin
        echo "obsync: push 失败，检查网络或远端是否有本机没有的提交（非快进）" >&2
        return 1
    end
end
