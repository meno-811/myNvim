-- 文件树插件

return {
  "nvim-neo-tree/neo-tree.nvim", -- 插件仓库
  branch = "v3.x", -- 使用 v3.x 分支
  dependencies = {
    "nvim-lua/plenary.nvim", -- 通用工具库
    "MunifTanjim/nui.nvim", -- UI 组件库
    "nvim-tree/nvim-web-devicons", -- 文件图标
    "mrbjarksen/neo-tree-diagnostics.nvim", -- <- 放在这里
  },
  cmd = "Neotree", -- 延迟加载命令（Neotree 命令触发时加载）
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" }, -- 切换侧边栏
    {
      "<leader>o",
      function()
        -- 如果当前 buffer 是 neo-tree，则切换到上一个窗口；否则聚焦 neo-tree
        if vim.bo.filetype == "neo-tree" then
          vim.cmd("wincmd p")
        else
          vim.cmd("Neotree focus")
        end
      end,
      desc = "Toggle Explorer Focus", -- 切换侧边栏焦点
    },
  },

  -- lazygit 关闭后刷新 Neo-tree 的几个 source
  init = function()
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit*", -- 匹配 lazygit 终端名
      callback = function()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if not ok then
          return
        end

        -- 刷新以下 source（如果已加载）
        for _, source in ipairs({ "filesystem", "git_status", "diagnostics" }) do
          local mod = "neo-tree.sources." .. source
          if package.loaded[mod] then
            manager.refresh(require(mod).name)
          end
        end
      end,
    })
  end,

  opts = function()
    local git_available = vim.fn.executable("git") == 1 -- 检查系统是否有 git 可执行文件

    -- source 选择器显示项（带显示名称）
    local sources = {
      { source = "filesystem", display_name = "File" }, -- 文件系统
      { source = "buffers", display_name = "Bufs" }, -- 打开的 buffer 列表
      { source = "diagnostics", display_name = "Diag" }, -- 诊断信息
    }
    if git_available then
      -- 如果有 git，则在第三位插入 git_status 源
      table.insert(sources, 3, { source = "git_status", display_name = "Git" })
    end

    return {
      enable_git_status = git_available, -- 是否启用 git 状态
      close_if_last_window = true, -- 如果是最后一个窗口则关闭 neo-tree
      auto_clean_after_session_restore = true, -- 会话恢复后自动清理

      -- 实际启用的 sources 列表（根据 git 可用性切换）
      sources = git_available and { "filesystem", "buffers", "git_status", "diagnostics" } or { "filesystem", "buffers", "diagnostics" },

      source_selector = {
        winbar = true, -- 在 winbar 显示 source 选择器
        content_layout = "center", -- 内容居中
        sources = sources, -- 上面构建的 sources 配置
      },

      commands = {
        -- 使用 Neovim 的 UI 打开文件（跨平台）
        system_open = function(state)
          vim.ui.open(state.tree:get_node():get_id())
        end,

        -- 如果有子节点且已展开则折叠，否则聚焦父节点
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if node:has_children() and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,

        -- 如果有子节点则展开或聚焦第一个子节点；否则打开文件
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node:has_children() then
            if not node:is_expanded() then
              state.commands.toggle_node(state)
            else
              if node.type == "file" then
                state.commands.open(state)
              else
                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
              end
            end
          else
            state.commands.open(state)
          end
        end,

        -- 复制路径/文件名等多种格式到系统剪贴板
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local vals = {
            ["BASENAME"] = modify(filename, ":r"), -- 不带扩展名的文件名
            ["EXTENSION"] = modify(filename, ":e"), -- 扩展名
            ["FILENAME"] = filename, -- 文件名
            ["PATH (CWD)"] = modify(filepath, ":."), -- 相对于当前工作目录的路径
            ["PATH (HOME)"] = modify(filepath, ":~"), -- 相对于 HOME 的路径
            ["PATH"] = filepath, -- 完整路径
            ["URI"] = vim.uri_from_fname(filepath), -- 文件 URI
          }

          -- 过滤掉空值选项
          local options = vim.tbl_filter(function(key)
            return vals[key] ~= ""
          end, vim.tbl_keys(vals))

          if vim.tbl_isempty(options) then
            vim.notify("No values to copy", vim.log.levels.WARN) -- 无可复制项时提示
            return
          end

          table.sort(options)

          -- 让用户选择要复制的项，并写入系统剪贴板（+ 寄存器）
          vim.ui.select(options, {
            prompt = "Choose value to copy:",
            format_item = function(item)
              return string.format("%s: %s", item, vals[item])
            end,
          }, function(choice)
            local result = vals[choice]
            if result then
              vim.fn.setreg("+", result) -- 写入系统剪贴板
              vim.notify("Copied: " .. result) -- 通知用户
            end
          end)
        end,
      },

      window = {
        width = 30, -- 侧边栏宽度
        mappings = {
          -- ["<BS>"] = false,
          ["<bs>"] = false,
          ["<S-CR>"] = "system_open", -- Shift+Enter 使用 system_open
          ["<space>"] = false, -- 取消空格默认映射
          ["[b"] = "prev_source", -- 切换到上一个 source
          ["]b"] = "next_source", -- 切换到下一个 source
          ["O"] = "system_open", -- 大写 O 也打开系统打开
          ["Y"] = "copy_selector", -- Y 调出复制选择器
          ["h"] = "parent_or_close", -- h 折叠或聚焦父节点
          ["l"] = "child_or_open", -- l 展开或打开子节点/文件
        },
        fuzzy_finder_mappings = {
          ["<C-J>"] = "move_cursor_down", -- 模糊查找中向下移动
          ["<C-K>"] = "move_cursor_up", -- 模糊查找中向上移动
        },
      },

      filesystem = {
        follow_current_file = { enabled = true }, -- 跟随当前打开的文件
        filtered_items = { hide_gitignored = git_available ,hide_dotfiles = false,visible = true}, -- 隐藏 .gitignore 中的文件（如果有 git）
        hijack_netrw_behavior = "open_current", -- 接管 netrw 行为并打开当前目录
        use_libuv_file_watcher = vim.fn.has("win32") ~= 1, -- 非 Windows 使用 libuv 文件监听
        -- window = {mappings = {["<bs>"] = false,["<BS>"] = false}}
      },

      event_handlers = {
        {
          event = "neo_tree_buffer_enter", -- 进入 neo-tree buffer 时触发
          handler = function()
            vim.opt_local.signcolumn = "auto" -- 本地启用 signcolumn 自动显示
            vim.opt_local.foldcolumn = "0" -- 隐藏 foldcolumn
          end,
        },
      },
    }
  end,
}
