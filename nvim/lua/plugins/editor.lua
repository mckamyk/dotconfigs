return {
	-- Fuzzy finder and picker
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<C-p>",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						"node_modules",
					},
					mappings = {
						i = {
							["<CR>"] = "select_default",
						},
						n = {
							["<CR>"] = "select_default",
						},
					},
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"kyazdani42/nvim-web-devicons",
		},
		keys = {
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({
						action = "focus",
						source = "filesystem",
						position = "float",
						reveal = true,
					})
				end,
				silent = true,
			},
			{
				"<leader>r",
				function()
					require("neo-tree.command").execute({
						action = "focus",
						source = "document_symbols",
						position = "float",
					})
				end,
				silent = true,
			},
		},
		config = function()
			vim.fn.sign_define("DiagnosticSignError", { text = "🔴", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DiagnosticSignWarn", { text = "🟡", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticSignHint" })

			require("neo-tree").setup({
				event_handlers = {
					{
						event = "file_open_requested",
						handler = function()
							vim.cmd("Neotree close")
						end,
					},
				},
				close_if_last_window = true,
				popup_border_style = "rounded",
				window = {
					position = "float",
					border = {
						style = "rounded",
					},
					popup = {
						size = {
							height = "90%",
							width = "25%",
						},
						position = {
							row = 4,
							col = 4,
						},
					},
					mappings = {
						["n"] = { "add" },
					},
				},
				filesystem = {
					filtered_items = {
						visible = true,
						hide_dotfiles = false,
					},
					follow_current_file = {
						enabled = true,
					},
				},
				sources = {
					"filesystem",
					"document_symbols",
					"git_status",
				},
				buffers = {
					follow_current_file = {
						enabled = true,
					},
				},
			})
		end,
	},
	-- Git integration
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
		config = function()
			vim.g.lazygit_floating_window_winblend = 0
		end,
	},
	-- Navigation
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
		},
	},
	-- Smooth scrolling
	{
		"karb94/neoscroll.nvim",
		opts = {
			easing = "quadratic",
			stop_eof = false,
		},
	},
}
