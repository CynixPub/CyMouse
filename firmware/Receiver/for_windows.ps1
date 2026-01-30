# 强制开启 UTF8 输出，防止中文显示乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ================= 配置区 =================
$FILES = @{
    "full" = "CyMouse_Receiver_firmware.bin"  # 接收端全量固件
}

$esptool = ".\esptool.exe"
# ==========================================

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "      CyMouse 接收端(Receiver) 固件工具 v1.0" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. 扫描并选择串口
$ports = [System.IO.Ports.SerialPort]::GetPortNames()
$pnpDevices = Get-PnpDevice -PresentOnly | Where-Object { $_.Class -eq "Ports" }

if ($ports.Count -eq 0) {
    Write-Host "[错误] 未发现任何串口设备，请检查连接。" -ForegroundColor Red
    Pause
    exit
}

Write-Host "`n[1] 发现以下串口设备:" -ForegroundColor Yellow
$portList = @()
for ($i = 0; $i -lt $ports.Count; $i++) {
    $devName = $ports[$i]
    $friendlyName = ($pnpDevices | Where-Object { $_.Caption -match "\($devName\)" }).Caption
    $typeHint = "USB"
    if ($friendlyName -match "CH340" -or $friendlyName -match "USB-SERIAL" -or $friendlyName -match "串口") { $typeHint = "COM" }
    Write-Host (" {0}. {1} - {2} [建议模式: {3}]" -f ($i+1), $devName, $friendlyName, $typeHint)
    $portList += [PSCustomObject]@{ Device = $devName; Hint = $typeHint }
}

$portIdx = Read-Host "`n请选择串口编号"
$selectedPort = $portList[$portIdx - 1].Device
$suggestedType = $portList[$portIdx - 1].Hint

# 2. 选择烧录模式
Write-Host "`n[2] 选择烧录模式 (当前建议: $suggestedType):" -ForegroundColor Yellow
Write-Host " 1. USB 模式 (针对内置 USB-Serial/JTAG, 使用 usb_reset)"
Write-Host " 2. COM 模式 (针对外部 CH340, 使用 default_reset)"
$modeChoice = Read-Host "请输入编号 (直接回车按建议模式)"
if ($modeChoice -eq "") { $modeChoice = if ($suggestedType -eq "USB") { "1" } else { "2" } }
$beforeMode = if ($modeChoice -eq "1") { "usb_reset" } else { "default_reset" }

# 定义基础参数
$baseArgs = @("--chip", "esp32s3", "--port", $selectedPort, "--baud", "460800", "--before", $beforeMode)

# 3. 进入主功能循环
do {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " 当前端口: $selectedPort | 模式: $beforeMode " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "`n[接收端菜单] 请选择操作功能:" -ForegroundColor Yellow
    Write-Host " 1. 接收端全刷 (写入 0x0 地址)"
    Write-Host " 2. 全片擦除"
    Write-Host " 0. 退出脚本"
    Write-Host "--------------------------------------------------"
    $func = Read-Host "请输入功能编号"

    if ($func -eq "0") { break }

    Write-Host "`n>>> 正在准备执行命令..." -ForegroundColor Gray
    
    try {
        switch ($func) {
            "1" { 
                # 检查文件是否存在
                if (-not (Test-Path $FILES.full)) { throw "找不到文件: $($FILES.full)" }
                $args = $baseArgs + @("--after", "hard_reset", "write_flash", "0x0", $FILES.full)
                & $esptool $args 
            }
            "2" { 
                $confirm = Read-Host "确定要全片擦除吗？(y/n)"
                if ($confirm -eq "y") { 
                    $args = $baseArgs + @("erase_flash")
                    & $esptool $args 
                }
            }
            Default { Write-Host "无效输入，请重新选择。" -ForegroundColor Yellow }
        }
        Write-Host "`n[操作完成]" -ForegroundColor Green
    }
    catch {
        Write-Host "`n[系统错误] " + $_.Exception.Message -ForegroundColor Red
    }

    Write-Host "`n按回车键返回主菜单..."
    $null = Read-Host
} while ($true)

Write-Host "`n正在退出..."
Start-Sleep -Seconds 1