return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
       require("catppuccin").setup({
         transparent_background = true,
       })
       vim.cmd.colorscheme("catppuccin-mocha")
       vim.api.nvim_set_hl(0, 'CursorLine', { blend = 50 })
    end,
  },
   {
     "f-person/auto-dark-mode.nvim",
     lazy = false,
      opts = {
        set_dark_mode = function()
          vim.cmd.colorscheme("catppuccin-mocha")
        end,
        set_light_mode = function()
          vim.cmd.colorscheme("catppuccin-latte")
        end,
        update_interval = 1000,
        fallback = "light",
      },
   },
}
