---
name: release-skills
description: xm-skills 项目专用发布工作流。分析 Git 提交、推荐版本号、更新 VERSION / SKILL_VERSIONS.md / marketplace.json / SKILL.md、生成双语 Changelog、提交打 Tag 并同步 clawhub。当用户说 "release"、"发布"、"新版本"、"bump version"、"push"、"推送" 时使用。
---

# Release Skills（xm-skills 专用）

xm-skills 项目的一键发布工作流，维护三层版本体系并自动同步 clawhub。

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

## 版本文件说明

| 文件 | 说明 |
|------|------|
| `VERSION` | 项目整体版本，单一来源 |
| `SKILL_VERSIONS.md` | 各 skill 独立版本总表 |
| `skills/<name>/SKILL.md` → `version` | 单个 skill 版本，与总表同步 |
| `.claude-plugin/marketplace.json` → `metadata.version` | 跟随 `VERSION` 同步 |

---

## 工作流

### Step 1：读取当前版本状态

```bash
# 项目版本
cat VERSION

# 各 skill 当前版本
cat SKILL_VERSIONS.md

# 验证 marketplace.json 与 VERSION 一致
jq -r '.metadata.version' .claude-plugin/marketplace.json
```

**检查 Changelog 文件**：

```bash
test -f CHANGELOG.md    || echo "CHANGELOG.md 不存在，将在发布时创建"
test -f CHANGELOG_zh.md || echo "CHANGELOG_zh.md 不存在，将在发布时创建"
```

**输出示例**：
```
当前版本：
  项目版本 (VERSION):     1.0.2
  marketplace.json:       1.0.2 ✓

Skill 版本（SKILL_VERSIONS.md）：
  weibo-hot-search-anonymous  1.0.2  2026-03-12
```

### Step 2：分析自上次 Tag 以来的 Git 提交

```bash
LAST_TAG=$(git tag --sort=-v:refname | head -1)

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
| chore | 维护性工作 | ✗ |
| style | 格式调整 | ✗ |

若检测到 Breaking Change（提交信息含 `BREAKING CHANGE`），提示用户建议使用 `--major`。

### Step 3：按 Skill/模块分组变更

分析提交影响的文件，按路径分组：

| 文件路径模式 | 分组归属 |
|-------------|---------|
| `skills/weibo-hot-search-anonymous/*` | `weibo-hot-search-anonymous` |
| `skills/<other>/*` | `<other>` |
| `VERSION`、`SKILL_VERSIONS.md`、`.claude-plugin/*`、`README*.md`、`CLAUDE.md`、`scripts/*` | `project` |

### Step 4：推荐版本号

#### 4.1 各 skill 版本推荐

对每个有变更的 skill，基于其变更类型推荐新版本：

| 变更类型 | 递增方式 |
|---------|---------|
| Breaking Change | Major |
| feat | Minor |
| fix / docs / refactor | Patch |

无变更的 skill **版本不动**。

#### 4.2 项目版本推荐（VERSION）

取所有变更 skill 中**最高升级幅度**：

```
示例：
  weibo-hot-search-anonymous: fix → Patch
  → 项目版本: 1.0.2 → 1.0.3（推荐）

  weibo-hot-search-anonymous: feat
  → 项目版本: 1.0.2 → 1.1.0（推荐）

  skill-a: feat + skill-b: fix
  → 项目版本: 取 feat 的 Minor 升级（推荐）
```

用户可通过 `--major/--minor/--patch` 覆盖推荐值。

### Step 5：逐模块提交代码

对每个 skill 分组依次执行：

1. **检查 README 是否需要更新**（新增参数、用法变更、新功能说明）
2. **暂存并提交**：

```bash
# skill 变更
git add skills/<skill-name>/
git add README.md README_zh.md   # 若有文档更新
git commit -m "<type>(<skill-name>): <描述>"

# project 级变更
git add README.md README_zh.md CLAUDE.md scripts/
git commit -m "docs(project): <描述>"
```

提交信息格式：`<type>(<scope>): <描述>`

### Step 6：生成双语 Changelog

分别更新 `CHANGELOG.md`（英文）和 `CHANGELOG_zh.md`（中文），**插入文件头部**，保留已有内容。

**格式**：

```markdown
## {VERSION} - {YYYY-MM-DD}

### Features
- Description of new feature

### Fixes
- Description of fix
```

只输出有变更的章节。

**章节标题对照**：

| 类型 | 英文 | 中文 |
|------|------|------|
| feat | Features | 新功能 |
| fix | Fixes | 修复 |
| docs | Documentation | 文档 |
| refactor | Refactor | 重构 |
| perf | Performance | 性能优化 |
| breaking | Breaking Changes | 破坏性变更 |

### Step 7：更新所有版本文件

按以下顺序更新，确保一致性：

#### 7.1 更新 VERSION（项目整体版本）

```bash
echo "<new-version>" > VERSION
cat VERSION  # 验证
```

#### 7.2 更新 SKILL_VERSIONS.md（skill 版本总表）

只更新**有变更**的 skill 行，格式：

```markdown
| [<skill-name>](./skills/<skill-name>/) | <new-version> | <YYYY-MM-DD> | <一句话变更摘要> |
```

无变更的 skill 行**保持不动**。

**操作示例**（用文本编辑，不要用 sed 替换整行，避免破坏表格其他列）：
- 读取 SKILL_VERSIONS.md
- 找到对应 skill 行，更新 Version 和 Last Updated 列
- 写回文件

#### 7.3 更新各 skill 的 SKILL.md version 字段

仅对有变更的 skill 执行：

```bash
sed -i'' "s/^version: .*/version: <new-skill-version>/" skills/<skill-name>/SKILL.md
grep '^version:' skills/<skill-name>/SKILL.md  # 验证
```

#### 7.4 同步 marketplace.json 版本（跟随 VERSION）

```bash
NEW_VERSION=$(cat VERSION)
jq --arg v "$NEW_VERSION" '.metadata.version = $v' .claude-plugin/marketplace.json \
  > /tmp/mp.json && mv /tmp/mp.json .claude-plugin/marketplace.json
jq -r '.metadata.version' .claude-plugin/marketplace.json  # 验证
```

### Step 8：用户确认

展示完整预览后，用 **AskUserQuestion** 确认两项：

1. **版本号**（单选）：推荐版本 + 其他 semver 选项
2. **Push 策略**（单选）：立即 push / 仅本地

**确认前预览格式**：

```
已创建提交：
  1. fix(weibo-hot-search-anonymous): 修复热搜 URL 判断逻辑
  2. docs(project): 更新双语 README

版本变更：
  VERSION:                             1.0.2 → 1.0.3（推荐，含 fix）
  weibo-hot-search-anonymous SKILL.md: 1.0.2 → 1.0.3
  SKILL_VERSIONS.md:                   已更新 weibo-hot-search-anonymous 行
  marketplace.json:                    1.0.2 → 1.0.3（跟随 VERSION）

Changelog 预览（英文）：
  ## 1.0.3 - 2026-03-12
  ### Fixes
  - Fix hot search URL navigation check

即将创建 Release Commit 和 Tag v1.0.3，请确认。
```

### Step 9：创建 Release Commit 和 Tag

用户确认后执行：

```bash
# 1. 暂存所有版本文件和 Changelog
git add VERSION
git add SKILL_VERSIONS.md
git add .claude-plugin/marketplace.json
git add CHANGELOG.md CHANGELOG_zh.md
git add skills/*/SKILL.md   # 有变更的 skill

# 2. Release Commit
git commit -m "chore: release v$(cat VERSION)"

# 3. Tag
git tag "v$(cat VERSION)"

# 4. Push（若用户选择）
git push origin main
git push origin "v$(cat VERSION)"
```

> **注意**：Release Commit 不添加 Co-Authored-By 行。

### Step 10：同步 clawhub

Push 完成（或用户选择仅本地）后，执行 clawhub 同步：

```bash
bash scripts/sync-clawhub.sh
```

若 clawhub sync 失败，提示用户手动执行，不阻断发布流程。

**发布完成输出**：

```
发布完成 v1.0.3

提交列表：
  1. fix(weibo-hot-search-anonymous): 修复热搜 URL 判断逻辑
  2. docs(project): 更新双语 README
  3. chore: release v1.0.3

版本快照：
  项目版本 (VERSION):             1.0.3
  weibo-hot-search-anonymous:     1.0.3
  marketplace.json:               1.0.3

Tag:     v1.0.3
状态:    已推送到 origin
clawhub: 同步完成
```

---

## Dry-Run 模式

`--dry-run` 时只输出预览，不执行任何写入或 git 操作：

```
=== DRY RUN 模式 ===

当前版本：
  VERSION: 1.0.2
  weibo-hot-search-anonymous: 1.0.2

分析结果：
  weibo-hot-search-anonymous:
    - fix: 修复热搜 URL 判断逻辑
    → skill 版本: 1.0.2 → 1.0.3（Patch）
    → 提交: fix(weibo-hot-search-anonymous): 修复热搜 URL 判断逻辑

推荐版本：1.0.2 → 1.0.3

将更新的文件：
  VERSION:              1.0.3
  SKILL_VERSIONS.md:    weibo-hot-search-anonymous 1.0.2 → 1.0.3
  skills/weibo-hot-search-anonymous/SKILL.md: version 1.0.3
  marketplace.json:     1.0.3
  CHANGELOG.md:         新增 ## 1.0.3 段落
  CHANGELOG_zh.md:      新增 ## 1.0.3 段落

未执行任何操作，移除 --dry-run 后正式发布。
```

---

## 使用示例

```
/release-skills              # 自动推荐版本
/release-skills --dry-run    # 仅预览，不执行
/release-skills --minor      # 强制 Minor 升级
/release-skills --patch      # 强制 Patch 升级
/release-skills --major      # 强制 Major 升级（需二次确认）
```

---

## 致谢

本 skill 的工作流设计参考了 [baoyu-skills](https://github.com/JimLiu/baoyu-skills) 项目中的 `release-skills`，感谢宝玉老师（[@JimLiu](https://github.com/JimLiu)）的开源贡献与启发。
