-- ~/.dotfiles/nvim/lua/plugins/telescope.lua
-- Fuzzy finding: files, grep, buffers, LSP symbols, help
-- Keymaps: <leader>f  <leader>g  <leader>b  <leader>fh  <leader>fs (from lsp.lua)
-- Inside picker: C-j/k navigate, C-q send to quickfix, Esc close

return {
  {
    "nvim-telescope/telescope.nvim",
    branch       = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Native fzf sorter: faster filtering (requires make)
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          -- bottom_pane: attaches to bottom of screen, doesn't float over buffer.
          -- Feels like a command-line tool rather than an IDE popup.
          layout_strategy = "bottom_pane",
          layout_config   = {
            bottom_pane = { height = 0.4 },
          },
          sorting_strategy = "ascending",
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
  },
}
