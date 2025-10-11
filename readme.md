# CyMouse: 一款支持健康监测的高性能鼠标

<img src="./assets/view2.png" width="1000" alt="CyMouse 效果图">


​	CyMouse 是一款支持健康监测的高性能鼠标。主控采用 **ESP32-S3FH4R2**，传感器为 **PAW3395DM-T6QU**，集成了血氧、心率传感器，并且配置了屏幕用于查看鼠标的相关状态和进行功能配置。

## ✨ 背景

​	由于我的工作性质，每天都需要长时间久坐，这让我开始思考：有没有一款产品可以在无感知的情况下监控我们的健康状态？

目前市面上的健康监控产品主要是手环和手表，但我个人不喜欢在工作时佩戴它们，因为手腕上的设备总是会与键盘发生磕碰。健康监测模块要求与身体紧密接触，最常见的部位是手指或手腕。在工作场景中，我们接触时间最长的外设无疑是鼠标。

于是，将健康监测功能集成到鼠标中的想法便诞生了，这就是 CyMouse 项目的由来。



## 🚀 主要功能

### 🖱️ 鼠标功能
- **三模连接**：USB-C 有线、蓝牙、2.4G 无线、三种连接方式。
- **高性能传感器**：采用 PAW3395DM-T6QU 传感器，最高支持 26000 DPI。
- **DPI 快速切换**：底部有独立的 DPI 切换按钮，方便快速调整。

  <img src="./assets/实物1.jpg" width="250" alt="实物图1">  <img src="./assets/实物2.jpg" width="250" alt="实物图2">   <img src="./assets/实物3.jpg" width="250" alt="实物图3">


#### 性能数据
- **USB / 无线模式**：由于 ESP32-S3 的 USB Full-Speed (12 Mbit/s) 限制，回报率最高为 1KHz。虽然这未能完全发挥 PAW3395DM-T6QU 的全部性能，但实际使用体验比我的罗技 G102 更加丝滑、精准。对于办公和各类游戏（包括 FPS）已完全足够。

  <img src=".\assets\usb_test\polling_rate.png" alt="polling_rate" width=250/>. <img src=".\assets\usb_test\interval_vs_Time.png" width=250/>. <img src=".\assets\usb_test\x_vs_y.png" alt="x_vs_y" width=250/>
  <img src=".\assets\usb_test\xCount_vs_Time.png" alt="xCount_vs_Time" width=250/>.  <img src=".\assets\usb_test\xSpeed_vs_Time.png" alt="xSpeed_vs_Time" width=250/>. <img src=".\assets\usb_test\xyCount_vs_Time.png" alt="xyCount_vs_Time" width=250 />
  <img src=".\assets\usb_test\xySpeed_vs_Time.png" alt="xySpeed_vs_Time" width=250/>.  <img src=".\assets\usb_test\yCount_vs_Time.png" alt="yCount_vs_Time" width=250 />. <img src=".\assets\usb_test\ySpeed_vs_Time.png" alt="ySpeed_vs_Time" width=250/>




- **蓝牙模式**：受限于 BLE 协议，性能上与有线和无线模式有一定差距，但完全满足办公等场景。

  <img src="assets/ble_test/polling_rate.png" width=250/>. <img src="assets/ble_test/interval_vs_Time.png" width=250/>. <img src="assets/ble_test/x_vs_y.png" alt="x_vs_y" width=250/>
  <img src="assets/ble_test/xCount_vs_Time.png" alt="xCount_vs_Time" width=250/>. <img src="assets/ble_test/xSpeed_vs_Time.png" alt="xSpeed_vs_Time" width=250/>. <img src="assets/ble_test/xyCount_vs_Time.png" alt="xyCount_vs_Time" width=250/>
  <img src="assets/ble_test/xySpeed_vs_Time.png" alt="xySpeed_vs_Time" width=250/>. <img src="assets/ble_test/yCount_vs_Time.png" alt="yCount_vs_Time" width=250/>. <img src="assets/ble_test/ySpeed_vs_Time.png" alt="ySpeed_vs_Time" width=250/>




- **鼠标重量**：鼠标本体重量约83g，包含电池约110.4g

  <img src="assets/with_bt.jpg" width=250/>    <img src="assets/with_out_bt.jpg" alt="with_out_bt" width=250/>




### ❤️ 健康监测
- **多维度数据**：支持血氧、心率、疲劳指数、微循环、血压、心输出、外周阻力等健康数据的监测。

- **智能提醒**：通过振动方式进行久坐提醒。

  <img src="assets/体检.jpg" width=250 />  <img src="assets/休息.jpg" width=250/>


注：当前灯光效果为随机色




### 💡 更多功能
- **可以鼠标DPI、滚轮速度等**
- **可以设置鼠标运动时的屏幕动画**
- **可以设置RGB灯效**
- **可以查看记录的健康和鼠标数据**
- **支持多语言等**


  <img src="assets/设置1.jpg" width=250 />  <img src="assets/设置2.jpg" width=250/>


### 💻 PC 客户端
在 USB 模式下，可以通过 PC 客户端：
- 查看健康监测历史数据。
- 主动发起一次健康监测。
- 查看鼠标使用数据统计。


  <img src="assets/pc1.png" width=300 />  <img src="assets/pc2.png" width=300/>



---

## 🛠️ 硬件定制与组装

硬件资源是开源的，您可以在以下地址找到相关文件：
- **开源地址**: https://oshwhub.com/keivenliao/cymouse

### 采购注意事项
大部分元器件可在立创商城采购，如遇缺货可在**其他**渠道购买。以下是需要单独购买的特殊配件：

- **传感器**: PAW3395DM-T6QU，需配套镜头型号 `LM19-LSI`。
- **血氧模块**: 我选择了一款支持血压检测的特殊模块。套件自带 6pin 连接线，3D 模型也基于此模块尺寸设计。
- **屏幕**: 0.49寸 OLED，`64*48` 分辨率，`16PIN` 接口。**注意**：务必购买与下图接口一致的屏幕。
  <img src="assets/OLED.jpg" width=250/>    <img src="assets/OLED_PIN.png" alt="with_out_bt" width=250/>
- **电池**: 型号 `103443-1500mAh` (尺寸: 10x34x43mm)。充满电可连续使用约 48 小时。可根据个人对重量和续航的平衡进行选择。如果只使用 USB 模式，可以不安装电池。
- **电池连接线**: `2P 1.25mm` 间距，公头 (单头)，线长 `50mm`。
- **USB 线**: 推荐购买细软的 USB 2.0 Type-C 数据线以获得更好的有线模式体验。
- **微动**: TTC 防尘金微动 (0.65N 软脆手感)，或任何尺寸兼容的微动。 
- **编码器**: TTC 防尘金轮编码器，高度 `12MM`。
- **中键**: 凯华静音微动，高度 `9.5mm`。
- **滚轮**: 罗技 G102 / G304 / G305 通用滚轮。
- **脚垫**: 小圆点冰版，直径 `7mm`。
- **螺丝和螺帽**:
    - 外壳螺丝: `M1.6 * 9mm` (头宽5mm, 头厚0.7mm)
    - 盖板固定螺丝: `M1.2 * 2mm` (头宽2.5mm, 头厚0.2mm)
    - 侧键固定螺丝: `M1.2 * 2.5mm` (头宽3.5mm, 头厚0.5mm)
    - 外壳螺帽: `M1.6` (长3mm, 外径2.5mm)
    - 盖板固定螺帽: `M1.2` (长1.5mm, 外径2mm)。**提示**: 热熔此螺帽时建议先拧上螺丝，防止堵孔。
- **FPC 连接线**: `4P`，`0.5mm` 间距，同向，长度 `5CM`。

### 焊接与组装说明

- **芯片方向**: `TPS61222DCKR` 和两颗 `TPS22919QDCKRQ1` 这三颗芯片容易焊错方向。芯片上的**竖线标记**必须与 PCB 丝印的**定位标记**保持一致。
- **接线座方向**: 4PIN 和 6PIN 接线座的方向不要装反，请参考下图

  <img src="assets/3d_board.png" width=450/> 
  
- **血氧模块 FPC**: 用于连接血氧模块的 6PIN FPC 线方向**必须**与图中一致（注意FPC金属面的朝向），否则会烧毁模块！

  <img src="assets/血氧传感器.jpg" width=250/> 

### 核心电路设计思路

- **充电芯片**: 选用 TI 的 `BQ24075RGTR` 而非常见的 `TP4056`，因为它支持路径管理，可以边充边放，并根据负载自动调整电流路径。
- **主电源**: 选用 `TLV62569DBVR` DCDC 芯片而非 LDO。这是综合功耗、发热和电池供电需求的考量。LDO 在长时间使用时产生的热量会在鼠标内部聚集，而本项目整体对电源纹波不十分敏感。
- **RGB LED 供电**: 增加了一颗 `TPS61222DCKR` 将 3.3V 升压至 5V，以确保在低亮度设置下 LED 发光稳定。同时配合 `TPS22919QDCKRQ1` 负载开关，可以由 MCU 彻底关断其供电，以获得最佳续航。屏幕电路也同理加入了负载开关。

### 3D 模型与打印说明
- **模型文件**: 3D 模型已拆分为上盖、上盖支撑、底壳、零件共 4 部分。
- **建模软件**: Autodesk Fusion 360，您可以下载源文件自行修改。
- **打印**: 提供了 Bambu Studio 的工程文件，导入后可直接打印。为提高成功率，建议将底壳和零件分盘打印。
- **打印后调整**: 打印完成后，左右按键的触杆长度可能需要根据实际装配情况进行微调。
- **推荐材料**: 半透明的 PETG 材料，配合 LED 灯光能获得不错的视觉效果。


  <img src="assets/3d_model.png" width=600/>
 - **注意1**：图中3处是我在建模时增加的支撑，打印出来后抠掉即可。
 
 
   <img src="assets/3d_model_1.png" width=600/>
 - **注意2**：图中2处，左右键触杆长度，会受到支撑与上盖的组合情况导致过长或过短，需要根据实际情况调整
 
 
   <img src="assets/3d_model_2.png" width=600/>
 - **注意3**：上盖支撑与上盖如果为一个整体打印质量会大幅下降，因此我分成了两个部分，用胶水粘合即可，推荐3D打印专用胶水。



---



## 💾 固件烧录与使用

### 烧录说明
- **鼠标本体**: 复刻硬件后，下载 **全量刷机固件** 进行首次烧录。后续更新时，只需刷入 **升级固件**，即可保留激活信息和历史数据。
- **无线接收端**: 任意一款 ESP32-S3 (带 R2 版本 Flash/RAM) 的开发板均可作为接收端。接收端固件完全开源，您可以根据自己的开发板修改源码适配。**注意**: 如果您的开发板有两个 USB 口，烧录后请将数据线连接到另一个用于通信的 USB 口。

### 关于激活
鼠标本体固件暂不开源。首次启动时，请扫描屏幕上的二维码，按照页面提示即可**免费获取**该设备的**终身**激活码。

> **扫码提示**:
> - 不要使用微信扫码，其内置浏览器不支持页面跳转。
> - 推荐使用手机系统自带的相机、浏览器或支付宝的扫码功能。
> - 如果扫码后无法跳转，可以手动连接 Wi-Fi 热点，名称为 `CyMouse_xxxx`，密码为 `12345678`，连接后会自动弹出激活页面。
> - 手机端打开页面获取设备ID后，恢复网络访问：https://cynix.cc/license/activate，以获取激活码

### 使用说明
- **进入设置**: 同时长按**两个侧键** 3 秒，即可进入鼠标设置菜单。


  <img src="assets/enter_config.png" width=800/>



---

### 🔋 未验证功能
硬件上已设计并支持无线充电功能，外壳建模也为无线接收模块预留了空间，相关电路和 PCB 均已完成设计，但暂未进行实际验证。您可以持续关注本项目的后续进展。

---


## 📜 开源与隐私

- **开源范围**: 本项目的**硬件 (PCB)**、**3D 模型**、**无线接收端固件**和 **PC 客户端**均完全开源。
  - 硬件开源地址：https://oshwhub.com/keivenliao/cymouse
  - 接收端开源地址：https://github.com/CynixPub/CyMouse_Receiver
  - PC端开源地址：https://github.com/CynixPub/PC_monitor

- **用户隐私**：鼠标本体固件没有任何联网逻辑，完全离线运行。PC 客户端记录的健康数据也完全存储在本地，代码开源可查。
- **开源协议**：开源内容均遵循CC BY-NC-SA 4.0   /  GPLv3 协议。

---



## 🙏感谢

以下三个项目：

https://github.com/Ghost-Girls/PMW3360-3389-PAW3395_STM32-CH32-APM32

https://github.com/Li-Dongze/stm32_paw3395_mouse

https://github.com/kirltrz/PAW3395_Arduino_ESP32

---



## ✍️ 写在最后

从技术上讲，PC 客户端完全可以实现对鼠标所有功能的配置。但这与我设计初衷——即在鼠标上通过屏幕直接完成所有配置——相冲突。因此，我仅在 PC 端实现了健康监测相关的部分功能。（当然，懒也是其中一个原因 😄）



硬件开发确实不易，一路走来踩了不少坑，还有3D模型的试错也颇费心血，部分**“祭品”**


  <img src="assets/more2.jpg" width=800/>

---

## ❤️ 捐赠
如果您觉得 CyMouse 对您有帮助，欢迎给予我一些支持，这将帮助我更好地完善这个项目。

  <img src="assets/wx21.png" width=150/>



