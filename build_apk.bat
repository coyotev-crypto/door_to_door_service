@echo off
setlocal enabledelayedexpansion

:: 1. 从 pubspec.yaml 获取应用名称和版本号
for /f "tokens=2 delims=: " %%a in ('findstr /b "name:" pubspec.yaml') do set APP_NAME=%%a
for /f "tokens=2 delims=: " %%a in ('findstr /b "version:" pubspec.yaml') do set FULL_VERSION=%%a
:: 处理版本号中的 + 号 (例如 1.0.0+1 -> 1.0.0)
for /f "tokens=1 delims=+" %%a in ("%FULL_VERSION%") do set VERSION=%%a

:: 2. 获取 Git Commit ID
set COMMIT_ID=nogit
for /f %%a in ('git rev-parse --short HEAD 2^>nul') do set COMMIT_ID=%%a

:: 3. 获取当前日期 (格式: YYYYMMDD)
for /f %%i in ('powershell -Command "Get-Date -Format 'yyyyMMdd'"') do set DATE_STR=%%i

:: 4. 构建 APK 文件名
set APK_NAME=%APP_NAME%_%COMMIT_ID%_v%VERSION%_%DATE_STR%.apk

echo --------------------------------------------------
echo Starting build: %APK_NAME%
echo --------------------------------------------------

:: 5. 执行 Flutter 打包
call flutter build apk --release --tree-shake-icons

:: 6. 检查结果并移动文件
if %ERRORLEVEL% EQU 0 (
    set SOURCE_PATH=build\app\outputs\flutter-apk\app-release.apk
    if exist !SOURCE_PATH! (
        move /y !SOURCE_PATH! .\%APK_NAME%
        echo.
        echo [Success] APK generated: %APK_NAME%
    ) else (
        echo.
        echo [Error] Build success but APK not found at: !SOURCE_PATH!
    )
) else (
    echo.
    echo [Failed] Flutter build failed.
)

echo.
pause
