/* $Revision: 1.6 $ 
 *
 * fromwavefile_ex_win32.h
 * Runtime library header file for Windows "From Wave File" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef FROMWAVEFILE_EX_H
#define FROMWAVEFILE_EX_H

int exMWDSP_Wafi_GetErrorCode(void);

const char* exMWDSP_Wafi_GetErrorMessage(void);

void* exMWDSP_Wafi_Create(const char* filename, unsigned short bits, 
			int minSampsToRead, int chans, int outputFrameSize, double rate, 
			int dType);

void exMWDSP_Wafi_Outputs(const void * obj, const void* signal);

void exMWDSP_Wafi_Terminate(const void* obj);

void exMWDSP_Wafi_SetNumRepeats(void* obj, long rpts);
long exMWDSP_Wafi_GetNumRepeats(void* obj);

void exMWDSP_Wafi_SetRestartMode(void* obj, int restart);
int exMWDSP_Wafi_GetRestartMode(void* obj);

unsigned short exMWDSP_Wafi_JustOutputFirstSample(void* obj);
unsigned short exMWDSP_Wafi_JustOutputLastSample(void* obj);

#endif /* FROMWAVEFILE_EX_H */
