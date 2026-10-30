local M = {}
local namespace = vim.api.nvim_create_namespace("project-walkthrough-target")

local function clear_highlights()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) then
      pcall(vim.api.nvim_buf_clear_namespace, buffer, namespace, 0, -1)
    end
  end
end

local function terminal_state()
  local ok, terminal = pcall(require, "claudecode.terminal")
  if not ok then return nil, nil end

  local buffer = terminal.get_active_terminal_bufnr()
  if not buffer then return nil, nil end

  for _, window in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(window) == buffer then return buffer, window end
  end

  if vim.fn.exists(":ClaudeCodeOpen") == 2 then
    pcall(vim.cmd, "ClaudeCodeOpen")
    for _, window in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(window) == buffer then return buffer, window end
    end
  end

  return buffer, nil
end

local function is_editor_window(window, terminal_buffer)
  if not vim.api.nvim_win_is_valid(window) then return false end
  local config = vim.api.nvim_win_get_config(window)
  if config.hide == true or config.relative ~= "" then return false end

  local buffer = vim.api.nvim_win_get_buf(window)
  if buffer == terminal_buffer then return false end

  local buftype = vim.bo[buffer].buftype
  local filetype = vim.bo[buffer].filetype
  if buftype ~= "" then return false end
  if filetype == "neo-tree" or filetype == "NvimTree" then return false end
  if vim.api.nvim_get_option_value("diff", { win = window }) then return false end
  return true
end

local function find_editor_window(terminal_buffer, terminal_window)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(current_tab)

  for _, window in ipairs(windows) do
    if is_editor_window(window, terminal_buffer) and vim.w[window].project_walkthrough then
      return window
    end
  end

  local current = vim.api.nvim_get_current_win()
  if is_editor_window(current, terminal_buffer) then return current end

  for _, window in ipairs(windows) do
    if is_editor_window(window, terminal_buffer) then return window end
  end

  if terminal_window and vim.api.nvim_win_is_valid(terminal_window) then
    vim.api.nvim_set_current_win(terminal_window)
    vim.cmd("leftabove vnew")
  else
    vim.cmd("vnew")
  end
  return vim.api.nvim_get_current_win()
end

local function open_target(window, file)
  local current_buffer = vim.api.nvim_win_get_buf(window)
  local current_name = vim.api.nvim_buf_get_name(current_buffer)

  if vim.bo[current_buffer].modified and current_name ~= file then
    vim.api.nvim_set_current_win(window)
    vim.cmd("leftabove vnew")
    window = vim.api.nvim_get_current_win()
  end

  local target_buffer = vim.fn.bufnr(file)
  if target_buffer > 0 and vim.api.nvim_buf_is_valid(target_buffer) then
    vim.api.nvim_win_set_buf(window, target_buffer)
  else
    local ok, err = pcall(vim.api.nvim_win_call, window, function()
      vim.cmd("edit " .. vim.fn.fnameescape(file))
    end)
    if not ok then return nil, err end
  end

  vim.w[window].project_walkthrough = true
  return window, nil
end

function M.navigate(request_path)
  local request = vim.fn.readfile(request_path)
  local file = request[1]
  local start_line = tonumber(request[2]) or 1
  local end_line = tonumber(request[3]) or start_line

  if not file or vim.fn.filereadable(file) ~= 1 then
    return "ERROR: target file is not readable"
  end

  if end_line < start_line then start_line, end_line = end_line, start_line end

  local terminal_buffer, terminal_window = terminal_state()
  local editor_window = find_editor_window(terminal_buffer, terminal_window)
  local open_error
  editor_window, open_error = open_target(editor_window, file)
  if not editor_window then return "ERROR: " .. tostring(open_error) end

  local buffer = vim.api.nvim_win_get_buf(editor_window)
  local line_count = math.max(1, vim.api.nvim_buf_line_count(buffer))
  start_line = math.min(math.max(1, start_line), line_count)
  end_line = math.min(math.max(start_line, end_line), line_count)

  clear_highlights()
  for line = start_line, end_line do
    vim.api.nvim_buf_add_highlight(buffer, namespace, "Visual", line - 1, 0, -1)
  end

  vim.api.nvim_set_current_win(editor_window)
  vim.api.nvim_win_set_cursor(editor_window, { start_line, 0 })
  vim.api.nvim_win_call(editor_window, function() vim.cmd("normal! zz") end)
  vim.cmd("stopinsert")
  vim.cmd("redraw")

  local layout = "hidden"
  if terminal_window and vim.api.nvim_win_is_valid(terminal_window) then
    local config = vim.api.nvim_win_get_config(terminal_window)
    layout = config.relative == "" and (config.split or "split") or "float"
  end

  return vim.json.encode({
    file = file,
    start_line = start_line,
    end_line = end_line,
    editor_window = editor_window,
    claude_layout = layout,
  })
end

function M.clear()
  clear_highlights()
  vim.cmd("redraw")
  return "cleared"
end

return M
