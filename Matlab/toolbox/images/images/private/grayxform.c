/* Copyright 1993-2003 The MathWorks, Inc. */

/*
   grayxform.c .MEX file

               out = grayxform(in, T)

               Apply a graylevel transform to an image.
               
               in should be of class uint8, uint16, or double.
               T should be double, in the range [0,1].
               
               Chris Griffin
               February 1998
*/


static char rcsid[] = "$Revision: 1.9.4.2 $";

#include <math.h>
#include "mex.h"

mxArray *TransformDoubleArray(const mxArray *A, const mxArray *T);
mxArray *TransformUINT16Array(const mxArray *A, const mxArray *T);
mxArray *TransformUINT8Array(const mxArray *A, const mxArray *T);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const mxArray *T;
    const mxArray *in;
    double *t;
    mxArray *out;
    int i;
    
    if(nrhs != 2) {
        mexErrMsgIdAndTxt("Images:grayxform:invalidInputArgs",
                          "%s","Invalid input arguments.");
    }
    if(nlhs > 1) {
        mexErrMsgIdAndTxt("Images:grayxform:tooManyOutputArgs",
                          "%s","Too many output arguments.");
    }
    
    in = prhs[0];
    
    /* Make sure the transform array is a double */    
    if (!mxIsDouble(prhs[1])) 
        mexErrMsgIdAndTxt("Images:grayxform:trasformArrayMustBeDouble",
                          "%s","Transformation array should be of"
                          " class double.");
    else
        T = prhs[1];

    if(mxIsEmpty(T))
        mexErrMsgIdAndTxt("Images:grayxform:emptyTransformArray",
                          "%s","Empty transformation array.");
    if(mxIsComplex(T)) 
        mexWarnMsgIdAndTxt("Images:grayxform:"
                           "imaginaryPartOfTransformArrayIgnored",
                           "%s","Complex transformation array, imaginary part"
                           " ignored.");
    if(mxIsComplex(in))
        mexErrMsgIdAndTxt("Images:grayxform:inputImageMustBeReal",
                          "%s","Input image is complex, only real"
                          " images are supported.");
    
    t = mxGetPr(T);

    for(i=0; i<mxGetNumberOfElements(T); i++) {
        if(t[i]<0 || t[i]>1)
            mexErrMsgIdAndTxt("Images:grayxform:"
                              "outOfRangeElementsOfTransformArray",
                              "%s","Elements of transformation array"
                              " outside the range [0,1].");
    }

    if(mxIsUint8(in)) 
        out = TransformUINT8Array(in, T);
    else if(mxIsDouble(in))
        out = TransformDoubleArray(in, T);
    else if(mxIsUint16(in))
        out = TransformUINT16Array(in, T);
    else
        mexErrMsgIdAndTxt("Images:grayxform:unsupportedInputClass",
                          "%s","Unsupported input data class.");
    
    plhs[0] = out;
}



mxArray *TransformUINT8Array(const mxArray *A, const mxArray *T) 
{
    uint8_T *a, *b;
    double *t;
    int maxTidx;
    uint32_T index;
    int *dims;
    int ndims, nelements, i;
    double scale;
    mxArray *B;
    
    a = (uint8_T *) mxGetData(A);
    ndims = mxGetNumberOfDimensions(A);
    dims = (int *) mxGetDimensions(A);

    B = mxCreateNumericArray(ndims, dims, mxUINT8_CLASS, mxREAL);
    b = (uint8_T *) mxGetData(B);

    maxTidx = mxGetNumberOfElements(T)-1;

    t = (double *) mxGetData(T);
    
    nelements = mxGetNumberOfElements(A);
    
    if(maxTidx == 255) {
        /* Perfect fit, we don't need to scale the index */
        for(i=0; i<nelements; i++) {
            b[i] = (uint8_T) (255.0 * t[a[i]] + 0.5);
        }
    } 
    else {
        /* Scale the index by maxTidx/255 */
        scale = maxTidx / 255.0;
        for(i=0; i<nelements; i++) {
            index = (uint32_T) (a[i] * scale + 0.5);
            b[i] = (uint8_T)  (255.0 * t[index] + 0.5);
        }
    }

    return(B);
}


mxArray *TransformUINT16Array(const mxArray *A, const mxArray *T) 
{
    uint16_T *a, *b;
    double *t;
    int maxTidx;
    uint32_T index;
    int *dims;
    int ndims, nelements, i;
    double scale;
    mxArray *B;
    
    a = (uint16_T *) mxGetData(A);
    ndims = mxGetNumberOfDimensions(A);
    dims = (int *) mxGetDimensions(A);

    B = mxCreateNumericArray(ndims, dims, mxUINT16_CLASS, mxREAL);
    b = (uint16_T *) mxGetData(B);

    maxTidx = mxGetNumberOfElements(T)-1;

    t = (double *) mxGetData(T);
    
    nelements = mxGetNumberOfElements(A);
    
    if(maxTidx == 65535) {
        /* Perfect fit, we don't need to scale the index */
        for(i=0; i<nelements; i++) {
            b[i] = (uint16_T) (65535.0 * t[a[i]] + 0.5);
        }
    }
    else {
        /* scale the index by maxTidx / 65535 */
        scale = maxTidx / 65535.0;
        for(i=0; i<nelements; i++) {
            index = (uint32_T) (a[i] * scale + 0.5);
            b[i] = (uint16_T) (65535.0 * t[index] + 0.5);
        }
    }

    return(B);
}


mxArray *TransformDoubleArray(const mxArray *A, const mxArray *T) 
{
    double *a, *b, val;
    double *t;
    int *dims;
    int ndims, nelements, i;
    mxArray *B;
    uint32_T index;
    int maxTidx;
    
    a = (double *) mxGetData(A);
    ndims = mxGetNumberOfDimensions(A);
    dims = (int *) mxGetDimensions(A);

    B = mxCreateNumericArray(ndims, dims, mxDOUBLE_CLASS, mxREAL);
    b = (double *) mxGetData(B);

    maxTidx = mxGetNumberOfElements(T)-1;
    t = (double *) mxGetData(T);
    
    nelements = mxGetNumberOfElements(A);
    
    for(i=0; i<nelements; i++) {
        /* Clip a[i] to the range [0,1] */
        val = a[i];
        if(val<0)
            val = 0;
        if(val>1)
            val = 1;
        index = (uint32_T) (val * maxTidx + 0.5);
        b[i] = t[index];
    }

    return(B);
}







