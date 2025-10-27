/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : segment_display.c
  * @brief          : 10-digit display driver implementation
  ******************************************************************************
  */
/* USER CODE END Header */

#include "segment_display.h"
#include "hc595.h"
#include <string.h>

/* 段码表（共阳极） */
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
    0x90, // 9
    0x88, // A
    0x83, // B
    0xC6, // C
    0xA1, // D
    0x86, // E
    0x8E, // F
    0xFF  // 全灭
};

/* LED段位映射 */
const uint8_t led_bit_map[6] = {3, 5, 1, 0, 2, 4};

/* 显示缓冲区 */
static uint8_t d7_buffer[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
static uint8_t d8_buffer[5] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
static uint8_t led_status = 0x00;
static uint8_t current_scan = 0;

/**
  * @brief  显示系统初始化
  * @param  None
  * @retval None
  */
void SEG_Init(void)
{
    memset(d7_buffer, 0xFF, 5);
    memset(d8_buffer, 0xFF, 5);
    led_status = 0x00;
    current_scan = 0;
}

/**
  * @brief  设置D7的某一位
  * @param  pos: 位置（0-4）
  * @param  value: 数值（0-16）
  * @param  dp: 小数点
  * @retval None
  */
void SEG_SetDigit_D7(uint8_t pos, uint8_t value, uint8_t dp)
{
    if (pos >= 5) return;
    if (value <= 16) {
        d7_buffer[pos] = seg_code[value];
    } else {
        d7_buffer[pos] = 0xFF;
    }
    if (dp) {
        d7_buffer[pos] &= ~0x80;
    }
}

/**
  * @brief  设置D8的某一位
  * @param  pos: 位置（0-4）
  * @param  value: 数值（0-16）
  * @param  dp: 小数点
  * @retval None
  */
void SEG_SetDigit_D8(uint8_t pos, uint8_t value, uint8_t dp)
{
    if (pos >= 5) return;
    if (value <= 16) {
        d8_buffer[pos] = seg_code[value];
    } else {
        d8_buffer[pos] = 0xFF;
    }
    if (dp) {
        d8_buffer[pos] &= ~0x80;
    }
}

/**
  * @brief  D7显示数字
  * @param  number: 数字（0-99999）
  * @retval None
  */
void SEG_SetNumber_D7(uint32_t number)
{
    if (number > 99999) number = 99999;
    SEG_SetDigit_D7(0, number / 10000, 0);
    SEG_SetDigit_D7(1, (number / 1000) % 10, 0);
    SEG_SetDigit_D7(2, (number / 100) % 10, 0);
    SEG_SetDigit_D7(3, (number / 10) % 10, 0);
    SEG_SetDigit_D7(4, number % 10, 0);
}

/**
  * @brief  D8显示数字
  * @param  number: 数字（0-99999）
  * @retval None
  */
void SEG_SetNumber_D8(uint32_t number)
{
    if (number > 99999) number = 99999;
    SEG_SetDigit_D8(0, number / 10000, 0);
    SEG_SetDigit_D8(1, (number / 1000) % 10, 0);
    SEG_SetDigit_D8(2, (number / 100) % 10, 0);
    SEG_SetDigit_D8(3, (number / 10) % 10, 0);
    SEG_SetDigit_D8(4, number % 10, 0);
}

/**
  * @brief  D7显示字符串
  * @param  str: 字符串
  * @retval None
  */
void SEG_DisplayString_D7(const char *str)
{
    uint8_t len = strlen(str);
    if (len > 5) len = 5;
    
    for (uint8_t i = 0; i < 5; i++) {
        if (i < len) {
            char c = str[i];
            if (c >= '0' && c <= '9') {
                d7_buffer[i] = seg_code[c - '0'];
            } else if (c >= 'A' && c <= 'F') {
                d7_buffer[i] = seg_code[c - 'A' + 10];
            } else if (c >= 'a' && c <= 'f') {
                d7_buffer[i] = seg_code[c - 'a' + 10];
            } else {
                d7_buffer[i] = 0xFF;
            }
        } else {
            d7_buffer[i] = 0xFF;
        }
    }
}

/**
  * @brief  D8显示字符串
  * @param  str: 字符串
  * @retval None
  */
void SEG_DisplayString_D8(const char *str)
{
    uint8_t len = strlen(str);
    if (len > 5) len = 5;
    
    for (uint8_t i = 0; i < 5; i++) {
        if (i < len) {
            char c = str[i];
            if (c >= '0' && c <= '9') {
                d8_buffer[i] = seg_code[c - '0'];
            } else if (c >= 'A' && c <= 'F') {
                d8_buffer[i] = seg_code[c - 'A' + 10];
            } else if (c >= 'a' && c <= 'f') {
                d8_buffer[i] = seg_code[c - 'a' + 10];
            } else {
                d8_buffer[i] = 0xFF;
            }
        } else {
            d8_buffer[i] = 0xFF;
        }
    }
}

/**
  * @brief  设置LED状态
  * @param  led_id: LED编号
  * @param  state: 状态（1=亮，0=灭）
  * @retval None
  */
void SEG_SetLED(uint8_t led_id, uint8_t state)
{
    if (led_id >= 6) return;
    
    if (state) {
        led_status |= (1 << led_bit_map[led_id]);
    } else {
        led_status &= ~(1 << led_bit_map[led_id]);
    }
}

/**
  * @brief  清空所有LED
  * @param  None
  * @retval None
  */
void SEG_ClearAllLED(void)
{
    led_status = 0x00;
}

/**
  * @brief  清空数码管
  * @param  None
  * @retval None
  */
void SEG_Clear(void)
{
    memset(d7_buffer, 0xFF, 5);
    memset(d8_buffer, 0xFF, 5);
}

/**
  * @brief  刷新显示
  * @param  None
  * @retval None
  */
void SEG_Refresh(void)
{
    uint8_t u6_data, u2_data, u1_data;
    
    current_scan++;
    if (current_scan >= 7) current_scan = 0;
    
    if (current_scan == 0) {
        /* 周期0：显示5个普通LED */
        u6_data = 0xFF;
        u2_data = 0x01;
        u1_data = led_status & 0x3F;
    } else if (current_scan == 1) {
        /* 周期1：显示RUN LED */
        HC595_SendData(0xFF, ~0x00, 0xFF);
        for(uint8_t i = 0; i < 10; i++);
        
        u6_data = 0xFF;
        u2_data = 0x01;
        u1_data = led_status & 0x3F;
    } else {
        /* 周期2-6：显示数码管 */
        uint8_t digit_pos = 6 - current_scan;
        
        u6_data = d8_buffer[digit_pos];
        u2_data = 1 << current_scan;
        u1_data = d7_buffer[digit_pos];
    }
    
    HC595_SendData(u6_data, ~u2_data, u1_data);
}

/**
  * @brief  显示频率
  * @param  freq_hz: 频率（单位：0.01Hz）
  * @retval None
  */
void SEG_DisplayFrequency(uint16_t freq_hz)
{
    memset(d8_buffer, 0xFF, 5);
    
    d7_buffer[0] = seg_code[freq_hz / 10000];
    d7_buffer[1] = seg_code[(freq_hz / 1000) % 10];
    d7_buffer[2] = seg_code[(freq_hz / 100) % 10] & ~0x80;
    d7_buffer[3] = seg_code[(freq_hz / 10) % 10];
    d7_buffer[4] = seg_code[freq_hz % 10];
    
    SEG_SetLED(LED_HZ, 1);
}

/**
  * @brief  显示电流
  * @param  current_da: 电流（单位：0.1A）
  * @retval None
  */
void SEG_DisplayCurrent(uint16_t current_da)
{
    memset(d8_buffer, 0xFF, 5);
    SEG_SetLED(LED_A, 1);
}

/**
  * @brief  显示电压
  * @param  voltage_v: 电压（单位：V）
  * @retval None
  */
void SEG_DisplayVoltage(uint16_t voltage_v)
{
    memset(d8_buffer, 0xFF, 5);
    SEG_SetLED(LED_V, 1);
}

/**
  * @brief  显示错误代码
  * @param  error_code: 错误代码
  * @retval None
  */
void SEG_DisplayError(uint8_t error_code)
{
    memset(d8_buffer, 0xFF, 5);
    d7_buffer[0] = seg_code[14];
    d7_buffer[1] = 0xFF;
    d7_buffer[2] = seg_code[error_code / 100];
    d7_buffer[3] = seg_code[(error_code / 10) % 10];
    d7_buffer[4] = seg_code[error_code % 10];
    
    SEG_SetLED(LED_ALM, 1);
}

/**
  * @brief  设置电机状态
  * @param  state: 电机状态
  * @retval None
  */
void SEG_SetMotorState(MotorState_t state)
{
    switch (state) {
        case MOTOR_STOP:
            SEG_SetLED(LED_RUN, 0);
            SEG_SetLED(LED_FR, 0);
            break;
        case MOTOR_RUN_FORWARD:
            SEG_SetLED(LED_RUN, 1);
            SEG_SetLED(LED_FR, 0);
            break;
        case MOTOR_RUN_REVERSE:
            SEG_SetLED(LED_RUN, 1);
            SEG_SetLED(LED_FR, 1);
            break;
        case MOTOR_ALARM:
            SEG_SetLED(LED_RUN, 0);
            SEG_SetLED(LED_ALM, 1);
            break;
    }
}

