/* $Revision: 1.1 $ */
/*
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
*/

static int caldac_wr(int, unsigned int, int, unsigned int);
static int eeprom_read(int,unsigned int, int, unsigned int*);
/* int eeprom_write(int, unsigned int, int, unsigned int); */


/* Board Types */

#define  AT_MIO_16X        0   /* 128X8 eeprom */
#define  AT_MIO_64F_5      1   /* 128X8 eeprom */
#define  AT_MIO_16F_5      2   /* 64X16 eeprom */
#define  AT_AO_6_10        3   /* 128X16 eeprom */
#define  EISA_A2000        4	  /* Not Supported yet */

#define  MAX_BRDTYPE_NUM         3  


/* max and min board base addresses */

#define  MIN_BASE_ADDR           0x100
#define  MAX_BASE_ADDR           0x3E0


/* max addresses for the different eeprom types */

#define  MAX_128X16_ADDR         127
#define  MAX_128X8_ADDR          127
#define  MAX_64X16_ADDR          63

#define  MAX_128X16_WRITE_ADDR   95
#define  MAX_128X8_WRITE_ADDR    95
#define  MAX_64X16_WRITE_ADDR    51

#define  MAX_128X16_VALUE        0xFFFF
#define  MAX_128X8_VALUE         0xFF
#define  MAX_64X16_VALUE         0xFFFF


/* macros */

#define  OUT_OF_RANGE(x,y,z)     ((((x)<(y)) || ((x)>(z)))?   1:0)


/* 16X and 64F5 register macros;  base_addr is a variable defined
   in the eeprom and caldac functions */

#define  ATMIO_16X_COMM1_REG     (base_addr + 0x0)
#define  ATMIO_16X_STAT0_REG     (base_addr + 0x18)
#define  ATMIO_16X_DAC0LD_REG    (base_addr + 0x0A)
#define  ATMIO_16X_DAC1LD_REG    (base_addr + 0x1A)
         
/* 16F5 register macros */

#define  ATMIO_16F5_COMM1_REG    (base_addr + 0x0)
#define  ATMIO_16F5_STAT_REG     (base_addr + 0x0)

/* AO6-10 register macros */

#define  AO_6_10_CFG1_REG        (base_addr + 0xA)
#define  AO_6_10_CFG2_REG        (base_addr + 0x2)
#define  AO_6_10_STAT_REG        (base_addr + 0xA)


/* error codes */

/*#define  NO_ERROR                   0 */
#define  EEPROM_MODE_ERROR          1
#define  EEPROM_WAIT_ERROR          2

#define  FUNCTION_OUT_OF_RANGE      3
#define  BRDTYPE_OUT_OF_RANGE       4
#define  BASE_ADDR_OUT_OF_RANGE     5
#define  EEPROM_ADDR_OUT_OF_RANGE   6
#define  VALUE_OUT_OF_RANGE         7
#define  DAC_OUT_OF_RANGE           8


/* eeprom constants and commands */

#define  CMD_128X16_CNT             11       /* at_ao_6_10                  */
#define  CMD_128X8_CNT              10       /* at_mio_16X and at_mio_64f_5 */
#define  CMD_64X16_CNT              9        /* at_mio_16f_5                */

#define  WRITE_128X16_CNT           16
#define  WRITE_128X8_CNT            8
#define  WRITE_64X16_CNT            16

#define  READ_128X16_CNT            16
#define  READ_128X8_CNT             8
#define  READ_64X16_CNT             16

#define  EEPROM_128X16_READ         0x0600
#define  EEPROM_128X16_WRITE        0x0500
#define  EEPROM_128X16_EWEN         0x04C0

#define  EEPROM_128X8_READ          0x0300
#define  EEPROM_128X8_WRITE         0x0280
#define  EEPROM_128X8_EWEN          0x0260

#define  EEPROM_64X16_READ          0x0180
#define  EEPROM_64X16_WRITE         0x0140
#define  EEPROM_64X16_EWEN          0x0130
