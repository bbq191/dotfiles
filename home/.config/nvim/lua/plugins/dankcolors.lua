return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#0f150b',
				base01 = '#0f150b',
				base02 = '#686c66',
				base03 = '#686c66',
				base04 = '#212320',
				base05 = '#babfb7',
				base06 = '#babfb7',
				base07 = '#babfb7',
				base08 = '#c34521',
				base09 = '#c34521',
				base0A = '#2f800b',
				base0B = '#078c00',
				base0C = '#5b8944',
				base0D = '#2f800b',
				base0E = '#92bb7f',
				base0F = '#92bb7f',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#686c66',
				fg = '#babfb7',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#2f800b',
				fg = '#0f150b',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#686c66' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#5b8944', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#92bb7f',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#2f800b',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#2f800b',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#5b8944',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#078c00',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#212320' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#212320' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#686c66',
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
