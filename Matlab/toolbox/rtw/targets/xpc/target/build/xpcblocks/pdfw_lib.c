/* $Revision: 1.1.2.3 $ */
//===========================================================================
//
// NAME:    pdfw_lib.c
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver firmware interface library
//
// AUTHOR:  Alex Ivchenko
//
// DATE:    12-APR-2000
//
// REV:     0.8
//
// R DATE:  
//
// HISTORY:
//
//      Rev 0.8,     12-MAR-2000,     Initial version.
//      Rev 0.86     18-DEC-2000,     Updated FW
//
//---------------------------------------------------------------------------
//      Copyright (C) 2000 United Electronic Industries, Inc.
//      All rights reserved.
//---------------------------------------------------------------------------
//
#define __NO_VERSION__

#define XPC 1

#ifndef XPC

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
//#include <i86.h>
#include <string.h>

#else
void delay(unsigned int a);
#ifdef __WATCOMC__
#define XPCCALLCONV __syscall
#else
#define XPCCALLCONV 
#endif
#include "tmwtypes.h"
#include <windows.h>
//#include        "io_xpcimport.h"
//#include        "pci_xpcimport.h"
#include        "time_xpcimport.h"
#endif


#include <errno.h>

#ifndef XPC

#include <fcntl.h>
#include <hw/pci.h>
#include <hw/sysinfo.h>

#endif

//#include <mig4nto.h>

//#include <sys/seginfo.h>
//#include <sys/osinfo.h>
//#include <sys/irqinfo.h>
//#include <sys/proxy.h>
//#include <sys/pci.h>
//#include <sys/inline.h>
#ifndef XPC
#include <sys/mman.h> 
#endif
//#include <sys/kernel.h> 

#include "win2qnx.h"
#include "powerdaq.h"
#include "pd_hcaps.h"
#include "pd-int.h"
#include "pdfw_if.h"
#include "pdfwload_i.h"
#include "pdfw_ao_iA.h"  // firmware for PD2-AO boards
#include "pdfw_mf_iM.h"  // firmware for PD2-MF and MFS boards
#include "pdfw_def.h"



pd_board_t pd_board[PD_MAX_BOARDS];
int num_pd_boards = 0;

// Two following definition substitutes OSAL read/write memory functions
// with QNX kernel ones

#define size_t int

// Firmware interface itself
#include "pdl_fwi.c"
#include "pdl_brd.c"
#include "pdl_ain.c"
#include "pdl_aio.c"
#include "pdl_ao.c"
#include "pdl_dio.c"
#include "pdl_uct.c"
#include "pdl_int.c"
#include "pdl_evt.c"
#include "pdl_init.c"
#include "pd_caps.c"

#include "pd2_dao.c"
