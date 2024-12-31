-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"kyazdani42/nvim-web-devicons",
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
			popup_border_status = "rounded",
			window = {
				mappings = {
					["n"] = { "add" },
					["e"] = function()
						vim.cmd.wincmd("p")
					end,
				},
			},
			filesystem = {
				window = {
					position = "float",
					float = {
						col = 2,
						row = 2,
						width = 50,
						height = vim.o.lines - 2,
						border = "rounded",
					},
				},
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
				},
				follow_current_file = {
					enabled = true,
				},
			},
			buffers = {
				follow_current_file = {
					enabled = true,
				},
			},
		})

		vim.keymap.set("n", "<leader>e", function()
			require("neo-tree.command").execute({
				action = "focus",
				source = "filesystem",
				position = "float",
				reveal = true,
			})
		end, { silent = true })
	end,
}
