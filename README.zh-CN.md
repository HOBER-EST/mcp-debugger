[![English](https://img.shields.io/badge/🌐-English-blue.svg)](README.md)

# mcp-debugger（新手向--主要用于配置mcp时的bug处理）

诊断和修复 MCP（Model Context Protocol）服务器配置问题的 Claude Code 技能。

## 功能

当 MCP 服务器不显示、启动失败或工具缺失时，自动扫描配置、找出所有问题并一键修复。

### 覆盖的问题

- 🔴 **全局服务器放错位置** — `~/.claude/mcp.json` 是遗留路径，2.x 静默忽略；正确位置是 `~/.claude.json`
- 🔴 **JSON 语法错误** — 整个文件的所有服务器都会失效
- 🟡 **缺少 `type` 字段** — 没有 `"type": "stdio"` 服务器会被忽略
- 🟡 **Windows `cmd /c` 包装** — `npx` 命令在 Windows 上必须用 `cmd /c` 包装
- 🟡 **错误的 npm 包** — 名字带 "mcp" 不一定是 MCP 服务器
- 🟡 **缺少环境变量** — API key 未设置
- 🟡 **项目服务器未启用** — `.mcp.json` 需要 `enableAllProjectMcpServers`
- 🟡 **settings.json 残留配置** — 旧版 `mcpServers` 冲突

## 快速开始

### 安装技能

```bash
# 复制 skill.md 到 Claude Code 技能目录
cp skill.md ~/.claude/skills/mcp-debugger/skill.md
cp -r evals ~/.claude/skills/mcp-debugger/
```

### 触发技能

直接描述你的 MCP 问题，技能会自动触发：
- "MCP 不显示"
- "MCP 服务器启动不了"
- "MCP 工具缺失"

或手动调用：
```
/mcp-debugger
```

## MCP 配置模型（Claude Code 2.x）

```
优先级  位置                                        作用域
──────  ─────────────────────────────────────────  ────────────
  1     CLI --mcp-config 参数                      单次调用
  2     ./.mcp.json                               项目级（团队共享）
  3     ~/.claude.json → projects.<cwd>.mcpServers 本地级
  4     ~/.claude.json → mcpServers                全局级（所有项目）
  5     ~/.claude/mcp.json                         ❌ 遗留，被忽略！
```

## 使用示例

```
用户: "只有项目级MCP能显示，全局配置的显示不出来"

mcp-debugger:
  → 扫描 ~/.claude.json、./.mcp.json、settings.json
  → 发现: 6 个服务器在遗留文件 ~/.claude/mcp.json 中
  → 迁移到 ~/.claude.json → mcpServers
  → 删除遗留文件
  → 提醒重启 Claude Code
```

## 文件结构

```
mcp-debugger/
├── skill.md          # 技能定义文件
├── evals/
│   └── evals.json    # 评估测试用例
├── README.md         # 英文文档
└── README.zh-CN.md   # 中文文档
```

## 许可证

MIT
