-- AstroCore 仅管理诊断基础配置和 Treesitter 适配。
return {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
        opts.diagnostics = {
            update_in_insert = true,
            virtual_text = true,
            signs = true,
            underline = true,
            severity_sort = true,
        }

        -- 使用 AstroCore 对 nvim-treesitter main 分支的新 API 适配。
        -- 它会负责安装解析器，并按文件类型启用高亮、缩进和文本对象。
        opts.treesitter = {
            enabled = true,
            highlight = true,
            indent = true,
            ensure_installed = { "lua", "vim", "vimdoc", "bash", "markdown", "markdown_inline", "json", "go", "python" },
            auto_install = true,
            textobjects = {
                select = {
                    select_textobject = {
                        ["af"] = { query = "@function.outer", desc = "Select around function" },
                        ["if"] = { query = "@function.inner", desc = "Select inside function" },
                        ["ac"] = { query = "@class.outer", desc = "Select around class" },
                        ["ic"] = { query = "@class.inner", desc = "Select inside class" },
                    },
                },
            },
        }
    end,
}
