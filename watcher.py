import time
import os
import argparse
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from test import format_and_process_links_in_file

class MarkdownEventHandler(FileSystemEventHandler):
    """一个只响应 Markdown 文件修改的事件处理器。"""   
    def _is_valid_file(self, event):
        """检查事件是否是有效的、非临时/隐藏的 Markdown 文件。"""
        if event.is_directory:
            return False
        filename = os.path.basename(event.src_path)
        if filename.startswith('.~'):
            return False
        if not event.src_path.endswith('.md'):
            return False
        return True

    def on_modified(self, event):
        """当文件被修改时调用。"""
        if self._is_valid_file(event):
            print(f"\n检测到文件被修改: {event.src_path}")
            try:
                time.sleep(1) 
                format_and_process_links_in_file(event.src_path, download=True)
            except Exception as e:
                print(f"处理文件 {event.src_path} 时发生异常: {e}")

    def on_created(self, event):
        """当文件被创建时调用。"""
        if self._is_valid_file(event):
            print(f"\n检测到新文件被创建: {event.src_path}")
            try:
                time.sleep(1)
                format_and_process_links_in_file(event.src_path, download=True)
            except Exception as e:
                print(f"处理文件 {event.src_path} 时发生异常: {e}")

def main():
    """主函数，启动监控服务。"""
    parser = argparse.ArgumentParser(description="持续监控指定目录中的 Markdown 文件变化，并自动处理。")
    parser.add_argument('--repo', dest='repo_path', required=True, help="需要监控的 Git 仓库（Markdown 笔记）的路径。")
    args = parser.parse_args()

    repo_path = args.repo_path
    if not os.path.isdir(repo_path):
        print(f" 指定的路径 '{repo_path}' 不是一个有效的目录。")
        return

    event_handler = MarkdownEventHandler()
    observer = Observer()
    observer.schedule(event_handler, repo_path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n--- 监控服务已停止 ---")
        observer.stop()
    observer.join()

if __name__ == '__main__':
    main()
