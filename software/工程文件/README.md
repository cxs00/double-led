# 工程文件

## 📋 文件夹说明

本文件夹包含STM32 500双LED项目的主要工程文件。

## 📁 文件结构

### 核心文件
- **500 double led.ioc** - CubeMX项目配置文件
- **Core/** - 核心源代码文件夹
- **Drivers/** - STM32 HAL库文件夹
- **MDK-ARM/** - Keil uVision项目文件夹

### 源代码文件
```
Core/
├── Inc/                    ← 头文件
│   ├── hc595.h            ← 74HC595驱动头文件
│   ├── key.h              ← 按键处理头文件
│   ├── main.h             ← 主程序头文件
│   ├── menu_system.h      ← 菜单系统头文件
│   ├── segment_display.h  ← 数码管显示头文件
│   ├── spi_display.h      ← SPI显示头文件
│   ├── stm32f1xx_hal_conf.h ← HAL库配置头文件
│   └── stm32f1xx_it.h    ← 中断处理头文件
└── Src/                   ← 源文件
    ├── hc595.c           ← 74HC595驱动源文件
    ├── key.c             ← 按键处理源文件
    ├── main.c            ← 主程序源文件
    ├── menu_system.c     ← 菜单系统源文件
    ├── segment_display.c ← 数码管显示源文件
    ├── spi_display.c     ← SPI显示源文件
    ├── stm32f1xx_hal_msp.c ← HAL库MSP源文件
    ├── stm32f1xx_it.c    ← 中断处理源文件
    └── system_stm32f1xx.c ← 系统初始化源文件
```

### HAL库文件
```
Drivers/
├── CMSIS/                    ← ARM CMSIS库
│   ├── Core/                ← 核心文件
│   ├── Device/             ← 设备文件
│   ├── DSP/                  ← 数字信号处理库
│   ├── Include/              ← 包含文件
│   ├── Lib/                  ← 库文件
│   ├── NN/                   ← 神经网络库
│   ├── RTOS/                 ← 实时操作系统
│   └── RTOS2/                ← 实时操作系统2
└── STM32F1xx_HAL_Driver/     ← STM32F1 HAL驱动
    ├── Inc/                  ← 头文件
    ├── Src/                  ← 源文件
    └── LICENSE.txt           ← 许可证文件
```

### Keil项目文件
```
MDK-ARM/
├── 500 double led/           ← 编译输出文件夹
│   ├── *.crf                ← 交叉引用文件
│   ├── *.d                   ← 依赖文件
│   ├── *.o                   ← 目标文件
│   └── 其他编译文件
├── 500 double led.uvguix.xx  ← Keil用户界面文件
├── 500 double led.uvoptx     ← Keil选项文件
├── DebugConfig/              ← 调试配置
├── JLinkLog.txt              ← J-Link日志
├── JLinkSettings.ini         ← J-Link设置
├── RTE/                      ← 运行时环境
├── startup_stm32f103xb.lst   ← 启动文件列表
└── startup_stm32f103xb.s     ← 启动汇编文件
```

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

## 🚀 快速开始

### 1. 打开项目
```
路径：software/MDK-ARM/500 double led.uvprojx
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

## 📚 文件说明

### 核心源文件
- **main.c** - 主程序，包含主循环和初始化
- **hc595.c** - 74HC595驱动，控制数码管和LED
- **key.c** - 按键处理，读取74HC165输入
- **segment_display.c** - 数码管显示，段码和位码控制
- **spi_display.c** - SPI显示，SPI通信控制
- **menu_system.c** - 菜单系统，多级菜单处理

### 配置文件
- **500 double led.ioc** - CubeMX项目配置
- **stm32f1xx_hal_conf.h** - HAL库配置
- **JLinkSettings.ini** - J-Link调试配置

### 库文件
- **Drivers/** - 完整的STM32 HAL库
- **CMSIS/** - ARM CMSIS库
- **启动文件** - STM32F103启动代码

## ⚠️ 注意事项

### 编译注意事项
- 确保所有头文件路径正确
- 检查HAL库版本兼容性
- 注意Flash大小配置（64KB）

### 调试注意事项
- 使用SWD接口，禁用JTAG
- 检查调试器连接
- 注意调试器驱动版本

### 硬件注意事项
- 确保硬件连接正确
- 检查电源电压
- 注意共阳极数码管特性

## 🔧 维护建议

### 代码维护
- 定期检查代码质量
- 更新HAL库版本
- 优化代码结构

### 文档维护
- 更新代码注释
- 维护API文档
- 记录变更历史

### 版本管理
- 使用Git版本控制
- 创建重要版本备份
- 维护版本发布记录

---

**最后更新：** 2025-10-25
