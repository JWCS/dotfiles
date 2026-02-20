-- ~/.dotfiles/nvim/lua/plugins/core.lua
-- Core plugins: syntax, git, navigation, session, snacks

local feat = function(var)
  return vim.env[var] ~= nil and vim.env[var] ~= ""
end

return {
  -- Treesitter: real syntax (not regex), proper indent/fold for C/Python/bash/etc.
  -- :TSInstall <lang>  :TSUpdate
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "python", "bash", "lua", "vim", "vimdoc",
          "cmake", "make", "yaml", "toml", "json",
          "markdown", "markdown_inline", "dockerfile",
          "ninja",
        },
        auto_install  = true,
        highlight     = { enable = true },
        indent        = { enable = true },
      })
    end,
  },

  -- Git gutter: added/changed/removed lines; hunk navigation with ]c [c
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs  = package.loaded.gitsigns
        local map = function(m, l, r, d)
          vim.keymap.set(m, l, r, { buffer = bufnr, desc = d })
        end
        map("n", "]c",        gs.next_hunk,    "Next hunk")
        map("n", "[c",        gs.prev_hunk,    "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk,  "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk,  "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk,"Preview hunk")
      end,
    },
  },

  -- Seamless C-hjkl navigation across nvim splits AND tmux panes.
  -- Requires tmux plugin (added in .tmux.conf): @plugin 'christoomey/vim-tmux-navigator'
  {
    "christoomey/vim-tmux-navigator",
    cmd  = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  silent = true },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  silent = true },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    silent = true },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", silent = true },
    },
  },

  -- tmux-resurrect session integration (vim-obsession tracks the session file)
  { "tpope/vim-obsession" },

  -- Return to last edit position on file open
  { "farmergreg/vim-lastplace" },

  -- Auto-close brackets/quotes
  { "LunarWatcher/auto-pairs" },

  -- Makes . repeat work for plugins (surround, etc.)
  { "tpope/vim-repeat" },

  -- tpope essentials: surround (cs"' ds" ysiw"), unimpaired ([b ]b etc.), abolish, fugitive
  -- Enable: export VRC_FEAT_TP_STD=1
  {
    "tpope/vim-surround",
    enabled      = feat("VRC_FEAT_TP_STD"),
    dependencies = { "tpope/vim-repeat" },
  },
  { "tpope/vim-unimpaired", enabled = feat("VRC_FEAT_TP_STD") },
  { "tpope/vim-abolish",    enabled = feat("VRC_FEAT_TP_STD") },
  { "tpope/vim-fugitive",   enabled = feat("VRC_FEAT_TP_STD") },

  -- GitHub Copilot. Enable: export VRC_FEAT_COPILOT=1
  { "github/copilot.vim",   enabled = feat("VRC_FEAT_COPILOT") },

  -- snacks.nvim: small QoL utilities (indent guides + word highlighting only)
  -- Everything else explicitly disabled to keep things lean.
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy     = false,
    opts = {
      indent   = { enabled = true },  -- show indent guides
      words    = { enabled = true },  -- highlight word under cursor across buffer
      -- explicitly disable the rest
      bigfile   = { enabled = false },
      dashboard = { enabled = false },
      explorer  = { enabled = false },
      picker    = { enabled = false },
      terminal  = { enabled = false },
      lazygit   = { enabled = false },
      notifier  = { enabled = false },
      scroll    = { enabled = false },
      animate   = { enabled = false },
      image     = { enabled = false },
    },
  },
}
