-- 终端集成

return{
    -- toggleterm.nvim  终端插件，用于在 Neovim 中打开终端窗口。
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                size = 20,
                open_mapping = [[<c-\>]],  -- Ctrl-\ 打开终端
                direction = 'float',
            })
        end
    },
}