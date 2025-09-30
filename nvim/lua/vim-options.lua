vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.termguicolors = true

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set nu")
vim.cmd("set cursorline")
vim.cmd("set relativenumber")
vim.cmd("set signcolumn=yes")

-- Tabs
vim.keymap.set("n", "<leader>h", ":-tabnext<cr>")
vim.keymap.set("n", "<leader>l", ":+tabnext<cr>")
vim.keymap.set("n", "<leader>bo", ":tabo<cr>")

vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>Q", ":qa<cr>")


