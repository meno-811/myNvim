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
  -- 2. diffview：专业级 diff / history / merge 工具
  -- ===========================
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- ===========================
  -- 3. lazygit：终端 Git UI（IDE 常用）
  -- ===========================
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },

  -- ===========================
  -- 4. git-conflict：冲突高亮 + 快速解决
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
  -- 5. gitlinker：生成 GitHub/GitLab 等链接
  -- ===========================
  {
    "ruifm/gitlinker.nvim",
    event = "BufReadPre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      mappings = "<leader>gy", -- 复制当前行链接
    },
  },

  -- ===========================
  -- 6. advanced-git-search：增强 Git 搜索（commit / branch / tag）
  -- ===========================
  {
    "aaronhallaert/advanced-git-search.nvim",
    cmd = {
      "AdvancedGitSearch",
      "AdvancedGitSearchDiffCommitLine",
      "AdvancedGitSearchDiffCommitFile",
    },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-fugitive",
    },
    opts = {},
  },

  -- ===========================
  -- 7. neogit：轻量 Git 客户端（类似 Magit）
  -- ===========================
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      integrations = {
        diffview = true,
      },
    },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    },
  },

  -- ===========================
  -- 8. aicommits：AI 生成 commit message
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