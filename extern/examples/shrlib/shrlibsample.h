/* $Revision: 1.1.6.2 $ */
/* 
 * shrlibsample.h
 *
 * Copyright 2002 The MathWorks, Inc.
 */

#ifndef shrlibsample_h
#define shrlibsample_h
#include "shrhelp.h"

typedef enum Enum1 {en1=1,en2,en4=4} TEnum1;

struct c_struct {
    double p1;
    short p2;
    long  p3;
};

/* Function declarations */
EXPORTED_FUNCTION void multDoubleArray(double *,int);

EXPORTED_FUNCTION double addMixedTypes(short,int,double);

EXPORTED_FUNCTION double addDoubleRef(double,double *,double);

EXPORTED_FUNCTION char* stringToUpper(char *);

EXPORTED_FUNCTION char* readEnum(TEnum1);

EXPORTED_FUNCTION double addStructFields(struct c_struct);

EXPORTED_FUNCTION double *multDoubleRef(double *x);

EXPORTED_FUNCTION double addStructByRef(struct c_struct *);

EXPORTED_FUNCTION void allocateStruct(struct c_struct**);

EXPORTED_FUNCTION void deallocateStruct(void *ptr);

EXPORTED_FUNCTION void multiplyShort(short *,int);

#endif

