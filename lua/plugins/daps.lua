-- 调试器插件

return {
  -- DAP 核心插件
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- =========================
      --  基础 UI
      -- =========================
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup({
        commented = true, -- 在注释中显示虚拟文本
      })

      -- 自动打开/关闭 UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- =========================
      --  常用快捷键
      -- =========================
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI Toggle" })

      -- =========================
      --  Go 调试器（dlv）
      -- =========================
      dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }

      dap.configurations.go = {
        {
          type = "go",
          name = "Debug",
          request = "launch",
          program = "${file}",
        },
        {
          type = "go",
          name = "Debug Package",
          request = "launch",
          program = "${fileDirname}",
        },
      }

      -- =========================
      --  Python 调试器（debugpy）
      -- =========================
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
        },
      }

    --   -- =========================
    --   --  Node / JS / TS 调试器（vscode-js-debug）
    --   -- =========================
    --   dap.adapters["pwa-node"] = {
    --     type = "server",
    --     host = "localhost",
    --     port = "${port}",
    --     executable = {
    --       command = "node",
    --       args = {
    --         vim.fn.stdpath("data") .. "/lazy/vscode-js-debug/out/src/vsDebugServer.js",
    --         "${port}",
    --       },
    --     },
    --   }

    --   dap.configurations.javascript = {
    --     {
    --       type = "pwa-node",
    --       request = "launch",
    --       name = "Launch file",
    --       program = "${file}",
    --       cwd = "${workspaceFolder}",
    --     },
    --   }

    --   dap.configurations.typescript = dap.configurations.javascript
    end,
  },

--   -- vscode-js-debug（JS/TS 调试器）
--   {
--     "microsoft/vscode-js-debug",
--     build = "npm install --legacy-peer-deps && npm run compile",
--   },
}
