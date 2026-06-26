# AGENTS.md

Guidance for AI agents working in this repository.

## Repository overview

`my-cursor` 存放 Cursor 相关配置，当前包含：

- `README.md` — 项目说明
- `.cursor/skills/a-share-industry-notion/` — A 股行业全链路 Notion 页面生成 skill（HTML 信息图 + MCP 写页）

## Cursor Cloud specific instructions

- **Dependencies**: Skill 截图脚本需要 `puppeteer-core`（在运行时 `npm install --prefix /opt/cursor/artifacts`）；需系统安装 Google Chrome（`/usr/local/bin/google-chrome`）。
- **Services**: Notion MCP 需用户在 Cursor 中完成连接；无本地 dev server。
- **Lint / test / build**: 无自动化测试；skill 变更后可在 Cloud Agent 中用真实行业名做一次端到端验证。
- **Typical agent work**: 维护 `.cursor/skills/`、按 skill 工作流为用户生成 Notion 行业页；**不要把运行时生成的 HTML/PNG 提交进 git**（模板在 skill 的 `assets/` 内）。

When this repo grows into a real application, update this section with the non-obvious startup and test caveats (not dependency install steps—that belongs in the update script).
