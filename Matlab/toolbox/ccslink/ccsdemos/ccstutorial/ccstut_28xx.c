/*-------------------------------------------------------------------*
 * CCSTUT.C - Target Source code for demo : CCSTUTORIAL
 * Simple program example to show Memory Read/Write
 *
 *------------------------------------------------------------------*/
/* Copyright 2002 The MathWorks, Inc.
 * $Revision: 1.1 $ $Date: 2002/07/28 01:08:32 $ */
#include "stdio.h"
#include "limits.h"


/*-------------------------------------------------------------------*
 * Define 16/32 bit types (for either 28x or 5x or 6x family)
 *------------------------------------------------------------------*/
#if SHRT_MAX == 0x7FFF
#define int16_T short
#elif INT_MAX == 0x7FFF
#define int16_T int
#endif

#if INT_MAX == 0x7FFFFFFF 
#define int32_T int
#elif LONG_MAX == 0x7FFFFFFF
# define int32_T long
#endif


/*-------------------------------------------------------------------*
 * Complex Data types - enumerated, structures, 
 *------------------------------------------------------------------*/
typedef enum TAG_myEnum {
	MATLAB = 0,
	Simulink,
	SignalToolbox,
	MatlabLink,
	EmbeddedTargetC6x
} myEnum;

struct TAG_myStruct {
	int iy[2][3];
	myEnum iz;
} myStruct = { {{1,2,3},{4,-5,6}}, MatlabLink};

char myString[] = "Treat me like an ANSI String";
int16_T ibuf[10];



/*------------------------------------------------------------------*
 * Buffers/definitions
 *------------------------------------------------------------------*/ 
int16_T idat[] = { 1,508,647,7000};
double ddat[] = { 16.3, -2.13, 5.1, 11.8 };



/*----------- main ---------------------------------------------*
 * Simple main program to print values in ddat and idat
 *-------------------------------------------------------------*/
void main()
{ 

/*  Breakpoint on next line ! */
printf("After Modification from MATLAB \nDouble Data array = %g %g %g %g\n",ddat[0],ddat[1],ddat[2],ddat[3]);

printf("Integer Data array = %d %d %d %d\n",idat[0],idat[1],idat[2],idat[3]);


}

