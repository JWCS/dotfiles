-- ~/.dotfiles/nvim/lua/keys.lua
-- Keybindings: preserves vim muscle memory, adds telescope/LSP/DAP

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local map  = vim.keymap.set
local opts = { silent = true }

-- Insert mode escape (same as vim)
map("i", "jj", "<ESC>")

-- Clear search highlight
map("n", "<leader><cr>", ":noh<cr>", opts)

-- Toggle line numbers
map("n", "<leader>n", ":set relativenumber! number!<cr>", opts)

-- Redraw (e.g. after terminal resize)
map("n", "<leader>l", ":redraw!<cr>", opts)

-- Source config
map("n", "<leader>s", ":source $MYVIMRC<cr>")

-- Paste without replacing yank register
map("x", "p", '"_dP')

-- Window navigation: vim-tmux-navigator overrides these when active.
-- Kept as fallback if plugin not loaded.
map("n", "<C-h>", "<C-W>h")
map("n", "<C-j>", "<C-W>j")
map("n", "<C-k>", "<C-W>k")
map("n", "<C-l>", "<C-W>l")

-- Telescope
map("n", "<leader>f",  "<cmd>Telescope find_files<cr>",  opts)
map("n", "<leader>g",  "<cmd>Telescope live_grep<cr>",   opts)
map("n", "<leader>b",  "<cmd>Telescope buffers<cr>",     opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",   opts)

-- LSP (on_attach adds buffer-local: gd gD gr gi K <leader>rn <leader>ca <leader>fs)

-- Diagnostics (buffer-global)
map("n", "[d",        vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
map("n", "]d",        vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
