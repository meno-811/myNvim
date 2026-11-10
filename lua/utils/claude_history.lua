local M = {}
local marker
local internal_focus = false
local pending_entry
local history_windows = {}

local function focus_terminal(win)
  internal_focus = true
  vim.api.nvim_set_current_win(win)
  internal_focus = false
end

local function close_history(win)
  local view = history_windows[win]
  if view and vim.api.nvim_win_is_valid(view) then
    vim.api.nvim_win_close(view, true)
  end
end

function M.start_input(win)
  -- ClaudeCodeOpen may already have queued a normal-mode WinEnter.
  pending_entry = nil
  -- Focus Claude first so Snacks does not close zoom on entering the editor.
  focus_terminal(win)
  close_history(win)
  vim.cmd.startinsert()
end

function M.on_exit(terminal)
  pending_entry = nil
  local windows = vim.fn.win_findbuf(terminal)
  local zoom = Snacks.zen.win
  local close_zoom = zoom and vim.tbl_contains(windows, zoom.win)
  vim.schedule(function()
    for _, win in ipairs(windows) do close_history(win) end
    if close_zoom and zoom:valid() then zoom:close() end
  end)
end

function M.on_enter(terminal)
  if internal_focus then return end
  local win = vim.api.nvim_get_current_win()
  local entry = {}
  pending_entry = entry
  vim.schedule(function()
    if pending_entry ~= entry then return end
    pending_entry = nil
    if vim.api.nvim_get_current_win() == win and vim.fn.mode() == "n" then
      M.open(terminal)
    end
  end)
end

function M.terminal_command()
  local root = vim.fn.stdpath("config")
  local settings = vim.fn.tempname() .. ".json"
  marker = vim.fn.tempname()
  local command = table.concat({
    vim.fn.shellescape(vim.v.progpath), "-l",
    vim.fn.shellescape(root .. "/claude-session.lua"), vim.fn.shellescape(marker),
  }, " ")
  vim.fn.writefile({ vim.json.encode({
    hooks = { SessionStart = { { hooks = { { type = "command", command = command } } } } },
  }) }, settings)
  return ('claude --settings "%s"'):format(settings)
end

local function transcript_lines()
  if not marker or vim.fn.filereadable(marker) == 0 then return end
  local path = vim.fn.readfile(marker, "", 1)[1]
  if not path or vim.fn.filereadable(path) == 0 then return end

  local lines = {}
  for _, raw in ipairs(vim.fn.readfile(path)) do
    local ok, entry = pcall(vim.json.decode, raw)
    if ok and type(entry) == "table" and not entry.isSidechain and not entry.isMeta
        and (entry.type == "user" or entry.type == "assistant") and type(entry.message) == "table" then
      local content = entry.message.content
      local blocks = type(content) == "string" and { { type = "text", text = content } } or content
      for _, block in ipairs(type(blocks) == "table" and blocks or {}) do
        if type(block) == "table" and block.type == "text" and type(block.text) == "string" then
          vim.list_extend(lines, { entry.type == "user" and "## 你" or "## Claude", "" })
          vim.list_extend(lines, vim.split(block.text, "\n", { plain = true }))
          table.insert(lines, "")
        end
      end
    end
  end
  return #lines > 0 and lines or nil
end

function M.zoom(terminal, on_focus)
  local zoom = Snacks.zen.win
  local current = vim.api.nvim_get_current_win()
  local sidebar
  if zoom and zoom.win == current then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if win ~= current and vim.api.nvim_win_get_buf(win) == terminal
          and vim.api.nvim_win_get_config(win).hide ~= true then
        sidebar = win
        break
      end
    end
  end

  internal_focus = true
  Snacks.zen.zoom()
  internal_focus = false
  if sidebar or on_focus then
    vim.schedule(function()
      if sidebar and vim.api.nvim_win_is_valid(sidebar)
          and vim.api.nvim_win_get_buf(sidebar) == terminal then
        focus_terminal(sidebar)
      end
      if vim.api.nvim_get_current_buf() == terminal and on_focus then on_focus() end
    end)
  end
end

function M.open(terminal, lines, cursor, markdown)
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) ~= terminal or vim.bo[terminal].buftype ~= "terminal" then
    return
  end

  local existing = history_windows[win]
  if existing and vim.api.nvim_win_is_valid(existing) then
    vim.api.nvim_set_current_win(existing)
    return
  end

  if not lines then
    lines = transcript_lines()
    markdown = lines ~= nil
    lines = lines or vim.api.nvim_buf_get_lines(terminal, 0, -1, false)
  end
  while #lines > 1 and lines[#lines]:match("^%s*$") do
    table.remove(lines)
  end

  local history = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(history, 0, -1, false, lines)
  vim.bo[history].modifiable = false
  vim.bo[history].bufhidden = "wipe"
  if markdown then vim.bo[history].filetype = "markdown" end

  -- Snacks owns the terminal window and restores its buffer on BufWinEnter.
  -- Cover it with a separate window while keeping the terminal grid intact.
  local height = vim.api.nvim_win_get_height(win)
  local footer = height > 1
  local view = vim.api.nvim_open_win(history, true, {
    relative = "win",
    win = win,
    row = 0,
    col = 0,
    width = vim.api.nvim_win_get_width(win),
    height = footer and height - 1 or height,
    style = "minimal",
    border = footer and { "", "", "", "", "", "─", "", "" } or "none",
    footer = footer and { { " ❯ ", "Title" }, { "i  返回 Claude 输入 ", "Comment" } } or nil,
    zindex = (vim.api.nvim_win_get_config(win).zindex or 50) + 1,
  })

  history_windows[win] = view

  local function return_to_terminal()
    local valid = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == terminal
    -- Closing the focused overlay first may enter the editor and close Snacks zoom.
    if valid then focus_terminal(win) end
    close_history(win)
    return valid
  end

  vim.keymap.set("n", "i", function()
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == terminal then
      M.start_input(win)
    end
  end, { buffer = history, desc = "返回 Claude 输入" })
  vim.keymap.set({ "n", "x" }, "<A-x>", function()
    local position = vim.api.nvim_win_get_cursor(view)
    if not return_to_terminal() then return end
    M.zoom(terminal, function() M.open(terminal, lines, position, markdown) end)
  end, { buffer = history, desc = "切换 Claude 全屏并重新排版历史" })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = { tostring(win), tostring(view) },
    callback = function(event)
      history_windows[win] = nil
      if tonumber(event.match) == win then
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(view) then vim.api.nvim_win_close(view, true) end
        end)
      end
      return true
    end,
  })

  vim.wo[view].wrap, vim.wo[view].linebreak = true, true
  vim.api.nvim_win_set_cursor(view, cursor or { #lines, 0 })
end

return M
