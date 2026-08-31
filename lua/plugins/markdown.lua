-- Markdown 文档在 Neovim 内的实时渲染预览。
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<Leader>m",
      "<Cmd>RenderMarkdown toggle<CR>",
      desc = "切换 Markdown 预览",
    },
  },
  opts = {
    file_types = { "markdown" },
  },
}
