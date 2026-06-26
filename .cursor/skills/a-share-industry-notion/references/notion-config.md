# Notion 配置

## 父页面

| 字段 | 值 |
|------|-----|
| 标题 | code |
| Page ID | `38a63db5-6956-80f0-aae1-fb7d88a88118` |
| URL | https://app.notion.com/p/38a63db5695680f0aae1fb7d88a88118 |

所有行业分析页均作为 **code 的直接子页面** 创建。

## 页面命名

| 字段 | 规则 |
|------|------|
| 标题 | `A股 {行业} 行业全链路分析` |
| 图标 | 📊 |
| 示例 | `A股 PCB 行业全链路分析` |

## 查重逻辑

1. `notion-fetch` 父页面 `code`，读取 `<content>` 中的 `<page>` 子页列表
2. 或 `notion-search` + `page_url` 限定在 code 下搜索
3. 标题完全匹配（或仅差「A股」「行业」等已规范化后的相同行业名）→ **更新**
4. 否则 → **新建**

**注意**：若 `notion-fetch` 用 UUID 返回 404，改用完整 `https://app.notion.com/p/...` URL 读取；若仍无法 `update`，在 `code` 下新建同标题页并迁移正文（旧页可手动删除）。

## 已知页面（示例）

| 行业 | Page ID | URL |
|------|---------|-----|
| PCB | `38a63db5-6956-817b-b7e7-c9f7f2c91f7b` | https://app.notion.com/p/38a63db56956817bb7e7c9f7f2c91f7b |

> 新行业页创建后无需写入本文件；以 Notion 实时查询为准。

## MCP 工具速查

| 操作 | 工具 | 命令/参数 |
|------|------|-----------|
| 读父页/子页 | `notion-fetch` | `id` = page URL 或 UUID |
| 搜索 | `notion-search` | `query` + 可选 `page_url` |
| 新建 | `notion-create-pages` | `parent.page_id` = code |
| 全文替换 | `notion-update-page` | `command: replace_content` |
| 局部替换 | `notion-update-page` | `command: update_content` + `content_updates` |

## 图片外链（picGo）

| 字段 | 值 |
|------|-----|
| 仓库 | `wanghaowish/picGo`（SSH host: `github-picgo`） |
| 目录 | `img/cursor/` |
| 命名 | `{行业名称}-map-uhd.png`（与标题中行业名一致，如 `PCB`、`固态电池`、`CPO`） |
| 外链模板 | `https://raw.githubusercontent.com/wanghaowish/picGo/main/img/cursor/{行业名称}-map-uhd.png` |
| 推送脚本 | `.cursor/skills/a-share-industry-notion/scripts/push-to-picgo.sh` |

## 图片限制

- MCP **不支持**本地文件上传
- 仅支持 `![caption](https://...)` 外链
- 无法通过 API 设置图片块宽度（用户 UI 拖至 100%）
- 外链图 Notion 可能压缩；本地上传最清晰
