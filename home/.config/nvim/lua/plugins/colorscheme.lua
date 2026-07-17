return {
	{
		-- DMS 官方 neovim 集成：colors/dms.lua（matugen 生成）依赖此插件，
		-- 把 github_light/dark 向壁纸主色调和后加载，换壁纸自动热重载
		"AvengeMedia/base46",
		lazy = false,
		priority = 1000,
		config = function()
			-- transparency：Normal 等背景置 NONE，透出 kitty 的 0.85 透明背景
			require("base46").setup({ transparency = true })
			vim.cmd.colorscheme("dms")
		end,
	},
}
