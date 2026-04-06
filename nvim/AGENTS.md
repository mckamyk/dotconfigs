# Neovim Config Documentation (AGENTS.md)

This document summarizes the reorganized Neovim configuration structure. The config has been consolidated into 4 logical plugin groups for better maintainability.

## Overview

- **Structure**: 4 plugin categories + core files
- **Principles**:
  - Aggressive lazy loading (preload TypeScript ecosystem)
  - Standardized JS/TS tooling (always oxfmt + oxlint + tsgo + tailwindcss)
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
│   ├── utils.lua            # Shared utility functions (theme loader)
│   └── plugins/
│       ├── ui.lua           # Theme, status line, dashboard, snacks, bufferline
│       ├── editor.lua       # Fuzzy finder, file explorer, git, navigation, indent guides
│       ├── coding.lua       # Syntax, completion, LSP, tools
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
- **bufferline.nvim** - tab-like buffer bar with diagnostics integration

**Features**:

- Loads theme override from `.nvim.local` (theme=light/dark)
- Auto-dark-mode respects `.nvim.local` theme setting
- Buffer line shows open buffers with close icons and LSP diagnostics

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
- **indent-blankline.nvim** - indent guides (vertical lines showing indentation levels)

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
- **mason.nvim** + **mason-lspconfig.nvim** + **nvim-lspconfig** - LSP management
- **neocodeium** - AI completion (event: VeryLazy)
- **tailwind-highlight.nvim** - Tailwind CSS color highlighting
- **nvim-autopairs** - auto-close brackets (event: InsertEnter)
- **nvim-ts-autotag** - auto-close/rename HTML tags

**LSP Servers** (all via nvim-lspconfig):

- **Always enabled**: lua_ls, solidity, jsonls, taplo, gopls
- **JS/TS ecosystem**:
  - tsgo - TypeScript language features
  - oxlint - Linting and diagnostics (uses nvim-lspconfig defaults)
  - oxfmt - Code formatting via LSP (uses nvim-lspconfig defaults)
  - tailwindcss - CSS completion and IntelliSense (custom config for v4 support)
- Tailwind v4 CSS config detection (auto-detects @import 'tailwindcss')

**Formatting**:

- Uses oxfmt LSP for JS/TS files (no conform.nvim)
- Format on save enabled via LSP

**Diagnostics**:

- Custom signs: 🔴 for ERROR, 🟡 for WARN

### tools.lua

**Purpose**: Specialized development tools

**Plugins**:

- **opencode.nvim** - OpenCode AI assistant
  - Dependencies: snacks.nvim
  - Config: autoread enabled, automatic file reload on edits

## Keymaps Reference

### General

- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>Q` - Quit all
- `<leader>h` / `<leader>l` - Previous/next buffer (bufferline)
- `<leader>bo` - Close other buffers
- `<leader>bd` - Close current buffer

### LSP (conditional: only when LSP attached)

- `K` / `<leader>t` - Hover documentation
- `gd` - Go to definition (opens in new tab if different file)
- `gr` - Show references
- `<leader>a` - Code actions
- `<leader>n` / `<leader>m` - Next/previous diagnostic
- `<leader>si` - LSP info

### Formatting

- `<leader>cf` - Format with LSP (oxfmt for JS/TS)

### Bufferline

- `<leader>h` / `<leader>l` - Navigate buffers left/right
- `<leader>bo` - Close all other buffers
- `<leader>bd` - Delete current buffer

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

Create a `.nvim.local` file in project root to set theme preference:

```bash
# Example .nvim.local
theme=dark
```

**Format**:

- Lines starting with `#` are comments
- `theme=light` or `theme=dark` sets the color scheme
- Tool selection has been removed - all projects now use: oxfmt, oxlint, tsgo, tailwindcss

## Maintenance Commands

- **Update plugins**: `:Lazy update`
- **Clean unused**: `:Lazy clean`
- **Profile startup**: `:Lazy profile`
- **Check health**: `:checkhealth`
- **View logs**: `:Lazy log`
- **Sync lockfile**: `:Lazy sync`
- **Check LSP status**: `:LspInfo`

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
- For JS/TS LSPs (oxlint, oxfmt, tsgo, tailwindcss), ensure you're in a JS/TS file

### Formatting Not Working

- Ensure oxfmt LSP is running (`:LspInfo`)
- Verify filetype is javascript/typescript/javascriptreact/typescriptreact
- Check LSP logs for errors

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

## Recent Changes

- **Major refactor**: Removed conform.nvim and all .nvim.local tool configuration
- Now using LSP-native formatting via oxfmt (removed conform.nvim)
- Always enabled: oxfmt (formatting), oxlint (linting), tsgo (TypeScript), tailwindcss (CSS)
- All JS/TS LSPs are filetype-restricted to only load on relevant files
- Removed nvim-oxlint plugin (now using oxlint LSP directly)
- Removed vtsls option - tsgo is now the only TypeScript LSP
- .nvim.local now only supports theme configuration (light/dark)
- **Added format-on-save** (synchronous) for all files
- **Added indent-blankline.nvim** for visual indent guides
- **Added bufferline.nvim** for tab-like buffer bar
- **Created lua/utils.lua** for shared theme loading (deduplicated from ui.lua and coding.lua)
- **Fixed duplicate web-devicons** dependency in neo-tree
- **Simplified oxlint/oxfmt configuration** - now using nvim-lspconfig defaults with just `vim.lsp.enable()`

---

## Document Version

**Commit Hash**: `4ef093fa84571fb69e3d6d45f7ec7758b252c518`

### How to Update This Document

To update AGENTS.md in the future:

1. Get the current commit hash:

   ```bash
   git rev-parse HEAD
   ```

2. Compare changes since this document version:

   ```bash
   git diff 4ef093fa84571fb69e3d6d45f7ec7758b252c518..HEAD -- lua/ init.lua
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
