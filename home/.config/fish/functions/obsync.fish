function obsync --description "Sync Obsidian vault via git"
    set -l vault ~/Documents/ikate
    git -C $vault add -A
    git -C $vault diff --cached --quiet; or git -C $vault commit -m "sync "(date +%H:%M)
    git -C $vault pull --rebase || return 1
    git -C $vault push
end
