-- Git 相关的插件

return {
  -- ===========================
  -- 1. gitsigns：行内 Git 变更标记 + hunk 操作
  -- ===========================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = true, -- 显示当前行 blame
      current_line_blame_opts = {
        delay = 300,
      },
    },
  },

  -- ===========================
  -- 2. lazygit：终端 Git UI（IDE 常用）
  -- ===========================
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },

  -- ===========================
  -- 3. git-conflict：冲突高亮 + 快速解决
  -- ===========================
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      default_mappings = true,
      disable_diagnostics = true,
    },
  },

  -- ===========================
  -- 4. aicommits：AI 生成 commit message
  -- ===========================
--   {
--     "james1236/aicommits.nvim",
--     cmd = "AICommits",
--     opts = {
--       model = "gpt-4o-mini", -- 可改为你喜欢的模型
--       commit_msg_format = "conventional", -- conventional commit 风格
--     },
--   },
}
