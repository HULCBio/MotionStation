/* $Revision: 1.2 $ $Date: 2002/03/25 04:13:50 $ */
/* multidsrubymm.h - Constant definitions for the Diamond */
/* Systems Ruby-MM D to A and discrete IO pc104 board.    */
/* Copyright 1996-2002 The MathWorks, Inc. */

// Register map, register offsets from IO base address.
#define C0MSB         0
#define C1MSB         1
#define C2MSB         2
#define C3MSB         3
#define C4MSB         4
#define C5MSB         5
#define C6MSB         6
#define C7MSB         7
#define LSB           8
#define RESET         9
#define CONFIG       10
// offset 11 is not used.
#define DIOA         12
#define DIOB         13
#define DIOC         14
#define DIOCONTROL   15

#define UNIPOLAR      0
#define BIPOLAR       1
