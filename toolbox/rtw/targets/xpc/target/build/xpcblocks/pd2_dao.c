/* $Revision: 1.1 $ */
//===========================================================================
//
// NAME:    pd2_dao.c
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver PD2-DIO and PD2-AO function set
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

//#include <errno.h>
//#include "../win2qnx.h"
//#include "../powerdaq.h"
//#include "../pd-int.h"
//#include "../pdfw_def.h"
//#include "../pdfw_if.h"

//+
// Function:    _PdDIO256CmdRead
//
// Description: Internal functions help to creates a command
//_
u32 __PdDIO256MakeCmd(u32 dwRegister)
{
    u32 dwCmd = 0;
    switch (dwRegister)
    {
        case 0: dwCmd |= DIO_REG0; break;
        case 1: dwCmd |= DIO_REG1; break;
        case 2: dwCmd |= DIO_REG2; break;
        case 3: dwCmd |= DIO_REG3; break;
        case 4: dwCmd |= DIO_REG4; break;
        case 5: dwCmd |= DIO_REG5; break;
        case 6: dwCmd |= DIO_REG6; break;
        case 7: dwCmd |= DIO_REG7; break;
        default: dwCmd |= DIO_REG0; break;
    }
    return dwCmd;
}

//+
// Function:    _PdDIO256CmdRead
//
// Parameters:  u32 dwBank -- number of I/O bank (0 or 1)
//              u32 dwRegMask -- register mask
//
// Description: function forms bits 0-4 to write to DIO board
//
// Notes:       1. dwBank: 0-3 = bank 0; 4-7 = bank 1 (bXX)
//              2. DIO control command when register mask is used
//                 cmd1 cmd0 r3 r2 bank r1 r0
//-
u32 __PdDIO256MakeRegMask(u32 dwBank, u32 dwRegMask)
{
    u32   dwReg = dwBank;
    dwReg = (dwReg & 0x4);
    dwReg |= (dwRegMask & 0x3);
    dwReg |= ((dwRegMask << 1) & 0x18);
    return dwReg;
}

//+
// Function:    _PdDIOReset
//
// Parameters:  int board -- board to adapter
//
// Returns:     Negative error code or 0
//
// Description: Resets PD2-DIO board, disables (switches to DIn)
//              all DIO lines
// Notes:
//
//-
int _PdDIOReset(int board)
{
    int    bRes = TRUE;
    bRes &= pd_dio256_write_output(board, DIO_DIS_0_3,
                              0);
    bRes &= pd_dio256_write_output(board, DIO_DIS_4_7,
                              0);
    return bRes;
}

//+
// Function:    _PdDIOEnableOutput
//
// Parameters:  int board -- board to adapter
//              u32 dwRegMask -- mask of the registers to enable output
//
// Returns:     Negative error code or 0
//
// Description: Set output enable
//
// Notes: 1. dwRegMask selects which of 16-bit register set as DIn and which
//          as DOut. If register is in DIn it's tristated.
//          PD2-DIO64 uses only four lower bits of dwRegMask and PD2-DIO128 - eight
//          of them. Rest of the bits should be zero.
//
//        2. dwRegMask format: r7 r6 r5 r4 r3 r2 r1 r0
//          1 in the dwRegMask means that register is selected for output
//          0 means that register is selected for input
//          Example: To select registers 0,1 and 4,5 for output
//          dwRegMask = 0x33 ( 00110011 )
//-
int _PdDIOEnableOutput(int board, u32 dwRegMask)
{
     u32 dwRegM = ~dwRegMask;
     int  bRes = TRUE;

     bRes &= pd_dio256_write_output(board,
                               __PdDIO256MakeRegMask(DIO_REG0 & 0xF, (dwRegM & 0xF)) | DIO_WOE,
                               0);
     bRes &= pd_dio256_write_output(board,
                               __PdDIO256MakeRegMask(DIO_REG4 & 0xF, (dwRegM & 0xF0)>>4 ) | DIO_WOE,
                               0);
     return bRes;
}

//+
// Function:    _PdDIOLatchAll
//
// Parameters:  int board -- board to adapter
//              u32 dwRegister -- register
//
// Returns:     Negative error code or 0
//
// Description: Latch the state of all inputs in a bank
//              This function strobe latch signal and data presents
//              on the input lines is clocked into registers.
//              Use this function to latch all inputs are the same time
//              (simultaneously) and function _PdDIOSimpleRead to read latched
//              registers one by one (withuot re-latching them).
//
// Notes:       Function latches data for only one bank (16 x 4 lines)
//              If you use PD2-DIO128 board with two banks you might
//              need to call this function two times - first time for the bank 0
//              (dwRegister = 0) and second time for the bank 1 (dwRegister = 4)
//-
int _PdDIOLatchAll(int board, u32 dwRegister)
{
    u32   dwResult;
    return pd_dio256_read_input (board, DIO_LAL | (dwRegister & 0x4),
                            &dwResult);
}

//+
// Function:    _PdDIOSimpleRead
//
// Parameters:  int board -- board to adapter
//              u32 dwRegister -- register
//              u32 *pdwValue  -- ptr to variable to store value
//
// Returns:     Negative error code or 0
//
// Description: Returns value stored in the latch without strobing
//              of latch signal
//
// Notes:       Function doesn't return tha actual state of DIn lines
//              but rather data stored when latch was strobed last time
//-
int _PdDIOSimpleRead(int board, u32 dwRegister, u32 *pdwValue)
{
    return pd_dio256_read_input(board,
                            (__PdDIO256MakeCmd(dwRegister) | DIO_SRD),
                            pdwValue);
}

//+
// Function:    _PdDIORead
//
// Parameters:  int board -- board to adapter
//              u32 dwRegister -- register
//              u32 *pdwValue  -- ptr to variable to store value
//
// Returns:     Negative error code or 0
//
// Description: Strobe latch line for the register specified and
//              returns value stored in the latch
//
// Notes:       Use this function to retrieve state of the inpupts
//              immediately
//-
int _PdDIORead(int board, u32 dwRegister, u32 *pdwValue)
{
    return pd_dio256_read_input(board,
                            (__PdDIO256MakeCmd(dwRegister) | DIO_LAR),
                            pdwValue);
}

//+
// Function:    _PdDIOWrite
//
// Parameters:  int board -- board to adapter
//              u32 dwRegister -- register
//              u32 pdwValue  -- variable to write to DOut register
//
// Returns:     Negative error code or 0
//
// Description: Write values to digital output register
//
// Notes:       Upon this function call value is written to the output
//              register. To see actual voltages on the ouputs, specified
//              register shall be configured as output using _PdDIOEnableOutput
//-
int _PdDIOWrite(int board, u32 dwRegister, u32 dwValue)
{
    return pd_dio256_write_output(board,
                            (__PdDIO256MakeCmd(dwRegister) | DIO_SWR),
                            (dwValue & 0xFFFF));
}

//+
// Function:    _PdDIOPropEnable
//
// Parameters:  int board -- board to adapter
//              u32 *pError   -- ptr to last error status
//              u32 dwRegMask -- register mask
//
// Returns:     Negative error code or 0
//
// Description: Enable or disable propagate signal generation
//
// Notes:       PD2-DIO boards have special line "Propagate" to inform external
//              device about data has been writen to the output.
//              You can select write to which register causes "propagete" pulse.
//              dwRegMask format is <r7 r6 r5 r4 r3 r2 r1 r0> where rx are
//              16-bit registers. PD2-DIO64 has only fours registers, PD2-DIO128
//              eight of them.
//              1 in the dwRegMask means that write to this register will cause
//                pulse on "porpagate" line
//              0 in the dwRegMask means that write to this register will not
//                affect this line
//              Example: dwRegMask = 0xF0. It means that any write to the bank 1
//              will cause pulse on "propagate" line and writes to the bank 0
//              will not.
//-
int _PdDIOPropEnable(int board, u32 dwRegMask)
{
     u32 dwRegM = ~dwRegMask;
     int  bRes = TRUE;

     bRes &= pd_dio256_write_output(board,
                               __PdDIO256MakeRegMask(DIO_REG0 & 0xF, (dwRegM & 0xF)) | DIO_PWR,
                               0);

     bRes &= pd_dio256_write_output(board,
                               __PdDIO256MakeRegMask(DIO_REG4 & 0xF, (dwRegM & 0xF0)>>4 ) | DIO_PWR,
                               0);
     return bRes;
}

//+
// Function:    _PdDIOExtLatchEnable
//
// Parameters:  int board -- board to adapter
//              u32 dwBank -- bank
//              int bEnable -- enable (1) or disable (0)
//
// Returns:     Negative error code or 0
//
// Description: Set or clear external latch enable bit for specified bank
//              bEnable = 0 - disable external latch line (default)
//              bEnable = 1 - enable external latch line
//
// Notes:       You can enable or disable external latch line for each
//              register bank separately. If the "latch" line is enabled
//              pulse on this line will cause input registers to store
//              input signal levels.
//              You can use _PdDIOExtLatchRead function to find out was data
//              latched or not. Use _PdDIOSimpleRead function to read latched
//              data
//-
int _PdDIOExtLatchEnable(int board, u32 dwRegister, int bEnable)
{
    return pd_dio256_write_output(board,
                            (__PdDIO256MakeCmd(dwRegister & 0x4) | DIO_LWR | ((bEnable)?1:0)<<1),
                            0);
}

//+
// Function:    _PdDIOExtLatchRead
//
// Parameters:  int board -- board to adapter
//              u32 dwRegister -- bank
//              int *bLatch  -- ptr to variable to store value
//
// Returns:     Negative error code; 0 if data wasn't latched and 1 if it was
//
// Description: Returns status of the external latch line
//
// Notes:       External latch pulse set external latch status bit to "1"
//              This function clears external latch status bit.
//-
int _PdDIOExtLatchRead(int board, u32 dwRegister, int *bLatch)
{
    return pd_dio256_read_input(board,
                            (__PdDIO256MakeCmd(dwRegister & 0x4) | DIO_LRD),
                            (u32*)bLatch);
}

//+
// Function:    _PdDIOIntrEnable
//
// Parameters:  int board -- board to adapter
//              u32 *pError   -- ptr to last error status
//              u32 dwEnable  -- 0: disable, 1: enable DIO interrupts
//
// Returns:     Negative error code or 0
//
// Description: This function enables or disables host interrupt generation
//              for PD2-DIO board. Use _PdDIOSetIntrMask to set up DIO
//              interrupt mask
//
// Notes:
//-
int _PdDIOIntrEnable(int board, u32 dwEnable)
{ return -EIO; }

//+
// Function:    _PdDIOSetIntrMask
//
// Parameters:  int board -- board to adapter
//              u32* dwIntMask -- interrupt mask (array of 8 u32s)
//
// Returns:     Negative error code or 0
//
// Description: This function sets up interrupt mask. PD2-DIO is capable to
//              generate host interrupt when selected bit changes its state.
//              dwIntMask is array of 8 u32s each of them correspondes to
//              one register of PD2-DIO board.
//              Only lower 16 bits are valid
//
// Notes:
//-
int _PdDIOSetIntrMask(int board, u32* dwIntMask) { return -EIO; }

//+
// Function:    _PdDIOGetIntrData
//
// Parameters:  int board -- board to adapter
//              u32* dwIntData    -- array to store int data (8 u32s)
//              u32* dwEdgeData   -- array to store edge data (8 u32s)
//
// Returns:     Negative error code or 0
//
// Description: Function returns cause of interrupt
//              dwIntData contains "1" in position where bits have changed
//              their states. Only LSW is valid
//              dwEdgeData bits are valid only in the positions where dwIntData
//              contains "1"s. If a bit is "1" - rising edge caused the
//              interrupt, if a bit is "0" - falling edge occurs.
//
// Notes:       AND dwEdgeData and dwIntData with dwIntMask to mask "not care"
//              bits
//
//-
int _PdDIOGetIntrData(int board, u32* dwIntData, u32* dwEdgeData)
{ return -EIO; }

//+
// Function:    _PdDIODMASet
//
//
// Parameters:  int board -- board to adapter
//              u32 dwOffset -- DSP DMA channel 0 offset register
//              u32 dwCount -- DSP DMA channel 0 count register
//              u32 dwSource -- DSP DMA channel 0 source register
//
// Returns:     Negative error code or 0
//
// Notes: Use constants frm pdfw_def.h for proper operations
//
//-
int _PdDIODMASet(int board, u32 dwOffset, u32 dwCount, u32 dwSource)
{ return -EIO; }


//--- AO32 Subsystem Commands: ------------------------------------------
//+
// Function:    _PdAO32Reset
//
// Parameters:  int board -- board to adapter
//
// Returns:     Negative error code or 0
//
// Description: Reset PD2-AO32 subsystem to 0V state
//
// Notes:
//-
int _PdAO32Reset(int board)
{
    int    bRes = TRUE;
    u32   i;

    // remove any update channels
    bRes &= pd_dio256_read_input(board, 0, &i);

    // write zeroes to all DACs
    for (i = 0; i < 32; i++)
        bRes &= pd_dio256_write_output(board, i|AO32_WRPR|AO32_BASE, 0x7fff);

    return bRes;
}

//+
// Function:    _PdAO32Write
//
// Parameters:  int board -- board to adapter
//              u16   wChannel -- number of channel to write
//              u16   wValue -- value to write
//
// Returns:     Negative error code or 0
//
// Description: Write and update analog output immediately
//
// Notes:
//-
int _PdAO32Write(int board, u16 wChannel, u16 wValue)
{
    return pd_dio256_write_output(board,
                             (wChannel & 0x1F)|AO32_WRPR|AO32_BASE, wValue);
}

//+
// Function:    _PdAO32WriteHold
//
// Parameters:  int board -- board to adapter
//              u16   wChannel -- number of channel to write
//              u16   wValue -- value to write
//
// Returns:     Negative error code or 0
//
// Description: Write and update analog output upon PdAO32Update command
//
// Notes:
//-
int _PdAO32WriteHold(int board, u16 wChannel, u16 wValue)
{
    return pd_dio256_write_output(board,
                             (wChannel & 0x1F)|AO32_WRH|AO32_BASE, wValue);
}


//+
// Function:    _PdAO32Update
//
// Parameters:  int board -- board to adapter
//
// Returns:     Negative error code or 0
//
// Description: Update all outputs with previously written values
//
// Notes:       Use this function in pair with _PdAO32Write.
//              Write values to the DACs you want to update. Values will
//              be stored in registers. Then _PdAO32Update outputs stored
//              values to DACs
//-
int _PdAO32Update(int board)
{
    u32   dwValue;
    return pd_dio256_read_input(board, AO32_UPDALL|AO32_BASE, &dwValue);
}

//+
// Function:    _PdAO32SetUpdateChannel
//
// Parameters:  int board -- board to adapter
//              u16   wChannel -- number of channel to write
//              int   bEnable -- TRUE to enable, FALSE to release
//
// Returns:     Negative error code or 0
//
// Description: Set channel number writing to which updates all values
//
// Notes:       You can set channel which will trigger DACs update line
//              You might want to write data to all needed registers and
//              update them on the last write to selected register
//
//-
int _PdAO32SetUpdateChannel(int board, u16 wChannel, int bEnable)
{
    u32   dwValue;
    return pd_dio256_read_input(board,
                            wChannel | ((bEnable)?AO32_SETUPDMD|AO32_BASE:0),
                            &dwValue);
}
