return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#191112',
				base01 = '#191112',
				base02 = '#a5999b',
				base03 = '#a5999b',
				base04 = '#ffeff2',
				base05 = '#fff8f9',
				base06 = '#fff8f9',
				base07 = '#fff8f9',
				base08 = '#ff9fa1',
				base09 = '#ff9fa1',
				base0A = '#ffbdc6',
				base0B = '#baffa5',
				base0C = '#ffdce1',
				base0D = '#ffbdc6',
				base0E = '#ffc9d0',
				base0F = '#ffc9d0',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#a5999b',
				fg = '#fff8f9',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#ffbdc6',
				fg = '#191112',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#a5999b' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffdce1', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ffc9d0',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#ffbdc6',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#ffbdc6',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#ffdce1',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#baffa5',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#ffeff2' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#ffeff2' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#a5999b',
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
