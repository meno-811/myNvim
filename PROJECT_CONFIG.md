# Neovim 配置维护说明

最后核对日期：2026-10-19

本文只记录当前结构、设计取舍、已确认行为和排错结论，不充当变更日志。面向用户的安装与操作说明放在 `README.md`。

快捷键设计以降低记忆负担为首要原则：优先保持跨编辑器通用操作和既有肌肉记忆，在不冲突的前提下尽可能保留 Neovim 原生行为，只覆盖或迁移确有必要的按键。

## 总体结构

这是独立的 Neovim 0.12+ 配置，不是完整 AstroNvim 发行版。lazy.nvim 管理插件；AstroCore 只提供诊断基础配置和新版 Treesitter 适配。

启动顺序固定为：

1. `options.lua`：原生选项。
2. `key_map.lua`：Leader 与原生快捷键。
3. `autocmds.lua`：编辑器级事件。
4. `commands.lua`：用户命令。
5. `plugins/init.lua`：lazy.nvim 与插件模块。

Leader 必须先于插件快捷键注册。与插件无关的设置使用 Neovim API；插件设置、延迟加载入口和插件局部快捷键留在对应插件文件中，避免重复定义。

## 文件职责

| 文件 | 职责 |
| --- | --- |
| `init.lua` | 按固定顺序加载配置 |
| `lua/options.lua` | 行号、缩进、搜索、鼠标、剪贴板、`virtualedit`、`whichwrap` 等原生选项 |
| `lua/key_map.lua` | 严格 Leader、编辑/导航/窗口快捷键、诊断浮窗和鼠标交互 |
| `lua/autocmds.lua` | 外部文件检查、文件类型折行、插入模式诊断文字切换 |
| `lua/commands.lua` | `Loadenv` 会话环境加载、`MessagesBuffer`、`Readme` 及浮窗局部行为 |
| `lua/utils/buffer.lua` | 基于 Snacks 的安全 buffer 关闭与全窗口跳转列表重置 |
| `lua/plugins/astrocore.lua` | 诊断基础配置与 Treesitter 适配 |
| `lua/plugins/lsp.lua` | Mason、LSP 配置、LspAttach 映射、hover 和引用行为 |
| `lua/plugins/code_completion.lua` | nvim-cmp、LuaSnip、插入与命令行补全 |
| `lua/plugins/none_ls.lua` | stylua、black、shfmt 外部格式化 |
| `lua/plugins/status.lua` | lualine、Bufferline、Snacks 窗口缩放与关闭入口 |
| `lua/plugins/neo_tree.lua` | 文件树、路径复制、系统打开和 source 切换 |
| `lua/plugins/breadcrumb.lua` | Dropbar 路径栏及动态开关 |
| `lua/plugins/scrollbar.lua` | 诊断、搜索和 LSP 引用滚动条标记 |
| `lua/plugins/term.lua` | ToggleTerm 与 `:Config` |
| `lua/plugins/ai_claudecode.lua` | Claude Code 终端、上下文发送、diff 审阅和终端窗口导航 |
| `lua/plugins/ai_copilot.lua` | Copilot 行内建议；不占用 Tab |
| `lua/plugins/ai_copilotchat.lua` | 未导入的备用方案 |
| `lua/plugins/daps.lua` | Go/Python DAP 与 dap-ui |
| `lua/plugins/git.lua` | gitsigns、LazyGit、git-conflict |
| `lua/plugins/markdown.lua` | Markdown 终端内渲染 |
| `install-nvim.sh` | 按 Linux 架构安装或更新 Neovim AppImage |

插件专属快捷键可以留在 spec 的 `keys` 或 `config` 中。例如 `<Leader>e` 同时是 Neo-tree 的延迟加载入口，移到全局映射会破坏按需加载。

## 已确认的交互

### 原生编辑器层

- `Loadenv` 使用无启动配置的 Bash 子进程，以 `set -a` 执行 `source`，比较执行前后的 NUL 分隔环境快照，仅将变化和删除同步到 `vim.env`。脚本失败或未完成快照时不导入；Windows 优先标准位置的 Git Bash，避免 WSL 别名。变量只存在当前进程和之后启动的子进程中，已有终端/LSP 需重启；不导入函数、别名或工作目录变化。

- Leader 是空格。普通和可视模式先吞掉未配置的单个可打印组合，实际映射再覆盖，因此 `Space+i` 不会回退执行原生 `i`，`Space+a` 超时也不会执行原生 `a`。
- `Ctrl+a` 在普通和可视模式全选，插入模式保留原生“插入上次输入文本”；`Ctrl+n` 在普通和可视模式调用原生数字加一；Visual/Select 模式的 `Ctrl+c` 写入系统 `+` 剪贴板；`Ctrl+v` 在普通、插入、Visual/Select 和终端输入模式通过 `nvim_paste()` 粘贴系统 `+` 剪贴板，命令行使用原生寄存器插入，块选择改用原生 `Ctrl+q`；`Ctrl+s` 保存，插入模式会先退出；`Ctrl+z` / `Ctrl+Shift+z` 在普通、插入、Visual/Select 模式撤销 / 重做。
- `Alt+i` 在插入模式返回普通模式，在终端输入模式进入终端普通模式，作为统一的“退出当前输入状态”按键。
- 普通模式保留原生 `Ctrl+o/i`（或 `Tab`）跳转列表后退/前进。`Ctrl+d` 改为两阶段诊断浮窗；LSP buffer 中的 `Ctrl+f` 改为两阶段 hover，其他 buffer 仍为原生整页向下。
- 普通和可视模式使用 `Ctrl+h/l` 跨单词、`Ctrl+k/j` 跨段落；所有文本模式可用 `Ctrl+左右` 跨单词、`Ctrl+上下` 跨段落。原生 `{` / `}` 已禁用，统一使用 Ctrl 加上下键；`Ctrl+l` 覆盖的清高亮、diff 更新和重绘不迁移，需要时使用 `:noh`、`:diffupdate`、`:redraw!`。
- `keymodel=startsel` 与 `selectmode=key` 启用原生输入框式选择：在普通或插入模式按 Shift 加方向/Home/End/PageUp/PageDown 进入 Select 模式，进入后方向键和 Shift 加方向键都会继续调整选区，输入文字替换选区。普通、可视和 Select 模式的 `H/J/K/L` 等同于 `Shift+←/↓/↑/→`；Neo-tree 和操作符等待模式保留原生行为。
- 文本 buffer 在首行继续按 `↑` 到第 1 列，在末行继续按 `↓` 到行尾。补全菜单可见或 `buftype` 非空时保留原生方向键行为。
- 插入模式左右键可跨行；块选择通过 `virtualedit=block,onemore` 支持越过短行行尾。
- 普通模式双击左键保留原生单词选择。插入模式点击另一窗口时先退出插入，防止 Neo-tree 继承插入模式或 Claude 直接进入终端输入模式。
- 普通模式 `Ctrl+d` 打开并进入当前行诊断浮窗，再按关闭并返回。
- 普通模式使用原生 `Ctrl+w` 窗口命令，不再添加全局 `Alt+w w` 别名。

### 自动命令

`user_editor` augroup 每次加载先清空，当前包含：

| 事件 | 行为 |
| --- | --- |
| `VimEnter` | ShaDa 加载完成后清空所有窗口的跳转列表 |
| `FocusGained`、`BufEnter`、`CursorHold` | `checktime` 检查磁盘变化；只有无本地未保存修改的文件会按 `autoread` 重载 |
| 代码文件 `FileType` | Lua、Python、JavaScript、Go、Rust 关闭折行 |
| 文本文件 `FileType` | Markdown、text、vimwiki 开启 `wrap` 和 `linebreak` |
| `InsertEnter` / `InsertLeave` | 输入时隐藏诊断 virtual text，离开后恢复；标记和下划线始终保留 |

### 补全

- nvim-cmp 使用 `noselect`：`Tab` 接受当前项或首项，`Enter` 只确认手动选中的候选，否则换行。
- `↑/↓` 只改变候选选择，不立即插入；菜单可见时 `Esc` 只关闭菜单并保持插入模式。
- `:` 和 `/` 复用同一确认规则；无菜单时回退 Neovim 的命令行历史、补全和执行行为。
- Copilot 默认 Tab 映射关闭，只有 `Alt+l` 接受整条建议。

### LSP、诊断与滚动条

- Mason 安装 `gopls`、`pyright`、`lua_ls`、`rust_analyzer`。Python 由 Pyright 诊断、Black 格式化；Go 只用 gopls 格式化，避免重复 provider。
- LSP buffer 中的 `Ctrl+f` 打开 hover 后自动进入浮窗，再按关闭；关闭映射只挂在带 `textDocument/hover` 标记的浮窗。
- `grr` 不包含声明：0 个结果提示，1 个直接跳转，多个进入 quickfix，回车跳转后关闭列表。`gri` 跳转到实现；原生 `gi` 和 `gr` 前缀保持可用。
- 支持 documentHighlight 的 LSP 在 `CursorHold` 高亮语义引用，移动时清除；滚动条读取引用 extmark。搜索滚动条使用 nvim-scrollbar 与 hlslens 官方集成。
- `render-markdown.nvim` 只做终端内视觉渲染，不提供浏览器式字号、布局和图片能力。

### Buffer、文件树与 Git

- Bufferline `lazy=false`，启动即显示；使用 Neovim 原生 `[b` / `]b` 切换 buffer，`Leader 1…9` 按编号切换。
- 独立 AstroCore 不初始化完整 AstroNvim 的 `vim.t.bufs`，所以 buffer 关闭统一使用 `Snacks.bufdelete({ wipe=true })`。它负责未保存提示、替代 buffer 和窗口布局。
- `<Leader>q` 在普通文件中删除当前 buffer，在 quickfix/location-list 中关闭结果窗口；`:q` 仍是 Neovim 原义。`<Leader>ba` 关闭全部 buffer、`<Leader>bo` 仅保留当前 buffer 后，都会清空所有窗口的跳转列表。Neo-tree 成为最后一个窗口时不退出 Neovim。
- Neo-tree 打开文件后通过 `file_opened` 事件自动关闭文件树。`Y` 复制名称、相对/绝对路径或 URI；这与插件的文件复制队列不是同一功能。`O`/`Shift+Enter` 使用 `vim.ui.open()`。
- Windows 关闭 Neo-tree 的 libuv watcher；LazyGit 退出后通过插件官方回调刷新已加载的 filesystem、git_status、diagnostics source。
- Dropbar 只占普通文件窗口的 winbar，不进入 Neo-tree、Claude Code 或浮窗；全局开关会同步刷新已经打开的窗口。
- `Alt+x` 在普通、插入、Visual/Select 和终端输入模式调用 Snacks 原生 zoom，为当前 buffer 叠加全屏浮窗；代码、Neo-tree、quickfix 和诊断/hover 浮窗共用同一入口，关闭后恢复原布局并同步光标。

### 终端与 Claude Code

- 全局 `Alt+i` 用于从终端输入模式进入终端普通模式，包括 Claude Code 终端。`:Config` 新建受 ToggleTerm 管理的浮动终端，工作目录为 `stdpath("config")`，可被 `Ctrl+\` 和 `:TermSelect` 管理。
- Claude Code 设置 `auto_insert=false`；`<Leader>ac`、`<Leader>as` 的包装函数在明确打开、发送或添加后才聚焦并进入输入模式。普通鼠标切窗不会自动进入输入模式。
- Claude 终端内 `Ctrl+w` 后接 `h/j/k/l/w`、相应 Ctrl 组合或方向键进行窗口导航；未完成的 `Ctrl+w` 前缀超时后无操作，不会传入终端。
- Claude 终端在输入或普通模式都可使用 `Alt+x` 切换 Snacks 全屏浮窗，底下的编辑窗口、buffer 和 Claude 进程都保留。
- Claude 窗口里的 `<Leader>q` 调用窗口 `hide()`，保留 Claude 进程和 WebSocket；不要用删除 terminal buffer 代替隐藏。

## 保留的定制与理由

| 实现 | 理由 |
| --- | --- |
| `MessagesBuffer` | 必须显示完整 `:messages`；Snacks 通知历史不保证包含 `nvim_echo` 和命令输出 |
| LSP `smart_references()` | Neovim 的 `on_list` 是官方扩展点，当前 0/1/多结果交互与通用 Picker 不同 |
| LSP 引用滚动条 handler | nvim-scrollbar 没有 document-highlight handler；文本搜索会混入同名非语义结果 |
| Neo-tree `copy_selector` / `system_open` | 插件没有等价的“复制路径文本”命令；`vim.ui.open()` 已是最小跨平台方案 |
| Dropbar 动态开关 | `bar.enable` 能控制新附着，但没有让现有窗口立即同步的完整 toggle API |
| cmp 条件映射 | 插件没有单一选项表达“Tab 选首项、Enter 仅确认手选项、无菜单回退” |
| Claude Code 终端键 | `snacks_win_opts.keys` 是插件公开入口，映射保持在该终端局部 |

## 有意覆盖与兼容风险

- 文本窗口中的 `H/J/K/L` 覆盖屏幕顶端、合并行、关键词查询和屏幕底端，改为 Shift 选择；Neo-tree 和操作符等待模式不覆盖。
- 普通模式 `Ctrl+d` 覆盖半页向下；LSP buffer 中的 `Ctrl+f` 覆盖整页向下。
- `Ctrl+v` 覆盖普通模式块选择、插入/命令行的字面量输入及终端原始输入，统一用于系统剪贴板粘贴；块选择保留在 `Ctrl+q`。
- 普通和可视模式 `Ctrl+a` 覆盖数字递增，改用 `Ctrl+n` 加一；插入模式 `Ctrl+a` 保持原生。`Ctrl+x` 的递减仍保留。可视模式原生的 `g<C-a>` / `g<C-x>` 序列递增/递减仍可使用，但需以实际终端按键传输为准。
- `Ctrl+z` 在普通和 Visual/Select 模式覆盖原生挂起，需要时使用 `:suspend`。
- `Ctrl+h/j/k/l` 与 `Ctrl+方向键` 统一表示跨单词/段落移动；因此原生 `{` / `}` 已禁用，`Ctrl+l` 的原生清高亮、diff 更新和重绘也不再有快捷键。
- 插入模式 `Ctrl+s` 覆盖 Neovim 0.12 默认 LSP signature help。
- `<Leader>b` 同时是 DAP 断点和 `<Leader>ba/bo` 前缀，单独使用可能等待 `timeoutlen`。
- `Ctrl+Shift+z`、`Shift+Enter` 等组合是否可区分取决于终端和键盘协议；无法区分时 Neovim 收不到独立按键码。
- Shift 选择同样依赖终端能够区分 Shift 修饰的方向键及 Home/End/PageUp/PageDown。
- 当前终端不会把 `Ctrl+Shift+↑/↓` 传给 Neovim，因此不能用它们按段落开始或继续 Select；不要在 Neovim 内重复添加该组合的映射，除非先修改终端按键协议或绑定。
- 鼠标、Claude、Neo-tree、诊断/hover 浮窗和 quickfix 的特殊映射均限制在相应模式或 buffer，不能提升成全局映射。

## 环境与排错结论

### 字体与远程环境

- nvim-web-devicons 需要 Nerd Font 3.3+。终端 Neovim 的字体由本地终端控制，`guifont` 不生效；WSL/SSH 也应配置连接端的终端字体。
- SSH 中 `options.lua` 将剪贴板 provider 设为 OSC 52，支持远端 Neovim 复制到本机剪贴板。反向粘贴通常由终端完成；tmux/screen 还需允许 OSC 52 透传。
- `install-nvim.sh` 将 `x86_64/amd64` 映射到 x86_64 AppImage，将 `aarch64/arm64` 映射到 arm64；其他架构直接报错。脚本用临时文件和原子替换更新 `/usr/bin/nvim`。

### 受控环境中的无界面测试

- 受控测试环境可能把 `stdpath("config")` 和 `stdpath("data")` 重定向到空的沙箱目录，因此直接运行 `nvim --headless` 不一定会加载本仓库或已安装插件。先打印 `vim.fn.stdpath("config")` 核对实际路径；若行号、`whichwrap` 等所有选项都回到默认值，应先判定为配置未加载，不要误判成插件重置配置。
- 只验证原生选项和键位时，使用 `nvim --clean --headless -u NONE`，显式把本仓库加入 `runtimepath`，再 `require("options")`、`require("key_map")`。需要验证完整插件启动时，必须同时确认真实的 config/data 路径和插件目录可见，不能把上述局部模块测试当成完整启动测试。

### DAP UI 报 nvim-nio 缺失

`daps.lua` 已把 `nvim-neotest/nvim-nio` 声明为 `nvim-dap-ui` 的直接依赖，`lazy-lock.json` 也有记录。dap-ui 用 `pcall(require, "nio")` 把所有加载失败统一报告为“未安装”，所以必须先看原始错误：

```vim
:lua local ok, result = pcall(require, "nio"); print(ok, result)
```

2026-09-08 的受限无界面测试中，真实原因是 `nio/logger.lua` 无权创建 `nio.log`；切换到可写临时日志目录后 `nio` 和 `dapui` 均可加载。这属于测试环境写入限制，不应重复添加依赖或改变归属。

### Claude Code WebSocket `ECONNRESET`

该消息表示 WebSocket 对端重置连接，通常是 Claude 客户端/终端被关闭、重启或连接中断，不等同于 Markdown 选择操作本身出错。当前关闭路径使用 `hide()` 保留会话；若持续刷屏，先重新打开 Claude Code，并用 `:MessagesBuffer` 查看最早一条错误，而不是只看重复尾部。

## 检查入口与待验证项

- `:checkhealth astrocore`、`:checkhealth nvim-treesitter`、`:Lazy`、`:Mason`、`:LspInfo`。
- 修改配置后至少执行无界面启动检查；涉及 UI 或终端键时再做交互验证。
- 尚需实际体验验证：hlslens 搜索滚动条、Snacks 对多个未保存 buffer 的提示、LazyGit 退出后的 Neo-tree 即时刷新。

排查时先从“文件职责”定位唯一负责模块，再检查原始错误，避免在多个文件叠加补丁。
