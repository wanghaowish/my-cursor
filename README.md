# my-cursor

Cursor 相关配置与 Agent Skills。

## Skills

| Skill | 说明 |
|-------|------|
| [`a-share-industry-notion`](.cursor/skills/a-share-industry-notion/SKILL.md) | 用户给出 A 股行业名 → 在 Notion `code` 下新建或更新「全链路分析」页面（超清信息图 + 深度文字） |

使用方式：在 Cursor 对话中描述行业，例如「分析一下光伏行业」；或手动调用 `/a-share-industry-notion`。

**前置条件**：Notion MCP 已连接；Cloud Agent 环境需 Chrome + `puppeteer-core`。
