/*
 * dsp_sfcn_param_sim.c
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:13:01 $
 *
 * Abstract: S-function parameter handling helper functions
 */

#include "dsp_sfcn_param_sim.h"


EXPORT_FCN void interleaveComplexData( const byte_T *srcRealPtr, 
                            const byte_T *srcImagPtr, 
                            byte_T       *dstPtr, 
                            int_T         numElems, 
                            int_T         bytesPerRealElement )
{
    while (numElems-- > 0) {
        memcpy(dstPtr, srcRealPtr, bytesPerRealElement);
        dstPtr += bytesPerRealElement;
        srcRealPtr += bytesPerRealElement;
        memcpy(dstPtr, srcImagPtr, bytesPerRealElement);
        dstPtr += bytesPerRealElement;
        srcImagPtr += bytesPerRealElement;
    }
}


EXPORT_FCN void interleaveRealDataWithImagElement( const byte_T *srcRealPtr,
                                        const byte_T *imagElementPtr,
                                        byte_T       *dstPtr,
                                        int_T         numElems,
                                        int_T         bytesPerRealElement )
{
    while (numElems-- > 0) {
        memcpy(dstPtr, srcRealPtr, bytesPerRealElement);
        dstPtr += bytesPerRealElement;
        memcpy(dstPtr, imagElementPtr, bytesPerRealElement);
        dstPtr += bytesPerRealElement;
        srcRealPtr += bytesPerRealElement;
    }
}

EXPORT_FCN real32_T getRealScalarParamSingle(SimStruct *S, const mxArray *array)                                  
{
    real32_T mySingleVal = 0.0F;
    if (mxGetClassID(array) == mxDOUBLE_CLASS ) { /* indicates double */    
        mySingleVal  = (real32_T)(*(real_T *)mxGetData(array));                    
    } else if (mxGetClassID(array) == mxSINGLE_CLASS ) {/* indicates single */ 
        mySingleVal  = (*(real32_T *)mxGetData(array));                            
    } else {
        ssSetErrorStatus(S, "Currently this data-type is not permitted");
    }  
    return mySingleVal;
}

EXPORT_FCN real_T getRealScalarParamDouble(SimStruct *S, const mxArray *array)                                  
{
    real_T myDoubleVal = 0;
    if (mxGetClassID(array) == mxDOUBLE_CLASS ) { 
        myDoubleVal  = (*(real_T *)mxGetData(array));                              
    } else if (mxGetClassID(array) == mxSINGLE_CLASS ) {
        myDoubleVal  = (real_T)(*(real32_T *)mxGetData(array));                    
    } else {                                                                 
        ssSetErrorStatus(S, "Currently this data-type is not permitted");
    }   
    return myDoubleVal;
}

EXPORT_FCN real32_T getImagScalarParamSingle(SimStruct *S, const mxArray *array)                                  
{
    real32_T mySingleVal = 0.0F;
    if (mxGetClassID(array) == mxDOUBLE_CLASS ) { /* indicates double */    
        mySingleVal  = (real32_T)(*(real_T *)mxGetImagData(array));                    
    } else if (mxGetClassID(array) == mxSINGLE_CLASS ) {/* indicates single */ 
        mySingleVal  = (*(real32_T *)mxGetImagData(array));                            
    } else {
        ssSetErrorStatus(S, "Currently this data-type is not permitted");
    }  
    return mySingleVal;
}

EXPORT_FCN real_T getImagScalarParamDouble(SimStruct *S, const mxArray *array)                                  
{
    real_T myDoubleVal = 0;
    if (mxGetClassID(array) == mxDOUBLE_CLASS ) { 
        myDoubleVal  = (*(real_T *)mxGetImagData(array));                              
    } else if (mxGetClassID(array) == mxSINGLE_CLASS ) {
        myDoubleVal  = (real_T)(*(real32_T *)mxGetImagData(array));                    
    } else {                                                                 
        ssSetErrorStatus(S, "Currently this data-type is not permitted");
    }   
    return myDoubleVal;
}

/* [EOF] dsp_sfcn_param_sim.c */
