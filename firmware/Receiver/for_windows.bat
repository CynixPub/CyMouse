@echo off
setlocal enabledelayedexpansion
title CyMouse Receiver Firmware Tool v1.0
cd /d %~dp0

:: ================= 配置区 =================
:: 接收端固件文件名
set FILE_RECV=CyMouse_Receiver_firmware.bin

set ESPTOOL=esptool.exe
set "TEMP_PORT_LIST=%temp%\cymouse_recv_ports.txt"
:: ==========================================

:START
cls
echo ==================================================
echo       CyMouse 接收端(Receiver) 固件工具 v1.0
echo ==================================================
echo.

echo [1] 正在扫描串口...
echo --------------------------------------------------

:: 清理旧文件
if exist "%TEMP_PORT_LIST%" del "%TEMP_PORT_LIST%"

:: 使用 PowerShell 生成列表和文件
powershell -NoProfile -Command "$list = @(Get-PnpDevice -PresentOnly -Class Ports | Sort-Object Name); if($list.Count -eq 0) { Write-Host '  未发现串口' -F Red } else { $i=1; foreach($item in $list) { $pName='UNKNOWN'; if($item.FriendlyName -match '\((COM\d+)\)') { $pName=$matches[1] }; Write-Host ('  {0}. {1}' -f $i, $item.FriendlyName); $pName | Out-File -FilePath '%TEMP_PORT_LIST%' -Append -Encoding ASCII; $i++ } }"

echo --------------------------------------------------
echo.

:: 检查文件是否存在
if not exist "%TEMP_PORT_LIST%" (
    echo [ERROR] 未扫描到有效串口。
    echo 请检查连接后重试。
    pause
    goto START
)

:: 获取用户输入
set /p PORT_IDX="请输入序号 (直接回车刷新): "
if "%PORT_IDX%"=="" goto START

set SELECTED_PORT=
set CURR_LINE=0

:: 读取文件，匹配行号
for /f "usebackq delims=" %%a in ("%TEMP_PORT_LIST%") do (
    set /a CURR_LINE+=1
    if "!CURR_LINE!"=="%PORT_IDX%" (
        set SELECTED_PORT=%%a
    )
)

:: 清理文件
if exist "%TEMP_PORT_LIST%" del "%TEMP_PORT_LIST%"

:: 验证结果
if "%SELECTED_PORT%"=="" (
    echo.
    echo [ERROR] 序号无效，请重新选择。
    pause
    goto START
)

echo.
echo [OK] 已锁定端口: %SELECTED_PORT%
echo.

:: --------------------------------------------------------
:: 2. 模式选择
:: --------------------------------------------------------
echo [2] 选择烧录模式:
echo     1. USB 模式 (针对 S3 内置 USB, 使用 usb_reset)
echo     2. COM 模式 (针对外部 CH340, 使用 default_reset)
echo.
set /p MODE_INPUT="请输入选择 (默认 1): "
if "%MODE_INPUT%"=="" set MODE_INPUT=1

if "%MODE_INPUT%"=="1" (
    set RESET_MODE=usb_reset
) else (
    set RESET_MODE=default_reset
)

set BASE_CMD=%ESPTOOL% --chip esp32s3 --port %SELECTED_PORT% --baud 460800 --before %RESET_MODE%

:MENU
cls
echo ==================================================
echo  当前端口: %SELECTED_PORT%  /  模式: %RESET_MODE%
echo ==================================================
echo.
echo  1. 接收端全刷 (写入 0x0 地址)
echo  2. 全片擦除
echo  8. 重新选择串口
echo  0. 退出
echo.
echo --------------------------------------------------
set /p FUNC="请输入功能编号: "

if "%FUNC%"=="0" goto EXIT
if "%FUNC%"=="1" goto FLASH_RECV
if "%FUNC%"=="2" goto ERASE_CHIP
if "%FUNC%"=="8" goto START

echo 无效输入。
pause
goto MENU

:: ================= 功能执行区 =================

:FLASH_RECV
if not exist "%FILE_RECV%" ( echo [ERROR] 缺文件: %FILE_RECV% & pause & goto MENU )
echo.
echo 正在烧录接收端固件...
%BASE_CMD% --after hard_reset write_flash 0x0 %FILE_RECV%
goto END_OP

:ERASE_CHIP
echo.
set /p CONFIRM="警告: 确定要全片擦除吗？(y/n): "
if /i not "%CONFIRM%"=="y" goto MENU
echo 正在执行全片擦除...
%BASE_CMD% erase_flash
goto END_OP

:END_OP
if %errorlevel% neq 0 ( echo. & echo [ERROR] 操作失败! ) else ( echo. & echo [SUCCESS] 操作成功! )
echo.
pause
goto MENU

:EXIT
if exist "%TEMP_PORT_LIST%" del "%TEMP_PORT_LIST%"
exit