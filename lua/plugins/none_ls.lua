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
        local h = require("null-ls.helpers")
        local methods = require("null-ls.methods")
        local u = require("null-ls.utils")

        -- 注册 flake8 诊断 source
        local flake8 = h.make_builtin({
            name = "flake8",
            method = methods.internal.DIAGNOSTICS,
            filetypes = { "python" },
            generator_opts = {
                command = "flake8",
                args = { "--format=%(path)s:%(row)d:%(col)d: %(code)s %(text)s", "$FILENAME" },
                to_temp_file = true,
                format = "line",
                check_exit_code = function(code)
                    return code <= 1
                end,
                on_output = function(line, params)
                    local path = u.escape(params.temp_path)
                    local pattern = path .. [[:(%d+):(%d+): ([A-Z]+%d+) (.*)]]
                    local diagnostic = h.diagnostics.from_pattern(
                        pattern,
                        { "row", "col", "code", "message" },
                        { diagnostic = { source = "flake8" } }
                    )(line, params)

                    if not diagnostic then
                        return
                    end

                    local code = diagnostic.code or ""
                    local first = code:sub(1, 1)
                    if first == "E" or first == "F" then
                        diagnostic.severity = h.diagnostics.severities.error
                    else
                        diagnostic.severity = h.diagnostics.severities.warning
                    end

                    return diagnostic
                end,
            },
            factory = h.generator_factory,
        })

        -- 注册格式化、诊断等 source
        null_ls.setup({
            sources = {
                -- Lua
                null_ls.builtins.formatting.stylua,

                -- Python
                null_ls.builtins.formatting.black,
                flake8,

                -- Shell
                null_ls.builtins.formatting.shfmt,

                -- go
                null_ls.builtins.formatting.goimports,
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
            "prettier",
            "eslint_d",
            "black",
            "flake8",
            "shfmt",
        },
        automatic_installation = true,
    },
  },
}
