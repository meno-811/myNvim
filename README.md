# myNvim

个人维护的 Neovim 配置，主要用于 Go、Python、Lua 和 Rust 开发。

## 设计目标

本项目首先追求低记忆负担：不因使用 Vim 而额外维护一套与其他编辑器并行的快捷键体系。`Ctrl+c`、`Ctrl+v`、`Ctrl+z`、`Ctrl+Shift+z`、`Ctrl+a`，以及使用 `Ctrl+←/→` 跨单词移动等已经形成肌肉记忆的通用操作，是评估快捷键取舍时必须优先保障的核心习惯，目标是让它们保持可用且尽可能语义一致。在此基础上尽量保留 Neovim 的原生操作；只有当原生行为与这些通用习惯冲突或明显增加记忆成本时，才进行覆盖或迁移。

## 安装

需要 Neovim 0.12+。图标正常显示还需要终端使用 Nerd Font 3.3+。

```bash
git clone https://github.com/meno-811/myNvim.git ~/.config/nvim
```

在 x86_64 或 ARM64 Linux 上，也可以在项目根目录安装或更新最新 AppImage：

```bash
bash ./install-nvim.sh
```

首次启动后用 `:Mason` 查看语言服务器和外部工具。

## 常用命令

| 命令 | 功能 |
| --- | --- |
| `:Config` | 新建浮动终端并进入 Neovim 配置目录 |
| `:Loadenv path_of_file` | 用 Bash 加载环境变量，仅影响当前 Neovim 和之后启动的子进程 |
| `:Readme` / `:readme` | 在浮窗中查看本文档，按 `q` 或 `Esc` 关闭 |
| `:MessagesBuffer` | 在可滚动、可复制的浮窗中查看完整消息记录 |
| `:Lazy` / `:Mason` / `:LspInfo` | 查看插件、外部工具和当前 LSP 状态 |

`<Leader>` 是空格。未配置的 Leader 组合会被忽略，不会回退执行普通单键命令。

`:Loadenv .env` 支持文件路径补全，含空格的路径直接输入，无需引号。文件按 Bash `source` 执行，并自动导出普通变量赋值；支持引号、变量引用、命令替换和 `unset`。仅加载可信文件。需要 Bash，Windows 优先使用标准安装位置的 Git Bash。退出 Neovim 后变量不保留，也不会修改父终端或系统环境；已经运行的终端、LSP 等需重启才能继承。只同步环境变量，不同步脚本中的目录切换、函数或别名；脚本失败时不导入环境，但已经执行的外部操作不会回滚。

## 编辑与导航

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl+a`（普通 / 可视模式） | 全选 |
| `Ctrl+a`（插入模式） | 插入上一次输入的文本（原生行为） |
| `Ctrl+n`（普通 / 可视模式） | 将光标处或选区中的数字加一 |
| `Ctrl+c`（可视 / Select 模式） | 复制选区到系统剪贴板 |
| `Ctrl+v` | 从系统剪贴板粘贴 |
| `Ctrl+s` | 保存；插入模式下保存并返回普通模式 |
| `Ctrl+z` / `Ctrl+Shift+z` | 撤销 / 重做 |
| `Alt+i`（插入模式） | 返回普通模式 |
| `Ctrl+h/l`（普通 / 可视）或 `Ctrl+←/→` | 上一个 / 下一个单词 |
| `Ctrl+k/j`（普通 / 可视）或 `Ctrl+↑/↓` | 上一个 / 下一个段落 |
| `Shift+方向键` | 像普通输入框一样开始或扩展选区 |
| `Shift+h/j/k/l`（非 Neo-tree） | 等同于 `Shift+←/↓/↑/→` |
| `Ctrl+q` | 块可视模式 |
| `gc` / `gcc` | 注释操作符 / 切换当前行注释 |
| `*` / `#` | 向后 / 向前搜索光标下单词 |
| `:noh` | 清除搜索高亮和滚动条搜索标记 |

原生 `{` / `}` 已禁用，段落移动统一使用 `Ctrl+k/j` 或 `Ctrl+↑/↓`。`Ctrl+l` 覆盖的原生清高亮、diff 更新和重绘不迁移，需要时分别使用 `:noh`、`:diffupdate`、`:redraw!`。

Shift 选择使用 Neovim Select 模式：进入后可用方向键或 `Shift+方向键` 继续调整选区，直接输入会替换选中内容，`Esc` 取消选择。`Shift+Home/End/PageUp/PageDown` 也遵循同一规则。

多行插入相同内容：`Ctrl+q` 选择多行，按大写 `I` 输入，最后按 `Esc` 应用到全部选中行。

普通模式双击鼠标左键保留原生的单词选择。插入模式的左右键可以跨行；在首行继续按 `↑` 到行首，在末行继续按 `↓` 到行尾。

## 窗口与文件

| 快捷键 | 功能 |
| --- | --- |
| `[b` / `]b` | 上一个 / 下一个 buffer（Neovim 原生） |
| `<Leader>1` … `<Leader>9` | 切换到对应编号的文件标签 |
| `<Leader>q` | 关闭当前文件或结果窗口 |
| `<Leader>ba` / `<Leader>bo` | 关闭全部 / 仅保留当前文件；两者都会重置跳转列表 |
| `<Leader>e` / `<Leader>o` | 切换文件树 / 在文件树与编辑区间切换焦点 |
| `<Leader>up` | 显示或隐藏顶部路径栏 |
| `Alt+x` | 将当前窗口切换为全屏浮窗 |
| `Ctrl+w` 后接 `h/j/k/l`、方向键或 `w`（普通模式） | 移动窗口或切换到下一窗口 |

插入模式保留原生的 `Ctrl+w` 删除前一个单词，以及 `Ctrl+h/j/k` 的退格、换行和 Digraph；跨单词或段落可使用 Ctrl 加方向键。

Neo-tree 中选择文件打开后会自动关闭文件树；`[b` / `]b` 切换栏目，`Y` 选择要复制的路径格式，`O` 或 `Shift+Enter` 用系统默认程序打开节点。

Neo-tree 中最后一项再按 `↓` 回到第一项。`Ctrl+↑/↓` 跳到前面/后面深度不大于当前项的目录，跳过文件和更深的子目录；例如 `b2 → b → a`。没有符合条件的目录时停留原处，不展开或折叠目录。

## 代码跳转、诊断与补全

| 快捷键 | 功能 |
| --- | --- |
| `gd` / `gD` / `gri` / `grr` | 定义 / 声明 / 实现 / 引用 |
| `Ctrl+o` / `Ctrl+i`（或 `Tab`） | 跳转列表后退 / 前进（Neovim 原生） |
| `<Leader>;` | 选择顶部路径或代码层级 |
| `Ctrl+f`（LSP 文件） | 打开并进入 hover 浮窗；再按关闭 |
| `Ctrl+d` | 打开并进入当前行诊断浮窗；再按关闭 |
| `[d` / `]d` | 上一个 / 下一个诊断 |
| `<Leader>rn` / `<Leader>ca` | 重命名 / Code Action |
| `Alt+l` | 接受整条 Copilot 建议 |

补全菜单中，`Tab` 接受选中项或首项，`Enter` 只确认手动选中的候选，`↑/↓` 只移动选择；菜单打开时按 `Esc` 只关闭菜单并保持插入模式。命令行和搜索使用同样的候选确认规则。

## 终端与 Claude Code

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl+\` | 打开或关闭 ToggleTerm；Claude Code 终端输入模式下也可直接使用 |
| `Alt+i`（终端输入模式） | 进入终端普通模式 |
| `<Leader>ac` | 打开或切换 Claude Code，并进入输入状态 |
| `<Leader>as` | 发送选区、添加文件或聚焦 Claude Code，并进入输入状态 |
| `<Leader>ab` | 添加当前 buffer |
| `<Leader>ar` / `<Leader>aC` | 恢复 / 继续 Claude 会话 |
| `<Leader>am` | 选择 Claude 模型 |
| `<Leader>aa` / `<Leader>ad` | 接受 / 拒绝 Claude diff |

Claude Code 终端中可用 `Ctrl+w w` 切换到下一个窗口；未完成的 `Ctrl+w` 前缀超时后会被忽略，不会传给终端。终端普通模式下按 `<Leader>q` 只隐藏窗口，不会结束会话；终端输入模式也可直接使用 `Alt+x` 切换全屏浮窗。

## Markdown

| 快捷键 | 功能 |
| --- | --- |
| `<Leader>m`（Markdown） | 切换终端内实时渲染 |

Markdown 预览是终端内渲染，不提供浏览器式字号和图片排版。

另附claude code官方下载命令
curl -fsSL https://claude.ai/install.sh | bash
