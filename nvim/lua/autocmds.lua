-- ~/.dotfiles/nvim/lua/autocmds.lua
-- Translated from .vimrc.min augroups

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Strip trailing whitespace on save (preserves cursor position)
augroup("StripWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "StripWhitespace",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Filetype-specific settings
augroup("FiletypeSettings", { clear = true })

autocmd("FileType", {
  group   = "FiletypeSettings",
  pattern = { "make", "gitconfig" },
  callback = function()
    vim.opt_local.expandtab   = false
    vim.opt_local.tabstop     = 8
    vim.opt_local.shiftwidth  = 8
    vim.opt_local.softtabstop = 0
  end,
})

autocmd({ "BufRead", "BufNewFile", "BufReadPost" }, {
  group   = "FiletypeSettings",
  pattern = ".gitconfig.*",
  callback = function()
    vim.bo.filetype = "gitconfig"
  end,
})

autocmd("FileType", {
  group   = "FiletypeSettings",
  pattern = "python",
  callback = function()
    vim.opt_local.foldmethod  = "indent"
    vim.opt_local.foldnestmax = 2
  end,
})

-- Dockerfile folding (translated from vim's DockerfileFoldExpr)
_G.DockerfileFoldExpr = function(lnum)
  local line = vim.fn.getline(lnum)
  if line:match("^%s*$")   then return "-1" end  -- blank
  if line:match("^FROM")   then return "0"  end  -- FROM starts a stage
  if line:match("^##")     then return "0"  end  -- section comment
  if line:match("^#")      then return "1"  end  -- comment
  if line:match("^%u+")    then return ">1" end  -- ALLCAP directive (RUN, COPY…)
  return "2"
end

autocmd("FileType", {
  group   = "FiletypeSettings",
  pattern = "dockerfile",
  callback = function()
    vim.opt_local.expandtab   = false
    vim.opt_local.tabstop     = 2
    vim.opt_local.shiftwidth  = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.foldmethod  = "expr"
    vim.opt_local.foldlevel   = 2
    vim.opt_local.foldexpr    = "v:lua.DockerfileFoldExpr(v:lnum)"
  end,
})

-- Shell: shellcheck keymap (VRC_LANG_SH feature flag)
if vim.env.VRC_LANG_SH then
  autocmd("FileType", {
    group   = "FiletypeSettings",
    pattern = "sh",
    callback = function()
      vim.keymap.set("n", "<leader>c",
        "<cmd>ShellCheck! -x<cr><cr>",
        { buffer = true, silent = true, desc = "ShellCheck" })
    end,
  })
end
