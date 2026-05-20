function git
    if contains -- push pull fetch $argv
        if not ssh-add -l &>/dev/null
            if not rbw unlocked &>/dev/null
                echo "🔐 rbw vault 已锁定，请解锁以继续："
                rbw unlock; or return 1
            end
            rbw-ssh-load &>/dev/null
        end
    end
    command git $argv
end
