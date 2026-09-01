-- GitHub Copilot Chat 的备用配置。
-- 当前在 plugins/init.lua 中保持注释，不会安装或加载；需要替换 Claude Code 时再启用。
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "github/copilot.vim",
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    opts = {
      -- 默认使用浮动窗口，避免和 Claude Code 的右侧终端布局绑定。
      window = {
        layout = "float",
      },
    },
    keys = {
      { "<leader>ap", "<cmd>CopilotChatToggle<cr>", desc = "切换 Copilot Chat" },
      { "<leader>ac", "<cmd>CopilotChatCommit<cr>", desc = "生成 Git commit message" },
    },
  },
}
