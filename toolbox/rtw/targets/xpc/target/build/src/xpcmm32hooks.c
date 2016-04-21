// Hook functions for Diamond MM-32 frame-based A/D driver
// Copyright 2003 The MathWorks, Inc.

#ifndef __XPCMM32HOOKS_C__
#define __XPCMM32HOOKS_C__

#define MISC_CONTROL_REGISTER       (8) 
#define OPERATION_CONTROL_REGISTER  (9) 

#ifdef _MSC_VER            // Visual C/C++
#define OUTP _outp
#define INP  _inp
#elif defined(__WATCOMC__) // WATCOM C/C++
#define OUTP outp
#define INP  inp
#else                      // error out
#define OUTP
#define INP
#endif

#include <conio.h>
#include <windows.h>
#include "pci_xpcimport.h"

void __cdecl xpcmm32prehook(PCIDeviceInfo *pci);
void __cdecl xpcmm32posthook(PCIDeviceInfo *pci);
void __cdecl xpcmm32start(int vendor_id, int device_id, int slot);
void __cdecl xpcmm32stop(int vendor_id, int device_id, int slot);

void __cdecl xpcmm32prehook(PCIDeviceInfo *pci)
{
    OUTP((unsigned short)(pci->BaseAddress[0] + MISC_CONTROL_REGISTER), 0
        | 0x08 * 1  // INTRST: reset A/D interrupt on the board
        );

    OUTP((unsigned short)(pci->BaseAddress[0] + OPERATION_CONTROL_REGISTER), 0
        | 0x80 * 0  // ADINTE: enable A/D interrupt        
        | 0x02 * 1  // CLKEN:  enable A/D sampling clock
        | 0x01 * 1  // CLKSEL: select internal H/W clock 
        );
    return;
}

void __cdecl xpcmm32posthook(PCIDeviceInfo *pci)
{
    OUTP((unsigned short)(pci->BaseAddress[0] + OPERATION_CONTROL_REGISTER), 0
        | 0x80 * 1  // ADINTE: enable A/D interrupt        
        | 0x02 * 1  // CLKEN:  enable A/D sampling clock
        | 0x01 * 1  // CLKSEL: select internal H/W clock 
        );
    return;
}

void __cdecl xpcmm32start(int vendor_id, int device_id, int slot)
{
    _asm { cli };
    OUTP((unsigned short)(slot + OPERATION_CONTROL_REGISTER), 0
        | 0x80 * 1  // ADINTE: enable analog interrupt        
        | 0x02 * 1  // CLKEN:  enable A/D sampling clock
        | 0x01 * 1  // CLKSEL: select internal H/W clock 
        );
    _asm { sti };
    return;
}

void __cdecl xpcmm32stop(int vendor_id, int device_id, int slot)
{
    _asm { cli };
    OUTP((unsigned short)(slot + OPERATION_CONTROL_REGISTER), 0
        | 0x80 * 0  // ADINTE: enable A/D interrupt        
        | 0x02 * 0  // CLKEN:  enable A/D sampling clock
        | 0x01 * 1  // CLKSEL: select internal H/W clock 
        );
    _asm { sti };
    return;
}

#endif // __XPCMM32HOOKS_C__
