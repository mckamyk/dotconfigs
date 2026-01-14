# Neovim Config Documentation (AGENTS.md)

This document summarizes the reorganized Neovim configuration structure, established through conversation with the user. The config has been consolidated from 20+ individual plugin files into 4 logical groups for better maintainability.

## Overview

- **Structure**: 4 plugin categories + core files
- **Principles**:
  - Aggressive lazy loading (preload TypeScript ecosystem)
  - Conditional formatter loading based on project config files
  - TypeScript-first optimization (99% of development)
  - Centralized keymap management with plugin attribution
- **Package Manager**: lazy.nvim
- **Primary Language**: TypeScript/JavaScript with comprehensive tooling

## File Structure

```
├── init.lua                 # Bootstrap lazy.nvim, load options/keymaps, setup plugins
├── lua/
│   ├── options.lua          # Pure vim options (no keymaps/commands)
│   ├── keymaps.lua          # All keymaps with plugin-specific comments
│   └── plugins/
│       ├── ui.lua           # Theme, status line, dashboard, snacks
│       ├── editor.lua       # Fuzzy finder, file explorer, git, navigation
│       ├── coding.lua       # Syntax, completion, formatting, LSP, tools
│       └── tools.lua        # Specialized tools (OpenCode AI)
├── .luarc.json             # Lua LSP configuration
└── lazy-lock.json          # Plugin lockfile
```

## Core Files

### init.lua
- Bootstraps lazy.nvim from GitHub
- Requires `options.lua` and `keymaps.lua`
- Sets up plugins from `lua/plugins/` directory

### lua/options.lua
- Contains only `vim.opt` and `vim.g` settings
- No keymaps, commands, or plugin-specific code
- Includes: termguicolors, expandtab, number, cursorline, etc.

### lua/keymaps.lua
- All keymaps centralized for easy reference
- Comments indicate plugin ownership: `-- LSP: hover`, `-- Telescope: find files`
- Avoids overriding native keybinds without clear indication
- Organized by category with section comments

## Plugin Categories

### ui.lua
**Purpose**: Visual appearance and UI enhancements
**Plugins**: catppuccin (theme + auto-dark-mode), lualine, alpha (dashboard), snacks
**Lazy Loading**: Theme loaded immediately, others on demand

### editor.lua
**Purpose**: File navigation, search, git integration, and movement
**Plugins**: telescope (+ui-select), neo-tree, gitsigns, lazygit, vim-tmux-navigator, neoscroll
**Lazy Loading**: Aggressive - telescope on `<C-p>`, neotree on `<leader>e`, lazygit on `<leader>gg`

### coding.lua
**Purpose**: Language support, completion, formatting, and development tools
**Plugins**: treesitter, nvim-cmp (+cmp-nvim-lsp), conform, mason/mason-lspconfig/nvim-lspconfig, neocodeium, tailwind-tools, oxlint, nvim-autopairs, nvim-ts-autotag
**Lazy Loading**: TypeScript ecosystem preloaded (treesitter, LSP, conform), others lazy
**Conditional Loading**: Formatters only load when config files detected

### tools.lua
**Purpose**: Specialized development tools
**Plugins**: opencode (AI assistant)
**Lazy Loading**: As configured by plugin

## Plugin Management

### Adding New Plugins

1. **Determine Category**:
   - UI/visual: `ui.lua`
   - Navigation/search/git: `editor.lua`
   - Language/completion/formatting: `coding.lua`
   - AI/specialized: `tools.lua`

2. **Add to Appropriate File**:
   ```lua
   -- Example: Add a new formatter to coding.lua
   {
     "new/formatter.nvim",
     config = function()
       require("formatter").setup()
     end,
   },
   ```

3. **Lazy Loading**:
   - Use `event`, `cmd`, `keys` for aggressive loading
   - Preload TypeScript-related plugins
   - Example:
   ```lua
   {
     "new/plugin",
     keys = { { "<leader>np", "<cmd>NewPlugin<cr>", desc = "New plugin" } },
   }
   ```

4. **Dependencies**:
   - List in `dependencies` array
   - Ensure compatibility with existing plugins

5. **Testing**:
   - Run `:Lazy check` for issues
   - Run `:checkhealth` for health checks
   - Test functionality in a TypeScript project

### Formatting/Linting Setup

**Primary Tool**: conform.nvim (replaced none-ls for modern maintenance)
**Conditional Loading**:
- **Biome**: Only when `biome.json` exists
- **Prettier**: Only when `.prettierrc*` or `prettier.config.*` exist
- **ESLint**: Only when oxlint config NOT found (`.oxlintrc*`, `oxlint.json`)

**Priorities** (format-on-save):
1. biome (if available)
2. prettier (if available)
3. LSP fallback

**Configuration**: See `coding.lua` conform setup

### LSP Configuration

**Tools**: mason + mason-lspconfig + nvim-lspconfig
**Conditional Servers**:
- Always: lua_ls, vtsls, tailwindcss, solidity, biome (if config), jsonls, taplo
- Conditional: eslint (only without oxlint), gopls

**Preloaded**: TypeScript ecosystem for performance
**Keymaps**: Moved to `lua/keymaps.lua` (LSP section)

### Keymaps Organization

- **Centralized**: All in `lua/keymaps.lua`
- **Commented**: `-- LSP: hover`, `-- Telescope: find files`, etc.
- **Patterns**:
  - `<leader>`: Custom commands
  - `<C->`: Navigation (h/j/k/l for movement)
  - `<leader>n/m`: LSP diagnostics next/prev
- **Examples**:
  ```lua
  -- General
  vim.keymap.set("n", "<leader>w", ":w<cr>")

  -- Telescope
  vim.keymap.set("n", "<C-p>", function() require("telescope.builtin").find_files() end, { desc = "Find files" })

  -- LSP
  vim.keymap.set("n", "gd", goto_definition_function, { buffer = true })
  ```

## Examples

### Adding a New Formatter
```lua
-- In coding.lua, within conform setup
formatters = {
  -- Existing...
  new_formatter = {
    condition = function()
      return vim.fn.glob(".newformatterrc") ~= ""
    end,
  },
},
formatters_by_ft = {
  -- Existing...
  newlang = { "new_formatter" },
},
```

### Adding a New LSP Server
```lua
-- In coding.lua LSP section
vim.lsp.config("newlsp", {
  capabilities = capabilities,
  on_attach = on_attach,
})
vim.lsp.enable("newlsp")
-- Add to mason ensure_installed if needed
```

### Adding a New Plugin
```lua
-- In appropriate category file
{
  "author/new-plugin",
  keys = { { "<leader>np", "<cmd>NewPlugin<cr>", desc = "New plugin" } },
  config = function()
    require("new-plugin").setup()
  end,
},
-- Add keymap to lua/keymaps.lua with comment
vim.keymap.set("n", "<leader>np", "<cmd>NewPlugin<cr>")
```

## Maintenance Commands

- **Update plugins**: `:Lazy update`
- **Clean unused**: `:Lazy clean`
- **Profile startup**: `:Lazy profile`
- **Check health**: `:checkhealth`
- **View logs**: `:Lazy log`
- **Sync lockfile**: `:Lazy sync`

## Troubleshooting

### Plugin Not Loading
- Check lazy loading conditions (`event`, `cmd`, `keys`)
- Verify plugin name and repo URL
- Run `:Lazy check` for missing dependencies

### Keymaps Not Working
- Ensure plugin is loaded when keymap is used
- Check for conflicts in `lua/keymaps.lua`
- Verify buffer-local vs global keymaps

### LSP Not Starting
- Check if server is in mason (`:Mason`)
- Verify filetypes match
- Check LSP logs: `:LspInfo`

### Formatting Not Working
- Check if config files exist for conditional formatters
- Verify filetype in `formatters_by_ft`
- Run `:ConformInfo` to see available formatters

### Performance Issues
- Profile with `:Lazy profile`
- Check for eager loading of heavy plugins
- Review conditional loading logic

### TypeScript-Specific Issues
- Ensure treesitter, LSP, and conform are preloaded
- Check TypeScript config files
- Verify mason has correct servers

## Future Maintenance

- Keep categories balanced (avoid bloated files)
- Regularly update plugins and review for deprecated ones
- Test major changes in TypeScript projects first
- Update this AGENTS.md when structure changes

For questions about specific implementations, refer to the original conversation that established this structure.