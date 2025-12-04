return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	config = function()
		-- Required for automatic buffer reloading when OpenCode edits files
		vim.o.autoread = true

		-- OpenCode configuration
		vim.g.opencode_opts = {
			-- Use snacks for enhanced UI
			provider = {
				enabled = "snacks",
			},
			-- Enable automatic file reload on edits
			events = {
				reload = true,
			},
		}

		-- Keymaps with <leader>o prefix
		local opts = { noremap = true, silent = true }

		-- Core OpenCode functions
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Ask" }))

		vim.keymap.set({ "n", "x" }, "<leader>ox", function()
			require("opencode").select()
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Execute action" }))

		vim.keymap.set({ "n", "x" }, "<leader>op", function()
			require("opencode").prompt("@this")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Add to prompt" }))

		vim.keymap.set({ "n", "t" }, "<leader>ot", function()
			require("opencode").toggle()
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Toggle terminal" }))

		-- Session management
		vim.keymap.set("n", "<leader>on", function()
			require("opencode").command("session.new")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: New session" }))

		vim.keymap.set("n", "<leader>ol", function()
			require("opencode").command("session.list")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: List sessions" }))

		vim.keymap.set("n", "<leader>os", function()
			require("opencode").command("session.share")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Share session" }))

		vim.keymap.set("n", "<leader>oi", function()
			require("opencode").command("session.interrupt")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Interrupt session" }))

		vim.keymap.set("n", "<leader>oc", function()
			require("opencode").command("session.compact")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Compact session" }))

		-- Navigation
		vim.keymap.set("n", "<leader>ou", function()
			require("opencode").command("session.half.page.up")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Scroll up" }))

		vim.keymap.set("n", "<leader>od", function()
			require("opencode").command("session.half.page.down")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Scroll down" }))

		vim.keymap.set("n", "<leader>oU", function()
			require("opencode").command("session.first")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Jump to first message" }))

		vim.keymap.set("n", "<leader>oD", function()
			require("opencode").command("session.last")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Jump to last message" }))

		-- Undo/Redo
		vim.keymap.set("n", "<leader>ou", function()
			require("opencode").command("session.undo")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Undo" }))

		vim.keymap.set("n", "<leader>or", function()
			require("opencode").command("session.redo")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Redo" }))

		-- Quick prompts (using built-in prompts)
		vim.keymap.set({ "n", "x" }, "<leader>oe", function()
			require("opencode").prompt("explain @this")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Explain code" }))

		vim.keymap.set({ "n", "x" }, "<leader>of", function()
			require("opencode").prompt("fix @diagnostics")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Fix diagnostics" }))

		vim.keymap.set({ "n", "x" }, "<leader>ov", function()
			require("opencode").prompt("review @this")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Review code" }))

		vim.keymap.set({ "n", "x" }, "<leader>om", function()
			require("opencode").prompt("document @this")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Document code" }))

		vim.keymap.set({ "n", "x" }, "<leader>oT", function()
			require("opencode").prompt("test @this")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Add tests" }))

		vim.keymap.set({ "n", "x" }, "<leader>oO", function()
			require("opencode").prompt("optimize @this")
		end, vim.tbl_extend("force", opts, { desc = "OpenCode: Optimize code" }))
	end,
}
