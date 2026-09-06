-- fnm 管理的 node/npm 注入 PATH（Mason 安装 ts_ls 等需要）
local fnm_bin = vim.fn.expand("$HOME/.local/share/fnm/aliases/default/bin")
if vim.fn.isdirectory(fnm_bin) == 1 then
  vim.env.PATH = fnm_bin .. ":" .. vim.env.PATH
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lsp")
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  ui = { border = "rounded" },
  rocks = { enabled = false },  -- 不用 luarocks，关掉避免 hererocks 错误
  performance = {
    rtp = {
      -- gx 打开链接由 0.10+ 内置 vim.ui.open 承担，netrw 不再需要
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipfile", "netrwPlugin" },
    },
  },
})
