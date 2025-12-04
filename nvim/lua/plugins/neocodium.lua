return {
	"monkoose/neocodeium",
	event = "VeryLazy",
	config = function()
		local neocodeium = require("neocodeium")
		neocodeium.setup()

		-- Key mappings
		vim.keymap.set("i", "<Tab>", function()
			require("neocodeium").accept()
		end)
		vim.keymap.set("i", "<C-j>", function()
			require("neocodeium").cycle_or_complete()
		end)
		vim.keymap.set("i", "<C-k>", function()
			require("neocodeium").cycle_or_complete(-1)
		end)
		vim.keymap.set("i", "<C-h>", function()
			require("neocodeium").clear()
		end)
	end,
}
