# 项目配置文件

## 📋 文件夹说明

本文件夹包含STM32 500双LED项目的当前开发版本文件。

## 📁 文件结构

```
config/
├── 500 double led.ioc       ← CubeMX配置文件
├── Core/                    ← 核心源代码
│   ├── Inc/                 ← 头文件
│   └── Src/                 ← 源文件
├── Drivers/                 ← STM32 HAL库
│   ├── CMSIS/              ← ARM CMSIS库
│   └── STM32F1xx_HAL_Driver/ ← STM32F1 HAL驱动
└── MDK-ARM/                ← Keil项目文件
    ├── 500 double led/     ← 编译输出文件
    ├── 500 double led.uvguix.xx
    ├── 500 double led.uvoptx
    ├── DebugConfig/
    ├── JLinkLog.txt
    ├── JLinkSettings.ini
    ├── RTE/
    ├── startup_stm32f103xb.lst
    └── startup_stm32f103xb.s
```

## 🚀 快速开始

### 1. 打开项目
```
路径：config/MDK-ARM/500 double led.uvprojx
工具：Keil uVision 5
```

### 2. 编译项目
```
快捷键：F7
或点击：Build按钮
检查：0 Error, 0 Warning
```

### 3. 配置调试器
```
Options for Target → Debug → J-Link / J-Trace Cortex
Settings → Debug → Port: SW (不选JTAG)
Flash Download → Programming Algorithm: STM32F10x Med-density (64KB)
```

### 4. 烧录程序
```
连接J-Link调试器
点击Load按钮
等待烧录完成
```

## 📚 项目说明

### 核心功能
- ✅ 10位数码管显示系统（D7+D8）
- ✅ 6个状态LED指示（ALM、V、F/R、Hz、RUN、A）
- ✅ 9键按键系统（RUN、ENTER、FUNC、STOP、DOWN、PRG、SHIFT、UP）
- ✅ 双频模式切换（低频0.00-400.00Hz，高频0.0-4000.0Hz）
- ✅ 智能步进系统（4级步进：0.01Hz→0.1Hz→1Hz→10Hz）
- ✅ 长按连续调节功能
- ✅ 多级菜单系统

### 技术实现
- **硬件架构：** STM32F103C8T6 + 74HC595×3 + 74HC165
- **显示系统：** 共阳极数码管，动态扫描
- **按键系统：** 74HC165并行输入，9键映射
- **通信协议：** SPI2总线，级联控制
- **频率控制：** 双精度浮点运算，智能步进

## ⚠️ 注意事项

### 硬件注意事项
- 确保所有连接正确
- 检查电源电压（3.3V/5V）
- 注意共阳极数码管特性

### 软件注意事项
- 使用SWD调试接口
- 避免使用JTAG相关GPIO
- 注意Flash算法配置

## 🔧 开发环境

### 硬件要求
- **主控芯片：** STM32F103C8T6
- **显示驱动：** 74HC595×3
- **按键输入：** 74HC165
- **调试器：** J-Link或ST-Link

### 软件要求
- **开发环境：** Keil uVision 5.25+
- **HAL库：** STM32CubeF1 HAL 1.8.0+
- **配置工具：** STM32CubeMX
- **调试工具：** J-Link或ST-Link

## 📞 技术支持

如有问题，请查看：
- 故障经验文件夹
- 配置指南文件夹
- 版本更新记录

---

**版本：** v1.0  
**最后更新：** 2025-10-25  
**维护者：** STM32开发团队
