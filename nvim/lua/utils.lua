-- Shared utility functions for Neovim config
local M = {}

-- Get project root for .nvim.local lookup
function M.get_project_root()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		bufname = vim.fn.getcwd()
	end
	return vim.fs.root(bufname, { "pnpm-workspace.yaml", "turbo.json" })
		or vim.fs.root(bufname, { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" })
		or vim.fn.getcwd()
end

-- Load theme override from .nvim.local
function M.load_theme_override()
	local root = M.get_project_root()
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

return M
