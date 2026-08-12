-- IDE 风格的可点击路径/代码层级导航栏（显示在编辑窗口的 winbar 中）。
return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    vim.g.dropbar_enabled = vim.g.dropbar_enabled ~= false

    return {
      bar = {
        enable = function(buf, win)
          if not vim.g.dropbar_enabled then
            return false
          end
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
            return false
          end

          -- 只占用普通编辑窗口自身的标题栏，不影响 Neo-tree、Claude Code 或浮窗。
          return vim.fn.win_gettype(win) == ""
            and vim.bo[buf].buftype == ""
            and vim.bo[buf].filetype ~= "neo-tree"
            and vim.api.nvim_buf_get_name(buf) ~= ""
        end,
      },
    }
  end,
  config = function(_, opts)
    require("dropbar").setup(opts)

    local function toggle_dropbar()
      vim.g.dropbar_enabled = not vim.g.dropbar_enabled

      if not vim.g.dropbar_enabled then
        -- Dropbar 用窗口局部的 winbar 显示，清空它不会改变任何窗口布局。
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            vim.wo[win].winbar = ""
          end
        end
      else
        -- 重新触发附着事件，让所有可见的普通编辑窗口恢复路径栏。
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = buf, modeline = false })
          end
        end
      end

      vim.notify("路径导航栏已" .. (vim.g.dropbar_enabled and "开启" or "关闭"))
    end

    vim.keymap.set("n", "<leader>up", toggle_dropbar, {
      desc = "切换路径导航栏",
      silent = true,
    })
    vim.keymap.set("n", "<leader>;", require("dropbar.api").pick, {
      desc = "选择路径/代码层级",
      silent = true,
    })
  end,
}
