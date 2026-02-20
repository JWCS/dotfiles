-- ~/.dotfiles/nvim/lua/plugins/dap.lua
-- Debug Adapter Protocol: C/C++ (codelldb) + Python (debugpy)
-- mason-nvim-dap auto-installs adapters and configures them.
--
-- Workflow:
--   1. Set breakpoints:    <leader>db   (toggle),  <leader>dB (conditional)
--   2. Start/continue:     <F5>
--   3. Step over/into/out: <F10> / <F11> / <F12>
--   4. Toggle UI:          <leader>du   (manual — not auto-opened)
--   5. Open REPL:          <leader>dr
--
-- C/C++ notes:
--   - codelldb is installed by mason. It wraps lldb.
--   - On first launch you'll be prompted for the executable path.
--   - For repeated use, add a .nvim.lua in your project root:
--       require("dap").configurations.cpp = {{ name="...", type="codelldb",
--         request="launch", program="./build/my_binary", ... }}
--
-- Python notes:
--   - debugpy is installed by mason. Works with pyenv virtualenvs.

return {
  {
    "mfussenegger/nvim-dap",
    -- Load only when a DAP keymap is first pressed
    keys = {
      "<F5>", "<F10>", "<F11>", "<F12>",
      "<leader>db", "<leader>dB", "<leader>dr", "<leader>du",
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",         -- required by nvim-dap-ui
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      {
        -- Shows variable values as virtual text inline while debugging.
        -- Optional treesitter dep: uses it when loaded but doesn't require it at startup.
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- Auto-installs codelldb and debugpy; default handlers configure adapters
      require("mason-nvim-dap").setup({
        ensure_installed      = { "codelldb", "debugpy" },
        automatic_installation = true,
        handlers              = {},
      })

      dapui.setup()

      -- Fallback C/C++ launch config (mason-nvim-dap may set this already)
      if not dap.configurations.cpp then
        dap.configurations.cpp = {
          {
            name    = "Launch (codelldb)",
            type    = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd         = "${workspaceFolder}",
            stopOnEntry = false,
            args        = {},
          },
        }
        dap.configurations.c = dap.configurations.cpp
      end

      -- Keymaps
      local map = vim.keymap.set
      map("n", "<F5>",        dap.continue,         { desc = "DAP: Continue" })
      map("n", "<F10>",       dap.step_over,        { desc = "DAP: Step Over" })
      map("n", "<F11>",       dap.step_into,        { desc = "DAP: Step Into" })
      map("n", "<F12>",       dap.step_out,         { desc = "DAP: Step Out" })
      map("n", "<leader>db",  dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
      map("n", "<leader>dB",  function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end,                                           { desc = "DAP: Conditional Breakpoint" })
      map("n", "<leader>dr",  dap.repl.open,        { desc = "DAP: Open REPL" })
      map("n", "<leader>du",  dapui.toggle,         { desc = "DAP: Toggle UI" })
    end,
  },
}
