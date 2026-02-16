-- Helper function to check if LSP is attached
local function lsp_attached()
	return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
end

-- General keymaps
vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>Q", ":qa<cr>")

-- Tab navigation
vim.keymap.set("n", "<leader>h", ":-tabnext<cr>")
vim.keymap.set("n", "<leader>l", ":+tabnext<cr>")
vim.keymap.set("n", "<leader>bo", ":tabo<cr>")

-- Telescope
vim.keymap.set("n", "<C-p>", function()
	require("telescope.builtin").find_files()
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Telescope help tags" })

-- Git
vim.keymap.set("n", "<leader>ge", function()
	require("neo-tree.command").execute({
		action = "focus",
		source = "git_status",
		position = "float",
	})
end, { desc = "Git status tree" })

-- LSP
vim.keymap.set("n", "K", function()
	if lsp_attached() then
		vim.lsp.buf.hover()
	end
end)
vim.keymap.set("n", "<leader>t", function()
	if lsp_attached() then
		vim.lsp.buf.hover()
	end
end)
vim.keymap.set("n", "gd", function()
	if not lsp_attached() then
		return
	end
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return
	end
	local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
	local result = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 5000)
	if not result or vim.tbl_isempty(result) then
		return
	end
	for _, res in pairs(result) do
		if res.result then
			local locations = vim.lsp.util.locations_to_items(res.result)
			if not vim.tbl_isempty(locations) then
				local location = locations[1]
				local target_file = location.filename
				local current_file = vim.fn.expand("%:p")
				if target_file ~= current_file then
					vim.cmd("tabnew")
				end
				local uri = location.uri or vim.uri_from_fname(location.filename)
				local target_bufnr = vim.uri_to_bufnr(uri)
				vim.api.nvim_win_set_buf(0, target_bufnr)
				vim.api.nvim_win_set_cursor(0, { location.lnum, location.col - 1 })
				return
			end
		end
	end
end)
vim.keymap.set("n", "gr", function()
	if lsp_attached() then
		vim.lsp.buf.references()
	end
end)
vim.keymap.set("n", "<leader>a", function()
	if lsp_attached() then
		vim.lsp.buf.code_action()
	end
end)
vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next, {})
vim.keymap.set("n", "<leader>m", vim.diagnostic.goto_prev, {})
vim.keymap.set("n", "<leader>si", "<cmd>LspInfo<CR>", {})

-- Conform
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format()
end, {})

-- Neotree
vim.keymap.set("n", "<leader>e", function()
	require("neo-tree.command").execute({
		action = "focus",
		source = "filesystem",
		position = "float",
		reveal = true,
	})
end, { silent = true })
vim.keymap.set("n", "<leader>r", function()
	require("neo-tree.command").execute({
		action = "focus",
		source = "document_symbols",
		position = "float",
	})
end, { silent = true })

-- Neocodeium
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

-- LazyGit
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Tmux Navigator (using Alt/Meta modifier to match Ghostty cmd keybinds)
vim.keymap.set("n", "<a-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<a-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<a-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<a-l>", "<cmd>TmuxNavigateRight<cr>")

-- OpenCode
local opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "x" }, "<leader>oa", function()
	require("opencode").ask("@this: ", { submit = true })
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Ask" }))

vim.keymap.set({ "n", "x" }, "<leader>ox", function()
	require("opencode").select()
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Execute action" }))

vim.keymap.set({ "n", "x" }, "<leader>op", function()
	require("opencode").prompt("@this")
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Add to prompt" }))

vim.keymap.set({ "n" }, "<leader>ot", function()
	require("opencode").toggle()
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Toggle terminal" }))
vim.keymap.set({ "t" }, "<C-o>t", function()
	require("opencode").toggle()
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Toggle terminal" }))

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

vim.keymap.set("n", "<leader>ou", function()
	require("opencode").command("session.undo")
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Undo" }))

vim.keymap.set("n", "<leader>or", function()
	require("opencode").command("session.redo")
end, vim.tbl_extend("force", opts, { desc = "OpenCode: Redo" }))

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
