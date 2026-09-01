-- 终端集成

return {
    {
        -- toggleterm.nvim  终端插件，用于在 Neovim 中打开终端窗口。
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                size = 20,
                open_mapping = [[<C-\>]], -- Ctrl+\ 打开/关闭终端
                direction = "float",

                on_open = function(term)
                    local opts = {
                        buffer = term.bufnr,
                        silent = true,
                    }

                    -- Alt+n（Normal）：终端输入模式 → 终端普通模式。
                    -- 保留 Esc 给终端内的交互程序使用。
                    vim.keymap.set(
                        "t",
                        "<A-n>",
                        [[<C-\><C-n>]],
                        vim.tbl_extend("force", opts, {
                            desc = "进入终端普通模式",
                        })
                    )
                end,
            })
        end,
    },
}
