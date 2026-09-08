-- GitHub Copilot 官方 Vim/Neovim 插件
return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd = "Copilot",
    init = function()
      vim.g.copilot_version = false
      -- 不让 Copilot 占用 Tab；Tab 继续交给 nvim-cmp/LuaSnip 和编辑器本身。
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      -- Alt+L 明确接受 Copilot 的整条建议。
      vim.keymap.set("i", "<M-l>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        silent = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion",
      })
    end,
  },
}
