# v1.0 完整备份版本

## 📋 版本信息
- **版本号**: v1.0
- **创建时间**: 2025-10-25
- **备份类型**: 完整项目备份
- **状态**: 已验证完整

## 📁 文件结构
```
v1.0_完整备份/
├── 500 double led.ioc          ← CubeMX配置文件
├── Core/                       ← 核心源代码
│   ├── Inc/                    ← 头文件
│   │   ├── hc595.h
│   │   ├── key.h
│   │   ├── main.h
│   │   ├── menu_system.h
│   │   ├── segment_display.h
│   │   ├── spi_display.h
│   │   ├── stm32f1xx_hal_conf.h
│   │   └── stm32f1xx_it.h
│   └── Src/                    ← 源文件
│       ├── hc595.c
│       ├── key.c
│       ├── main.c
│       ├── menu_system.c
│       ├── segment_display.c
│       ├── spi_display.c
│       ├── stm32f1xx_hal_msp.c
│       ├── stm32f1xx_it.c
│       └── system_stm32f1xx.c
├── Drivers/                    ← STM32 HAL库
│   ├── CMSIS/                  ← ARM CMSIS库
│   └── STM32F1xx_HAL_Driver/   ← STM32F1 HAL驱动
└── MDK-ARM/                    ← Keil项目文件
    ├── 500 double led.uvguix.xx
    ├── 500 double led.uvoptx
    ├── JLinkSettings.ini
    └── 500 double led/         ← 编译输出文件
```

## 🎯 功能特性
- ✅ 双数码管显示系统 (D7/D8)
- ✅ 6个状态LED指示
- ✅ 9键键盘输入系统
- ✅ 智能步进频率调节
- ✅ 高低频模式切换
- ✅ 长按连续调节
- ✅ 多级菜单系统
- ✅ 完整的STM32F103C8T6支持

## 🔧 技术规格
- **MCU**: STM32F103C8T6
- **显示**: 2×5位数码管 (共阳极)
- **LED**: 6个状态指示 (ALM, V, F/R, Hz, RUN, A)
- **按键**: 9键输入 (74HC165)
- **驱动**: 74HC595移位寄存器
- **通信**: SPI2接口

## 📊 频率模式
### 低频模式 (0.00-400.00Hz)
- 步进: 0.01Hz → 0.1Hz → 1Hz → 10Hz
- 显示: XXX.XX Hz
- 最大步进: 10Hz

### 高频模式 (0.0-4000.0Hz)
- 步进: 0.1Hz → 1Hz → 10Hz → 100Hz
- 显示: XXXX.X Hz
- 最大步进: 100Hz

## 🚀 快速开始
1. 使用Keil MDK-ARM打开项目
2. 确保J-Link调试器连接
3. 编译并烧录到STM32F103C8T6
4. 验证硬件连接正确

## 📝 使用说明
- **RUN/STOP**: 启动/停止控制
- **UP/DOWN**: 频率调节 (支持长按)
- **FUNC**: 高低频模式切换
- **PRG**: 编程模式
- **ENTER**: 确认键
- **SHIFT**: 位移键

## ⚠️ 注意事项
- 确保硬件连接正确
- 检查电源电压 (3.3V/5V)
- 验证SPI通信正常
- 注意共阳极数码管特性

## 📞 技术支持
如有问题，请参考：
- 配置指南文档
- 故障排除指南
- Cursor AI规则系统

---
**备份完成时间**: 2025-10-25 13:44
**文件完整性**: ✅ 已验证