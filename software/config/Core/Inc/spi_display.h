/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : spi_display.h
  * @brief          : SPI Display Driver Header
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __SPI_DISPLAY_H
#define __SPI_DISPLAY_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

/* SPI句柄（在main.c中定义） */
extern SPI_HandleTypeDef hspi2;

/* LATCH引脚定义（PB7，74HC595的RCLK和74HC165的SH/LD共用） */
#define DISPLAY_LATCH_PIN       GPIO_PIN_7
#define DISPLAY_LATCH_PORT      GPIOB
#define DISPLAY_LATCH_LOW()     HAL_GPIO_WritePin(DISPLAY_LATCH_PORT, DISPLAY_LATCH_PIN, GPIO_PIN_RESET)
#define DISPLAY_LATCH_HIGH()    HAL_GPIO_WritePin(DISPLAY_LATCH_PORT, DISPLAY_LATCH_PIN, GPIO_PIN_SET)

/* 按键LOAD引脚定义（与LATCH共用PB7） */
#define KEY_LOAD_LOW()          DISPLAY_LATCH_LOW()
#define KEY_LOAD_HIGH()         DISPLAY_LATCH_HIGH()

void SPI_Display_Init(void);
void SPI_Display_SendData(uint8_t *data, uint8_t len);
uint16_t SPI_Key_Read9Bits(void);

#ifdef __cplusplus
}
#endif

#endif /* __SPI_DISPLAY_H */

