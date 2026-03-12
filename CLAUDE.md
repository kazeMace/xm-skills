# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**xm-skills** — kazeMace 的 Claude Code 技能插件集合，基于 Chrome CDP 实现浏览器自动化，提供微博热搜等数据抓取能力。

## Architecture

技能按插件分类，定义于 `.claude-plugin/marketplace.json`：

```
skills/
└── [weibo-skills]               # 微博相关技能
    ├── weibo-hot-search-anonymous/  # 匿名抓取微博热搜（无需登录）
    └── weibo-hot-search/            # 微博热搜（预留）
```

**插件分类**：

| 分类 | 说明 |
|------|------|
| `weibo-skills` | 微博数据抓取相关技能 |

每个技能包含：
- `SKILL.md` — YAML front matter（name、description）+ 使用文档
- `scripts/` — TypeScript 实现
- `LICENSE.md` — 许可证

## Running Skills

所有脚本均为 TypeScript，通过 Bun 运行时执行（无需编译）。

### Runtime Detection（`${BUN_X}`）

运行脚本前，**必须先检测运行时**，设置 `${BUN_X}`：

```bash
if command -v bun &>/dev/null; then
  BUN_X="bun"
elif command -v npx &>/dev/null; then
  BUN_X="npx -y bun"
else
  echo "Error: Neither bun nor npx found."
  echo "Install: brew install oven-sh/bun/bun (macOS) or npm install -g bun"
  exit 1
fi
```

| 优先级 | 条件 | `${BUN_X}` | 备注 |
|--------|------|------------|------|
| 1 | 已安装 `bun` | `bun` | 最快，原生执行 |
| 2 | 有 `npx` | `npx -y bun` | 首次运行时通过 npm 下载 bun |
| 3 | 均不存在 | 报错 | `brew install oven-sh/bun/bun` |

### Script Execution

```bash
${BUN_X} skills/<skill>/scripts/<script>.ts [options]
```

示例：

```bash
# 匿名抓取微博热搜，保存到当前目录
${BUN_X} skills/weibo-hot-search-anonymous/scripts/weibo-hot-search.ts

# 指定输出路径
${BUN_X} skills/weibo-hot-search-anonymous/scripts/weibo-hot-search.ts --output ./data/hotsearch.md
```

## Key Dependencies

- **Bun**：TypeScript 运行时（优先使用 `bun`，回退 `npx -y bun`）
- **Chrome / Chromium / Edge**：`weibo-hot-search-anonymous` 使用 Chrome CDP 进行浏览器自动化
- **clawhub**（可选）：用于同步技能，`npx -y clawhub` 回退可用

## Chrome Profile

使用 Chrome CDP 的技能共享**同一个** Profile 目录，不要为每个技能创建独立 Profile。

| 平台 | 默认路径 |
|------|----------|
| macOS | `~/Library/Application Support/xm-skills/chrome-profile` |
| Linux | `$XDG_DATA_HOME/xm-skills/chrome-profile`（回退 `~/.local/share/xm-skills/chrome-profile`） |
| Windows | `%APPDATA%/xm-skills/chrome-profile` |

**环境变量覆盖**：`XM_CHROME_PROFILE_DIR`（优先级最高，所有技能应遵守）。

### Implementation Pattern

新增需要 Chrome CDP 的技能时：

```typescript
function getDefaultProfileDir(): string {
  const override = process.env.XM_CHROME_PROFILE_DIR?.trim();
  if (override) return path.resolve(override);
  const base = process.platform === 'darwin'
    ? path.join(os.homedir(), 'Library', 'Application Support')
    : process.env.XDG_DATA_HOME || path.join(os.homedir(), '.local', 'share');
  return path.join(base, 'xm-skills', 'chrome-profile');
}
```

## Security Guidelines

### No Piped Shell Installs

**禁止**在代码、文档或错误信息中使用 `curl | bash` 或 `wget | sh` 模式，改用包管理器：

| 平台 | 安装命令 |
|------|----------|
| macOS | `brew install oven-sh/bun/bun` |
| npm | `npm install -g bun` |

### System Command Execution

技能使用平台相关命令进行浏览器自动化：
- 使用数组形式的 `spawn`/`execFile`，不要使用 shell 字符串拼接
- 不要将未经验证的用户输入传入 shell 命令
- 文件路径须从已知基础目录解析

## Plugin Configuration

`.claude-plugin/marketplace.json` 定义插件元数据和技能路径，版本遵循 semver。

## Skill Loading Rules

**重要**：在本项目中工作时，遵循以下规则：

| 规则 | 说明 |
|------|------|
| **优先加载项目技能** | 必须优先加载 `skills/` 目录下的所有技能，项目技能优先级高于同名系统/用户级技能 |

**加载优先级**（由高到低）：
1. 当前项目 `skills/` 目录
2. 用户级技能（`$HOME/.xm-skills/`）
3. 系统级技能

## Release Process

**重要**：用户请求 release/发布/push 时，必须按以下流程操作：

1. 更新 `CHANGELOG.md`（如有）
2. 更新 `marketplace.json` 版本号
3. 更新 `README.md`（如适用）
4. 所有文件一并提交后再打 tag

**发布前检查**：
- `marketplace.json` 版本号已更新
- 所有技能的 `SKILL.md` `version` 字段与 marketplace 版本一致
- README 中的技能说明与实际功能匹配

## Adding New Skills

**命名约定**：本项目技能无强制前缀要求，但建议使用有意义的短名称，避免与其他插件冲突。

### Steps

1. 创建 `skills/<name>/SKILL.md`，包含 YAML front matter
2. 在 `skills/<name>/scripts/` 中添加 TypeScript 脚本
3. 在 `marketplace.json` 中将技能路径注册到合适的插件分类下
4. 在 `SKILL.md` 中添加"脚本目录"章节（见下方模板）
5. 更新 `README.md`，添加技能说明

### SKILL.md Front Matter

```yaml
---
name: <skill-name>
description: <第三人称描述，包含功能说明和触发关键词，最多 1024 字符>
version: 1.0.0
metadata:
  openclaw:
    requires:
      anyBins:
        - bun
        - npx
---
```

### Script Directory Section Template

每个含脚本的 SKILL.md 必须包含此章节：

```markdown
## 脚本目录

**重要**：所有脚本位于本 skill 的 `scripts/` 子目录中。

**Agent 执行说明**：
1. 将本 SKILL.md 所在目录路径记为 `{baseDir}`
2. 脚本路径 = `{baseDir}/scripts/<script-name>.ts`
3. 将文档中所有 `{baseDir}` 替换为实际路径
4. 确定 `${BUN_X}` 运行时：已安装 `bun` → 使用 `bun`；有 `npx` → 使用 `npx -y bun`；否则提示安装 bun

**脚本说明**：
| 脚本 | 功能 |
|------|------|
| `scripts/main.ts` | 主入口 |
```

### Writing Effective Descriptions

**必须使用第三人称**（不能用"我可以帮你"或"你可以使用"）：

```yaml
# 正确
description: 匿名抓取微博实时热搜榜并保存为 Markdown 文件。当用户说"获取微博热搜"、"抓取热搜"时使用。

# 错误
description: 我可以帮你获取微博热搜
description: 你可以用这个抓取热搜
```

描述中需包含**功能说明**（做什么）和**触发时机**（何时使用/关键词）。

## Syncing Skills

使用 `scripts/sync-clawhub.sh` 同步技能到 clawhub 平台：

```bash
# 同步所有技能
bash scripts/sync-clawhub.sh

# 同步指定技能
bash scripts/sync-clawhub.sh --skill weibo-hot-search-anonymous
```

需要 `clawhub` 命令（回退使用 `npx -y clawhub`）。

## Code Style

- 全程 TypeScript，不加注释
- 使用 async/await
- 短变量名
- 类型安全的 interface 定义
