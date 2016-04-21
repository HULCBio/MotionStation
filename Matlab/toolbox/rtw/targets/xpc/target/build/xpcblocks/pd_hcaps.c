/* $Revision: 1.1 $ */
//=======================================================================
//
// NAME:    pd_hcaps.c
//
// SYNOPSIS:
//
//      Capabilities functions file of UEI PowerDAQ DLL
//
//
// DESCRIPTION:
//
//      This file contains easy-to-use caps functions 
//
// OPTIONS: none
//
//
// DIAGNOSTICS:
//
//
// NOTES:   See notice below.
//
// AUTHOR:  Alex Ivchenko 
//
// DATE:    14-JAN-98
//
// DATE:    14-JAN-98
//
// REV:     1.0.6
//
// R DATE:  14-SEP-99
//
// HISTORY:
//
//      Rev 0.1,      14-JAN-98,  A.I.,   Initial version.
//      Rev 1.0.1,    14-MAY-98,  A.I.,   PD_MF family members added
//      Rev 1.0.2,    25-JAN-99,  A.I.,   PD_MF_16_50 added
//      Rev 1.0.3,    10-MAR-99,  A.I.,   PD_MFS_6_1M added
//      Rev 1.0.4,    12-APR-99,  A.I.,   PD2_MF series added
//      Rev 1.0.4a,   16-APR-99,  A.I.,   16-bit compatibility added
//      Rev 1.0.5,    06-MAY-99,  A.I.,   PD2_MF series added
//      Rev 1.0.6,    14-SEP-99,  A.I.,   Integrated into DLL
//
//-----------------------------------------------------------------------
//
//      Copyright (C) 1998 United Electronic Industries, Inc.
//      All rights reserved.
//      United Electronic Industries Confidential Information.
//
//-----------------------------------------------------------------------
//
// Notice:
//
//      To be included into user Visual C++ or Borland C++ application
//
//=======================================================================



#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "pwrdaq.h"
#include "pd32hdr.h"
#include "pwrdaq32.h"
#include "pd_hcaps.h"
#include "pdfw_def.h"

extern Adapter_Info AdpInfo[MAX_PWRDAQ_ADAPTERS];

extern PD_ADAPTER_INFO AdapterInfo[MAX_PWRDAQ_ADAPTERS];

//=======================================================================
// Function returns pointer to DAQ_Information structure for dwBoardID 
// board (stored in PCI Configuration Space
//
// If dwBoardID is incorrect function returns NULL
//
DAQ_Information*  _PdGetCapsPtr(DWORD dwBoardID)
{
    if ((dwBoardID > PD_BRD_BASEID + PD_BRD_LST)|| 
        (dwBoardID < PD_BRD_BASEID)) return NULL;
    return (DAQ_Information*) &DAQ_Info[dwBoardID - PD_BRD_BASEID];
}

//=======================================================================
// Function returns pointer to DAQ_Information structure for dwBoardID 
// board (stored in PCI Configuration Space) using handle to adapter
//
// Returns TRUE if success and FALSE if failure
//
BOOL  _PdGetCapsPtrA(HANDLE hAdapter, DWORD* pdwError, PDAQ_Information* pDaqInf)
{
    PWRDAQ_PCI_CONFIG PciConfig;
    BOOL    bRes;   

    bRes = PdGetPciConfiguration(hAdapter, pdwError, &PciConfig);
    
    *pDaqInf = _PdGetCapsPtr(PciConfig.SubsystemID & 0xFFF);
    
    return bRes;
}

//=======================================================================
// Function parse channel definition string in DAQ_Information structure
// 
// Parameters:  dwBoardID -- board ID from PCI Config.Space
//              dwSubsystem -- subsystem enum from pwrdaq.h
//              dwProperty -- property of subsystem to retrieve:
//                  PDHCAPS_BITS       -- subsystem bit width
//                  PDHCAPS_FIRSTCHAN  -- first channel available
//                  PDHCAPS_LASTCHAN   -- last channel available
//                  PDHCAPS_CHANNELS   -- number of channels available
//
DWORD _PdParseCaps(DWORD dwBoardID, DWORD dwSubsystem, DWORD dwProperty)
{
    char    cSS[10];
    char    cST[100];
    char*   pcTok1;
    char*   pcTok2;
    BOOL    bDone = FALSE;
    DWORD   dwBits = 0;
    DWORD   dwFirstCh = 0;
    DWORD   dwLastCh = 0;

    if ((dwBoardID > PD_BRD_BASEID + PD_BRD_LST)|| 
        (dwBoardID < PD_BRD_BASEID)) return FALSE;

    // What subsystem is requested
    switch (dwSubsystem)
    {
        case AnalogIn:      strcpy(cSS, "AI"); break;
        case AnalogOut:     strcpy(cSS, "AO"); break;
        case DigitalIn:     strcpy(cSS, "DI"); break;
        case DigitalOut:    strcpy(cSS, "DO"); break;
        case CounterTimer:  strcpy(cSS, "CT"); break;
        default: return FALSE; 
    }

    // First, find needed subsystem
    strcpy(cST, DAQ_Info[dwBoardID - PD_BRD_BASEID].lpChannels);
    pcTok1 = strtok(cST, " ");
    while ((pcTok1)&&(!bDone))
    {
        // check, is it our subsystem
        if (strstr(pcTok1, cSS))     // subsystem found
        {
            pcTok2 = strtok(pcTok1, ":");
            if (pcTok2) dwBits = atol(pcTok2);
            pcTok2 = strtok(NULL, ":");
            pcTok2 = strtok(NULL, ":");
            if (pcTok2) dwFirstCh = atol(pcTok2);
            pcTok2 = strtok(NULL, ":");
            if (pcTok2) dwLastCh = atol(pcTok2);
            bDone = TRUE;
        }
        pcTok1 = strtok(NULL, " ");
    }
    if (!bDone) return FALSE;

    // what to return
    switch (dwProperty)
    {
        case PDHCAPS_BITS: return dwBits; break;
        case PDHCAPS_FIRSTCHAN: return dwFirstCh; break;
        case PDHCAPS_LASTCHAN: return dwLastCh; break;
        case PDHCAPS_CHANNELS: return (dwLastCh - dwFirstCh + 1); break;
        default: return FALSE;
    }

}


//=======================================================================
// Function fills up Adapter_Info structure distributed by DLL
//
// Returns TRUE if success
//
int pd_get_adapter_info(int board,					// Number of board
                       Adapter_Info* pAdInfo   // Pointer to the structure to
                                                         // store data (allocated by app)
                               )
{
  
    PDAQ_Information    pDaqInfo;
    DWORD               dwID, dwRangeVal;
    char                cST[80];
    char*               pcTok;
    char*               pc;
    BOOL                bUP, bBP;
    DWORD               id;

 
 
    // Start filling the structure

    // Get pointer to board caps
    pDaqInfo = _PdGetCapsPtr(pd_board[board].Pci_Config..SubsystemID & 0xFFF);

    // Clear structure
    memset( pAdInfo, 0, sizeof(Adapter_Info));


    // Fill board level stuff -----------------------------------------
    pAdInfo->dwBoardID = dwID = pd_board[board].Pci_Config.SubsystemID & 0xFFF;

    id = pAdInfo->dwBoardID;
    if (PD_IS_PDXI(pAdInfo->dwBoardID)) id -= 0x100;

    // Find out what type of board is it
    if ((pAdInfo->dwBoardID >= 0x101) && (pAdInfo->dwBoardID <= 0x10E))
        pAdInfo->atType = atPDMF;

    if ((pAdInfo->dwBoardID >= 0x10F) && (pAdInfo->dwBoardID <= 0x110))
        pAdInfo->atType = atPDMFS;

    if (PD_IS_MF(id)) pAdInfo->atType = atPD2MF;
    if (PD_IS_MFS(id)) pAdInfo->atType = atPD2MFS;
    if (PD_IS_DIO(id)) pAdInfo->atType = atPD2DIO;
    if (PD_IS_AO(id)) pAdInfo->atType = atPD2AO;
    
    if (PDL_IS_MFX(id)) pAdInfo->atType = atPD2MF;
    if (PDL_IS_AO(id)) pAdInfo->atType = atPD2AO;
    if (PDL_IS_DIO(id)) pAdInfo->atType = atPD2DIO;

    strcpy(pAdInfo->lpBoardName, pDaqInfo->lpBoardName);
    strcpy(pAdInfo->lpSerialNum, pd_board[board].Eeprom.Header.SerialNumber);

    // Fill Subsystem level stuff
    //
    //
    // All types of multifunctional boards
    if ((pAdInfo->atType & atMF))
    {
      // Analog input section MF, MFS
      pAdInfo->SSI[AnalogIn].dwChannels = _PdParseCaps(dwID, AnalogIn, PDHCAPS_CHANNELS);
      pAdInfo->SSI[AnalogIn].dwChBits = _PdParseCaps(dwID, AnalogIn, PDHCAPS_BITS);
      pAdInfo->SSI[AnalogIn].dwRate = pDaqInfo->iMaxAInRate;

      // gains    
      pAdInfo->SSI[AnalogIn].dwMaxGains = 0;
      strcpy(cST, pDaqInfo->lpAInGains);
      pcTok = strtok(cST, " ");
      while (pcTok)
      {
          pAdInfo->SSI[AnalogIn].fGains[pAdInfo->SSI[AnalogIn].dwMaxGains] = (float)atol(pcTok);
          pAdInfo->SSI[AnalogIn].dwMaxGains++;
          pcTok = strtok(NULL, " ");        // get next token
      }

      // ranges
      pAdInfo->SSI[AnalogIn].dwMaxRanges = 0; 
      strcpy(cST, pDaqInfo->lpAInRanges);
      pcTok = strtok(cST, " ");
      while (pcTok)
      {
          pc = pcTok; // get token
          bUP = FALSE;
          bBP = FALSE;

          while ( *pc != 0 )
          {
              if (*pc == 'U') bUP = TRUE;
              if (*pc == 'B') bBP = TRUE;
              pc++;
              if (bUP || bBP)
                  break;
          }
          dwRangeVal = atol(pc);
          pAdInfo->SSI[AnalogIn].fRangeHigh[pAdInfo->SSI[AnalogIn].dwMaxRanges] = (float)(WORD)dwRangeVal;
          pAdInfo->SSI[AnalogIn].fRangeLow[pAdInfo->SSI[AnalogIn].dwMaxRanges] = 
              (bUP) ? 0 : (- pAdInfo->SSI[AnalogIn].fRangeHigh[pAdInfo->SSI[AnalogIn].dwMaxRanges]);

          pAdInfo->SSI[AnalogIn].fFactor[pAdInfo->SSI[AnalogIn].dwMaxRanges] = 
              (pAdInfo->SSI[AnalogIn].fRangeHigh[pAdInfo->SSI[AnalogIn].dwMaxRanges] * ((bUP)?1:2)) /
              ((pDaqInfo->wAndMask | 0xF)+1);
          pAdInfo->SSI[AnalogIn].fOffset[pAdInfo->SSI[AnalogIn].dwMaxRanges] =
              - pAdInfo->SSI[AnalogIn].fRangeLow[pAdInfo->SSI[AnalogIn].dwMaxRanges];

          pAdInfo->SSI[AnalogIn].dwMaxRanges++;
          pcTok = strtok(NULL, " ");        // get next token
      }
      pAdInfo->SSI[AnalogIn].dwMaxRanges /= 2;
      pAdInfo->SSI[AnalogIn].wXorMask = pDaqInfo->wXorMask;
      pAdInfo->SSI[AnalogIn].wAndMask = pDaqInfo->wAndMask;
      pAdInfo->SSI[AnalogIn].dwFifoSize = pd_board[board].Eeprom.Header.ADCFifoSize * 1024;
      pAdInfo->SSI[AnalogIn].dwChListSize = pd_board[board].Eeprom.Header.CLFifoSize * 256;

      // Analog output section - MF, MFS
      pAdInfo->SSI[AnalogOut].dwChannels = _PdParseCaps(dwID, AnalogOut, PDHCAPS_CHANNELS);
      pAdInfo->SSI[AnalogOut].dwChBits = _PdParseCaps(dwID, AnalogOut, PDHCAPS_BITS);
      pAdInfo->SSI[AnalogOut].dwRate = pDaqInfo->iMaxAOutRate;

      pAdInfo->SSI[AnalogOut].fGains[0] = 1;
      pAdInfo->SSI[AnalogOut].dwMaxGains = 1;

      pAdInfo->SSI[AnalogOut].fRangeLow[0] = -10.0;
      pAdInfo->SSI[AnalogOut].fRangeHigh[0] = 10.0;
      
      pAdInfo->SSI[AnalogOut].fFactor[0] = (0xfff / 20.0);
      pAdInfo->SSI[AnalogOut].fOffset[0] = 10.0;
      pAdInfo->SSI[AnalogOut].dwMaxRanges = 1;

      pAdInfo->SSI[AnalogOut].wXorMask = 0;
      pAdInfo->SSI[AnalogOut].wAndMask = 0xFFF;
      pAdInfo->SSI[AnalogOut].dwFifoSize = 2048;
      pAdInfo->SSI[AnalogOut].dwChListSize = 2;

      // Digital Input/Output section - MF, MFS
      pAdInfo->SSI[DigitalIn].dwChannels = _PdParseCaps(dwID, DigitalIn, PDHCAPS_CHANNELS);
      pAdInfo->SSI[DigitalIn].dwChBits = _PdParseCaps(dwID, DigitalIn, PDHCAPS_BITS);
      pAdInfo->SSI[DigitalIn].dwRate = pDaqInfo->iMaxDIORate;

      pAdInfo->SSI[DigitalOut].dwChannels = _PdParseCaps(dwID, DigitalOut, PDHCAPS_CHANNELS);
      pAdInfo->SSI[DigitalOut].dwChBits = _PdParseCaps(dwID, DigitalOut, PDHCAPS_BITS);
      pAdInfo->SSI[DigitalOut].dwRate = pDaqInfo->iMaxDIORate;

      // Counter-timer section - MF, MFS
      pAdInfo->SSI[CounterTimer].dwChannels = _PdParseCaps(dwID, CounterTimer, PDHCAPS_CHANNELS);
      pAdInfo->SSI[CounterTimer].dwChBits = _PdParseCaps(dwID, CounterTimer, PDHCAPS_BITS);
      pAdInfo->SSI[CounterTimer].dwRate = pDaqInfo->iMaxUCTRate;

    }

    //
    // Analog output boards
    //
    if ((pAdInfo->atType & atPD2AO)) 
    {
      // Analog output section - AO
      pAdInfo->SSI[AnalogOut].dwChannels = _PdParseCaps(dwID, AnalogOut, PDHCAPS_CHANNELS);
      pAdInfo->SSI[AnalogOut].dwChBits = _PdParseCaps(dwID, AnalogOut, PDHCAPS_BITS);
      pAdInfo->SSI[AnalogOut].dwRate = pDaqInfo->iMaxAOutRate;

      pAdInfo->SSI[AnalogOut].fGains[0] = 1;
      pAdInfo->SSI[AnalogOut].dwMaxGains = 1;

      pAdInfo->SSI[AnalogOut].fRangeLow[0] = -10.0;
      pAdInfo->SSI[AnalogOut].fRangeHigh[0] = 10.0;
      
      pAdInfo->SSI[AnalogOut].fFactor[0] = (0xffff / 20.0);
      pAdInfo->SSI[AnalogOut].fOffset[0] = 10.0;
      pAdInfo->SSI[AnalogOut].dwMaxRanges = 1;

      pAdInfo->SSI[AnalogOut].wXorMask = 0x0;
      pAdInfo->SSI[AnalogOut].wAndMask = 0xFFFF;
      pAdInfo->SSI[AnalogOut].dwFifoSize = 2048;
      pAdInfo->SSI[AnalogOut].dwChListSize = 2;

      // Digital Input/Output section - AO
      pAdInfo->SSI[DigitalIn].dwChannels = _PdParseCaps(dwID, DigitalIn, PDHCAPS_CHANNELS);
      pAdInfo->SSI[DigitalIn].dwChBits = _PdParseCaps(dwID, DigitalIn, PDHCAPS_BITS);
      pAdInfo->SSI[DigitalIn].dwRate = pDaqInfo->iMaxDIORate;

      pAdInfo->SSI[DigitalOut].dwChannels = _PdParseCaps(dwID, DigitalOut, PDHCAPS_CHANNELS);
      pAdInfo->SSI[DigitalOut].dwChBits = _PdParseCaps(dwID, DigitalOut, PDHCAPS_BITS);
      pAdInfo->SSI[DigitalOut].dwRate = pDaqInfo->iMaxDIORate;

      // Counter-timer section - AO
      pAdInfo->SSI[CounterTimer].dwChannels = _PdParseCaps(dwID, CounterTimer, PDHCAPS_CHANNELS);
      pAdInfo->SSI[CounterTimer].dwChBits = _PdParseCaps(dwID, CounterTimer, PDHCAPS_BITS);
      pAdInfo->SSI[CounterTimer].dwRate = pDaqInfo->iMaxUCTRate;

    }

    //
    // Digital input/output boards
    //
    if ((pAdInfo->atType == atPD2DIO)) 
    {
      // Digital Input/Output section - DIO
      pAdInfo->SSI[DigitalIn].dwChannels = _PdParseCaps(dwID, DigitalIn, PDHCAPS_CHANNELS);
      pAdInfo->SSI[DigitalIn].dwChBits = _PdParseCaps(dwID, DigitalIn, PDHCAPS_BITS);
      pAdInfo->SSI[DigitalIn].dwRate = pDaqInfo->iMaxDIORate;

      pAdInfo->SSI[DigitalOut].dwChannels = _PdParseCaps(dwID, DigitalOut, PDHCAPS_CHANNELS);
      pAdInfo->SSI[DigitalOut].dwChBits = _PdParseCaps(dwID, DigitalOut, PDHCAPS_BITS);
      pAdInfo->SSI[DigitalOut].dwRate = pDaqInfo->iMaxDIORate;

      // Counter-timer section - DIO
      pAdInfo->SSI[CounterTimer].dwChannels = _PdParseCaps(dwID, CounterTimer, PDHCAPS_CHANNELS);
      pAdInfo->SSI[CounterTimer].dwChBits = _PdParseCaps(dwID, CounterTimer, PDHCAPS_BITS);
      pAdInfo->SSI[CounterTimer].dwRate = pDaqInfo->iMaxUCTRate;

    }
    return 0;
}



//
// Converts analog input data from raw format to volts (for MF/MFS boards)
//
//
int PdAInRawToVolts( HANDLE hAdapter,
                       DWORD dwMode,          // Mode used
                       WORD* wRawData,          // Raw data
                       double* fVoltage,        // Engineering unit
                       DWORD dwCount            // Number of samples to convert
                     )
{
    DWORD   i;
    PAdapter_Info pAdInfo = AdpInfo;

    // check parameters
    if (!(wRawData && fVoltage && dwCount)) return FALSE;

    // Calculate pointer
    i = 0;
    while (i < MAX_PWRDAQ_ADAPTERS)
    {
        if (AdapterInfo[i].hAdapter == hAdapter)
            break;
        else
            i++;
    }
    if (i == MAX_PWRDAQ_ADAPTERS) return FALSE;
    pAdInfo += i;

    // Perform one-channel conversion
    for (i = 0; i < dwCount; i++)
    {
        *(fVoltage + i) = ((*(wRawData + i) & pAdInfo->SSI[AnalogIn].wAndMask) ^ pAdInfo->SSI[AnalogIn].wXorMask) *
                          pAdInfo->SSI[AnalogIn].fFactor[(dwMode & 0x6)>>1] -
                          pAdInfo->SSI[AnalogIn].fOffset[(dwMode & 0x6)>>1];

    }   

    return TRUE;
}

//
// Converts volts to analog ouput raw data (for MF/MFS/AO boards)
//
//
int PdAOutVoltsToRaw( HANDLE hAdapter,
                        DWORD dwMode,            // Mode used
                        double* fVoltage,        // Engineering unit
                        DWORD* dwRawData,        // Raw data
                        DWORD dwCount            // Number of samples to convert
                      )
{
    DWORD   i;
    //DWORD   j, dwCh0, dwCh1;
    PAdapter_Info pAdInfo = AdpInfo;

    // check parameters
    if (!(dwRawData && fVoltage && dwCount)) return FALSE;

    // Calculate pointer
    i = 0;
    while (i < MAX_PWRDAQ_ADAPTERS)
    {
        if (AdapterInfo[i].hAdapter == hAdapter)
            break;
        else
            i++;
    }
    if (i == MAX_PWRDAQ_ADAPTERS) return FALSE;
    pAdInfo += i;

    if (pAdInfo->atType & atMF)
    {
      for (i = 0; i < dwCount; i++)
      {
        *(dwRawData + i) = (DWORD)(( *(fVoltage+i) + pAdInfo->SSI[AnalogOut].fOffset[0]) * pAdInfo->SSI[AnalogOut].fFactor[0]);
      }

    } else {

        for (i = 0; i < dwCount; i++)
      {
        *(dwRawData + i) = (DWORD)(( *(fVoltage+i) + pAdInfo->SSI[AnalogOut].fOffset[0]) * pAdInfo->SSI[AnalogOut].fFactor[0]);
      }
    }

//    if (pAdInfo->atType & atMF)
//    { 
//        // Do MF AOut conversion
//        for (i = 0, j = 0; i < dwCount; i+2, j++)
//        {
//            dwCh0 = (DWORD)(*(fVoltage+i) * pAdInfo->SSI[AnalogOut].fFactor[0] - pAdInfo->SSI[AnalogOut].fOffset[0]);
//            dwCh1 = (DWORD)(*(fVoltage+i+1) * pAdInfo->SSI[AnalogOut].fFactor[0] - pAdInfo->SSI[AnalogOut].fOffset[0]);
//            *(dwRawData + j) = dwCh0 | dwCh1;
//        }
//    } else {
//        // Do AO32 conversion
//        for (i = 0; i < dwCount; i++)
//        {
//            *(dwRawData + i) = (DWORD)(*(fVoltage+i) * pAdInfo->SSI[AnalogOut].fFactor[0] - pAdInfo->SSI[AnalogOut].fOffset[0]);
//            *(dwRawData + i) ^= pAdInfo->SSI[AnalogOut].wXorMask;
//        }
//    }

    return TRUE;
}




















