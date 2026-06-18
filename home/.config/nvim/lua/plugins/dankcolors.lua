return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#191210',
				base01 = '#191210',
				base02 = '#6c6867',
				base03 = '#6c6867',
				base04 = '#232121',
				base05 = '#bfbab8',
				base06 = '#bfbab8',
				base07 = '#bfbab8',
				base08 = '#c24437',
				base09 = '#c24437',
				base0A = '#aa5945',
				base0B = '#268c0c',
				base0C = '#69453d',
				base0D = '#aa5945',
				base0E = '#8f7069',
				base0F = '#8f7069',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#6c6867',
				fg = '#bfbab8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#aa5945',
				fg = '#191210',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#6c6867' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#69453d', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#8f7069',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#aa5945',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#aa5945',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#69453d',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#268c0c',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#232121' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#232121' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#6c6867',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
