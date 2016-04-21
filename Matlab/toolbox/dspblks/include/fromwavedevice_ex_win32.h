/* $Revision: 1.5 $
 *
 * fromwavedevice_ex_win32.h
 * Runtime library header file for Windows "From Wave Device" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef FROMWAVEDEVICE_EX_H
#define FROMWAVEDEVICE_EX_H

int exMWDSP_Wai_GetErrorCode(void);

const char* exMWDSP_Wai_GetErrorMessage(void);

void* exMWDSP_Wai_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, unsigned int whichDevice, unsigned short useTheWaveMapper);

void exMWDSP_Wai_Start(void* obj);


void exMWDSP_Wai_Outputs(const void * obj, const void* signal);

void exMWDSP_Wai_Terminate(const void* obj);


#endif /* FROMWAVEDEVICE_EX_H */
