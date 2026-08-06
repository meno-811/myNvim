-- nvim-treesitter 的 main 分支不支持延迟加载，也不再使用旧版模块配置。
-- 具体功能由 AstroCore 的新版 Treesitter 适配层统一启用。

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                branch = "main",
            },
        },
    },
}
