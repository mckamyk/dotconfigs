return {
	"luckasRanarison/tailwind-tools.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-telescope/telescope.nvim", -- optional
		"neovim/nvim-lspconfig", -- optional
	},
	opts = {
		server = {
			override = true, -- setup the server from the plugin if true
		},
		document_color = {
			enabled = true,
			kind = "inline",
			inline_symbol = "󰝤 ",
			debounce = 200,
		},
		conceal = {
			enabled = false,
			min_length = nil,
			symbol = "󱏿",
			highlight = {
				fg = "#38BDF8",
			},
		},
		cmp = {
			highlight = "foreground",
		},
	},
	build = ":UpdateRemotePlugins",
}
