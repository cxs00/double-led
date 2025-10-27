# 编码规范

## 📐 显示相关代码规则

### CS-001: 数码管段码表必须对共阳极取反

**规则说明：**  
本项目使用共阳极数码管，段码需要取反（0=亮，1=灭）。

**正确示例：**
```c
// ✅ 正确：共阳极数码管段码（已取反）
const uint8_t seg_code[] = {
    0xC0, // 0
    0xF9, // 1
    0xA4, // 2
    0xB0, // 3
    0x99, // 4
    0x92, // 5
    0x82, // 6
    0xF8, // 7
    0x80, // 8
    0x90  // 9
};
```

**错误示例：**
```c
// ❌ 错误：共阴极段码（未取反）
const uint8_t seg_code[] = {
    0x3F, // 0 ❌ 适用于共阴极
    0x06, // 1 ❌
    // ...
};
```

**验证方法：**
- 显示"0"时，数码管应正常显示
- 显示"8"时，所有段应点亮

---

### CS-002: U2输出必须再次取反

**规则说明：**  
U2（第2个74HC595）的输出经过PNP三极管反相，代码中需要再次取反补偿。

**正确示例：**
```c
// ✅ 正确：U2数据在发送前取反（补偿PNP三极管）
void SPI_Display_Refresh(void)
{
    uint8_t u1_data = d7_segment_data;   // D7段数据，不需要取反
    uint8_t u2_data = ~digit_select_led; // U2数据，必须取反 ✅
    uint8_t u6_data = d8_segment_data;   // D8段数据，不需要取反
    
    // SPI发送顺序：U1 → U2 → U6
    HAL_SPI_Transmit(&hspi2, &u1_data, 1, 100);
    HAL_SPI_Transmit(&hspi2, &u2_data, 1, 100);
    HAL_SPI_Transmit(&hspi2, &u6_data, 1, 100);
    
    // 锁存
    HAL_GPIO_WritePin(LATCH_GPIO_Port, LATCH_Pin, GPIO_PIN_SET);
    HAL_Delay(1);
    HAL_GPIO_WritePin(LATCH_GPIO_Port, LATCH_Pin, GPIO_PIN_RESET);
}
```

**错误示例：**
```c
// ❌ 错误：U2数据未取反
uint8_t u2_data = digit_select_led;  // ❌ 缺少取反，显示会反相
HAL_SPI_Transmit(&hspi2, &u2_data, 1, 100);
```

**原因：**
```
代码设置 → U2输出 → PNP三极管 → 实际输出
   1    →    1    →    反相0    →    0（错误）
   0    →    0    →    反相1    →    1（错误）

代码取反后：
   ~1=0 →    0    →    反相1    →    1（正确）
   ~0=1 →    1    →    反相0    →    0（正确）
```

**验证方法：**
- LED和位选择应正常工作
- 不应出现反相显示

---

### CS-003: 频率显示格式必须严格遵守

**规则说明：**  
低频和高频模式有不同的显示格式。

**显示格式：**
```
低频模式（0.00-400.00Hz）：
  格式：XXX.XX Hz
  小数点：第2位后（个位后）
  精度：0.01Hz
  示例：050.00, 123.45, 400.00

高频模式（0.0-4000.0Hz）：
  格式：XXXX.X Hz
  小数点：第3位后（个位后）
  精度：0.1Hz
  示例：0050.0, 1234.5, 4000.0
  **注意**：显示时必须四舍五入
```

**正确实现：**
```c
void SEG_DisplayFrequency(uint32_t freq_hz, uint8_t is_high_freq)
{
    if (is_high_freq) {
        // 高频模式：XXXX.X Hz
        // freq_hz单位为0.01Hz，需要四舍五入并转换为0.1Hz
        uint32_t display_freq = freq_hz;
        if ((freq_hz % 10) >= 5) {
            display_freq = freq_hz + 10;  // 四舍五入
        }
        display_freq = display_freq / 10;
        
        d7_buffer[0] = seg_code[(display_freq / 10000) % 10];        // 千位
        d7_buffer[1] = seg_code[(display_freq / 1000) % 10];         // 百位
        d7_buffer[2] = seg_code[(display_freq / 100) % 10];          // 十位
        d7_buffer[3] = seg_code[(display_freq / 10) % 10] & ~0x80;   // 个位（带小数点）✅
        d7_buffer[4] = seg_code[display_freq % 10];                  // 小数位1
    } else {
        // 低频模式：XXX.XX Hz
        // freq_hz单位为0.01Hz
        d7_buffer[0] = seg_code[freq_hz / 10000];           // 百位
        d7_buffer[1] = seg_code[(freq_hz / 1000) % 10];     // 十位
        d7_buffer[2] = seg_code[(freq_hz / 100) % 10] & ~0x80;  // 个位（带小数点）✅
        d7_buffer[3] = seg_code[(freq_hz / 10) % 10];       // 小数1
        d7_buffer[4] = seg_code[freq_hz % 10];              // 小数2
    }
}
```

---

### CS-004: 小数点位置代码规范

**规则说明：**  
使用`& ~0x80`在指定位添加小数点。

**低频模式（XXX.XX）：**
```c
// ✅ 正确：小数点在第2位（个位）后
d7_buffer[2] = seg_code[digit] & ~0x80;
```

**高频模式（XXXX.X）：**
```c
// ✅ 正确：小数点在第3位（个位）后
d7_buffer[3] = seg_code[digit] & ~0x80;
```

**D8电流显示（XXX.XX A）：**
```c
// ✅ 正确：小数点在第2位（个位）后
SEG_SetDigit_D8(2, digit, 1);  // 第三个参数1表示带小数点
```

**小数点原理：**
```
段码的bit7控制小数点：
  bit7=1 → 小数点灭
  bit7=0 → 小数点亮

~0x80 = 0b01111111
seg_code[digit] & ~0x80 → 强制bit7=0 → 点亮小数点
```

---

## ⌨️ 按键处理规则

### CS-005: KEY_Scan()必须使用电平触发模式

**规则说明：**  
为支持长按功能，`KEY_Scan()`必须使用电平触发，始终返回当前按键状态。

**正确实现：**
```c
// ✅ 正确：电平触发（支持长按）
uint8_t KEY_Scan(void)
{
    uint16_t key_state = KEY_Read();
    uint8_t key_pressed = KEY_NONE;
    
    // 消抖处理（仅在状态变化时消抖）
    if (key_state != key_last_state) {
        HAL_Delay(10);  // 消抖延迟10ms
        key_state = KEY_Read();
        
        if (key_state != key_last_state) {
            key_last_state = key_state;
        }
    }
    
    // ✅ 检测当前按键状态（无论是否变化，始终返回当前按键）
    if (key_state & 0x001) {
        key_pressed = KEY_RUN;
    } else if (key_state & 0x002) {
        key_pressed = KEY_RESERVED;
    } 
    // ... 其他按键
    
    return key_pressed;  // ✅ 长按期间持续返回按键值
}
```

**错误实现：**
```c
// ❌ 错误：边缘触发（长按失效）
uint8_t KEY_Scan(void)
{
    uint16_t key_state = KEY_Read();
    
    if (key_state != key_last_state) {
        HAL_Delay(10);
        key_state = KEY_Read();
        
        if (key_state != key_last_state) {
            key_last_state = key_state;
            
            // ❌ 只在状态变化时检测按键
            if (key_state & 0x001) return KEY_RUN;
            // ...
        }
    }
    
    return KEY_NONE;  // ❌ 长按期间一直返回NONE
}
```

---

### CS-006: 长按参数（已优化，不建议修改）

**规则说明：**  
长按参数已经过优化和测试，除非有特殊需求，否则不建议修改。

**推荐参数：**
```c
#define KEY_LONG_PRESS_THRESHOLD 5   // 250ms（5×50ms扫描周期）
#define KEY_REPEAT_RATE 2            // 100ms（2×50ms扫描周期）
```

**使用示例：**
```c
static uint8_t key_long_press_count = 0;

// 在主循环中（扫描周期50ms）
if (key_value != KEY_NONE) {
    key_long_press_count++;
} else {
    key_long_press_count = 0;
}

// UP/DOWN键：支持长按重复触发
if (key_value == KEY_UP || key_value == KEY_DOWN) {
    if (key_long_press_count == 1) {
        should_execute = 1;  // 首次按下，立即执行
    } else if (key_long_press_count >= KEY_LONG_PRESS_THRESHOLD) {
        // 长按状态，按重复速率执行
        if ((key_long_press_count - KEY_LONG_PRESS_THRESHOLD) % KEY_REPEAT_RATE == 0) {
            should_execute = 1;
        }
    }
}
```

**时间线：**
```
count=1:  50ms  → 首次触发 ✅
count=5:  250ms → 第1次重复 ✅
count=7:  350ms → 第2次重复 ✅
count=9:  450ms → 第3次重复 ✅
count=11: 550ms → 第4次重复 ✅
...每100ms重复一次
```

---

### CS-007: 智能步进超时规则

**规则说明：**  
超时500ms无操作后，必须重置步进级别为STEP_LEVEL_1。

**正确实现：**
```c
#define STEP_TIMEOUT 500  // 500ms超时

uint32_t last_freq_key_time = 0;
StepLevel_t current_step_level = STEP_LEVEL_1;

// 在UP/DOWN键处理中更新时间
case KEY_UP:
case KEY_DOWN:
    last_freq_key_time = HAL_GetTick();  // ✅ 更新时间戳
    // ... 频率调整逻辑
    break;

// 在主循环中检查超时
uint32_t current_time = HAL_GetTick();
if (current_time - last_freq_key_time > STEP_TIMEOUT) {
    current_step_level = STEP_LEVEL_1;  // ✅ 超时重置
}
```

**错误实现：**
```c
// ❌ 错误：超时后自动判定步进级别
if (current_time - last_freq_key_time > STEP_TIMEOUT) {
    AutoSetStepLevel(current_frequency);  // ❌ 不应自动判定
}
```

---

## ⏱️ 时序控制规则

### CS-008: 刷新周期（已优化）

**规则说明：**  
显示和按键的刷新周期已优化，必须使用`HAL_GetTick()`做定时，不使用`HAL_Delay()`阻塞。

**推荐周期：**
```c
#define DISPLAY_REFRESH_PERIOD 20   // 20ms（50Hz刷新率）
#define KEY_SCAN_PERIOD 50          // 50ms（20Hz扫描率）
```

**正确实现：**
```c
// ✅ 正确：非阻塞定时
int main(void)
{
    uint32_t last_display_time = 0;
    uint32_t last_key_scan_time = 0;
    
    while (1) {
        uint32_t current_time = HAL_GetTick();
        
        // 显示刷新（20ms周期）
        if (current_time - last_display_time >= DISPLAY_REFRESH_PERIOD) {
            SPI_Display_Refresh();
            last_display_time = current_time;
        }
        
        // 按键扫描（50ms周期）
        if (current_time - last_key_scan_time >= KEY_SCAN_PERIOD) {
            uint8_t key_value = KEY_Scan();
            // ... 按键处理
            last_key_scan_time = current_time;
        }
    }
}
```

**错误实现：**
```c
// ❌ 错误：阻塞延迟
while (1) {
    SPI_Display_Refresh();
    HAL_Delay(20);  // ❌ 阻塞主循环
    
    uint8_t key_value = KEY_Scan();
    HAL_Delay(50);  // ❌ 阻塞主循环
}
```

---

### CS-009: SPI通信顺序

**规则说明：**  
必须先读取按键（74HC165），再更新显示（74HC595），避免SPI总线冲突。

**正确顺序：**
```c
// ✅ 正确：先读键，再显示
while (1) {
    uint32_t current_time = HAL_GetTick();
    
    // 步骤1：读取按键（74HC165）
    if (current_time - last_key_scan_time >= KEY_SCAN_PERIOD) {
        uint8_t key_value = KEY_Scan();  // ✅ 先读取
        
        // 步骤2：处理按键逻辑
        if (key_value != KEY_NONE) {
            // ... 按键处理
            UpdateDisplay();  // 更新显示数据
        }
        
        last_key_scan_time = current_time;
    }
    
    // 步骤3：刷新显示（74HC595）
    if (current_time - last_display_time >= DISPLAY_REFRESH_PERIOD) {
        SPI_Display_Refresh();  // ✅ 后显示
        last_display_time = current_time;
    }
}
```

**错误顺序：**
```c
// ❌ 错误：显示和按键同时操作
SPI_Display_Refresh();  // ❌ 先显示
uint8_t key = KEY_Scan();  // ❌ 后读键，可能冲突
```

---

## 📋 编码检查清单

### 修改代码前必须检查
- [ ] 是否使用了JTAG相关GPIO（PB3、PB4）？
- [ ] 数码管段码是否取反？
- [ ] U2输出是否再次取反？
- [ ] 小数点位置是否正确？
- [ ] 按键映射是否正确？
- [ ] KEY_Scan()是否电平触发？
- [ ] 是否使用HAL_Delay()阻塞主循环？
- [ ] 智能步进逻辑是否正确？
- [ ] SPI通信顺序是否正确？

### 编译前必须检查
- [ ] 无未定义的标识符
- [ ] 无重复的case标签
- [ ] 所有必要的头文件已包含
- [ ] Flash算法配置正确（64KB）

### 烧录前必须检查
- [ ] Debug接口选择SWD
- [ ] J-Link设备识别正常
- [ ] 目标芯片选择STM32F103C8

---

## 🎨 代码风格

### 命名规范
```c
// 宏定义：全大写+下划线
#define LED_ALM 0
#define KEY_SCAN_PERIOD 50

// 枚举：首字母大写+下划线，_t后缀
typedef enum {
    FREQ_MODE_LOW = 0,
    FREQ_MODE_HIGH = 1
} FreqMode_t;

// 函数：大驼峰或下划线分隔
void SEG_DisplayFrequency(uint32_t freq, uint8_t mode);
void UpdateDisplay(void);

// 变量：下划线分隔
uint32_t current_frequency;
uint8_t key_long_press_count;
```

### 注释规范
```c
// ✅ 好的注释：解释"为什么"
u2_data = ~digit_select_led;  // U2输出经PNP三极管反相，需要取反补偿

// ❌ 坏的注释：重复代码
u2_data = ~digit_select_led;  // 取反u2数据
```

### 函数长度
- 建议：单个函数不超过50行
- 复杂逻辑应拆分为子函数
- main()主循环应简洁清晰

---

**最后更新：** 2025-10-25  
**规则数量：** 9条编码规范  
**状态：** ✅ 已验证并优化

