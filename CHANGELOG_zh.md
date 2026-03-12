## 1.1.0 - 2026-03-12

### 新功能
- 热搜词提取对应微博搜索链接，Markdown 输出中标题变为可点击链接

### 文档
- CLAUDE.md 补充版本管理规范说明
- README 新增 skill 版本标注

## 1.0.2 - 2026-03-12

### 新功能
- 新增 Microsoft Edge 浏览器检测支持（macOS、Windows、Linux）

### 修复
- 热搜抓取 URL 切换为 `weibo.com/newlogin?tabtype=search`，提升匿名访问稳定性
- 简化页面导航 URL 判断逻辑，避免不必要的重定向

### 文档
- 新增中英双语 README
- 新增 CLAUDE.md，记录项目架构与开发规范
