return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#131314',
				base01 = '#131314',
				base02 = '#686a6c',
				base03 = '#686a6c',
				base04 = '#212223',
				base05 = '#b9bcbf',
				base06 = '#b9bcbf',
				base07 = '#b9bcbf',
				base08 = '#b74a68',
				base09 = '#b74a68',
				base0A = '#5c7185',
				base0B = '#208c2e',
				base0C = '#27323b',
				base0D = '#5c7185',
				base0E = '#3f4951',
				base0F = '#3f4951',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#686a6c',
				fg = '#b9bcbf',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#5c7185',
				fg = '#131314',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#686a6c' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#27323b', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#3f4951',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#5c7185',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#5c7185',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#27323b',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#208c2e',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#212223' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#212223' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#686a6c',
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
