-- 伪 LSP 桥接器。
-- Neovim 原生通过 LSP 协议做格式化和诊断，但很多工具（prettier、black、eslint）并不是真正的 LSP 服务器。
-- none-ls 把这些外部命令行工具包装成 LSP 行为

return {
    {
        "nvimtools/none-ls.nvim",
        event = "BufReadPre",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "jay-babu/mason-null-ls.nvim",
        },

        config = function()
        local null_ls = require("null-ls")

        -- 注册格式化 source
        null_ls.setup({
            sources = {
                -- Lua
                null_ls.builtins.formatting.stylua,

                -- Python
                null_ls.builtins.formatting.black,

                -- Shell
                null_ls.builtins.formatting.shfmt,

            },
        })
    end,
    },
    -- mason-null-ls 自动安装工具
    {
        "jay-babu/mason-null-ls.nvim",
        event = "BufReadPre",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
        ensure_installed = {
            "stylua",
            "black",
            "shfmt",
        },
        automatic_installation = true,
    },
  },
}
