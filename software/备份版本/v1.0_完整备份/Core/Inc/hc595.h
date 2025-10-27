/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : hc595.h
  * @brief          : 74HC595 Shift Register Driver Header
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __HC595_H
#define __HC595_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

void HC595_Init(void);
void HC595_SendData(uint8_t data1, uint8_t data2, uint8_t data3);

#ifdef __cplusplus
}
#endif

#endif /* __HC595_H */
