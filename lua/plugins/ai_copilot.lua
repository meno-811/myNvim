-- GitHub Copilot 官方 Vim/Neovim 插件
return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd = "Copilot",
    init = function()
      vim.g.copilot_version = false
    end,
  },
}
