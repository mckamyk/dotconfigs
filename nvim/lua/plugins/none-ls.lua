return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    local utils = require("null-ls.utils").make_conditional_utils()

    local hasEslint = utils.root_has_file({
      "eslint.config.js",
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
    })

    local hasPrettier = utils.root_has_file({
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.js",
      ".prettierrc.cjs",
      "prettier.config.js",
      "prettier.config.cjs",
    })

    if not hasEslint and not hasPrettier then
      vim.lsp.enable("biome")
    else
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.stylua,
          require("none-ls.diagnostics.eslint_d").with({
            filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            condition = function()
              return hasEslint or hasPrettier
            end,
          }),
        },
        -- on_attach = function(client, bufnr)
        --   if client.supports_method("textDocument/formatting") then
        --     vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        --     vim.api.nvim_create_autocmd("BufWritePre", {
        --       group = augroup,
        --       buffer = bufnr,
        --       callback = function()
        --         vim.lsp.buf.format({ async = false })
        --       end,
        --     })
        --   end
        -- end,
      })
    end

    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
  end,
}
