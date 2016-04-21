/* $Revision: 1.1.6.3 $ */
/* shrlibsample.c
 *
 * Sample C shared library for use with MATLAB Shared 
 * Library Calling (CALLLIB)
 * Copyright 2002 The MathWorks, Inc.
 *
 */

#include <stdlib.h>
#include <mex.h>  /* only needed because of mexFunction below */
/*#include "windows.h"*/
#define EXPORT_FCNS
#include "shrhelp.h"


#include "shrlibsample.h"

EXPORTED_FUNCTION void multDoubleArray(double *x,int size)
{
    /* Multiple each element of the array by 3 */
    int i;
    for (i=0;i<size;i++)
	*x++ *= 3;
}

EXPORTED_FUNCTION double addMixedTypes(short x,int y,double z)
{
    return (x + y + z);
}

EXPORTED_FUNCTION double addDoubleRef(double x,double *y,double z)
{
    return (x + *y + z);
}

EXPORTED_FUNCTION char* stringToUpper(char *input)
{
    char *p = input;

    if (p!=NULL) 
    {
	while (*p!=0)
	{
	    *p = toupper(*p);
	    p++;
	}
    } else {
        input="Null pointer passed to stringToUpper.";
    } 
    return input;
}

EXPORTED_FUNCTION char* readEnum(TEnum1 val)
{
    switch (val) {
	case en1: return "You chose en1";
	case en2: return "You chose en2";
	case en4: return "You chose en4";
	default : return "enum not defined";
    }
    return "ERROR";
}

EXPORTED_FUNCTION double addStructFields(struct c_struct st)
{
    double t = st.p1 + st.p2 + st.p3;
    return t;
}

EXPORTED_FUNCTION double *multDoubleRef(double *x)
{
     *x *= 5;
     return x;
}

EXPORTED_FUNCTION double addStructByRef(struct c_struct *st)
{
    double t = st->p1+st->p2+st->p3;
    st->p1=5.5;
    st->p2=1234;
    st->p3=12345678;
    return t;
}

EXPORTED_FUNCTION void allocateStruct(struct c_struct** val)
{
    *val=(struct c_struct*) malloc(sizeof(struct c_struct));
    (*val)->p1 = 12.4;
    (*val)->p2 = 222;
    (*val)->p3 = 333333;
}


EXPORTED_FUNCTION void deallocateStruct(void *ptr)
{
    free(ptr);
}


EXPORTED_FUNCTION void multiplyShort(short *x, int size)
{
    int i;
    for (i=0; i<size; i++)
	*x++ *= i;
}

/* this function exists so that mex may be used to compile the library
   it is not otherwise needed */
   
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{
}
/*
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved)
{
    return TRUE;
}
*/

