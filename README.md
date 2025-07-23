# Paper Link Formatter
- 一个简单的工具，可以扫描指定目录下的 Markdown 文件，查找 arXiv 链接，并将其替换为包含标题、作者和引用数等的规范化格式。

## 功能
- 从文件中提取裸露的 arXiv.org 链接。

- 调用 Semantic Scholar API 获取论文元数据（标题、作者、引用数）。

- 自动将链接替换为 [标题 - 作者](链接) (引用数) [PDF](本地路径)的格式。

- 自动下载链接对应的 PDF 文件。

## 使用方法
- 下载`release`

- 运行`run.bat`，出现弹窗选择你的笔记仓库路径。

