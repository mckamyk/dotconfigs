-- Helper to get project root (duplicated from coding.lua to avoid circular deps)
local function get_project_root()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		bufname = vim.fn.getcwd()
	end
	return vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
		or vim.fs.root(bufname, { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" })
		or vim.fn.getcwd()
end

-- Helper to load theme from .nvim.local
local function load_theme_override()
	local root = get_project_root()
	local config_file = root .. "/.nvim.local"
	if vim.fn.filereadable(config_file) ~= 1 then
		return nil
	end

	local lines = vim.fn.readfile(config_file)
	for _, line in ipairs(lines) do
		line = vim.trim(line)
		if line ~= "" and not line:match("^#") then
			local theme_value = line:match("^theme=(.+)")
			if theme_value and (theme_value == "light" or theme_value == "dark") then
				return theme_value
			elseif line == "light" or line == "dark" then
				return line
			end
		end
	end
	return nil
end

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
			local theme_override = load_theme_override()
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
			return load_theme_override() == nil
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
}
