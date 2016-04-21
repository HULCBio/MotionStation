/* $Revision: 1.2 $ */
/* dopci6527.c - xPC Target, non-inlined S-function driver for digital output */
/* section for the National Instruments 6527 board */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

typedef struct {
    volatile unsigned char input[3];      // 0, 1, 2
    volatile unsigned char output[3];     // 3, 4, 5
    volatile unsigned char id;            // 6
    volatile unsigned char clear;         // 7
    volatile unsigned char filter_interval[3];  // 8, 9, 0xA
    unsigned char dummy1;           // 0xB
    volatile unsigned char filter_enable[3];  // 0xC, 0xD, 0xE
    unsigned char dummy2[5];               // 0xF to 0x13
    volatile unsigned char intstatus;      // 0x14
    volatile unsigned char intcontrol;     // 0x15
    unsigned char dummy3[2];               // 0x16 and 0x17
    volatile unsigned char intrising[3];   // 0x18, 0x19, 0x1A
    unsigned char dummy4[5];               // 0x1B to 0x1F
    volatile unsigned char intfalling[3];  // 0x20, 0x21, 0x22
} regs_6527;

#define ID_6527                 0x27
