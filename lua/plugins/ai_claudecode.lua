-- Claude Code IDE 集成：终端、上下文发送和 diff 审阅。
local function focus_claude_insert(retries)
  local ok, terminal = pcall(require, "claudecode.terminal")
  local bufnr = ok and terminal.get_active_terminal_bufnr() or nil

  if bufnr then
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      local win_config = vim.api.nvim_win_get_config(winid)
      if vim.api.nvim_win_get_buf(winid) == bufnr and win_config.hide ~= true then
        vim.api.nvim_set_current_win(winid)
        vim.cmd("startinsert")
        return
      end
    end
  end

  if retries > 0 then
    vim.defer_fn(function() focus_claude_insert(retries - 1) end, 20)
  end
end

local function claude_toggle_insert()
  vim.cmd("ClaudeCode")
  focus_claude_insert(10)
end

local function claude_open_insert()
  vim.cmd("ClaudeCodeOpen")
  focus_claude_insert(10)
end

local function claude_send_insert()
  vim.cmd("ClaudeCodeSend")
  -- ClaudeCodeSend 会安排选区处理；让聚焦动作排在它之后。
  vim.schedule(claude_open_insert)
end

local function claude_tree_add_insert()
  vim.cmd("ClaudeCodeTreeAdd")
  claude_open_insert()
end

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        git_repo_cwd = true,
        auto_insert = false,
        snacks_win_opts = {
          on_buf = function(self)
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(self.buf) then return end
              vim.keymap.set("t", "<C-w>", "<Nop>", {
                buffer = self.buf,
                nowait = false,
                desc = "Claude 窗口命令前缀",
              })
            end)
          end,
          keys = {
            claude_toggleterm = {
              [[<C-\>]],
              function() vim.cmd("ToggleTerm") end,
              mode = "t",
              desc = "切换终端浮窗",
            },
            claude_hide = {
              "<leader>q",
              function(self) self:hide() end,
              mode = "n",
              desc = "隐藏 Claude Code",
            },
            claude_win_left = {
              "<C-w>h",
              function() vim.cmd("wincmd h") end,
              mode = "t",
              desc = "移动到左侧窗口",
            },
            claude_win_down = {
              "<C-w>j",
              function() vim.cmd("wincmd j") end,
              mode = "t",
              desc = "移动到下方窗口",
            },
            claude_win_up = {
              "<C-w>k",
              function() vim.cmd("wincmd k") end,
              mode = "t",
              desc = "移动到上方窗口",
            },
            claude_win_right = {
              "<C-w>l",
              function() vim.cmd("wincmd l") end,
              mode = "t",
              desc = "移动到右侧窗口",
            },
            claude_win_next = {
              "<C-w>w",
              function() vim.cmd("wincmd w") end,
              mode = "t",
              desc = "切换到下一个窗口",
            },
            claude_win_left_ctrl = {
              "<C-w><C-h>",
              function() vim.cmd("wincmd h") end,
              mode = "t",
              desc = "移动到左侧窗口",
            },
            claude_win_down_ctrl = {
              "<C-w><C-j>",
              function() vim.cmd("wincmd j") end,
              mode = "t",
              desc = "移动到下方窗口",
            },
            claude_win_up_ctrl = {
              "<C-w><C-k>",
              function() vim.cmd("wincmd k") end,
              mode = "t",
              desc = "移动到上方窗口",
            },
            claude_win_right_ctrl = {
              "<C-w><C-l>",
              function() vim.cmd("wincmd l") end,
              mode = "t",
              desc = "移动到右侧窗口",
            },
            claude_win_next_ctrl = {
              "<C-w><C-w>",
              function() vim.cmd("wincmd w") end,
              mode = "t",
              desc = "切换到下一个窗口",
            },
            claude_win_left_arrow = {
              "<C-w><Left>",
              function() vim.cmd("wincmd h") end,
              mode = "t",
              desc = "移动到左侧窗口",
            },
            claude_win_down_arrow = {
              "<C-w><Down>",
              function() vim.cmd("wincmd j") end,
              mode = "t",
              desc = "移动到下方窗口",
            },
            claude_win_up_arrow = {
              "<C-w><Up>",
              function() vim.cmd("wincmd k") end,
              mode = "t",
              desc = "移动到上方窗口",
            },
            claude_win_right_arrow = {
              "<C-w><Right>",
              function() vim.cmd("wincmd l") end,
              mode = "t",
              desc = "移动到右侧窗口",
            },
          },
        },
      },
    },
    keys = {
      { "<leader>a", "<Nop>", desc = "AI/Claude Code" },
      {
        "<leader>ac",
        claude_toggle_insert,
        desc = "切换 Claude Code",
      },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "聚焦 Claude Code" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "恢复 Claude 会话" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "继续 Claude 会话" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "选择 Claude 模型" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "添加当前缓冲区" },
      {
        "<leader>as",
        claude_send_insert,
        mode = "v",
        desc = "发送选区并聚焦 Claude",
      },
      {
        "<leader>as",
        claude_tree_add_insert,
        desc = "添加文件并聚焦 Claude",
        ft = { "neo-tree" },
      },
      {
        "<leader>as",
        claude_open_insert,
        desc = "聚焦 Claude Code 并输入",
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "接受 Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "拒绝 Claude diff" },
    },
  },
}
