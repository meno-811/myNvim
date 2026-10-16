-- 终端集成

return {
    {
        -- toggleterm.nvim  终端插件，用于在 Neovim 中打开终端窗口。
        "akinsho/toggleterm.nvim",
        config = function()
            local toggleterm = require("toggleterm")
            local Terminal = require("toggleterm.terminal").Terminal
            toggleterm.setup({
                size = 20,
                open_mapping = [[<C-\>]], -- Ctrl+\ 打开/关闭终端
                direction = "float",
            })

            vim.api.nvim_create_user_command("Config", function()
                local term = Terminal:new({
                    dir = vim.fn.stdpath("config"),
                    direction = "float",
                })
                term:open()
            end, { desc = "在终端中进入 Neovim 配置目录" })
        end,
    },
}
