import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import subprocess
import argparse
import os

class MarkdownChangeHandler(FileSystemEventHandler):
    def __init__(self, repo_path):
        self.repo_path = repo_path

    def on_modified(self, event):
        if event.src_path.endswith('.md'):
            print(f"\n 检测到修改: {event.src_path}\n 正在执行脚本...\n")
            subprocess.run(['python', 'test.py', '--repo', self.repo_path])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=str, required=True, help='Path to markdown repo')
    args = parser.parse_args()

    event_handler = MarkdownChangeHandler(args.repo)
    observer = Observer()
    observer.schedule(event_handler, path=args.repo, recursive=True)
    observer.start()
    print(f" 正在监听目录 {args.repo} 中的 Markdown 文件变化...(Ctrl+C 可停止)")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

if __name__ == "__main__":
    main()
