#!/bin/bash

# ================= 配置区 =================
declare -A FILES=(
    ["full"]="CyMouse_Main_firmware.bin"
    ["update"]="CyMouse_Main_update_firmware.bin"
    ["nvs"]="backup_nvs.bin"
    ["littlefs"]="backup_littlefs.bin"
)

declare -A ADDR=(
    ["nvs"]="0x9000"
    ["nvs_size"]="0x4000"
    ["app"]="0x10000"
    ["littlefs"]="0x290000"
    ["littlefs_size"]="0x160000"
)
# ==========================================

# 颜色定义
RED='\033[0.31m'
GREEN='\033[0.32m'
YELLOW='\033[0.33m'
NC='\033[0m' 

# 1. 环境检查
check_env() {
    echo -e "${YELLOW}[环境检查]${NC}"
    
    # 检查 esptool 命令是否可用
    if command -v esptool &> /dev/null; then
        ESP_CMD="esptool"
    elif command -v esptool.py &> /dev/null; then
        ESP_CMD="esptool.py"
    else
        echo -e "${YELLOW}未检测到 esptool，尝试通过 apt 自动安装...${NC}"
        sudo apt update && sudo apt install -y esptool
        
        if [ $? -eq 0 ]; then
            ESP_CMD="esptool"
        else
            echo -e "${YELLOW}apt 安装失败，尝试通过 pip3 安装...${NC}"
            if ! command -v pip3 &> /dev/null; then
                sudo apt install -y python3-pip
            fi
            pip3 install esptool || python3 -m pip install esptool
            ESP_CMD="python3 -m esptool"
        fi
    fi
    
    # 最终确认
    if ! $ESP_CMD version &> /dev/null; then
        echo -e "${RED}错误: 无法启动 esptool。请手动执行 sudo apt install esptool${NC}"
        exit 1
    fi
    echo -e "${GREEN}环境就绪: 使用 $ESP_CMD${NC}"
}

# 2. 串口扫描
select_port() {
    echo -e "\n${YELLOW}[1] 扫描串口设备:${NC}"
    # 扫描 USB 转串口和 S3 原生 USB
    ports=($(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null))
    
    if [ ${#ports[@]} -eq 0 ]; then
        echo -e "${RED}错误: 未发现串口设备！${NC}"
        echo -e "提示: 1. 确保设备已连接"
        echo -e "      2. 权限不足？请运行: sudo usermod -a -G dialout \$USER && reboot${NC}"
        exit 1
    fi

    for i in "${!ports[@]}"; do
        hint="[COM]"
        if [[ "${ports[$i]}" == *"/dev/ttyACM"* ]]; then hint="[USB/JTAG]"; fi
        echo -e " $((i+1)). ${ports[$i]} $hint"
    done

    read -p "请选择串口编号: " port_idx
    SELECTED_PORT=${ports[$((port_idx-1))]}
}

# 3. 模式选择
select_mode() {
    echo -e "\n${YELLOW}[2] 选择烧录模式:${NC}"
    echo " 1. USB 模式 (针对内置 USB-Serial, 使用 usb_reset)"
    echo " 2. COM 模式 (针对外部 CH340, 使用 default_reset)"
    read -p "请输入选择 [默认 1]: " m_choice
    m_choice=${m_choice:-1}
    
    BEFORE="usb_reset"
    [ "$m_choice" == "2" ] && BEFORE="default_reset"
}

# 执行初始化
check_env
select_port
select_mode

BASE_ARGS="--chip esp32s3 --port $SELECTED_PORT --baud 460800 --before $BEFORE"

# 4. 主循环菜单
while true; do
    clear
    echo -e "${GREEN}==================================================${NC}"
    echo -e "      CyMouse Linux 维护工具 | 端口: $SELECTED_PORT"
    echo -e "${GREEN}==================================================${NC}"
    echo " 1. 备份 NVS (配置数据)"
    echo " 2. 备份 LittleFS (文件系统)"
    echo " 3. 恢复 NVS"
    echo " 4. 恢复 LittleFS"
    echo " 5. 完全重刷 (从 0x0 写入合并包)"
    echo " 6. 固件升级 (仅更新 App 区域)"
    echo " 7. 全片擦除"
    echo " 0. 退出脚本"
    echo "--------------------------------------------------"
    read -p "请输入功能编号: " func

    # 检查文件是否存在逻辑
    check_file() {
        if [ ! -f "$1" ]; then
            echo -e "${RED}错误: 找不到文件 $1，请确保它在脚本同级目录下。${NC}"
            return 1
        fi
        return 0
    }

    case $func in
        1) $ESP_CMD $BASE_ARGS read_flash ${ADDR[nvs]} ${ADDR[nvs_size]} ${FILES[nvs]} ;;
        2) $ESP_CMD $BASE_ARGS read_flash ${ADDR[littlefs]} ${ADDR[littlefs_size]} ${FILES[littlefs]} ;;
        3) check_file ${FILES[nvs]} && $ESP_CMD $BASE_ARGS write_flash ${ADDR[nvs]} ${FILES[nvs]} ;;
        4) check_file ${FILES[littlefs]} && $ESP_CMD $BASE_ARGS write_flash ${ADDR[littlefs]} ${FILES[littlefs]} ;;
        5) check_file ${FILES[full]} && $ESP_CMD $BASE_ARGS --after hard_reset write_flash 0x0 ${FILES[full]} ;;
        6) check_file ${FILES[update]} && $ESP_CMD $BASE_ARGS --after hard_reset write_flash ${ADDR[app]} ${FILES[update]} ;;
        7) read -p "确定要全片擦除吗？(y/n): " conf
           if [ "$conf" == "y" ]; then $ESP_CMD $BASE_ARGS erase_flash; fi ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选择${NC}" ;;
    esac

    echo -e "\n${GREEN}[操作结束] 按回车键返回菜单...${NC}"
    read
done