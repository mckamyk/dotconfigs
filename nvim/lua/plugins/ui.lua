-- Load shared utilities
local utils = require("utils")

return {
	-- Theme and colorscheme
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
			})

			-- Load theme override from .nvim.local
			local theme_override = utils.load_theme_override()
			vim.g.nvim_local_theme = theme_override

			-- Set theme based on override or default to dark
			if theme_override == "light" then
				vim.cmd.colorscheme("catppuccin-latte")
			elseif theme_override == "dark" then
				vim.cmd.colorscheme("catppuccin-mocha")
			else
				-- No override, set default (auto-dark-mode will handle it)
				vim.cmd.colorscheme("catppuccin-mocha")
			end

			vim.api.nvim_set_hl(0, "CursorLine", { blend = 50 })
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		cond = function()
			-- Only load if no theme override is set
			return utils.load_theme_override() == nil
		end,
		opts = {
			set_dark_mode = function()
				vim.cmd.colorscheme("catppuccin-mocha")
			end,
			set_light_mode = function()
				vim.cmd.colorscheme("catppuccin-latte")
			end,
			update_interval = 1000,
			fallback = "light",
		},
	},
	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "dracula",
				},
			})
		end,
	},
	-- Dashboard
	{
		"goolord/alpha-nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.startify")

			dashboard.section.header.val = {
				[[                                                                       ]],
				[[                                                                       ]],
				[[                                                                       ]],
				[[                                                                       ]],
				[[                                                                     ]],
				[[       ████ ██████           █████      ██                     ]],
				[[      ███████████             █████                             ]],
				[[      █████████ ███████████████████ ███   ███████████   ]],
				[[     █████████  ███    ████████████ █████ ██████████████   ]],
				[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
				[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
				[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
				[[                                                                       ]],
				[[                                                                       ]],
				[[                                                                       ]],
			}

			alpha.setup(dashboard.opts)
		end,
	},
	-- Snacks for OpenCode
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			input = { enabled = true },
			picker = { enabled = true },
			terminal = { enabled = true },
		},
	},
	-- Buffer line (tab-like interface)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				mode = "buffers",
				separator_style = "slant",
				always_show_bufferline = true,
				show_buffer_close_icons = true,
				show_close_icon = false,
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and "🔴" or "🟡"
					return " " .. icon .. " " .. count
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						highlight = "Directory",
						separator = true,
					},
				},
			},
		},
	},
}
