@echo off
setlocal

echo �����Զ����� Python ��װ·��...
for /f "delims=" %%p in ('where python') do (
    set "PYTHON_EXE_PATH=%%p"
    goto :PythonFound
)

:PythonNotFound
echo ��ϵͳ���Ҳ��� python.exe����ȷ�� Python �Ѱ�װ������ӵ�ϵͳ�� PATH ���������С�
pause
exit /b

:PythonFound
set "PYTHONW_EXE_PATH=%PYTHON_EXE_PATH:python.exe=pythonw.exe%"
echo ���ҵ� Python: %PYTHON_EXE_PATH%
echo.

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo �����������ԱȨ��...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
echo �ѻ�ȡ����ԱȨ�ޡ�
echo.

cd /d "%~dp0"
echo ��ǰ����Ŀ¼���趨Ϊ: %cd%
set "PROJECT_DIR=%cd%"
echo ��ĿĿ¼���Զ�����Ϊ: %PROJECT_DIR%
echo.

echo ���ڼ�鲢��װ Python ������ (from requirements.txt)...
if exist "requirements.txt" (
    "%PYTHON_EXE_PATH%" -m pip install -r requirements.txt --upgrade
    echo �����װ��ɡ�
) else (
    echo δ�ҵ� requirements.txt �ļ�������������װ��
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
  echo δѡ��ֿ�Ŀ¼���˳���
  pause
  exit /b
)

echo �������� run_watcher.bat...
echo @echo off > "%PROJECT_DIR%\run_watcher.bat"
echo rem --- Auto-generated script, do not modify manually --- >> "%PROJECT_DIR%\run_watcher.bat"
echo echo --- Run at %%date%% %%time%% --- ^>^> "%PROJECT_DIR%\watcher_log.txt" >> "%PROJECT_DIR%\run_watcher.bat"
echo cd /d "%PROJECT_DIR%" >> "%PROJECT_DIR%\run_watcher.bat"
echo start "MarkdownWatcherService" "%PYTHONW_EXE_PATH%" "%PROJECT_DIR%\watcher.py" --repo "%REPO_PATH%" >> "%PROJECT_DIR%\run_watcher.bat"
echo echo --- End Run --- ^>^> "%PROJECT_DIR%\watcher_log.txt" >> "%PROJECT_DIR%\run_watcher.bat"
echo echo. ^>^> "%PROJECT_DIR%\watcher_log.txt" >> "%PROJECT_DIR%\run_watcher.bat"

echo run_watcher.bat �ѳɹ�������
echo.

schtasks /Create ^
  /TN "MarkdownWatcher" ^
  /TR "\"%PROJECT_DIR%\run_watcher.bat\"" ^
  /SC ONLOGON ^
  /RL HIGHEST ^
  /F

if %ERRORLEVEL% equ 0 (
    echo [��ʾ] �ѳɹ��������������״�����ִ��һ�Σ�
    "%PYTHON_EXE_PATH%" "%PROJECT_DIR%\watcher.py" --repo "%REPO_PATH%"
) else (
    echo [����] ����ƻ�����ʧ�ܣ����룺%ERRORLEVEL%
)
rem pause