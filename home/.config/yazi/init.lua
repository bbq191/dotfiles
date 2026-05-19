-- yazi init.lua — 当前为最小配置
-- 如需安装插件，使用：ya pack -a <author/plugin>
-- 数据目录（XDG）：~/.local/share/yazi/

-- ── GVFS 远程挂载（FTP / SMB / WebDAV 等）────────────────────
-- 使用：M m 挂载并跳转，M u 卸载，M a 添加新挂载，g m 跳转已挂载
require("gvfs"):setup({
  -- 挂载点选择键（单字符，按顺序分配）
  which_keys = "1234567890qwertyuiopasdfghjklzxcvbnm",
  -- 密码存储：gnome-keyring（已运行），首次输入后自动保存
  password_vault = "keyring",
  save_password_autoconfirm = true,
  input_position = { "center", y = 0, w = 60 },
})
