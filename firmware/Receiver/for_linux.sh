#!/bin/bash

# ================= 配置区 =================
declare -A FILES=(
    ["full"]="CyMouse_Receiver_firmware.bin"  # 接收端全量固件
)

# 颜色定义
RED='\033[0.31m'
GREEN='\033[0.32m'
YELLOW='\033[0.33m'
CYAN='\033[0.36m'
NC='\033[0m' # No Color

# ==========================================

# 1. 环境检查 (自动识别 esptool)
check_env() {
    echo -e "${YELLOW}[环境检查]${NC}"
    
    # 优先检查系统命令
    if command -v esptool &> /dev/null; then
        ESP_CMD="esptool"
    elif command -v esptool.py &> /dev/null; then
        ESP_CMD="esptool.py"
    else
        echo -e "${YELLOW}未检测到系统 esptool，尝试检查 pip3 模块...${NC}"
        # 尝试检查 python 模块
        if python3 -m esptool version &> /dev/null; then
            ESP_CMD="python3 -m esptool"
        else
            echo -e "${RED}错误: 未找到 esptool。${NC}"
            echo -e "请运行安装命令: ${GREEN}sudo apt install esptool${NC} 或 ${GREEN}pip3 install esptool${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}环境就绪: 使用 $ESP_CMD${NC}"
}

# 2. 串口扫描
select_port() {
    echo -e "\n${YELLOW}[1] 扫描串口设备:${NC}"
    ports=($(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null))
    
    if [ ${#ports[@]} -eq 0 ]; then
        echo -e "${RED}错误: 未发现串口设备！请检查连接或权限。${NC}"
        echo -e "权限提示: sudo usermod -a -G dialout \$USER"
        exit 1
    fi

    for i in "${!ports[@]}"; do
        hint="[COM]"
        if [[ "${ports[$i]}" == *"/dev/ttyACM"* ]]; then hint="[USB/JTAG]"; fi
        echo -e " $((i+1)). ${ports[$i]} $hint"
    done

    read -p "请选择串口编号: " port_idx
    # 简单的输入验证
    if ! [[ "$port_idx" =~ ^[0-9]+$ ]] || [ "$port_idx" -lt 1 ] || [ "$port_idx" -gt "${#ports[@]}" ]; then
        echo -e "${RED}无效选择，默认选择第一个。${NC}"
        port_idx=1
    fi
    SELECTED_PORT=${ports[$((port_idx-1))]}
}

# 3. 模式选择
select_mode() {
    echo -e "\n${YELLOW}[2] 选择烧录模式:${NC}"
    echo " 1. USB 模式 (usb_reset)  - 适用于 S3 内置 USB"
    echo " 2. COM 模式 (default_reset) - 适用于 CH340/外部串口"
    read -p "请输入选择 [默认 1]: " m_choice
    m_choice=${m_choice:-1}
    
    BEFORE="usb_reset"
    [ "$m_choice" == "2" ] && BEFORE="default_reset"
}

# 辅助函数：检查文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}错误: 找不到文件 $1${NC}"
        echo -e "请确保固件文件位于脚本同一目录下。"
        return 1
    fi
    return 0
}

# --- 程序入口 ---
check_env
select_port
select_mode

BASE_ARGS="--chip esp32s3 --port $SELECTED_PORT --baud 460800 --before $BEFORE"

# 4. 主循环菜单
while true; do
    clear
    echo -e "${CYAN}==================================================${NC}"
    echo -e "   CyMouse 接收端(Receiver) Linux 工具 | 端口: $SELECTED_PORT"
    echo -e "${CYAN}==================================================${NC}"
    echo " 1. 接收端全刷 (写入 0x0 地址)"
    echo " 2. 全片擦除"
    echo " 0. 退出脚本"
    echo "--------------------------------------------------"
    read -p "请输入功能编号: " func

    case $func in
        1) 
            check_file ${FILES[full]} && \
            $ESP_CMD $BASE_ARGS --after hard_reset write_flash 0x0 ${FILES[full]} 
            ;;
        2) 
            read -p "确定要全片擦除吗？这会清空所有数据 (y/n): " conf
            if [ "$conf" == "y" ]; then 
                $ESP_CMD $BASE_ARGS erase_flash
            fi 
            ;;
        0) 
            echo "正在退出..."
            exit 0 
            ;;
        *) 
            echo -e "${RED}无效选择${NC}" 
            ;;
    esac

    echo -e "\n${GREEN}[操作结束] 按回车键返回菜单...${NC}"
    read
done