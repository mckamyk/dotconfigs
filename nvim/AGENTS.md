# Neovim Config Documentation (AGENTS.md)

This document summarizes the reorganized Neovim configuration structure. The config has been consolidated into 4 logical plugin groups for better maintainability.

## Overview

- **Structure**: 4 plugin categories + core files
- **Principles**:
  - Aggressive lazy loading (preload TypeScript ecosystem)
  - Conditional formatter/loader loading based on project `.nvim.local` config files
  - TypeScript-first optimization
  - Centralized keymap management with plugin-specific comments
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
- Includes: termguicolors, expandtab, number, cursorline, autoread, etc.

### lua/keymaps.lua
- All keymaps centralized for easy reference
- Comments indicate plugin ownership
- Organized by category: General, Telescope, Git, LSP, Conform, Neotree, Neocodeium, LazyGit, Tmux, OpenCode
- Helper function `lsp_attached()` for conditional LSP keymaps

## Plugin Categories

### ui.lua
**Purpose**: Visual appearance and UI enhancements

**Plugins**:
- **catppuccin** (theme + transparent background) - loaded immediately, priority 1000
- **auto-dark-mode.nvim** - automatic light/dark mode switching (conditional: only if no `.nvim.local` theme override)
- **lualine.nvim** - status line with dracula theme
- **alpha-nvim** - dashboard with custom header
- **snacks.nvim** - UI components (input, picker, terminal) for OpenCode

**Features**:
- Loads theme override from `.nvim.local` (theme=light/dark)
- Auto-dark-mode respects `.nvim.local` theme setting

### editor.lua
**Purpose**: File navigation, search, git integration, and movement

**Plugins**:
- **telescope.nvim** (+ plenary.nvim) - fuzzy finder
  - `<C-p>`/`<leader>ff`: Find files
  - `<leader>fg`: Live grep
  - `<leader>fb`: Buffers
  - `<leader>fh`: Help tags
- **telescope-ui-select.nvim** - enhanced UI select dropdown
- **neo-tree.nvim** - file explorer
  - `<leader>e`: Filesystem tree (float)
  - `<leader>r`: Document symbols
  - `<leader>ge`: Git status tree
  - Config: rounded borders, 90% height, 25% width
- **gitsigns.nvim** - git integration
- **lazygit.nvim** - lazygit terminal UI
  - `<leader>gg`: Open LazyGit
- **vim-tmux-navigator** - tmux navigation
  - `<a-h>`, `<a-j>`, `<a-k>`, `<a-l>`: Navigate panes
- **neoscroll.nvim** - smooth scrolling with quadratic easing

**Lazy Loading**:
- Telescope: `keys` (loads on keypress)
- Neotree: `keys` (loads on keypress)
- Lazygit: `cmd` and `keys`
- Tmux-navigator: `cmd`

### coding.lua
**Purpose**: Language support, completion, formatting, and development tools

**Plugins**:
- **nvim-treesitter** - syntax highlighting (main branch, auto_install)
- **nvim-cmp** + **cmp-nvim-lsp** - auto completion with LSP source
- **conform.nvim** - formatting
- **mason.nvim** + **mason-lspconfig.nvim** + **nvim-lspconfig** - LSP management
- **neocodeium** - AI completion (event: VeryLazy)
- **tailwind-highlight.nvim** - Tailwind CSS color highlighting (conditional)
- **nvim-oxlint** - oxlint integration (conditional)
- **nvim-autopairs** - auto-close brackets (event: InsertEnter)
- **nvim-ts-autotag** - auto-close/rename HTML tags

**Conditional Loading via `.nvim.local`**:
Project-level configuration file for tool selection:
```
# .nvim.local format:
theme=dark          # or light
oxfmt               # enable oxfmt formatter
biome               # enable biome formatter/linter
prettier            # enable prettier formatter
oxlint              # enable oxlint linter
eslint              # enable eslint
tailwindcss         # enable tailwindcss LSP + highlighting
```

**Formatter Priority** (format-on-save):
1. oxfmt (if specified)
2. biome-check (if specified or no config file)
3. prettier (if specified)
4. LSP fallback

**LSP Servers**:
- Always enabled: lua_ls, vtsls, solidity, jsonls, taplo
- Conditional: biome, eslint, tailwindcss, gopls
- Tailwind v4 CSS config detection (auto-detects @import 'tailwindcss')

**Diagnostics**:
- Custom signs: 🔴 for ERROR, 🟡 for WARN

### tools.lua
**Purpose**: Specialized development tools

**Plugins**:
- **opencode.nvim** - OpenCode AI assistant
  - Dependencies: snacks.nvim
  - Config: autoread enabled, snacks provider

## Keymaps Reference

### General
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>Q` - Quit all
- `<leader>h` / `<leader>l` - Previous/next tab
- `<leader>bo` - Close other tabs

### LSP (conditional: only when LSP attached)
- `K` / `<leader>t` - Hover documentation
- `gd` - Go to definition (opens in new tab if different file)
- `gr` - Show references
- `<leader>a` - Code actions
- `<leader>n` / `<leader>m` - Next/previous diagnostic
- `<leader>si` - LSP info

### Formatting
- `<leader>cf` - Format with conform

### Neocodeium (insert mode)
- `<Tab>` - Accept suggestion
- `<C-j>` - Next suggestion
- `<C-k>` - Previous suggestion
- `<C-h>` - Clear suggestion

### OpenCode
- `<leader>oa` - Ask about current file
- `<leader>ox` - Execute action
- `<leader>op` - Add to prompt
- `<leader>ot` / `<C-o>t` (terminal) - Toggle terminal
- `<leader>on` - New session
- `<leader>ol` - List sessions
- `<leader>os` - Share session
- `<leader>oi` - Interrupt session
- `<leader>oc` - Compact session
- `<leader>ou` / `<leader>od` - Scroll up/down
- `<leader>oU` / `<leader>oD` - Jump to first/last message
- `<leader>oe` - Explain code
- `<leader>of` - Fix diagnostics
- `<leader>ov` - Review code
- `<leader>om` - Document code
- `<leader>oT` - Add tests
- `<leader>oO` - Optimize code

## Project Configuration (.nvim.local)

Create a `.nvim.local` file in project root to customize tools:

```bash
# Example .nvim.local
theme=dark
biome
prettier
oxlint
tailwindcss
```

**Format**:
- Lines starting with `#` are comments
- `theme=light` or `theme=dark` sets the color scheme
- Tool names enable those tools: `biome`, `prettier`, `oxlint`, `eslint`, `oxfmt`, `tailwindcss`

## Maintenance Commands

- **Update plugins**: `:Lazy update`
- **Clean unused**: `:Lazy clean`
- **Profile startup**: `:Lazy profile`
- **Check health**: `:checkhealth`
- **View logs**: `:Lazy log`
- **Sync lockfile**: `:Lazy sync`
- **Check LSP status**: `:LspInfo`
- **Check formatters**: `:ConformInfo`

## Troubleshooting

### Plugin Not Loading
- Check lazy loading conditions (`event`, `cmd`, `keys`)
- Verify plugin name and repo URL
- Run `:Lazy check` for missing dependencies

### Keymaps Not Working
- Ensure plugin is loaded when keymap is used
- Check for conflicts in `lua/keymaps.lua`
- Verify buffer-local vs global keymaps
- Use `:verbose map <key>` to debug

### LSP Not Starting
- Check if server is in mason (`:Mason`)
- Verify filetypes match
- Check LSP logs: `:LspInfo`
- Check if tool is enabled in `.nvim.local`

### Formatting Not Working
- Check if config files exist for conditional formatters
- Verify filetype in `formatters_by_ft`
- Run `:ConformInfo` to see available formatters
- Check `.nvim.local` tool configuration

### Theme Issues
- Check `.nvim.local` for theme override
- Verify auto-dark-mode loads (only when no override)
- Check catppuccin setup

### Performance Issues
- Profile with `:Lazy profile`
- Check for eager loading of heavy plugins
- Review conditional loading logic
- TypeScript ecosystem is preloaded for performance

## Future Maintenance

- Keep categories balanced (avoid bloated files)
- Regularly update plugins and review for deprecated ones
- Test major changes in TypeScript projects first
- Update this AGENTS.md when structure changes
- Document new `.nvim.local` tools when added

## Recent Changes

- Replaced none-ls with conform.nvim for formatting
- Added `.nvim.local` project configuration support
- Added telescope-ui-select extension
- Added vim-tmux-navigator and neoscroll for navigation
- Expanded OpenCode keymaps
- Added tailwind-highlight and oxlint (conditional)
- Moved all keymaps to centralized keymaps.lua

---

## Document Version

**Commit Hash**: `9256841b8134d82b1e2a69f558ef3b2f929e2a79`

### How to Update This Document

To update AGENTS.md in the future:

1. Get the current commit hash:
   ```bash
   git rev-parse HEAD
   ```

2. Compare changes since this document version:
   ```bash
   git diff 9256841b8134d82b1e2a69f558ef3b2f929e2a79..HEAD -- lua/ init.lua
   ```

3. Review all plugin files and keymaps to identify changes:
   - `lua/plugins/ui.lua`
   - `lua/plugins/editor.lua`
   - `lua/plugins/coding.lua`
   - `lua/plugins/tools.lua`
   - `lua/keymaps.lua`

4. Update the relevant sections in this document

5. Update the commit hash at the bottom to the new HEAD

For questions about specific implementations, refer to the conversation that established this structure.