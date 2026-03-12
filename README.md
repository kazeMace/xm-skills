[中文](./README_zh.md) | English

# xm-skills

Claude Code skills shared by kazeMace to boost your daily productivity.

> Inspired by [baoyu-skills](https://github.com/JimLiu/baoyu-skills). Many thanks to the author for their open-source contribution.

## Prerequisites

- Node.js installed
- Ability to run `npx bun`
- Google Chrome, Chromium, or Microsoft Edge (required by some skills)

## Installation

### Register the plugin marketplace

In Claude Code, run:

```bash
/plugin marketplace add kazeMace/xm-skills
```

### Install skills

**Option 1: Browse the UI**

1. Select **Browse and install plugins**
2. Select **xm-skills**
3. Choose the plugin you want
4. Select **Install now**

**Option 2: Direct install**

```bash
# Install Weibo-related skills
/plugin install weibo-skills@xm-skills
```

### Available plugins

| Plugin | Description | Included skills |
|--------|-------------|-----------------|
| **weibo-skills** | Weibo utilities | [weibo-hot-search-anonymous](#weibo-hot-search-anonymous) |

## Available Skills

### weibo-hot-search-anonymous

**No Weibo account or login required.** Scrapes the Weibo real-time trending list anonymously via Chrome/Edge CDP and saves it as a Markdown file.

**Trigger**: Tell Claude "获取微博热搜", "抓取热搜", "微博热搜榜", "get Weibo hot search", "weibo trending", etc.

```bash
# Scrape trending topics and save to ./<today's date>-weibo-hot-search.md
/weibo-hot-search-anonymous

# Specify output path
/weibo-hot-search-anonymous --output ./data/hotsearch.md
```

**Parameters**:

| Parameter | Description |
|-----------|-------------|
| `--output <path>` | Output Markdown file path (default: `./<YYYY-MM-DD>-weibo-hot-search.md`) |

**Output format**:

```markdown
# 微博热搜 2026-03-11

> 采集时间：2026/3/11 10:00:00
> 共 50 条

| 排名 | 热搜词 | 热度 | 标签 |
|------|--------|------|------|
| 1 | some topic | - | 置顶 |
| 2 | another topic | 1046777 | - |
| 3 | third topic | 764477 | 新 |
...
```

**Notes**:
- **Pinned**: Government/official pinned entries, always listed first
- **Tags**: Original Weibo tags (新/热/爆/沸, etc.)
- **Heat**: Raw heat score; pinned entries usually have no score, shown as `-`
- Ad entries are filtered out automatically
- Anonymous access — no account cookies required, works in any environment

**Environment variables**:

| Variable | Description |
|----------|-------------|
| `WEIBO_BROWSER_CHROME_PATH` | Override Chrome/Edge executable path |
| `WEIBO_BROWSER_DEBUG_PORT` | Fix CDP debug port (for debugging) |

**Requirements**: Google Chrome, Chromium, or Microsoft Edge, plus the `bun` runtime.

## Credits

This project is inspired by the following open-source work:

- [baoyu-skills](https://github.com/JimLiu/baoyu-skills) by [@JimLiu](https://github.com/JimLiu) — the architecture and implementation ideas behind this project

## License

MIT
