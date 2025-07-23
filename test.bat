@echo off
setlocal

echo 正在自动查找 Python 安装路径...
for /f "delims=" %%p in ('where python') do (
    set "PYTHON_EXE_PATH=%%p"
    goto :PythonFound
)

:PythonNotFound
echo 在系统中找不到 python.exe。请确保 Python 已安装并已添加到系统的 PATH 环境变量中。
pause
exit /b

:PythonFound
set "PYTHONW_EXE_PATH=%PYTHON_EXE_PATH:python.exe=pythonw.exe%"
echo 已找到 Python: %PYTHON_EXE_PATH%
echo.

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
echo 已获取管理员权限。
echo.

cd /d "%~dp0"
echo 当前工作目录已设定为: %cd%
set "PROJECT_DIR=%cd%"
echo 项目目录已自动设置为: %PROJECT_DIR%
echo.

echo 正在检查并安装 Python 依赖项 (from requirements.txt)...
if exist "requirements.txt" (
    "%PYTHON_EXE_PATH%" -m pip install -r requirements.txt --upgrade
    echo 依赖项安装完成。
) else (
    echo 未找到 requirements.txt 文件，跳过依赖安装。
)
echo.

set "TEMP_FILE=%TEMP%\selected_path.txt"

echo.
echo Selecting Markdown Directory...
powershell -ExecutionPolicy Bypass -File ".\get-folder.ps1" -Title "Select Markdown Directory" -OutputFile "%TEMP_FILE%"

if exist "%TEMP_FILE%" (
    set /p REPO_PATH=<"%TEMP_FILE%"
    del "%TEMP_FILE%"
)
echo.
echo =================================
echo  Folders Selected:
echo =================================
echo Project Directory: [%PROJECT_DIR%]
echo Markdown Directory: [%REPO_PATH%]
echo.

rem pause

if not defined REPO_PATH (
  echo 未选择仓库目录，退出。
  pause
  exit /b
)

echo 正在生成 run_watcher.bat...
echo @echo off > "%PROJECT_DIR%\run_watcher.bat"
echo rem --- Auto-generated script, do not modify manually --- >> "%PROJECT_DIR%\run_watcher.bat"
echo echo --- Run at %%date%% %%time%% --- ^>^> "%PROJECT_DIR%\watcher_log.txt" >> "%PROJECT_DIR%\run_watcher.bat"
echo cd /d "%PROJECT_DIR%" >> "%PROJECT_DIR%\run_watcher.bat"
echo start "MarkdownWatcherService" "%PYTHONW_EXE_PATH%" "%PROJECT_DIR%\watcher.py" --repo "%REPO_PATH%" >> "%PROJECT_DIR%\run_watcher.bat"
echo echo --- End Run --- ^>^> "%PROJECT_DIR%\watcher_log.txt" >> "%PROJECT_DIR%\run_watcher.bat"
echo echo. ^>^> "%PROJECT_DIR%\watcher_log.txt" >> "%PROJECT_DIR%\run_watcher.bat"

echo run_watcher.bat 已成功创建。
echo.

schtasks /Create ^
  /TN "MarkdownWatcher" ^
  /TR "\"%PROJECT_DIR%\run_watcher.bat\"" ^
  /SC ONLOGON ^
  /RL HIGHEST ^
  /F

if %ERRORLEVEL% equ 0 (
    echo [提示] 已成功创建启动任务，首次立即执行一次：
    "%PYTHON_EXE_PATH%" "%PROJECT_DIR%\watcher.py" --repo "%REPO_PATH%"
) else (
    echo [错误] 任务计划创建失败，代码：%ERRORLEVEL%
)
rem pause