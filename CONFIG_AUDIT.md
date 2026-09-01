# Neovim 自定义实现与快捷键审计

审计日期：2026-09-01

本文只记录当前实际启用的配置。`bak.lua`、`lua/bak.plugins/` 和
`lua/Draft/` 是备份或草稿，不参与启动，也不计为快捷键冲突。

## 判定标准

- **保留**：插件没有等价选项，或当前实现表达了明确的个人交互习惯。
- **可用原生能力简化**：已有维护中的官方接口，但替换前要确认行为差异。
- **建议调整**：覆盖了 Neovim/插件的重要默认按键，或实现依赖非公开细节。
- **局部覆盖**：只在特定 buffer 或模式生效，不算全局冲突。

## 自定义实现清单

| 位置 | 当前实现解决的问题 | 官方/插件已有能力 | 结论 |
| --- | --- | --- | --- |
| `lua/utils/buffer.lua` | 像 IDE 标签页一样 wipe buffer，同时保持窗口布局 | Snacks 提供 `Snacks.bufdelete({ wipe = true })`、`all()`、`other()` | **已改用官方能力试用**。Snacks 负责未保存提示、替代 buffer 和布局保护；与旧实现的区别是它会逐个询问未保存文件，而不是整批取消 |
| `lua/plugins/init.lua` 的 `MessagesBuffer` | 把原生 `:messages` 全部内容放进可滚动、可复制的浮窗 | Snacks 有 `Snacks.notifier.show_history()` / notification picker | **暂时保留**。Snacks 只保证保存经过 notifier 的通知，不等于完整的 `:messages` 历史；直接替换可能漏掉 `nvim_echo`、命令输出等消息 |
| `lua/plugins/lsp.lua` 的 `smart_references()` | 无引用时提示；单个引用直接跳；多个引用打开 quickfix；回车跳转后自动关闭列表 | Neovim 官方支持 `vim.lsp.buf.references(..., { on_list = ... })`；Snacks 提供 `Snacks.picker.lsp_references()` | **保留交互或改用 Picker 二选一**。当前 `on_list` 本身就是官方扩展点，不是绕过插件；Snacks 更短但会改变为统一 Picker 体验 |
| `lua/plugins/lsp.lua` 的引用高亮自动命令 | 停留时请求语义引用，移动后清除；异步完成后刷新滚动条 | Neovim 提供 `document_highlight()`/`clear_references()`，但仍需要事件触发；没有“自动显示到 nvim-scrollbar”的选项 | **保留**。事件部分是官方推荐模式；滚动条刷新属于跨插件集成 |
| `lua/plugins/scrollbar.lua` 的搜索同步 | 把 `*`、`#`、`/` 搜索结果持续画到滚动条，直到执行 `:noh` | nvim-scrollbar 自带依赖 `nvim-hlslens` 的 search handler；hlslens 官方要求在 `*`/`#` 映射后调用 `start()` | **已改用官方集成**。删除了逐行扫描全文的函数，关闭 hlslens 自己的行尾计数，并按官方映射启动 lens，以保留原有的持续黄色滚动条标记 |
| `lua/plugins/scrollbar.lua` 的 LSP 引用 handler | 读取 Neovim 语义引用 extmark，在滚动条上显示真正同一符号的引用，避免把同名文本混入 | nvim-scrollbar 没有内置 LSP document-highlight handler | **保留**。这是确有价值的跨插件功能；但 `nvim.lsp.references` 命名空间名称属于实现细节，升级 Neovim 时需要复查 |
| `lua/plugins/neo_tree.lua` 的 `copy_selector` | 用 `Y` 选择并复制 basename、扩展名、文件名、相对/绝对路径或 URI 到系统剪贴板 | Neo-tree 的 `copy_to_clipboard` 是文件复制/粘贴队列，不是复制路径文本 | **保留**。二者名字相似但功能不同，不应误替换 |
| `lua/plugins/neo_tree.lua` 的 `system_open` | 用操作系统默认应用打开节点 | 当前实现调用 Neovim 官方 `vim.ui.open()`；Neo-tree v3 没有等价的通用默认命令 | **保留**，实现已经足够简单且跨平台 |
| `lua/plugins/git.lua` 的 LazyGit 退出刷新 | LazyGit 修改仓库后刷新 filesystem、git_status、diagnostics；Windows 上又关闭了 libuv watcher | lazygit.nvim 提供 `vim.g.lazygit_on_exit_callback` | **已改用官方回调**。删除了 Neo-tree 中匹配 `TermClose` buffer 名称的间接实现 |
| `lua/plugins/breadcrumb.lua` 的启用判断 | 只在普通文件窗口显示 Dropbar，不占用 Neo-tree、Claude Code 或浮窗的 winbar | Dropbar 官方支持 `bar.enable` 函数 | **保留**。这已经是在使用插件原生选项 |
| `lua/plugins/breadcrumb.lua` 的全局开关 | 动态关闭所有现有 winbar，重新开启时触发重新附着 | Dropbar 提供 `bar.enable`，但没有完整等价的全局 toggle API | **保留**。手工刷新是为了让已打开窗口立刻响应，而不只是影响以后打开的窗口 |
| `lua/plugins/code_completion.lua` 的 `<CR>`/`<Tab>` 回调 | Enter 只确认手动选中的候选；Tab 只跳 LuaSnip 占位符，不选择补全项 | nvim-cmp 通过 mapping 回调提供这类条件行为，没有一个布尔选项完全等价 | **保留**。这是明确的补全交互策略 |
| `lua/plugins/astrocore.lua` 的插入模式左右键 | 补全菜单显示时保持方向键语义；否则允许左右跨行 | Neovim 的 `whichwrap` 与表达式映射可实现；没有插件选项能同时表达这个条件 | **保留** |
| `lua/plugins/astrocore.lua` 的插入/离开模式诊断切换 | 输入时隐藏 virtual text，离开输入模式恢复 | `update_in_insert` 只控制诊断更新时间，不控制是否显示已有 virtual text | **保留** |
| `lua/plugins/term.lua` 的 `Alt+n` | ToggleTerm 中从终端输入模式进入普通模式，保留 `Esc` 给交互程序 | ToggleTerm 官方文档本身建议为退出终端模式设置 buffer-local mapping | **保留** |
| `lua/plugins/ai_claudecode.lua` 的 `Alt+n` 和窗口移动键 | Claude Code 终端中进入普通模式、跨窗口移动 | Claude Code 官方将 `snacks_win_opts` 透传给 Snacks window，并明确支持其中的 `keys` | **保留**。当前写法就是插件公开配置入口，不是旁路补丁 |

## 快捷键风险

### 已确认的有意覆盖

1. `gr` 被设置成 `nowait = true` 的引用跳转。

   Neovim 0.12 的全局 LSP 默认键包括 `gra`（Code Action）、`gri`
   （Implementation）、`grn`（Rename）、`grr`（References）、`grt` 和 `grx`。
   当前两键 `gr` 会立即执行，因此所有以 `gr` 开头的三键默认映射都不可达。
   项目虽然另外映射了 `gi`、`<Leader>rn`、`<Leader>ca`，但 `grt`/`grx`
   会被遮蔽。用户已确认只需要无延迟的 `gr`，不使用这套三键默认映射，因此保持现状。

2. 插入模式 `<C-s>` 覆盖 Neovim 0.12 的 LSP `signature_help` 默认键。

   当前用途是保存文件，这是用户确认的 IDE 风格选择，不属于重复实现。签名帮助用于在输入
   函数调用参数时显示函数签名、当前参数位置和参数文档；如以后需要，可另设按键。

### 中优先级

- 普通模式 `<C-d>` 和 `<C-f>` 被改为跳转列表后退/前进，覆盖了原生半页向下和整页向下。
- 普通模式 `<C-h/j/k/l>` 用于调整窗口，覆盖了部分原生控制键语义；窗口移动实际使用的是
  `<C-Left/Down/Up/Right>`。这套分工可用，但与 README 现有描述正好写反了，需要修正文档。
- `<Leader>b` 是 DAP 断点，同时也是 `<Leader>ba`/`<Leader>bo` 的前缀。它们能共存，
  但单独按 `<Leader>b` 时可能等待 `timeoutlen`，不算覆盖冲突，却会产生延迟感。
- `<C-S-z>` 在不同终端/键盘协议中不一定能与 `<C-z>` 区分，重做快捷键可能失效或被识别为撤销。

### 安全的局部覆盖

- Claude Code 与 ToggleTerm 的 `<A-n>` 都只在各自终端 buffer 的 terminal mode 生效。
- Neo-tree 的 `[b`、`]b`、`Y`、`O` 和 fuzzy finder 的 `<C-j>/<C-k>` 是插件窗口局部映射。
- quickfix 中的 `<CR>` 只绑定到本次 LSP 引用结果 buffer。
- 消息浮窗中的 `q`/`Esc` 只绑定到消息 buffer。
- git-conflict 的 `co`、`ct`、`cb`、`c0`、`[x`、`]x` 只在检测到冲突的文件中建立。

## 建议的后续处理顺序

1. 实际体验 hlslens 搜索滚动条是否仍符合预期。
2. 实际体验 Snacks 对未保存 buffer 的逐个提示，再决定是否长期保留。
3. 验证一次 LazyGit 修改文件并退出后，Neo-tree 是否立即刷新。
4. 保留已确认的 `gr`、`Ctrl+s`，以及 Neo-tree 路径选择器、Dropbar 动态开关、补全条件映射和终端 `<A-n>`。

## 本次核对的官方资料

- [Neovim LSP defaults](https://neovim.io/doc/user/lsp/#lsp-defaults)
- [Snacks bufdelete](https://github.com/folke/snacks.nvim/blob/main/docs/bufdelete.md)
- [Snacks notifier](https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md)
- [Snacks picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
- [Neo-tree v3 configuration and mappings](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [Dropbar configuration](https://github.com/Bekaboo/dropbar.nvim)
- [nvim-scrollbar search integration](https://github.com/petertriho/nvim-scrollbar)
- [ToggleTerm configuration](https://github.com/akinsho/toggleterm.nvim)
- [Claude Code terminal/window configuration](https://github.com/coder/claudecode.nvim)
- [lazygit.nvim exit callback](https://github.com/kdheepak/lazygit.nvim)
