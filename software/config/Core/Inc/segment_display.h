/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : segment_display.h
  * @brief          : 10-digit display driver (2×5 digits + 6 LEDs)
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __SEGMENT_DISPLAY_H
#define __SEGMENT_DISPLAY_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

/* 显示配置 */
#define SEG_DIGIT_NUM_D7    5
#define SEG_DIGIT_NUM_D8    5
#define SEG_TOTAL_DIGITS    10
#define SEG_LED_NUM         6
#define SEG_REFRESH_TIME    2

/* LED功能定义 */
#define LED_HZ      0
#define LED_A       1
#define LED_V       2
#define LED_ALM     3
#define LED_FR      4
#define LED_RUN     5

/* 显示模式 */
typedef enum {
    DISPLAY_MODE_FREQ,
    DISPLAY_MODE_CURRENT,
    DISPLAY_MODE_VOLTAGE,
    DISPLAY_MODE_ERROR
} DisplayMode_t;

/* 电机状态 */
typedef enum {
    MOTOR_STOP,
    MOTOR_RUN_FORWARD,
    MOTOR_RUN_REVERSE,
    MOTOR_ALARM
} MotorState_t;

/* 基础函数 */
void SEG_Init(void);
void SEG_SetDigit_D7(uint8_t pos, uint8_t value, uint8_t dp);
void SEG_SetDigit_D8(uint8_t pos, uint8_t value, uint8_t dp);
void SEG_SetNumber_D7(uint32_t number);
void SEG_SetNumber_D8(uint32_t number);
void SEG_DisplayString_D7(const char *str);
void SEG_DisplayString_D8(const char *str);
void SEG_SetLED(uint8_t led_id, uint8_t state);
void SEG_ClearAllLED(void);
void SEG_Clear(void);
void SEG_Refresh(void);

/* 应用层函数 */
void SEG_DisplayFrequency(uint16_t freq_hz);
void SEG_DisplayCurrent(uint16_t current_da);
void SEG_DisplayVoltage(uint16_t voltage_v);
void SEG_DisplayError(uint8_t error_code);
void SEG_SetMotorState(MotorState_t state);

#ifdef __cplusplus
}
#endif

#endif /* __SEGMENT_DISPLAY_H */

