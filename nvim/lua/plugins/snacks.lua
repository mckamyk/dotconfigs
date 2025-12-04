return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Enable only the components needed for OpenCode
		input = { enabled = true },
		picker = { enabled = true },
		terminal = { enabled = true },
	},
}
