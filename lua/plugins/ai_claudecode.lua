-- Claude Code IDE 集成：终端、上下文发送和 diff 审阅。
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        git_repo_cwd = true,
        auto_insert = false,
        snacks_win_opts = {
          keys = {
            claude_terminal_normal = {
              "<A-n>",
              function() vim.cmd("stopinsert") end,
              mode = "t",
              desc = "进入终端普通模式",
            },
            claude_win_left = {
              "<C-Left>",
              function() vim.cmd("wincmd h") end,
              mode = "t",
              desc = "移动到左侧窗口",
            },
            claude_win_down = {
              "<C-Down>",
              function() vim.cmd("wincmd j") end,
              mode = "t",
              desc = "移动到下方窗口",
            },
            claude_win_up = {
              "<C-Up>",
              function() vim.cmd("wincmd k") end,
              mode = "t",
              desc = "移动到上方窗口",
            },
            claude_win_right = {
              "<C-Right>",
              function() vim.cmd("wincmd l") end,
              mode = "t",
              desc = "移动到右侧窗口",
            },
          },
        },
      },
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "切换 Claude Code" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "聚焦 Claude Code" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "恢复 Claude 会话" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "继续 Claude 会话" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "选择 Claude 模型" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "添加当前缓冲区" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "发送选区给 Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "添加文件给 Claude",
        ft = { "neo-tree" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "接受 Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "拒绝 Claude diff" },
    },
  },
}
