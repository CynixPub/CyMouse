[中文版本 🇨🇳](./readme_cn.md)



# CyMouse: A High-Performance Mouse with Health Monitoring

<img src="./assets/view2.png" width="1000" alt="CyMouse Preview">

**CyMouse** is a high-performance mouse that supports health monitoring. It is powered by an **ESP32-S3FH4R2** controller and equipped with a **PAW3395DM-T6QU** sensor. It also integrates SpO₂ and heart rate sensors, as well as a built-in display for viewing mouse status and configuring settings.

---

## ✨ Background

Due to the nature of my work, I spend long hours sitting in front of a computer. This made me wonder — could there be a product that monitors our health unobtrusively?

Currently, most health monitoring devices are wristbands or smartwatches. However, I personally dislike wearing them while working because they often bump against the keyboard. Health monitoring sensors need close contact with the body — usually the wrist or fingers. In the workplace, the peripheral we touch the most is undoubtedly the **mouse**.

Thus, the idea of integrating health monitoring into a mouse was born — and that’s how **CyMouse** came to life.

---

## 🚀 Key Features

### 🖱️ Mouse Features

- **Tri-mode connectivity**: USB-C wired, Bluetooth, and 2.4G wireless.  
- **High-performance sensor**: PAW3395DM-T6QU sensor, up to 26,000 DPI.  
- **Quick DPI switching**: Dedicated DPI button on the bottom for easy adjustment.

  <img src="./assets/实物1.jpg" width="250">  <img src="./assets/实物2.jpg" width="250">  <img src="./assets/实物3.jpg" width="250">

#### Performance Data

- **USB / Wireless Mode**:  
  Due to the ESP32-S3’s USB Full-Speed (12 Mbit/s) limitation, the maximum polling rate is 1 kHz. While this doesn’t fully unleash the PAW3395DM-T6QU’s capabilities, the actual experience is smoother and more precise than my Logitech G102 — more than enough for office use and gaming (including FPS titles).

  *(Performance charts omitted for brevity — same as original)*

- **Bluetooth Mode**:  
  Performance is slightly limited by BLE protocol constraints but is perfectly sufficient for office use.

  *(Performance charts omitted for brevity — same as original)*

- **Mouse Weight**:  
  Base weight: 83 g; with battery: approximately 110.4 g.

  <img src="assets/with_bt.jpg" width=250> <img src="assets/with_out_bt.jpg" width=250>

---

### ❤️ Health Monitoring

- **Multi-dimensional data**: Supports SpO₂, heart rate, fatigue index, microcirculation, blood pressure, cardiac output, peripheral resistance, and more.  
- **Smart reminders**: Vibration-based sedentary alerts.

  <img src="assets/体检.jpg" width=250> <img src="assets/休息.jpg" width=250>

*(Note: Current lighting effects use random colors.)*

---

### 💡 Additional Features

- Adjustable DPI and scroll speed  
- Customizable on-screen animations during movement  
- RGB lighting effects  
- Health and mouse data history  
- Multi-language support  

  <img src="assets/设置1.jpg" width=250> <img src="assets/设置2.jpg" width=250>

---

### 💻 PC Client

In USB mode, the PC client can:

- View historical health monitoring data  
- Manually initiate a new health check  
- Display usage statistics for the mouse  

  <img src="assets/pc1.png" width=300> <img src="assets/pc2.png" width=300>

---

## 🛠️ Hardware Customization and Assembly

Hardware resources are open source. You can find them here:  
- **Open-source repository**: https://oshwlab.com/keivenliao/cymouse

### Procurement Notes

Most components are available on LCSC. If out of stock, you may source alternatives elsewhere. Special parts include:

- **Sensor**: PAW3395DM-T6QU (with lens model `LM19-LSI`)  
- **SpO₂ Module**: Custom module supporting blood pressure monitoring; includes 6-pin cable and 3D model matched to its dimensions  
- **Display**: 0.66" OLED, `64×48` resolution, `16PIN` interface (ensure connector matches reference image)  
  <img src="assets/OLED.jpg" width=250> <img src="assets/OLED_PIN.png" width=250>  
- **Battery**: `103443-1500mAh` (10×34×43 mm), ~48 hrs continuous use; optional if using USB mode only  
- **Battery Cable**: `2P 1.25mm` male, 50mm length  
- **USB Cable**: Flexible USB 2.0 Type-C for optimal wired performance  
- **Switches**: TTC Dustproof Gold (0.65N), or compatible  
- **Encoder**: TTC Dustproof Gold wheel encoder (12mm height)  
- **Middle Button**: Kailh Silent (9.5mm height)  
- **Scroll Wheel**: Compatible with Logitech G102 / G304 / G305  
- **Feet Pads**: 7mm diameter ice-type dots  
- **Screws and Nuts**: *(details same as original)*  
- **FPC Cable**: `4P`, `0.5mm` pitch, same direction, 5cm length  

### Soldering & Assembly Notes

- **Chip orientation**: Ensure `TPS61222DCKR` and both `TPS22919QDCKRQ1` chips align with PCB markings.  
- **Connector orientation**: Check 4-pin and 6-pin headers carefully.  
- **SpO₂ FPC cable**: Orientation **must** match the reference; incorrect direction may damage the module!  

  <img src="assets/血氧传感器.jpg" width=250>

---

### Core Circuit Design

- **Charging Chip**: TI `BQ24075RGTR` (supports power path management) instead of common `TP4056`.  
- **Main Power**: `TLV62569DBVR` DCDC instead of LDO for reduced heat and higher efficiency.  
- **RGB LED Power**: `TPS61222DCKR` boosts 3.3V→5V for stable illumination; combined with `TPS22919QDCKRQ1` load switch for MCU-controlled power-off.

---

### 3D Model & Printing

- Model split into top cover, top support, base, and small parts.  
- Designed in Autodesk Fusion 360 (source files provided).  
- Printable directly via included Bambu Studio project files.  
- Recommended material: **translucent PETG** for best LED lighting effects.  

*(Assembly and support adjustment details same as original)*

---

## 💾 Firmware Flashing & Usage

### Flashing Guide

- **Mouse firmware**: Flash the **full firmware** first. For later updates, use **upgrade firmware** to retain activation and history.  
- **Wireless receiver**: Any ESP32-S3 (with R2 Flash/RAM) board works. Receiver firmware is open-source and adaptable.  

### Activation

Firmware is closed-source. On first boot, scan the on-screen QR code to obtain a **free lifetime activation code**.

> **Tips**:
> - Avoid using WeChat scanner (browser limitation)  
> - Use your phone’s camera, browser, or Alipay  
> - If redirect fails, connect to Wi-Fi hotspot `CyMouse_xxxx` (password `12345678`) to auto-open activation page  
> - Retrieve activation code at: https://cynix.cc/license/activate  

### Usage

- **Enter Settings**: Hold both side buttons for 3 seconds.  

  <img src="assets/enter_config.png" width=800>

---

### 🔋 Unverified Features

Hardware design includes wireless charging support with reserved module space, though it hasn’t been tested yet. Follow for updates.

---

## 📜 Open Source & Privacy

- **Open components**: Hardware (PCB), 3D model, receiver firmware, and PC client.  
  - Hardware: https://oshwhub.com/keivenliao/cymouse  
  - Receiver: https://github.com/CynixPub/CyMouse_Receiver  
  - PC Client: https://github.com/CynixPub/PC_monitor  
- **User Privacy**: Mouse firmware works fully offline; PC client stores data locally.  
- **Licenses**: CC BY-NC-SA 4.0 / GPLv3.

---

## 🙏 Acknowledgments

Inspired by the following projects:

- https://github.com/Ghost-Girls/PMW3360-3389-PAW3395_STM32-CH32-APM32  
- https://github.com/Li-Dongze/stm32_paw3395_mouse  
- https://github.com/kirltrz/PAW3395_Arduino_ESP32  

---

## ✍️ Final Words

Technically, the PC client could configure all mouse features, but that would defeat the purpose — I wanted all settings adjustable directly **on the mouse display**. (Also, I’ll admit... a bit of laziness 😄)

Hardware development isn’t easy — I’ve gone through countless trials, especially with 3D model fitting. Here are some of the **“sacrifices”** made along the way:

  <img src="assets/more2.jpg" width=800>

---

## ❤️ Donation

If CyMouse has been helpful to you, consider supporting me — it helps improve and maintain this project.

  <img src="assets/usdt.png" width=50> TFexGjjxHDo7EsU6x8Yiz7Eu2kqVYpnEw1
