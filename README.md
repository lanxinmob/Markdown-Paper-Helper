# Paper Link Formatter

一个命令行工具，可以自动扫描 Markdown 文件，查找 arXiv 链接，并将其替换为包含标题、作者和引用数的规范化格式。

## 功能
- 使用 Git 自动检测已修改的 Markdown 文件。
- 从文件中提取 arXiv 链接。
- 调用 Semantic Scholar API 获取论文元数据。
- 自动将裸露的 URL 替换为 `[标题 - 作者](链接) (引用数)` 的格式。

## 安装
1. 克隆本仓库：
   `git clone https://github.com/your-username/paper-formatter.git`
2. 进入项目目录：
   `cd paper-formatter`
3. 安装依赖：
   `pip install -r requirements.txt`

## 使用方法
直接在终端中运行脚本，并将 Markdown 文件路径作为参数传入：

# 只格式化链接，不下载 PDF
python format_papers.py "D:/poem/"

# 格式化链接，并且下载 PDF
python format_papers.py "D:/poem/" --download