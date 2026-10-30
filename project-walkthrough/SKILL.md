---
name: project-walkthrough
description: >
  Interactive guided walkthrough of a codebase: explain one concept at a time,
  keep Claude Code visible as a Neovim sidebar, open the relevant file, move the
  cursor to and highlight the exact code, then pause with a Claude Code question
  so the user can continue or ask something else. Use when the user says “带我理解
  这个项目”,“这个项目是干什么的”, “逐步讲解代码”, “交互式项目导览”, “walk me through this repo”,
  “explain this project step by step”, or asks to learn a codebase interactively.
argument-hint: "[topic, feature, file, or question]"
---

# Project Walkthrough

Guide the user through a real codebase in small, interactive steps. The code is
on the left, Claude Code remains visible on the right, and each meaningful step
ends with a Claude Code confirmation—not a Neovim popup.

This mode is read-only unless the user separately asks for a change.

## Start

1. Use the topic or path the user named. If none was named, inspect the README,
   manifest, entry points, and top-level structure, then choose the smallest
   useful route through the project.
2. State the route in one short sentence. Do not begin with a broad questionnaire.
3. Read enough connected code to explain the real flow: entry point, callers,
   callees, data in, data out, and relevant tests.
4. Explain one concept per step. Do not dump the whole repository at once.

## The walkthrough loop

For every step, in this order:

1. **Explain briefly**
   - What the user is looking at.
   - Why it matters to the current flow.
   - What value or control flow enters and leaves it.
   - Cite the exact location as `path:line`.
2. **Navigate Neovim**
   - Open the file and place the cursor at the first relevant line.
   - Highlight only the relevant range.
   - Center it with `zz` and leave focus in the code window for reading.
   - Keep the Claude terminal visible as the right sidebar.
3. **Pause in Claude Code**
   - Call `AskUserQuestion` only after all navigation tools have finished.
   - Use a single-select question such as:
     - `继续下一步 (Recommended)` — follow the planned route.
     - `深入当前代码` — explain the current block in more detail.
     - `查看相关调用` — navigate to a caller or callee first.
     - `结束导览` — stop and summarize.
   - The UI supplies `Other`; the user can type any question there.
4. **Resume from the answer**
   - A custom question temporarily interrupts the route. Answer it, navigate if
     useful, then return to the same checkpoint unless the user changes scope.
   - Keep a short breadcrumb: current step, current file, and next destination.

Pause at architectural boundaries, call-chain transitions, or difficult logic;
not after every small helper.

## Neovim navigation

First check that this is a Neovim-hosted session:

```bash
test -n "${NVIM:-}" && nvim --server "$NVIM" --remote-expr '1'
```

When connected, use the bundled helper from any project directory:

```bash
"$HOME/.claude/skills/project-walkthrough/scripts/navigate.sh" path/to/file.lua 42 58
```

Arguments are file, first line, and optional last line. The helper:

- reuses a normal editor window without replacing modified buffers;
- opens Claude Code if its terminal buffer is hidden and the command exists;
- preserves the Claude terminal as configured (normally the right split);
- focuses the source file, moves the cursor, highlights the range, and runs `zz`;
- changes no source files.

At the end of the tour, remove the walkthrough highlight:

```bash
"$HOME/.claude/skills/project-walkthrough/scripts/navigate.sh" --clear
```

If `$NVIM` is unavailable or RPC fails, fall back gracefully: cite `path:line`,
continue the same explanation loop, and still pause with `AskUserQuestion`.
Never create a Neovim floating confirmation window and never block inside
`nvim --remote-expr`; the conversation pause belongs to `AskUserQuestion`.

## Claude sidebar behavior

- Prefer the existing `claudecode.nvim` terminal. Its normal layout is a right
  split, so do not close or replace its terminal buffer.
- Leave focus in the code window after navigation. The user can inspect the code,
  then click or move to the Claude sidebar to answer the question.
- Do not hide Neo-tree or other user windows unless they obstruct the requested
  location and the user asks for a simpler layout.

## Auto mode and safety

`AskUserQuestion` still blocks in Auto mode. Auto mode can bypass edit diffs, so
this skill does not edit files by default. If the user changes from learning to
editing, state that transition and follow the normal edit workflow; use a Claude
confirmation for a genuinely consequential choice, not for every harmless read.

Never claim the user understood a step merely because time passed. Continue only
from their actual answer.

## Finish

Clear the highlight and give a compact map of what was covered:

- entry point;
- main modules and their responsibilities;
- the call/data path followed;
- unanswered questions or useful next routes.

Do not modify project files, Neovim configuration, or Claude settings as part of
a walkthrough unless the user explicitly asks.
