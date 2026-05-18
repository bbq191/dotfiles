local opt = vim.opt

-- 行号
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true

-- 缩进（Python 用 4，TS 用 2，依靠 EditorConfig/LSP 覆盖）
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- 文件
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 200
opt.timeoutlen = 300

-- 分屏
opt.splitright = true
opt.splitbelow = true

-- 外观
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- 剪贴板
opt.clipboard = "unnamedplus"

-- 补全
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 12

-- 折叠（treesitter）
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- 文件编码
opt.fileencoding = "utf-8"

-- GUI 字体（Neovide 等 GUI 客户端生效；终端下由 Kitty 控制）
opt.guifont = "Maple Mono NF CN:h11"

-- 禁用未使用的 provider，消除 :checkhealth 警告
vim.g.loaded_python3_provider = 0  -- 不需要 pynvim
vim.g.loaded_perl_provider     = 0
vim.g.loaded_ruby_provider     = 0
vim.g.loaded_node_provider     = 0  -- node-client 不是 LSP，禁用不影响 ts_ls
