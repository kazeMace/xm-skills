---
name: release-skills
description: xm-skills 项目专用发布工作流。自动分析 Git 提交、更新 marketplace.json 版本号、生成中英双语 Changelog、提交并打 Tag。当用户说 "release"、"发布"、"新版本"、"bump version"、"push"、"推送" 时使用。
---

# Release Skills（xm-skills 专用）

xm-skills 项目的一键发布工作流，自动完成版本号管理、双语 Changelog 生成、Git 提交与 Tag 创建。

## 快速开始

直接运行 `/release-skills`，无需任何参数。

## 选项

| 参数 | 说明 |
|------|------|
| `--dry-run` | 预览所有操作，不实际执行 |
| `--major` | 强制 Major 版本升级 |
| `--minor` | 强制 Minor 版本升级 |
| `--patch` | 强制 Patch 版本升级 |

---

## 工作流

### Step 1：检测项目配置

本项目固定配置如下，无需自动检测：

| 配置项 | 值 |
|--------|----|
| 版本文件 | `.claude-plugin/marketplace.json`，路径 `$.metadata.version` |
| Changelog（英文） | `CHANGELOG.md` |
| Changelog（中文） | `CHANGELOG_zh.md` |
| 文档文件 | `README.md`（英文）、`README_zh.md`（中文） |
| 技能目录 | `skills/` |

**检查 Changelog 是否存在**：

```bash
test -f CHANGELOG.md    || echo "CHANGELOG.md 不存在，将在发布时创建"
test -f CHANGELOG_zh.md || echo "CHANGELOG_zh.md 不存在，将在发布时创建"
```

读取当前版本号：

```bash
# 从 marketplace.json 读取
node -e "console.log(require('./.claude-plugin/marketplace.json').metadata.version)"
# 或使用 jq
jq -r '.metadata.version' .claude-plugin/marketplace.json
```

**输出示例**：
```
项目配置：
  版本文件: .claude-plugin/marketplace.json (1.0.0)
  Changelogs:
    - CHANGELOG.md (en)
    - CHANGELOG_zh.md (zh)
```

### Step 2：分析自上次 Tag 以来的 Git 提交

```bash
LAST_TAG=$(git tag --sort=-v:refname | head -1)

# 若无 tag，分析全部提交
if [ -z "$LAST_TAG" ]; then
  git log --oneline
else
  git log ${LAST_TAG}..HEAD --oneline
  git diff ${LAST_TAG}..HEAD --stat
fi
```

按 conventional commit 类型分类：

| 类型 | 说明 | Changelog 中展示 |
|------|------|----------------|
| feat | 新功能 | ✓ |
| fix | Bug 修复 | ✓ |
| docs | 文档更新 | ✓ |
| refactor | 代码重构 | ✓ |
| perf | 性能优化 | ✓ |
| chore | 维护性工作 | ✗（跳过） |
| style | 格式调整 | ✗（跳过） |

**Breaking Change 检测**：
- 提交信息以 `BREAKING CHANGE` 开头
- 提交 body/footer 包含 `BREAKING CHANGE:`

若检测到 Breaking Change，提示用户：「检测到破坏性变更，建议使用 --major 参数。」

### Step 3：确定版本号升级方式

优先级（由高到低）：
1. 用户传入 `--major / --minor / --patch` → 直接使用
2. 检测到 Breaking Change → Major（`1.x.x → 2.0.0`）
3. 存在 `feat:` 提交 → Minor（`1.2.x → 1.3.0`）
4. 其他情况 → Patch（`1.2.3 → 1.2.4`）

显示版本变化：`1.0.0 → 1.1.0`

### Step 4：按 Skill/模块分组变更

分析提交所影响的文件，按如下规则分组：

| 文件路径模式 | 分组归属 |
|-------------|---------|
| `skills/weibo-hot-search-anonymous/*` | `weibo-hot-search-anonymous` |
| `skills/weibo-hot-search/*` | `weibo-hot-search` |
| `skills/<other>/*` | `<other>` |
| `.claude-plugin/marketplace.json` | `project` |
| `README*.md`、`CLAUDE.md`、`scripts/*` | `project` |

**示例分组**：
```
weibo-hot-search-anonymous:
  - fix: 修复 Chrome 调试端口检测逻辑
  - feat: 支持自定义输出路径

project:
  - docs: 更新 README 安装说明
```

### Step 5：逐模块提交代码

对每个分组依次执行：

1. **检查 README 是否需要更新**：
   - 新增参数/选项 → 更新 README.md 和 README_zh.md 中的参数表
   - 用法变更 → 更新用法示例
   - 新功能说明 → 更新功能描述

2. **暂存并提交**：

```bash
# 示例：skill 变更
git add skills/weibo-hot-search-anonymous/
git add README.md README_zh.md   # 若有文档更新
git commit -m "<type>(weibo-hot-search-anonymous): <描述>"

# 示例：项目级变更
git add README.md README_zh.md CLAUDE.md scripts/
git commit -m "docs(project): <描述>"
```

3. **提交信息格式**：`<type>(<scope>): <描述>`
   - `<type>`：feat / fix / refactor / docs / perf
   - `<scope>`：skill 名称或 `project`
   - `<描述>`：简洁明确的变更说明

### Step 6：生成双语 Changelog

分别生成/更新 `CHANGELOG.md`（英文）和 `CHANGELOG_zh.md`（中文）。

**插入位置**：文件头部（保留已有内容）。

**格式**：

```markdown
## {VERSION} - {YYYY-MM-DD}

### Features
- Description of new feature

### Fixes
- Description of fix

### Documentation
- Description of docs changes
```

只输出有变更的章节，空章节省略。

**章节标题对照**：

| 类型 | 英文（CHANGELOG.md） | 中文（CHANGELOG_zh.md） |
|------|---------------------|------------------------|
| feat | Features | 新功能 |
| fix | Fixes | 修复 |
| docs | Documentation | 文档 |
| refactor | Refactor | 重构 |
| perf | Performance | 性能优化 |
| breaking | Breaking Changes | 破坏性变更 |

**双语示例**：

英文（CHANGELOG.md）：
```markdown
## 1.1.0 - 2026-03-12

### Features
- Add custom output path support for weibo-hot-search-anonymous

### Fixes
- Fix Chrome debug port detection logic
```

中文（CHANGELOG_zh.md）：
```markdown
## 1.1.0 - 2026-03-12

### 新功能
- weibo-hot-search-anonymous 支持自定义输出路径

### 修复
- 修复 Chrome 调试端口检测逻辑
```

### Step 7：更新版本号

用新版本号更新 `.claude-plugin/marketplace.json` 中的 `metadata.version`：

```bash
# 使用 jq 更新（推荐）
jq '.metadata.version = "1.1.0"' .claude-plugin/marketplace.json > /tmp/mp.json && mv /tmp/mp.json .claude-plugin/marketplace.json

# 验证
jq -r '.metadata.version' .claude-plugin/marketplace.json
```

同时检查各 skill 的 `SKILL.md` front matter 中的 `version` 字段，如有需要一并更新：

```bash
# 检查 weibo-hot-search-anonymous SKILL.md 版本
grep '^version:' skills/weibo-hot-search-anonymous/SKILL.md
```

### Step 8：用户确认

在创建 Release Commit 前，使用 **AskUserQuestion** 向用户确认两项内容：

1. **版本号选择**（单选）：
   - 推荐版本（含标注）
   - 其他 semver 选项

2. **是否 Push 到远端**（单选）：
   - 「是，提交后立即 push」
   - 「否，仅保留本地」

**确认前展示预览**：
```
已创建提交：
  1. fix(weibo-hot-search-anonymous): 修复 Chrome 调试端口检测逻辑
  2. feat(weibo-hot-search-anonymous): 支持自定义输出路径
  3. docs(project): 更新 README 安装说明

Changelog 预览（英文）：
  ## 1.1.0 - 2026-03-12
  ### Features
  - Add custom output path support for weibo-hot-search-anonymous
  ### Fixes
  - Fix Chrome debug port detection logic

即将创建 Release Commit 和 Tag，请确认。
```

### Step 9：创建 Release Commit 和 Tag

用户确认后执行：

```bash
# 1. 暂存版本文件和 Changelog
git add .claude-plugin/marketplace.json
git add CHANGELOG.md CHANGELOG_zh.md
# 若有 SKILL.md 版本更新
git add skills/*/SKILL.md

# 2. 创建 Release Commit
git commit -m "chore: release v{VERSION}"

# 3. 创建 Tag
git tag v{VERSION}

# 4. 若用户选择 push
git push origin main
git push origin v{VERSION}
```

> **注意**：Release Commit 不添加 Co-Authored-By 行。

**发布完成输出**：
```
发布完成 v1.1.0

提交列表：
  1. fix(weibo-hot-search-anonymous): 修复 Chrome 调试端口检测逻辑
  2. feat(weibo-hot-search-anonymous): 支持自定义输出路径
  3. docs(project): 更新 README 安装说明
  4. chore: release v1.1.0

Tag: v1.1.0
状态: 已推送到 origin  # 或 「仅本地，需要时手动 git push」
```

---

## Dry-Run 模式

`--dry-run` 时仅输出预览，不执行任何 git 操作：

```
=== DRY RUN 模式 ===

当前版本: 1.0.0
建议版本: 1.1.0（含 feat 提交）

变更分组：
  weibo-hot-search-anonymous:
    - feat: 支持自定义输出路径
    - fix: 修复 Chrome 调试端口检测逻辑
    → 提交: feat(weibo-hot-search-anonymous): 支持自定义输出路径
    → 提交: fix(weibo-hot-search-anonymous): 修复 Chrome 调试端口检测逻辑
    → README 更新: 参数表

Changelog 预览（英文）：
  ## 1.1.0 - 2026-03-12
  ### Features
  - Add custom output path support for weibo-hot-search-anonymous
  ### Fixes
  - Fix Chrome debug port detection logic

将创建的提交：
  1. feat(weibo-hot-search-anonymous): 支持自定义输出路径
  2. fix(weibo-hot-search-anonymous): 修复 Chrome 调试端口检测逻辑
  3. chore: release v1.1.0

未执行任何操作，移除 --dry-run 后正式发布。
```

---

## 使用示例

```
/release-skills              # 自动检测版本升级类型
/release-skills --dry-run    # 仅预览，不执行
/release-skills --minor      # 强制 Minor 升级
/release-skills --patch      # 强制 Patch 升级
/release-skills --major      # 强制 Major 升级（需二次确认）
```

---

## 致谢

本 skill 的工作流设计参考了 [baoyu-skills](https://github.com/JimLiu/baoyu-skills) 项目中的 `release-skills`，感谢宝玉老师（[@JimLiu](https://github.com/JimLiu)）的开源贡献与启发。
