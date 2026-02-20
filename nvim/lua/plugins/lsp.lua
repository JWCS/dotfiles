-- ~/.dotfiles/nvim/lua/plugins/lsp.lua
-- LSP (smart completion + hints) + nvim-cmp (smart + dumb buffer-word completion)
-- Uses nvim 0.11+ native vim.lsp.config / vim.lsp.enable API (lspconfig deprecated)
--
-- :Mason               browse/install/update language servers
-- :LspInfo             show active LSP for current buffer
-- :LspLog              debug LSP issues
--
-- LSP keymaps (buffer-local, set on attach via LspAttach autocmd):
--   gd         go to definition
--   gD         go to declaration
--   gr         find all references (telescope)
--   gi         go to implementation
--   K          hover docs
--   <leader>rn rename symbol
--   <leader>ca code action
--   <leader>fs document symbols (telescope)
--
-- Completion keymaps:
--   C-n / C-p  navigate suggestions
--   C-Space    trigger completion manually
--   C-e        abort/close completion
--   CR         confirm (only if item is explicitly selected)
--   Tab/S-Tab  navigate + jump luasnip placeholders

return {
  -- Mason: installs/manages LSP servers, DAP adapters, linters, formatters
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },

  -- mason-lspconfig: bridges mason ↔ nvim's lsp (auto-installs servers)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",    -- C / C++
          "pyright",   -- Python (node-based; works regardless of installed Python version)
          "bashls",    -- Bash / sh  (uses your node from pnpm)
          "lua_ls",    -- Lua        (for editing this nvim config)
          "yamlls",    -- YAML
          "jsonls",    -- JSON
          "taplo",     -- TOML
          -- "cmake",  -- CMake language server needs Python >=3.9;
          --           -- uncomment after: pyenv install 3.x && pyenv global 3.x
        },
        automatic_installation = true,
      })
    end,
  },

  -- Lightweight LSP status spinner (bottom-right while server indexes)
  { "j-hui/fidget.nvim", opts = {} },

  -- nvim-lspconfig: server configs consumed by vim.lsp.config (nvim 0.11+ native API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",    -- must load before lspconfig to get capabilities
      "j-hui/fidget.nvim",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Buffer-local LSP keymaps, set on every LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end
          local tb = require("telescope.builtin")

          map("gd",          vim.lsp.buf.definition,     "Go to definition")
          map("gD",          vim.lsp.buf.declaration,    "Go to declaration")
          map("gr",          tb.lsp_references,          "Find references")
          map("gi",          vim.lsp.buf.implementation, "Go to implementation")
          map("K",           vim.lsp.buf.hover,          "Hover docs")
          map("<leader>rn",  vim.lsp.buf.rename,         "Rename symbol")
          map("<leader>ca",  vim.lsp.buf.code_action,    "Code action")
          map("<leader>fs",  tb.lsp_document_symbols,    "Document symbols")
        end,
      })

      -- nvim 0.11 native API: vim.lsp.config + vim.lsp.enable
      -- lspconfig provides the default configs (cmd, root_dir, etc.) which
      -- vim.lsp.config inherits; we just override capabilities and per-server settings.

      local servers = {
        clangd  = {},
        pyright = {
          settings = {
            python = {
              -- Prefers pyenv shim if available; falls back to system python3/python
              pythonPath = (
                vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
                or vim.fn.exepath("python")
              ),
            },
          },
        },
        bashls  = {},
        yamlls  = {},
        jsonls  = {},
        taplo   = {},
        lua_ls  = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace   = {
                library         = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        -- vim.lsp.config merges with lspconfig's default (cmd, root_dir, filetypes)
        vim.lsp.config(server, config)
      end

      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },

  -- nvim-cmp: completion engine
  -- Sources (in priority order): LSP → LuaSnip → nvim Lua API → buffer words → paths
  -- cmp-buffer (keyword_length=3) provides "dumb" completion from open buffers,
  -- equivalent to YCM's identifier completer.
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-d>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          -- CR only confirms an explicitly selected item (select=false).
          -- Pressing Enter on a blank line stays blank — no surprise completions.
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "nvim_lua" },
          },
          {
            { name = "buffer", keyword_length = 3 },
            { name = "path" },
          }
        ),
      })
    end,
  },
}
