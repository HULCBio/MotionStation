/* $Revision: 1.5 $ 
 *
 * towavedevice_ex_win32.h
 * Runtime library header file for Windows "To Wave Device" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef TOWAVEDEVICE_EX_H
#define TOWAVEDEVICE_EX_H


int exMWDSP_Wao_GetErrorCode(void);

const char* exMWDSP_Wao_GetErrorMessage(void);

void* exMWDSP_Wao_Create(double rate, unsigned short bits, int chans, int inputBufSize, int dType,
						double bufSizeInSeconds, double initialDelay, unsigned int whichDevice, 
						unsigned short useTheWaveMapper);

void exMWDSP_Wao_Start(void* obj);

void exMWDSP_Wao_Update(const void * obj, const void* signal);

void exMWDSP_Wao_Terminate(const void* obj);

#endif /* TOWAVEDEVICE_EX_H */
