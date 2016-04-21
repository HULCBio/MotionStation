/* $Revision: 1.2 $ $Date: 2002/03/25 04:13:32 $ */
/* diobvmpmcdio64.h - xPC Target, header file that describes common pieces of
 * the digital input and digital output sections of the BVM PMCDIO64 board */
/* Copyright 1996-2002 The MathWorks, Inc. */

// Define the register map structure

struct dio64regs {
    uint32_T inlow;
    uint32_T inhigh;
    uint32_T outlow;
    uint32_T outhigh;
    uint32_T flaglow;
    uint32_T flaghigh;
    uint8_T  direction;
    uint8_T  function;
    uint16_T statuscontrol;
};

