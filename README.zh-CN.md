<div align="center">

# 🔧 MCP Debugger

**别再瞎猜。30 秒内诊断并修复 MCP 服务器配置问题。**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/HOBER-EST/mcp-debugger)](https://github.com/HOBER-EST/mcp-debugger/stargazers)
[![Forks](https://img.shields.io/github/forks/HOBER-EST/mcp-debugger)](https://github.com/HOBER-EST/mcp-debugger/fork)
[![Last commit](https://img.shields.io/github/last-commit/HOBER-EST/mcp-debugger)](https://github.com/HOBER-EST/mcp-debugger/commits/master)
![Claude Code Skill](https://img.shields.io/badge/Claude_Code-skill-7c3aed)

**诊断 · 修复 · 验证** — 一个 [Claude Code 技能](https://docs.claude.com/en/docs/claude-code/skills)，捕获你 MCP 配置里的每一种静默失败。

[English](README.md) · [中文](README.zh-CN.md)

</div>

---

<p align="center">
  <img src="assets/hero.svg" alt="MCP Debugger — 诊断、修复并验证你的 MCP 服务器配置" width="100%">
</p>

## 你经历过这种痛吗

你加了一个 MCP 服务器，重启 Claude Code，**它不在列表里。**

没报错、没日志、没线索。Google 搜 20 分钟，找到一篇 4 个月前的 Stack Overflow 答案，不知道还适不适配你这版 Claude Code。试了 3 种方法，没一个管用。删掉整个配置从头来。

熟吗？

**问题不在你。MCP 配置静默失败的方式有 8 种以上**，每种修复涉及不同的文件、不同的语法、不同的操作系统坑。想要报错信息？没有。

这个技能把 30 分钟的糟心调试变成 30 秒的诊断。

---

## 它做什么

`mcp-debugger` 是一个 Claude Code 技能，你只要描述 MCP 问题，它会自动：

1. 🔍 **扫描** 所有配置源（`~/.claude.json`、`.mcp.json`）+ 所有遗留/失效位置
2. 🔬 **诊断** 每一种已知问题——不只是第一个
3. 🛠️ **修复** 按优先级，附带可复制粘贴的命令
4. ✅ **验证** 修复后的配置（重新校验 + 烟测）

| 症状 | 没有这个技能 | 有这个技能 |
|------|-------------|-----------|
| "全局 MCP 服务器不显示" | Google 30 分钟 → 也许迁移 `~/.claude/mcp.json` | 30 秒 → "在遗留文件里发现 6 个服务器，正在迁移。" |
| "服务器启动但没工具" | 重装包然后祈祷 | "包 `foo-mcp` 没有 `@modelcontextprotocol/sdk` 依赖——不是 MCP 服务器" |
| "升级 Claude Code 2.x 后全挂了" | 回退，丢特性 | "遗留 `~/.claude/mcp.json` 已被忽略。自动迁移到 `~/.claude.json`。" |
| "Mac 正常，Windows 挂" | 切回 Mac 叹气 | "缺少 `cmd /c` 包装。自动修复所有 `npx` 调用。" |

---

## 快速开始

### 安装

```bash
# 方式一 — 手动安装
mkdir -p ~/.claude/skills/mcp-debugger
cp skill.md ~/.claude/skills/mcp-debugger/
cp -r evals examples ~/.claude/skills/mcp-debugger/
```

### 触发

用日常语言描述你的 MCP 问题即可自动触发，任何一种都生效：

- "MCP 不显示"
- "MCP 配置"
- "MCP 服务器启动不了"
- "MCP 工具缺失"
- "我的 MCP 服务器不见了"

或显式调用：`/mcp-debugger`

---

## 内置能力

### 10 种已知问题类型（持续扩充）

| # | 问题 | 严重程度 |
|---|------|----------|
| 1 | 全局 MCP 在遗留 `~/.claude/mcp.json`（2.x 静默忽略） | 🔴 严重 |
| 2 | JSON 语法错误（使该文件下所有服务器失效） | 🔴 严重 |
| 3 | 缺少 `type` 字段（服务器被静默丢弃） | 🟡 警告 |
| 4 | Windows 上 `npx` 缺少 `cmd /c` 包装 | 🟡 警告 |
| 5 | 错误的 npm 包（名字带 `xxx-mcp` 但不是 MCP 服务器） | 🟡 警告 |
| 6 | 缺少必需的环境变量 / API key | 🟡 警告 |
| 7 | `.mcp.json` 里的项目服务器未启用 | 🟡 警告 |
| 8 | `settings.json` 里有残留的 `mcpServers`（升级后产生） | 🟡 警告 |
| 9 | 服务器启动后立刻退出（烟测） | 🟠 隐藏 |
| 10 | 全局和项目里重名（同名遮蔽） | 🟡 警告 |

完整诊断和修复 → 见 [`skill.md`](skill.md)。

---

## MCP 配置模型（Claude Code 2.x）

技能理解真实的加载顺序：

```
┌──────────────────────────────────────────────────────────────┐
│  解析优先级（Claude Code 2.x）                                 │
├─────┬───────────────────────────────────────┬────────────────┤
│  1  │ CLI --mcp-config 参数                 │ 单次调用        │
│  2  │ ./.mcp.json                           │ 项目级          │
│  3  │ ~/.claude.json → projects.<cwd>...    │ 本地级          │
│  4  │ ~/.claude.json → mcpServers           │ 全局级          │
│  5  │ ~/.claude/mcp.json                    │ ❌ 遗留，已忽略 │
└─────┴───────────────────────────────────────┴────────────────┘
```

⚠️ **最大的坑：** `~/.claude/mcp.json` 在 2.x 里**被静默忽略**了，但**不报错**。服务器在里头看上去"全局"，但永远不会加载。这正是"全局 MCP 不见了"的 #1 原因。

---

## 症状 → 诊断 → 修复

| 症状 | 最可能原因 | 修复 |
|------|-----------|------|
| **全局 MCP 不显示（项目级正常）** | 服务器在遗留 `~/.claude/mcp.json` | 迁移到 `~/.claude.json` → `mcpServers`；删除遗留文件 |
| **所有 MCP 服务器一个都不出现** | JSON 语法错误 | 验证 JSON；Windows 上对 `~/.claude.json` 用 UTF-8 |
| **缺一个，其他都正常** | 缺 `type`、错误的包，或 Windows 缺 `cmd /c` | 加 `"type": "stdio"`；验证包；包装 npx |
| **`.mcp.json` 里的服务器不加载** | `settings.local.json` 里没启用 | 设 `enableAllProjectMcpServers: true` |
| **Windows 上 npx 服务器失败** | 缺 `cmd /c` 包装 | `"command": "cmd", "args": ["/c", "npx", ...]` |
| **服务器启动后立即退出** | 缺环境变量或包崩溃 | 检查 `env` 键；终端手动跑一遍 |
| **服务器加载了但没工具** | 错误的包（不是 MCP 服务器） | `npm view <pkg> dependencies` 查 `@modelcontextprotocol/sdk` |
| **SSE 服务器连不上** | 服务器没启动或 URL 错 | `curl <url>`；确认 Claude 启动前服务器已运行 |
| **所有服务器全消失** | `settings.json` 里有残留 `mcpServers: {}` | 从 `settings.json` 里删掉 `mcpServers` |

---

## 示例

<p align="center">
  <img src="assets/demo.png" alt="mcp-debugger 会话示例" width="900">
</p>

```
👤 你: "我刚升级到 Claude Code 2.x，全局 MCP 服务器都没了。
       只有 .mcp.json 里的项目级还能用。"

🤖 Claude（启用 mcp-debugger）：

   扫描配置源…

   ✓ ~/.claude.json              → 0 个服务器（无 mcpServers 键）
   ✓ ./.mcp.json                 → 2 个服务器
   ⚠ ~/.claude/mcp.json          → 6 个服务器  ← 遗留，2.x 已忽略

   发现的问题
   ─────────────────────────────────────────────
   🔴 严重  6 个全局服务器在遗留文件 ~/.claude/mcp.json 中。
             Claude Code 2.x 不加载此文件，它们将被忽略。

   迁移计划
   ─────────────────────────────────────────────
   → 把 6 个服务器从 ~/.claude/mcp.json 移到 ~/.claude.json 的
     顶级 mcpServers 键
   → 保留顺序和元数据
   → 之后删除遗留文件

   执行迁移...            ✓ 完成
   校验 ~/.claude.json...  ✓ JSON 合法，6 个服务器
   确认无遗留文件...       ✓ 已清理

   ⏰ 请重启 Claude Code 让变更生效。

👤 你: "🎉 全回来了，谢谢。"
```

---

## 项目结构

```
mcp-debugger/
├── skill.md                ← 技能定义文件（Claude Code 加载）
├── evals/
│   └── evals.json          ← 10 个真实测试用例
├── examples/
│   ├── README.md           ← 断/修演练说明
│   ├── broken-mcp.json     ← 故意写错的配置（用来测试）
│   └── fixed-mcp.json      ← 技能修复后的同一份配置
├── assets/
│   ├── hero.svg            ← README 横幅
│   ├── demo.html           ← 截图源文件
│   ├── demo.png            ← 渲染后的截图
│   └── capture-demo.ps1    ← 重新生成截图的脚本
├── README.md               ← 英文文档
├── README.zh-CN.md         ← 你在这里
├── LICENSE                 ← MIT
├── CONTRIBUTING.md         ← 如何贡献新问题模式
└── CHANGELOG.md            ← 版本历史
```

---

## 贡献

欢迎提 bug 报告、新 MCP 失败模式、平台特定修复。

- 🐛 **新增失败模式** → 提 issue：触发短语 + 诊断方式 + 修复
- 🧪 **新增测试用例** → 复制 `evals/evals.json` 里的 schema，加入你的断配置
- 🔧 **修 bug** → fork + PR，请附上覆盖你修复的测试

完整流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 路线图

- [ ] 从包元数据自动识别 SSE vs stdio
- [ ] 支持 VS Code MCP 配置（`<workspace>/.vscode/mcp.json`）
- [ ] 支持 Cursor MCP 配置（`~/.cursor/mcp.json`）
- [ ] "上次升级改了什么"——配置 diff 工具

---

## 致谢

从真实的调试痛点中提炼。模式来自在 macOS、Windows（含 GBK 编码坑）、Linux 上跑通的真实 Claude Code 设置。感谢在 issues 里分享断配置的所有人。

---

## 许可证

[MIT](LICENSE) — 使用、修改、分发均可，欢迎署名。

## 📈 Star History

如果 `mcp-debugger` 帮你省了时间，给个 ⭐️ 是最好的支持。

<a href="https://star-history.com/#HOBER-EST/mcp-debugger&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=HOBER-EST/mcp-debugger&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=HOBER-EST/mcp-debugger&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=HOBER-EST/mcp-debugger&type=Date" />
  </picture>
</a>
