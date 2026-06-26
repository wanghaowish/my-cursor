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
|------|-----|
| 标题 | `A股 {行业} 行业全链路分析` |
| 图标 | 📊 |
| 示例 | `A股 PCB 行业全链路分析` |

## 查重逻辑

1. `notion-fetch` 父页面 `code`，读取 `<content>` 中的 `<page>` 子页列表（**最可靠**）
2. 或 `notion-search` + `page_url` 限定在 code 下搜索
3. 标题完全匹配 → **更新**（先用 UUID 验证可写）
4. 否则 → **新建**

### Page ID 陷阱

| 现象 | 处理 |
|------|------|
| `notion-search` 返回 UUID，但 UUID `fetch`/`update` 404 | 用完整 `https://app.notion.com/p/...` URL `fetch` 读正文；**不要**用该 UUID 更新 |
| URL 能读、UUID 不能写 | 新建可写子页 → 迁移正文 → 父页移除旧 `<page>` 引用（见下） |
| `code` 下两个同标题子页 | 保留有信息图且 UUID 可写的；清理另一个 |

## 清理重复/不可写旧页

MCP **没有** `delete-page` 工具。从父页 `code` 删除旧子页的 `<page url="...">` 行，并传 `allow_deleting_content: true`，未引用子页会进入 Notion 回收站。

```json
{
  "page_id": "38a63db5-6956-80f0-aae1-fb7d88a88118",
  "command": "update_content",
  "allow_deleting_content": true,
  "content_updates": [{
    "old_str": "<page url=\"https://app.notion.com/p/{旧页32位ID}\">A股 {行业} 行业全链路分析</page>\n",
    "new_str": ""
  }]
}
```

## 已知页面（示例）

| 行业 | Page ID | URL |
|------|---------|-----|
| PCB | `38b63db5-6956-812e-a05c-cc7980fb2234` | https://app.notion.com/p/38a63db56956812ea05ccc7980fb2234 |
| CPO | `38b63db5-6956-81ec-9039-e80205ac2c18` | https://app.notion.com/p/38b63db5695681ec9039e80205ac2c18 |
| 固态电池 | `38b63db5-6956-81ae-9bef-c631a0c811da` | https://app.notion.com/p/38a63db5695681ae9befc631a0c811da |

> 以 `notion-fetch code` 子页列表为准；上表仅供加速，不必每次写入 git。

## MCP 工具速查

| 操作 | 工具 | 命令/参数 |
|------|------|-----------|
| 读父页/子页 | `notion-fetch` | `id` = page URL 或 UUID |
| 搜索 | `notion-search` | `query` + 可选 `page_url` |
| 新建 | `notion-create-pages` | `parent.page_id` = code |
| 全文替换 | `notion-update-page` | `command: replace_content` |
| 局部替换 | `notion-update-page` | `command: update_content` + `content_updates` |
| 删子页引用 | `notion-update-page` | `update_content` + `allow_deleting_content: true` |

## 图片外链（picGo）

| 字段 | 值 |
|------|-----|
| 仓库 | `wanghaowish/picGo`（SSH host: `github-picgo`） |
| Secret | `PICGO_DEPLOY_KEY`（Cloud Agent Secrets） |
| 启动脚本 | `.cursor/setup-picgo-ssh.sh`（见 `.cursor/environment.json`） |
| 目录 | `img/cursor/` |
| 命名 | `{行业名称}-map-uhd.png`（如 `PCB`、`固态电池`、`CPO`） |
| 外链模板 | `https://raw.githubusercontent.com/wanghaowish/picGo/main/img/cursor/{行业名称}-map-uhd.png` |
| 推送脚本 | `.cursor/skills/a-share-industry-notion/scripts/push-to-picgo.sh` |

中文行业名 URL 编码示例：固态电池 → `%E5%9B%BA%E6%80%81%E7%94%B5%E6%B1%A0`（Notion markdown 中可直接用中文或编码 URL）。

## 图片限制

- MCP **不支持**本地文件上传
- 仅支持 `![caption](https://...)` 外链
- 无法通过 API 设置图片块宽度（用户 UI 拖至 100%）
- 外链图 Notion 可能压缩；本地上传最清晰
