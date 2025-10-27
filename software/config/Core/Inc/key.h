/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : key.h
  * @brief          : Key scan driver header
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __KEY_H
#define __KEY_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

/* 按键数量：SER + D0-D7 = 9个按键 */
#define KEY_NUM  9

/* 按键ID定义（对应74HC165的引脚） */
typedef enum {
    KEY_NONE = 0,
    KEY_RUN = 1,         // SER（bit8）
    KEY_RESERVED = 2,    // D0（bit0）
    KEY_ENTER = 3,       // D1（bit1）
    KEY_FUNC = 4,        // D2（bit2）
    KEY_STOP = 5,        // D3（bit3）
    KEY_DOWN = 6,        // D4（bit4）
    KEY_RPG = 7,         // D5（bit5）
    KEY_SHIFT = 8,       // D6（bit6）
    KEY_UP = 9           // D7（bit7）
} KEY_ID;

void KEY_Init(void);
uint8_t KEY_Scan(void);
uint16_t KEY_Read(void);

#ifdef __cplusplus
}
#endif

#endif /* __KEY_H */

