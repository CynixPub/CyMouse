@echo off
setlocal enabledelayedexpansion
title CyMouse Firmware Tool v1.0
cd /d %~dp0

:: ================= 配置区 =================
set FILE_FULL=CyMouse_Main_firmware.bin
set FILE_UPDATE=CyMouse_Main_update_firmware.bin
set FILE_NVS=backup_nvs.bin
set FILE_FS=backup_littlefs.bin

set ADDR_NVS=0x9000
set SIZE_NVS=0x4000
set ADDR_APP=0x10000
set ADDR_FS=0x290000
set SIZE_FS=0x160000

set ESPTOOL=esptool.exe
set "TEMP_PORT_LIST=%temp%\cymouse_ports.txt"
:: ==========================================

:START
cls
echo ==================================================
echo          CyMouse 固件维护工具 v1.0
echo ==================================================
echo.

echo [1] 正在扫描串口...
echo --------------------------------------------------

:: 清理旧文件
if exist "%TEMP_PORT_LIST%" del "%TEMP_PORT_LIST%"

:: 生成列表
powershell -NoProfile -Command "$list = @(Get-PnpDevice -PresentOnly -Class Ports | Sort-Object Name); if($list.Count -eq 0) { Write-Host '  未发现串口' -F Red } else { $i=1; foreach($item in $list) { $pName='UNKNOWN'; if($item.FriendlyName -match '\((COM\d+)\)') { $pName=$matches[1] }; Write-Host ('  {0}. {1}' -f $i, $item.FriendlyName); $pName | Out-File -FilePath '%TEMP_PORT_LIST%' -Append -Encoding ASCII; $i++ } }"

echo --------------------------------------------------
echo.

if not exist "%TEMP_PORT_LIST%" (
    echo [ERROR] 未扫描到有效串口。
    echo 请检查连接后重试。
    pause
    goto START
)

set /p PORT_IDX="请输入序号 (直接回车刷新): "
if "%PORT_IDX%"=="" goto START

set SELECTED_PORT=
set CURR_LINE=0

:: 读取文件
for /f "usebackq delims=" %%a in ("%TEMP_PORT_LIST%") do (
    set /a CURR_LINE+=1
    if "!CURR_LINE!"=="%PORT_IDX%" (
        set SELECTED_PORT=%%a
    )
)

if exist "%TEMP_PORT_LIST%" del "%TEMP_PORT_LIST%"

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
echo  1. 备份 NVS
echo  2. 备份 LittleFS
echo  3. 恢复 NVS
echo  4. 恢复 LittleFS
echo  5. 完全重刷 (0x0)
echo  6. 固件升级 (App)
echo  7. 全片擦除
echo  8. 重新选择串口
echo  0. 退出
echo.
echo --------------------------------------------------
set /p FUNC="请输入功能编号: "

if "%FUNC%"=="0" goto EXIT
if "%FUNC%"=="1" goto BACKUP_NVS
if "%FUNC%"=="2" goto BACKUP_FS
if "%FUNC%"=="3" goto RESTORE_NVS
if "%FUNC%"=="4" goto RESTORE_FS
if "%FUNC%"=="5" goto FLASH_FULL
if "%FUNC%"=="6" goto FLASH_UPDATE
if "%FUNC%"=="7" goto ERASE_CHIP
if "%FUNC%"=="8" goto START

echo 无效输入。
pause
goto MENU

:: ================= 功能执行区 =================
:BACKUP_NVS
%BASE_CMD% read_flash %ADDR_NVS% %SIZE_NVS% %FILE_NVS%
goto END_OP

:BACKUP_FS
%BASE_CMD% read_flash %ADDR_FS% %SIZE_FS% %FILE_FS%
goto END_OP

:RESTORE_NVS
if not exist "%FILE_NVS%" ( echo [ERROR] 缺文件: %FILE_NVS% & pause & goto MENU )
%BASE_CMD% write_flash %ADDR_NVS% %FILE_NVS%
goto END_OP

:RESTORE_FS
if not exist "%FILE_FS%" ( echo [ERROR] 缺文件: %FILE_FS% & pause & goto MENU )
%BASE_CMD% write_flash %ADDR_FS% %FILE_FS%
goto END_OP

:FLASH_FULL
if not exist "%FILE_FULL%" ( echo [ERROR] 缺文件: %FILE_FULL% & pause & goto MENU )
%BASE_CMD% --after hard_reset write_flash 0x0 %FILE_FULL%
goto END_OP

:FLASH_UPDATE
if not exist "%FILE_UPDATE%" ( echo [ERROR] 缺文件: %FILE_UPDATE% & pause & goto MENU )
%BASE_CMD% --after hard_reset write_flash %ADDR_APP% %FILE_UPDATE%
goto END_OP

:ERASE_CHIP
set /p CONFIRM="警告: 确定要全片擦除吗？(y/n): "
if /i not "%CONFIRM%"=="y" goto MENU
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