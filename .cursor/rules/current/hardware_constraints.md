# 硬件约束规则

本文档描述了所有**不可更改**的硬件约束。违反这些约束将导致系统无法正常工作。

---

## HW-001: 调试接口 - 只使用SWD，禁用JTAG {#hw-001}

### 约束内容
- **必须使用**：SWD调试接口
- **严禁使用**：JTAG调试接口
- **可用引脚**：PA13 (SWDIO), PA14 (SWCLK)
- **禁用引脚**：PB3 (JTDO), PB4 (NJTRST) - 不可作为普通GPIO

### 原因
- 避免二次烧录失败
- STM32F103C8T6的SWD更稳定
- PB3/PB4作为GPIO会导致调试接口失效

### CubeMX配置
```
Pinout & Configuration → System Core → SYS
Debug: Serial Wire (不选JTAG)
```

### Keil配置
```
Options for Target → Debug
- Use: J-Link / J-Trace Cortex
- Settings → Port: SW (不选JTAG)
```

### 代码配置
```c
// ✅ 正确：SWD配置（CubeMX自动生成）
// 不需要额外代码

// ❌ 错误：禁用SWD或重映射
// __HAL_AFIO_REMAP_SWJ_DISABLE();  // ❌ 禁用调试接口
// 不要使用PB3、PB4作为GPIO
```

---

## HW-002: 74HC595级联配置 {#hw-002}

### 芯片配置
本项目使用**3个74HC595**芯片级联：

```
     MOSI
      │
   ┌──┴──┐
   │ U1  │ → 74HC595 #1
   └──┬──┘
      │
   ┌──┴──┐
   │ U2  │ → 74HC595 #2
   └──┬──┘
      │
   ┌──┴──┐
   │ U6  │ → 74HC595 #3
   └─────┘
```

### U1 - D7数码管段控制 + LED阴极
```
QA → D7数码管 a段  + LED_D1阴极 (ALM)
QB → D7数码管 b段  + LED_D2阴极 (V)
QC → D7数码管 c段  + LED_D3阴极 (F/R)
QD → D7数码管 d段  + LED_D4阴极 (Hz)
QE → D7数码管 e段  + LED_D5阴极 (RUN)
QF → D7数码管 f段  + LED_D6阴极 (A)
QG → D7数码管 g段
QH → D7数码管 dp段（小数点）
```

### U2 - 位选择 + LED阳极（⚠️ PNP三极管反相）
```
QA → D7_DIG1 (D7第1位选择)
QB → D7_DIG2 (D7第2位选择)
QC → D7_DIG3 (D7第3位选择)
QD → D7_DIG4 (D7第4位选择)
QE → D7_DIG5 (D7第5位选择)
QF → DIG_6 (6个LED的共阳极)
QG → D8_DIG1 (D8第1位选择)
QH → D8_DIG2 (D8第2位选择)

⚠️ 重要：U2的输出经过PNP三极管反相！
代码中必须再次取反补偿：u2_data = ~original_data;
```

### U6 - D8数码管段控制
```
QA → D8数码管 a1段
QB → D8数码管 b1段
QC → D8数码管 c1段
QD → D8数码管 d1段
QE → D8数码管 e1段
QF → D8数码管 f1段
QG → D8数码管 g1段
QH → D8数码管 dp1段（小数点）
```

### 数据流向
```
STM32 MOSI (PB15) → U1 SER
U1 QH' → U2 SER
U2 QH' → U6 SER
```

### SPI发送顺序
```c
// 必须按照级联顺序发送：U1 → U2 → U6
HAL_SPI_Transmit(&hspi2, &u1_data, 1, 100);  // 先发送U1
HAL_SPI_Transmit(&hspi2, &u2_data, 1, 100);  // 再发送U2
HAL_SPI_Transmit(&hspi2, &u6_data, 1, 100);  // 最后发送U6
```

---

## HW-003: 74HC165按键输入 {#hw-003}

### 芯片配置
本项目使用**1个74HC165**芯片读取**9位**按键输入。

### 引脚连接
```
74HC165          按键
─────────────────────
SER (串行输入)  → RUN键
D0 (并行输入0)  → RESERVED键（保留）
D1 (并行输入1)  → ENTER键
D2 (并行输入2)  → FUNC键
D3 (并行输入3)  → STOP键
D4 (并行输入4)  → DOWN键
D5 (并行输入5)  → RPG键（编程）
D6 (并行输入6)  → SHIFT键
D7 (并行输入7)  → UP键

QH (串行输出)   → STM32 MISO (PB14)
SH/LD (控制)    → STM32 PB7（与595共享）
CLK (时钟)      → STM32 SCLK (PB13，与595共享)
```

### 共享SPI总线
```
⚠️ 重要：74HC165与74HC595共享SPI2总线和LATCH引脚！

PB13 (SCLK)  → 74HC595 SRCLK + 74HC165 CLK
PB7 (LATCH)  → 74HC595 RCLK  + 74HC165 SH/LD
```

### 读取顺序
```
必须先读取按键（74HC165），再更新显示（74HC595），避免冲突！
```

---

## HW-004: SPI2引脚分配（固定，不可更改）{#hw-004}

### 引脚定义
```
引脚      功能           连接
────────────────────────────────────────
PB13   → SPI2_SCK    → 74HC595 SRCLK (所有) + 74HC165 CLK
PB14   → SPI2_MISO   → 74HC165 QH
PB15   → SPI2_MOSI   → 74HC595 SER (U1)
PB7    → GPIO_Output → 74HC595 RCLK (所有) + 74HC165 SH/LD
```

### SPI2配置参数
```c
hspi2.Init.Mode = SPI_MODE_MASTER;
hspi2.Init.Direction = SPI_DIRECTION_2LINES;
hspi2.Init.DataSize = SPI_DATASIZE_8BIT;
hspi2.Init.CLKPolarity = SPI_POLARITY_LOW;     // 空闲时低电平
hspi2.Init.CLKPhase = SPI_PHASE_1EDGE;         // 第一个边沿采样
hspi2.Init.NSS = SPI_NSS_SOFT;                 // 软件控制片选
hspi2.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_8;  // 9MHz
hspi2.Init.FirstBit = SPI_FIRSTBIT_MSB;        // 高位先发
```

### 电气特性
```
- 供电：74HC595/165 = 5V, STM32 = 3.3V
- 兼容性：74HC系列支持3.3V输入
- 速度：SPI时钟约9MHz
```

---

## HW-005: 数码管类型 - 共阳极 {#hw-005}

### 数码管配置
```
类型：共阳极7段数码管
位数：D7和D8各5位
```

### 共阳极特性
```
- 段码控制：低电平(0)点亮，高电平(1)熄灭
- 位选择：高电平有效（选中）
- 段码需要取反
```

### 段码表（已取反）
```c
const uint8_t seg_code[] = {
    0xC0, // 0: 0b11000000
    0xF9, // 1: 0b11111001
    0xA4, // 2: 0b10100100
    0xB0, // 3: 0b10110000
    0x99, // 4: 0b10011001
    0x92, // 5: 0b10010010
    0x82, // 6: 0b10000010
    0xF8, // 7: 0b11111000
    0x80, // 8: 0b10000000
    0x90  // 9: 0b10010000
};
```

### 段位定义
```
  a
 ───
f│  │b
 ─g─
e│  │c
 ───  · dp
  d
```

---

## HW-006: LED映射（固定不可更改）{#hw-006}

### LED硬件连接
```
LED编号  LED名称  功能          阴极(U1)  阳极(U2)
──────────────────────────────────────────────
LED_D1   ALM     报警指示       a段      DIG_6
LED_D2   V       电压指示       b段      DIG_6
LED_D3   F/R     正反转/高频     c段      DIG_6
LED_D4   Hz      频率单位       d段      DIG_6
LED_D5   RUN     运行指示       e段      DIG_6
LED_D6   A       电流单位       f段      DIG_6
```

### 代码定义
```c
// LED索引（固定不可更改）
#define LED_ALM  0  // D1 报警指示
#define LED_V    1  // D2 电压指示
#define LED_FR   2  // D3 F/R指示（高频模式）
#define LED_Hz   3  // D4 频率单位
#define LED_RUN  4  // D5 运行指示
#define LED_A    5  // D6 电流单位
```

### 控制方法
```c
// 点亮LED：阴极0（U1对应位）+ 阳极1（U2的DIG_6）
// 熄灭LED：阴极1 或 阳极0

// 示例：点亮Hz LED
u1_data |= (1 << LED_Hz);    // 阴极为0（位为1）
u2_data |= (1 << 5);          // DIG_6为1（阳极）
```

---

## HW-007: 按键映射（74HC165，固定不可更改）{#hw-007}

### 按键硬件连接
```
74HC165位  bit  按键名称     功能
─────────────────────────────────────
SER        0    RUN        运行键
D0         1    RESERVED   保留键
D1         2    ENTER      确认键
D2         3    FUNC       功能键（模式切换）
D3         4    STOP       停止/复位键
D4         5    DOWN       递减键
D5         6    RPG        编程键
D6         7    SHIFT      位移键
D7         8    UP         递增键
```

### 代码定义
```c
// 按键枚举（固定不可更改）
typedef enum {
    KEY_NONE = 0,
    KEY_RUN      = 1,   // bit0 = SER
    KEY_RESERVED = 2,   // bit1 = D0
    KEY_ENTER    = 3,   // bit2 = D1
    KEY_FUNC     = 4,   // bit3 = D2
    KEY_STOP     = 5,   // bit4 = D3
    KEY_DOWN     = 6,   // bit5 = D4
    KEY_RPG      = 7,   // bit6 = D5
    KEY_SHIFT    = 8,   // bit7 = D6
    KEY_UP       = 9    // bit8 = D7
} KeyValue_t;
```

### 位映射代码
```c
uint8_t KEY_Scan(void) {
    uint16_t key_state = KEY_Read();  // 读取9位数据
    
    if (key_state & 0x001) return KEY_RUN;      // bit0
    if (key_state & 0x002) return KEY_RESERVED; // bit1
    if (key_state & 0x004) return KEY_ENTER;    // bit2
    if (key_state & 0x008) return KEY_FUNC;     // bit3
    if (key_state & 0x010) return KEY_STOP;     // bit4
    if (key_state & 0x020) return KEY_DOWN;     // bit5
    if (key_state & 0x040) return KEY_RPG;      // bit6
    if (key_state & 0x080) return KEY_SHIFT;    // bit7
    if (key_state & 0x100) return KEY_UP;       // bit8
    
    return KEY_NONE;
}
```

---

## 📐 硬件连接总览

### 完整连接图
```
STM32F103C8T6
├─ PA13 (SWDIO)  ─── J-Link
├─ PA14 (SWCLK)  ─── J-Link
│
├─ PB13 (SPI2_SCK)  ──┬── 74HC595 SRCLK ×3
│                      └── 74HC165 CLK
├─ PB14 (SPI2_MISO) ───── 74HC165 QH
├─ PB15 (SPI2_MOSI) ───── 74HC595 U1 SER
└─ PB7  (LATCH)     ──┬── 74HC595 RCLK ×3
                       └── 74HC165 SH/LD

74HC595 级联：
U1 (D7段+LED阴) → U2 (位+LED阳) → U6 (D8段)

74HC165：
9个按键输入 → QH → STM32 MISO

数码管：
D7 (5位共阳) + D8 (5位共阳)

LED：
6个LED（ALM, V, F/R, Hz, RUN, A）
```

---

## ⚠️ 严禁操作

### 不可修改的内容
- ❌ 修改SPI2引脚定义
- ❌ 修改74HC595级联顺序
- ❌ 修改74HC165按键映射
- ❌ 修改LED映射
- ❌ 使用PB3、PB4作为GPIO
- ❌ 使用JTAG调试接口
- ❌ 更改数码管类型
- ❌ 删除U2输出取反补偿

### 可以修改的内容
- ✅ 显示内容和格式
- ✅ 按键功能逻辑
- ✅ SPI速度（不超过规格）
- ✅ 刷新频率（不低于最小值）
- ✅ LED指示逻辑

---

## 📋 硬件检查清单

### 开发前检查
- [ ] 了解所有硬件约束
- [ ] 确认引脚定义不可更改
- [ ] 确认级联顺序固定
- [ ] 确认映射关系固定

### 编码时检查
- [ ] 使用SWD接口
- [ ] U2输出已取反
- [ ] 按键映射正确
- [ ] LED映射正确
- [ ] SPI顺序正确

### 调试时检查
- [ ] J-Link连接SWD
- [ ] 引脚无短路
- [ ] 供电正常（5V/3.3V）
- [ ] SPI波形正常

---

**最后更新：** 2025-10-25  
**硬件版本：** v1.0  
**状态：** ✅ 已验证，不可更改

