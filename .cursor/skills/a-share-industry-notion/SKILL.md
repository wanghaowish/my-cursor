---
name: a-share-industry-notion
description: 当用户询问 A 股某个行业的产业链、全链路分析、行业图谱，或要求在 Notion 生成/更新行业研究页面时使用。自动在 Notion「code」下创建或更新「A股 {行业} 行业全链路分析」页面，含超清三栏信息图 + 深度文字分析。
compatibility: 需要 Notion MCP 已连接；Cloud Agent 环境需有 Google Chrome 与 puppeteer-core（npm install puppeteer-core）；可访问外网上传图片外链。
metadata:
  parent-notion-page: code
  parent-notion-page-id: 38a63db5-6956-80f0-aae1-fb7d88a88118
  page-title-pattern: "A股 {行业} 行业全链路分析"
  page-icon: "📊"
---

# A 股行业全链路 → Notion 页面

用户给出**行业名称**（如「PCB」「光伏」「锂电池」）时，交付一份完整的 Notion 行业研究页：**顶部超清产业链信息图** + **下方 11 章深度文字分析**。

## 触发条件

- 用户说「分析一下 XX 行业」「XX 全链路」「在 Notion 写 XX 行业」
- 用户要求更新已有行业页
- 用户引用本 skill（`/a-share-industry-notion`）

## 硬性规则

1. **不要把 HTML 源码提交进 git**；HTML 仅在运行时生成到临时目录（如 `/opt/cursor/artifacts/`）。
2. **重复行业 → 更新**；**新行业 → 在 `code` 下新建子页**。
3. 信息图必须用 **HTML 模板渲染 + Puppeteer 截图**，不要用 AI 生图替代（布局不一致）。
4. Notion MCP **不能上传本地图片**；用外链 `![](url)` 插入，并提示用户可下载原图后本地上传以获得最佳清晰度。
5. 外链图在 Notion 中默认较窄，提醒用户拖至 **100% 列宽**。

## 工作流（按顺序执行）

### 1. 解析行业并查重

从用户消息提取行业名 `{行业}`（去掉「A股」「行业」「分析一下」等修饰词）。

用 Notion MCP 查重：

```
notion-fetch id="38a63db5-6956-80f0-aae1-fb7d88a88118"
```

查看 `code` 页下是否已有标题匹配 **`A股 {行业} 行业全链路分析`** 的子页。

也可用：

```
notion-search query="A股 {行业} 行业全链路分析" page_url="38a63db5-6956-80f0-aae1-fb7d88a88118"
```

| 结果 | 动作 |
|------|------|
| 已存在同标题子页 | `notion-fetch` 该页 → 记录 `page_id` → 走**更新**流程 |
| 不存在 | 走**新建**流程 |

标题匹配时忽略空格差异；「PCB」与「印制电路板」视为不同行业，除非用户明确说同一行业。

### 2. 研究行业内容

针对 A 股该行业，梳理：

- **上游**：原材料、核心零部件、专用设备（每类 3–6 家 A 股，标注 ★ 龙头）
- **中游**：制造/集成环节，按产品技术阶梯分层
- **下游**：终端应用场景，按景气度排序（★ 数量表示强度）
- **投资框架**：五维分析、确定性 vs 弹性、扩产周期、风险、龙头速查

公司需带 **A 股代码**（6 位数字）。数据注明「截至公开信息」，文末加免责声明。

### 3. 生成信息图 HTML

1. 复制 `assets/industry-chain-map.template.html` 到临时路径，如 `/opt/cursor/artifacts/{行业名称}-map.html`
2. 按行业替换模板中所有 PCB 专属内容，保持**三栏蓝/绿/橙**结构与模块卡片样式不变
3. **必须保留**完整版布局（上游 A–F 模块、中游龙头速览 `leader-box`、下游 A–F、底部五维分析）
4. **不要改** `.page { overflow: visible; }`（`overflow: hidden` 会裁切截图）
5. 保持 `max-width: 1280px` 与 `body padding: 32px 20px 48px`（完整高度约 7000×9880）

模块结构参考模板中 `.module` 块：图标、标签字母、标题、描述、股票标签（龙头用 `class="stock leader"`）。

### 4. 导出超清 PNG

在含 `puppeteer-core` 的环境执行：

```bash
# 若未安装
npm install puppeteer-core --prefix /opt/cursor/artifacts

node .cursor/skills/a-share-industry-notion/scripts/screenshot-uhd.js \
  /opt/cursor/artifacts/{行业名称}-map.html \
  /opt/cursor/artifacts/assets/{行业名称}-map-uhd.png
```

验收标准：

- 宽度 **7000px**（viewport 1400 × deviceScaleFactor 5）
- 高度通常 **9500–9900px**（完整三栏版）
- 文件 **2MB+**

Chrome 路径默认 `/usr/local/bin/google-chrome`；不可用则设置环境变量 `CHROME_PATH`。

### 5. 上传图片获取外链（picGo `img/cursor/`）

Cloud Agent 环境需已配置 `PICGO_DEPLOY_KEY`（见 `.cursor/setup-picgo-ssh.sh`）。

**命名规则**：图片存于 `img/cursor/`，文件名用**行业名称**（与 Notion 标题中的 `{行业}` 一致），如 `PCB`、`固态电池`、`CPO`。

```bash
# 一键推送（推荐）
bash .cursor/skills/a-share-industry-notion/scripts/push-to-picgo.sh {行业名称} \
  /opt/cursor/artifacts/assets/{行业名称}-map-uhd.png

# 或手动：
git clone git@github-picgo:wanghaowish/picGo.git /tmp/picGo
mkdir -p /tmp/picGo/img/cursor
cp /opt/cursor/artifacts/assets/{行业名称}-map-uhd.png /tmp/picGo/img/cursor/{行业名称}-map-uhd.png
cd /tmp/picGo && git add img/cursor/{行业名称}-map-uhd.png
git commit -m "feat(cursor): add {行业名称} industry chain map"
git push origin main
```

永久外链格式：

```
https://raw.githubusercontent.com/wanghaowish/picGo/main/img/cursor/{行业名称}-map-uhd.png
```

示例：
- PCB → `.../img/cursor/PCB-map-uhd.png`
- 固态电池 → `.../img/cursor/固态电池-map-uhd.png`
- CPO → `.../img/cursor/CPO-map-uhd.png`

告知用户：GitHub raw 链接长期有效；若 Notion 显示仍嫌模糊，可下载原图后本地上传。

### 6. 撰写 Notion 正文

遵循 `references/content-outline.md` 的 **11 章结构**，使用 **Notion-flavored Markdown**（表格用 `<table header-row="true">`，代码块标注语言）。

页面顶部固定结构：

```markdown
# 全链路图解

![A股 {行业} 行业全链路图谱]({图片外链})

> 超清信息图（约 7000×9800px）。若显示模糊，请下载原图后本地上传至本页，并拖至 100% 列宽。

---
```

正文各章用 `---` 分隔；末尾附：

```markdown
*以上仅为行业产业链研究梳理，不构成投资建议。*
*由 Cursor Agent 生成 · {日期}*
```

写之前可读 `notion://docs/enhanced-markdown-spec`（通过 MCP resource）。

### 7. 写入 Notion

**新建**（`notion-create-pages`）：

```json
{
  "parent": { "page_id": "38a63db5-6956-80f0-aae1-fb7d88a88118", "type": "page_id" },
  "pages": [{
    "properties": { "title": "A股 {行业} 行业全链路分析" },
    "icon": "📊",
    "content": "{完整 markdown}"
  }]
}
```

**更新**（`notion-update-page`）：

```json
{
  "page_id": "{已有 page_id}",
  "command": "replace_content",
  "new_str": "{完整 markdown}"
}
```

更新时替换全部正文，保留页面 URL 不变。仅改图时用 `update_content` 替换图片块。

### 8. 回复用户

交付内容须包含：

- Notion 页面链接
- 图片下载直链（方便本地上传）
- 本行业上游/中游/下游各 1–2 句核心结论
- 若是更新：说明「已更新已有页面」；若是新建：说明「已在 code 下新建」

## 参考文件

| 文件 | 用途 |
|------|------|
| `assets/industry-chain-map.template.html` | 三栏信息图 HTML 模板（以 PCB 为范例） |
| `scripts/screenshot-uhd.js` | Puppeteer 5× 全页截图 |
| `scripts/push-to-picgo.sh` | 推送截图到 picGo `img/cursor/` 并输出 raw 外链 |
| `references/content-outline.md` | Notion 正文 11 章大纲 |
| `references/notion-config.md` | 父页面 ID、命名约定 |

## 常见问题

**Q: 用户说「再详细一点」？**  
A: 在已有页面上 `replace_content`，扩充各章表格与「深度看点」，不重命名页面。

**Q: 能否把 HTML 放进 git？**  
A: 不要。仅 skill 内的 `template.html` 作为模板保留。

**Q: 图片模糊？**  
A: 确认使用 5× 截图；建议用户本地上传；不要用 3× fullwidth 版替代。

**Q: Notion MCP 不可用？**  
A: 告知用户连接 Notion MCP；可先在本地生成 HTML/PNG 与 markdown 文稿备用。
