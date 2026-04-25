return {
  "nickjvandyke/opencode.nvim",
  config = function()
    vim.g.opencode_opts = {}
    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<leader>o", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode..." })
  end,
}
