function git
    # 在需要 SSH 认证的操作时检查并按需解锁 rbw、加载 SSH 密钥
    if contains -- push pull fetch $argv
        set _key_fp "SHA256:DdedK/2nU9yFpNCZOiM1De0J+Gdhr6TwS4bs1wxM2dA"
        if not ssh-add -l 2>/dev/null | grep -qF $_key_fp
            if not rbw unlocked 2>/dev/null
                echo "🔐 rbw vault 已锁定，请解锁以继续 push："
                rbw unlock
                or return 1
            end
            rbw get "3f921d39-38e5-47cb-bba0-b3920045d37a" --field "private_key" 2>/dev/null \
                | ssh-add - 2>/dev/null
        end
    end
    command git $argv
end
