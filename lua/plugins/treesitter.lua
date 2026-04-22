-- 语法解析及高亮
-- 代替正则高亮

return{
{
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects", -- 必须加这个！
    },
    branch = "main",
    event = "VeryLazy",     -- 延迟加载,等到VeryLazy事件触发后再加载
    lazy = vim.fn.argc(-1) == 0,    -- 仅在没有命令行参数时才加载
    build = ":TSUpdate",     -- 建议在启动时更新解析器
    cmd = { "TSInstall", "TSUpdate", "TSUninstall" },
    opts = {
        -- 核心：必须指定要装哪些解析器，否则打开文件时报错
        ensure_installed = { "lua", "vim", "vimdoc", "bash", "markdown", "json","go","python" },

        -- 自动安装缺失的解析器（推荐）
        auto_install = true,

        -- 启用语法高亮（Treesitter 存在的意义）
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false, -- 关闭 vim 自带的正则高亮
        },

        -- 启用智能缩进
        indent = { enable = true },

        -- 启用增量选择
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",    -- 回车键，选择当前光标下的最小语法单元
                node_incremental = "<CR>",    -- 回车键，逐步扩大到外层节点
                node_decremental = "<BS>",    -- 回退键，回到上一层节点
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = "@function.outer",    -- 选择当前函数（包括函数声明）
                    ["if"] = "@function.inner",    -- 选择当前函数内部（不包括函数声明）
                    ["ac"] = "@class.outer",    -- 选择当前类（包括类声明）
                    ["ic"] = "@class.inner",    -- 选择当前类内部（不包括类声明）
                },
            },
        },
    },
    config = function(_, opts)
    require("nvim-treesitter").setup(opts)
    end,
},
}
