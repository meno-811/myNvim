-- =================================================
-- 插件管理
-- =================================================

-- ===============================安装插件管理====================================
-- 构造一个标准的安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- 如果插件不存在，就用git克隆它
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error(
      "lazy.nvim 下载失败：\n"
        .. output
        .. "\n请检查 Git、GitHub 网络或代理设置。"
    )
  end
end
-- 把插件路径../lazy/lazy.nvim添加到运行时路径，一般是/home/a3213/.local/share/nvim/data/lazy/lazy.nvim
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_create_user_command("MessagesBuffer", function()
    vim.cmd("new")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.api.nvim_buf_set_lines(
        0,
        0,
        -1,
        false,
        vim.split(vim.fn.execute("messages"), "\n")
    )
end, {})

require("lazy").setup({
  { import = "plugins.ai_claudecode" },-- Claude Code IDE 集成
  { import = "plugins.ai_copilot" },-- GitHub Copilot 官方插件
  { import = "plugins.astrocore" },-- AstroCore 插件
  { import = "plugins.code_completion" },-- 代码补全
  { import = "plugins.daps" },-- 调试器插件
  { import = "plugins.git" },-- Git 相关的插件
  { import = "plugins.lsp" },-- LSP
  { import = "plugins.neo_tree" },-- 文件树插件
  { import = "plugins.none_ls" },-- 伪 LSP 桥接器
  { import = "plugins.status" },-- 状态栏
  { import = "plugins.subject_skin" },-- 主题皮肤
  { import = "plugins.term" },-- 终端
  { import = "plugins.treesitter" },-- 树状语法分析器
})
