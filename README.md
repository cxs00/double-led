# 🎯 STM32双数码管显示系统

> **项目类型**: STM32嵌入式系统  
> **硬件平台**: STM32F103C8T6  
> **功能**: 双数码管显示 + 6LED状态指示 + 9键输入系统  
> **版本**: v1.0  
> **状态**: ✅ 已完成开发

---

## 📋 项目概述

本项目是一个基于STM32F103C8T6的双数码管显示系统，具有完整的频率控制、状态指示和用户交互功能。

### 🎯 核心功能
- **双数码管显示**: D7显示频率，D8显示电流
- **6个状态LED**: ALM(报警)、V(电压)、F/R(正反转)、Hz(频率单位)、RUN(运行)、A(电流单位)
- **9键输入系统**: RUN、STOP、UP、DOWN、FUNC、PRG、ENTER、SHIFT、RESERVED
- **智能步进调节**: 根据频率范围自动调整步进值
- **高低频模式**: 支持0.00-400.00Hz和0.0-4000.0Hz两种模式
- **长按连续调节**: 支持长按连续增减频率

---

## 🔧 硬件架构

### 核心组件
- **MCU**: STM32F103C8T6
- **显示驱动**: 3×74HC595级联 (U1段控制+LED阴极, U2位选择+LED阳极, U6段控制)
- **按键输入**: 1×74HC165 (9位按键扫描)
- **显示器件**: 2×5位共阳极数码管 (D7频率显示, D8电流显示)
- **状态指示**: 6个LED (ALM, V, F/R, Hz, RUN, A)

### 引脚分配
```
STM32F103C8T6
├─ PA13 (SWDIO)  ─── J-Link调试器
├─ PA14 (SWCLK)  ─── J-Link调试器
├─ PB13 (SPI2_SCK)  ──┬── 74HC595 SRCLK ×3
│                      └── 74HC165 CLK
├─ PB14 (SPI2_MISO) ───── 74HC165 QH
├─ PB15 (SPI2_MOSI) ───── 74HC595 U1 SER
└─ PB7  (LATCH)     ──┬── 74HC595 RCLK ×3
                       └── 74HC165 SH/LD
```

### 74HC595级联结构
```
U1 (D7段+LED阴) → U2 (位+LED阳) → U6 (D8段)
```

### 74HC165按键映射
```
SER → RUN键     D0 → RESERVED键
D1 → ENTER键    D2 → FUNC键
D3 → STOP键     D4 → DOWN键
D5 → PRG键      D6 → SHIFT键
D7 → UP键
```

---

## 🚀 快速开始

### 1. 环境要求
- **开发环境**: Keil MDK-ARM 5.x
- **调试器**: J-Link或ST-Link
- **CubeMX**: STM32CubeMX (可选，用于配置)

### 2. 硬件连接
1. 连接J-Link调试器到SWD接口 (PA13/PA14)
2. 连接74HC595和74HC165到SPI2接口
3. 连接数码管和LED到对应引脚
4. 确保电源供应 (3.3V/5V)

### 3. 软件配置
1. 打开Keil项目: `software/config/MDK-ARM/500 double led.uvprojx`
2. 配置J-Link调试器
3. 编译并烧录程序

### 4. 功能验证
- 数码管显示正常
- LED状态指示正常
- 按键响应正常
- 频率调节功能正常

---

## 📊 功能特性

### 频率控制
- **低频模式**: 0.00-400.00Hz，步进0.01Hz→0.1Hz→1Hz→10Hz
- **高频模式**: 0.0-4000.0Hz，步进0.1Hz→1Hz→10Hz→100Hz
- **智能步进**: 根据当前频率自动选择合适步进值
- **长按连续**: 支持长按连续增减频率

### 显示功能
- **D7数码管**: 显示当前频率 (XXX.XX Hz 或 XXXX.X Hz)
- **D8数码管**: 显示当前电流 (XXXX.XX A)
- **状态LED**: 实时指示系统状态

### 按键功能
- **RUN/STOP**: 启动/停止控制
- **UP/DOWN**: 频率调节 (支持长按)
- **FUNC**: 高低频模式切换
- **PRG**: 编程模式
- **ENTER**: 确认键
- **SHIFT**: 位移键

---

## 📁 项目结构

```
500 double led/
├── README.md                   ← 项目说明 (本文件)
├── HARDWARE_CONFIG.h           ← 硬件配置
├── PROJECT_SUMMARY.md          ← 项目总结
├── QUICKSTART.md               ← 快速开始
├── TROUBLESHOOTING.md          ← 故障排除
├── CHANGELOG.md                ← 变更日志
├── ACCEPTANCE_CHECKLIST.md     ← 验收清单
├── TEST_VERIFY.md              ← 测试验证
├── build_check.bat             ← 编译检查
├── QUICK_FIX.md                ← 快速修复
├── FIX_SUMMARY.txt             ← 修复总结
├── CONTRIBUTING.md             ← 贡献指南
├── AI_COLLABORATION.md         ← AI协作
├── COLLABORATION_GUIDE.md      ← 协作指南
├── DOCUMENTATION_INDEX.md      ← 文档索引
├── FINAL_SUMMARY.md            ← 最终总结
├── JLINK_SETUP.md              ← J-Link配置
├── UPDATE_SUMMARY.md           ← 更新总结
├── software/                   ← 软件目录
│   ├── config/                 ← 当前项目配置
│   │   ├── 500 double led.ioc  ← CubeMX配置
│   │   ├── Core/               ← 源代码
│   │   ├── Drivers/            ← HAL库
│   │   └── MDK-ARM/            ← Keil项目
│   ├── 备份版本/               ← 历史版本
│   ├── 使用说明/             ← 用户文档
│   ├── 工程文件/               ← 项目文档
│   ├── 版本更新记录/           ← 版本管理
│   └── 配置指南/               ← 技术文档
├── 故障经验/                   ← 故障排除
└── .cursor/                    ← AI规则系统
```

---

## 🔧 技术规格

### 硬件规格
- **MCU**: STM32F103C8T6 (72MHz, 64KB Flash, 20KB RAM)
- **显示**: 2×5位共阳极数码管
- **LED**: 6个状态指示LED
- **按键**: 9键输入系统
- **通信**: SPI2接口 (9MHz)
- **电源**: 3.3V/5V双电源

### 软件规格
- **开发环境**: Keil MDK-ARM 5.x
- **HAL库**: STM32F1xx HAL Driver
- **调试接口**: SWD (Serial Wire Debug)
- **编程语言**: C语言
- **实时性**: 定时器中断驱动

---

## 📚 文档指南

### 用户文档
- [快速开始指南](QUICKSTART.md) - 快速上手
- [项目使用指南](software/使用说明/项目使用指南.md) - 详细使用说明
- [故障排除指南](TROUBLESHOOTING.md) - 常见问题解决

### 技术文档
- [硬件配置](HARDWARE_CONFIG.h) - 硬件参数配置
- [配置指南](software/配置指南/) - 开发环境配置
- [故障经验](故障经验/) - 开发故障记录

### 开发文档
- [贡献指南](CONTRIBUTING.md) - 如何参与开发
- [AI协作指南](AI_COLLABORATION.md) - AI辅助开发
- [文档索引](DOCUMENTATION_INDEX.md) - 完整文档索引

---

## 🎯 项目状态

### ✅ 已完成功能
- [x] 硬件架构设计
- [x] 软件架构设计
- [x] 双数码管显示系统
- [x] 6LED状态指示
- [x] 9键输入系统
- [x] 智能步进频率调节
- [x] 高低频模式切换
- [x] 长按连续调节
- [x] 多级菜单系统
- [x] 完整的STM32F103C8T6支持

### 🔄 持续改进
- [ ] 性能优化
- [ ] 功能扩展
- [ ] 文档完善
- [ ] 测试覆盖

---

## 🤝 贡献指南

### 如何参与
1. 阅读[贡献指南](CONTRIBUTING.md)
2. 查看[AI协作指南](AI_COLLABORATION.md)
3. 了解[项目结构](software/工程文件/项目结构.md)
4. 参考[故障经验](故障经验/)避免常见问题

### 开发规范
- 遵循现有的代码风格
- 添加必要的注释
- 更新相关文档
- 进行充分测试

---

## 📞 技术支持

### 获取帮助
1. **文档优先**: 先查看相关文档
2. **故障经验**: 查看[故障经验](故障经验/)目录
3. **AI规则**: 参考[.cursor/rules](.cursor/rules/)目录
4. **社区支持**: 在相关技术社区寻求帮助

### 常见问题
- **编译错误**: 查看[故障排除指南](TROUBLESHOOTING.md)
- **硬件连接**: 参考[硬件配置](HARDWARE_CONFIG.h)
- **调试问题**: 查看[配置指南](software/配置指南/)

---

## 📄 许可证

本项目采用MIT许可证，详见LICENSE文件。

---

## 🙏 致谢

感谢所有参与项目开发的贡献者和技术支持。

---

**项目创建时间**: 2025-10-25  
**最后更新**: 2025-10-25  
**版本**: v1.0  
**状态**: ✅ 开发完成

---

<div align="center">

## 🎉 项目亮点

**🚀 完整功能**: 双数码管显示 + 6LED状态 + 9键输入  
**🔧 智能调节**: 自动步进 + 长按连续 + 模式切换  
**📚 完善文档**: 用户指南 + 技术文档 + 故障排除  
**🤖 AI协作**: Cursor规则 + 自动错误避免 + 智能提示  

**让STM32开发更简单，让嵌入式系统更智能！** 💪

</div>
