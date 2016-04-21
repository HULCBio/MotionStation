/* $Revision: 1.5 $ 
 *
 * towavefile_ex_win32.h
 * Runtime library header file for Windows "To Wave File" block.
 * Link:  (no import library needed)
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef TOWAVEFILE_EX_H
#define TOWAVEFILE_EX_H

int exMWDSP_Wafo_GetErrorCode(void);

const char* exMWDSP_Wafo_GetErrorMessage(void);

void* exMWDSP_Wafo_Create(char* outputFilename, unsigned short bits, 
		    int minSampsToWrite, int chans, int inputBufSize,
		    double rate, int dType);

void exMWDSP_Wafo_Outputs(const void * obj, const void* signal);

void exMWDSP_Wafo_Terminate(const void* obj);

#endif /* TOWAVEFILE_EX_H */
