/* $Revision: 1.1.6.2 $ */
//===========================================================================
//
// NAME:    powerdaq-internal.h
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver definitions needed for kernel driver only
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
//
//
//---------------------------------------------------------------------------
//      Copyright (C) 2000 United Electronic Industries, Inc.
//      All rights reserved.
//---------------------------------------------------------------------------
//
#ifndef __POWER_DAQ_INTERNAL_H__
#define __POWER_DAQ_INTERNAL_H__

#include "powerdaq.h"
#include "pdfw_def.h"
#include "win2qnx.h"

// The max number of boards the driver can deal with.
#define PD_MAX_BOARDS 32

// Some ID strings for the driver.
#define PD_VERSION "PowerDAQ QNX driver, release 0.1 (beta 0)\n"

#define PD_ID
#define KERN_ERR
#define _NO_USERSPACE

// General debug messages
//#define PD_DEBUG

// Subsystem States (State):
typedef enum {
    ssConfig            = 0,        // configuration state (default)
    ssStandby           = 1,        // on standby ready to start
    ssRunning           = 2,        // running
    ssPaused            = 3,        // paused
    ssStopped           = 4,        // stopped
    ssDone              = 5,        // operation done, stopped
    ssError             = 6         // error condition, stopped
} PDSubsystemState;

// DaqBuf Get DaqBuf Status Info Struct
typedef struct
{
    u32   ScanValues;       // maximum number of scans in buffer
    u32   MaxValues;        // maximum number of samples in buffer
    u32   FrameValues;      // maximum number of frames in buffer

    u32   ScanIndex;        // buffer index of first scan
    u32   NumValidValues;   // number of valid values available
    u32   NumValidScans;    // number of valid scans available
    u32   NumValidFrames;   // number of valid frames available
    u32   WrapCount;        // total num times buffer wrapped
    u32   ScanSize;         // scan size in samples (2 bytes each)
    u32   FrameSize;        // frame size in scans
    u32   NumFrames;        // number of scans
    u16*  databuf;          // pointer to the buffer contains samples
    u32   Head;             // head of the buffer
    u32   Tail;             // tail of the buffer
    u32   Count;            // current position in the buffer
    u32   ValueCount;       // number of samples
    u32   ValueIndex;       // sample index
    u32   BufMode;          // mode of buffer usage
    u32   bWrap;            // buffer is in the "WRAPPED" mode
    u32   bRecycle;         // buffer is in the "RECYCLED" mode

    u32   XferBufValues;    // number of values in Xfer buffer
    u16*  XferBuf;          // DMA ready driver buffer
    u32   XferBufValueCount;// number of samples written to Xfer buffer
    u32   BlkXferValues;    // ???

} TBuf_Info, * PTBuf_Info;

// this structure holds information about AIn subsystem
typedef struct
{
    u32   SubsysState;            // current subsystem state
    u32   SubsysConfig;           // keeps latest AIn configuration
    u32   dwAInCfg;               // AIn configuration word
    u32   dwAInPreTrigCount;      // pre-trigger scan count
    u32   dwAInPostTrigCount;     // post-trigger scan count
    u32   dwCvRate;               // conversion start clock divider
    u32   dwClRate;               // channel list start clock divider
    u32   dwEventsNotify;         // subsystem user events notification
    u32   dwEventsStatus;         // subsystem user events status
    u32   dwEventsNew;            // new events
    u32   dwChListChan;           // number of channels in list
    u32   ChList[PD_MAX_CL_SIZE]; // channel list data buffer
    TBuf_Info BufInfo;            // buffer information
    TScan_Info ScanInfo;          // scan information
    u32   FifoValues;             // ???
    u32   bInUse;                 // TRUE -> SS is in use
    int   iPID;                   // PID of the process owned subsystem

} TAinSS, * PTAinSS;

// this structure holds information about AOut subsystem
typedef struct 
{
    u32   SubsysState;
    u32   dwMode;
    u32   dwCvRate;
    u32   dwAoutValue;
    u32   dwEventsNotify;   
    u32   dwEventsStatus;
    u32   dwEventsNew;
    TBuf_Info BufInfo;
    TScan_Info ScanInfo;
    u32   bInUse;                 // TRUE -> SS is in use
    int   iPID;                   // PID of the process owned subsystem

} TAoutSS, * PTAoutSS;

// this structure holds information about UCT subsystem
typedef struct 
{
    u32   SubsysState;
    u32   dwMode;
    u32   dwCvRate;
    u32   dwEventsNotify;   
    u32   dwEventsStatus;
    u32   dwEventsNew;
    u32   bInUse;                 // TRUE -> SS is in use
    int   iPID;                   // PID of the process owned subsystem

} TUctSS, * PTUctSS;

// this structure holds information about DIO subsystem
typedef struct 
{
    u32   SubsysState;
    u32   dwMode;
    u32   dwCvRate;
    u32   dwEventsNotify;   
    u32   dwEventsStatus;
    u32   dwEventsNew;
    u32   bInUse;                 // TRUE -> SS is in use
    int   iPID;                   // PID of the process owned subsystem

} TDioSS, * PTDioSS;


//
// this structure holds everything the driver knows about a board
//
typedef struct 
{
   struct pci_dev *dev;
   void *address;
   u32 size;

   int irq;
   int open;
   int bTestInt;     // TRUE for interrupt test

   u32 HI32CtrlCfg;
   u16 caps_idx;    // board type index in pd_hcaps.h

   struct fasync_struct *fasync;  // for asynchronous notification (SIGIO)

   // Subsystem-related variables
   TAinSS  AinSS;
   TAoutSS AoutSS;
   TUctSS  UctSS;
   TDioSS  DioSS;
   PD_EEPROM Eeprom;
   PD_PCI_CONFIG PCI_Config;
   int bImmUpdate;
   int fd[MAX_PWRDAQ_SUBSYSTEMS];

   // Event-related variables
   TEvents FwEventsConfig;   // current adapter's events config
   TEvents FwEventsNotify;   // firmware events to notify      
   TEvents FwEventsStatus;   // firmware event status saved
   
} pd_board_t;


//  The max number of times to poll the board before we declare it dead.
#define MAX_PCI_BUSY_WAIT 0x10000

//  The max number of milliseconds to wait for the board to act before we
//  declare it dead.  This is not currently used.
#define MAX_PCI_WAIT 1000

// AIn/AOut temporary storage data transfer buffer definition.
//
// Size set to be sufficient to store AIn/AOut FIFO samples.
//      (AIn/AOut FIFO samples * 2 bytes/sample)
//
#define PD_AIN_MAX_FIFO_VALUES  0x400
#define PD_AOUT_MAX_FIFO_VALUES 0x400
#define ANALOG_XFERBUF_VALUES   (PD_AIN_MAX_FIFO_VALUES)
#define ANALOG_XFERBUF_SIZE     (ANALOG_XFERBUF_VALUES * sizeof(WORD))

#endif


