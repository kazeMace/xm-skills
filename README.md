# xm-skills

kazeMace 分享的 Claude Code 技能集，提升日常工作效率。

> 感谢 [baoyu-skills](https://github.com/JimLiu/baoyu-skills) 项目的启发与参考，感谢宝玉老师的开源贡献。

## 前置要求

- 已安装 Node.js 环境
- 能够运行 `npx bun` 命令
- Google Chrome、Chromium 或 Microsoft Edge（部分技能需要）

## 安装

### 注册插件市场

在 Claude Code 中运行：

```bash
/plugin marketplace add kazeMace/xm-skills
```

### 安装技能

**方式一：通过浏览界面**

1. 选择 **Browse and install plugins**
2. 选择 **xm-skills**
3. 选择要安装的插件
4. 选择 **Install now**

**方式二：直接安装**

```bash
# 安装微博相关技能
/plugin install weibo-skills@xm-skills
```

### 可用插件

| 插件 | 说明 | 包含技能 |
|------|------|----------|
| **weibo-skills** | 微博相关工具 | [weibo-hot-search-anonymous](#weibo-hot-search-anonymous) |

## 可用技能

### weibo-hot-search-anonymous

**无需微博账号，无需登录**，通过 Chrome/Edge CDP 以匿名身份抓取微博实时热搜榜并保存为 Markdown 文件。

**触发方式**：告诉 Claude "获取微博热搜"、"抓取热搜"、"微博热搜榜"、"不用登录查热搜" 等。

```bash
# 采集热搜，保存到当前目录下 ./<今天日期>-weibo-hot-search.md
/weibo-hot-search-anonymous

# 指定输出路径
/weibo-hot-search-anonymous --output ./data/hotsearch.md
```

**参数说明**：

| 参数 | 说明 |
|------|------|
| `--output <路径>` | 输出 Markdown 文件路径（默认：`./<YYYY-MM-DD>-weibo-hot-search.md`） |

**输出格式**：

```markdown
# 微博热搜 2026-03-11

> 采集时间：2026/3/11 10:00:00
> 共 50 条

| 排名 | 热搜词 | 热度 | 标签 |
|------|--------|------|------|
| 1 | 某热搜词 | - | 置顶 |
| 2 | 另一个热搜 | 1046777 | - |
| 3 | 热搜三 | 764477 | 新 |
...
```

**说明**：
- **置顶**：政府/官方置顶内容，排在最前
- **标签**：微博原始标签（新、热、爆、沸等）
- **热度**：原始热度数值；置顶条目通常无热度，显示 `-`
- 广告条目自动过滤
- 匿名访问，不依赖任何账号 Cookie，可在任意环境直接运行

**环境变量**：

| 变量 | 说明 |
|------|------|
| `WEIBO_BROWSER_CHROME_PATH` | 覆盖 Chrome/Edge 可执行文件路径 |
| `WEIBO_BROWSER_DEBUG_PORT` | 固定 CDP 调试端口（调试用） |

**前置条件**：Google Chrome、Chromium 或 Microsoft Edge，以及 `bun` 运行时。

## 致谢

本项目受到以下开源项目的启发，感谢它们的作者：

- [baoyu-skills](https://github.com/JimLiu/baoyu-skills) by [@JimLiu](https://github.com/JimLiu)（宝玉老师） — 本项目的架构设计与实现思路来源

## 许可证

MIT
