/* 
 * IMLINCOMBC.<mex>
 *
 * Y = lincombc(IMAGES,SCALARS,OUTPUT_CLASS)
 *
 * Computes SCALARS(1)*IMAGES{1} + ... + SCALARS(P)*IMAGES{P} + SCALARS(P+1)
 * or SCALARS(1)*IMAGES{1} + ... + SCALARS(P)*IMAGES{P}.
 *
 *
 * IMAGES  P-element vector
 *         cell array
 *         cell contents must be numeric, real, nonsparse
 *         cell contents must all have the same class
 *         cell contents must all have the same size
 *
 * SCALARS P-element or (P+1)-element vector
 *         double
 *         real
 *         nonsparse
 *
 * OUTPUT_CLASS  One of these string values: uint8, uint16, uint32,
 *               int8, int16, int32, single, double.
 *
 * OUTPUT_CLASS can be omitted, in which case the class of Y is the same 
 * as the class of the input images.
 *
 * $Revision: 1.1.6.4 $  $Date: 2003/08/01 18:11:14 $
 * Copyright 1993-2003 The MathWorks, Inc.
 */

#include <string.h>
#include "imlincombc.h"
#include "mex.h"


#define FCN_NAME     "imlincombc"
#define IMAGES       (prhs[0])
#define SCALARS      (prhs[1])
#define OUTPUT_CLASS (prhs[2])

static char rcsid[] = "$Id: imlincombc.cpp,v 1.1.6.4 2003/08/01 18:11:14 batserve Exp $";

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
bool LinComb::isSameSize(const mxArray *array1, const mxArray *array2)
{
    int k;
    int num_dims;
    const int *dims1;
    const int *dims2;

    num_dims = mxGetNumberOfDimensions(array1);
    if (num_dims != mxGetNumberOfDimensions(array2))
    {
        return false;
    }
    else
    {
        dims1 = mxGetDimensions(array1);
        dims2 = mxGetDimensions(array2);
        
        for (k = 0; k < num_dims; k++)
        {
            if (dims1[k] != dims2[k])
            {
                return false;
            }
        }
    }
    
    return true;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::checkSizeAndClassMatch(const mxArray *images)
{
    int k;
    const mxArray *first_cell;
    mxClassID first_cell_class;
    int first_num_dims;
    const int *first_dims;

    mxAssert(! mxIsEmpty(images), "");

    first_cell = mxGetCell(images, 0);
    first_cell_class = mxGetClassID(first_cell);
    first_num_dims = mxGetNumberOfDimensions(first_cell);
    first_dims = mxGetDimensions(first_cell);
    
    for (k = 1; k < mxGetNumberOfElements(images); k++)
    {
        if (mxGetClassID(mxGetCell(images,k)) != first_cell_class)
        {
            mexErrMsgIdAndTxt("Images:imlincomb:mismatchedArrayClass",
                              "%s",
                              "Function imlincomb expected its array input "
                              "arguments (A1, A2, ...) to "
                              "have the same class.");

        }
        
        if (! isSameSize(first_cell, mxGetCell(images, k)))
        {
            mexErrMsgIdAndTxt("Images:imlincomb:mismatchedArraySize",
                              "%s",
                              "Function imlincomb expected its array input "
                              "arguments (A1, A2, ...) to be the same size.");
        }
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
mxClassID LinComb::getOutputClassID(const mxArray *output_class_array)
{
    char *string;
    mxClassID result;

    string = mxArrayToString(output_class_array);

    if (strcmp(string,"uint8") == 0)
    {
	result = mxUINT8_CLASS;
    }
    else if (strcmp(string,"uint16") == 0)
    {
	result = mxUINT16_CLASS;
    }
    else if (strcmp(string,"uint32") == 0)
    {
	result = mxUINT32_CLASS;
    }
    else if (strcmp(string,"double") == 0)
    {
	result = mxDOUBLE_CLASS;
    }
    else if (strcmp(string,"single") == 0)
    {
	result = mxSINGLE_CLASS;
    }
    else if (strcmp(string,"int8") == 0)
    {
	result = mxINT8_CLASS;
    }
    else if (strcmp(string,"int16") == 0)
    {
	result = mxINT16_CLASS;
    }
    else if (strcmp(string,"int32") == 0)
    {
	result = mxINT32_CLASS;
    }
    else
    {
	mexErrMsgIdAndTxt("Images:imlincomb:invalidOutputClass",
                          "%s\n%s",
                          "Function imlincomb expected its last "
                          "input argument, OUTPUT_CLASS,",
                          "to be a string containing the name "
                          "of a numeric class.");
    }

    mxFree(string);

    return result;
}
//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::checkCellTypes(const mxArray *images)
{
    int k;
    const mxArray *cell;

    for (k = 0; k < mxGetNumberOfElements(images); k++)
    {
	cell = mxGetCell(images, k);
	if (!(mxIsNumeric(cell) || mxIsLogical(cell)) || 
            mxIsComplex(cell) || mxIsSparse(cell))
	{
            mexErrMsgIdAndTxt("Images:imlincomb:invalidArray",
                              "%s\n%s",
                              "Function imlincomb expected its array input ",
                              "arguments (A1, A2, ...) to be numeric"
                              " or logical, real, and full.");
	}
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
mxClassID LinComb::checkInputs(int nlhs, mxArray *plhs[], int nrhs, 
                               const mxArray *prhs[])
{

    if (nrhs < 2)
    {
        mexErrMsgIdAndTxt("Images:imlincombc:tooFewInputs",
                          "IMLINCOMBC expected at least two inputs.");
    }
    if (nrhs > 3)
    {
        mexErrMsgIdAndTxt("Images:imlincombc:tooManyInputs",
                          "IMLINCOMBC expected at most three inputs.");
    }

    if ((mxGetNumberOfElements(SCALARS) < mxGetNumberOfElements(IMAGES)) ||
        (mxGetNumberOfElements(SCALARS) > (mxGetNumberOfElements(IMAGES) + 1)))
    {
        mexErrMsgIdAndTxt("Images:imlincombc:mismatchedLength",
                          "%s %s %s\n%s",
                          "Function", FCN_NAME, "expected its"
                          " second input argument, SCALARS,",
                          "to have the same length as IMAGES"
                          " or be one element longer.");
    }

    checkSizeAndClassMatch(IMAGES);

    checkCellTypes(IMAGES);

    if (nrhs == 3)
    {
        return getOutputClassID(OUTPUT_CLASS);
    }
    else
    {
        return mxGetClassID(mxGetCell(IMAGES,0));
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
LinComb::LinComb()
{
    //Initialize member variables
    fInputClassID  = mxUNKNOWN_CLASS;
    fOutputClassID = mxUNKNOWN_CLASS;
    fNumElements   = -1;
    fNumImages     = -1;
    fNumScalars    = -1;


#ifdef __i386__  //Don't use this code on non-Intel platforms
    fMwIppl        = new MwIppl();
    bUseIPPL       = true;

    ippiAdd_8u_C1RSfs = (ippiAdd_8u_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiAdd_8u_C1RSfs", ippI);
    if(!ippiAdd_8u_C1RSfs) bUseIPPL = false;
    ippiAdd_16s_C1RSfs = (ippiAdd_16s_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiAdd_16s_C1RSfs", ippI);
    if(!ippiAdd_16s_C1RSfs) bUseIPPL = false;
    ippiAdd_32f_C1R = (ippiAdd_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiAdd_32f_C1R", ippI);
    if(!ippiAdd_32f_C1R) bUseIPPL = false;


    ippiAddC_8u_C1RSfs = (ippiAddC_8u_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiAddC_8u_C1RSfs", ippI);
    if(!ippiAddC_8u_C1RSfs) bUseIPPL = false;
    ippiAddC_16s_C1RSfs = (ippiAddC_16s_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiAddC_16s_C1RSfs", ippI);
    if(!ippiAddC_16s_C1RSfs) bUseIPPL = false;
    ippiAddC_32f_C1R = (ippiAddC_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiAddC_32f_C1R", ippI);
    if(!ippiAddC_32f_C1R) bUseIPPL = false;


    ippiSub_8u_C1RSfs = (ippiSub_8u_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiSub_8u_C1RSfs", ippI);
    if(!ippiSub_8u_C1RSfs) bUseIPPL = false;
    ippiSub_16s_C1RSfs = (ippiSub_16s_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiSub_16s_C1RSfs", ippI);
    if(!ippiSub_16s_C1RSfs) bUseIPPL = false;
    ippiSub_32f_C1R = (ippiSub_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiSub_32f_C1R", ippI);
    if(!ippiSub_32f_C1R) bUseIPPL = false;


    ippiSubC_8u_C1RSfs = (ippiSubC_8u_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiSubC_8u_C1RSfs", ippI);
    if(!ippiSubC_8u_C1RSfs) bUseIPPL = false;
    ippiSubC_16s_C1RSfs = (ippiSubC_16s_C1RSfs_T)
        fMwIppl->getMethodPointer("ippiSubC_16s_C1RSfs", ippI);
    if(!ippiSubC_16s_C1RSfs) bUseIPPL = false;
    ippiSubC_32f_C1R = (ippiSubC_32f_C1R_T)
        fMwIppl->getMethodPointer("ippiSubC_32f_C1R", ippI);
    if(!ippiSubC_32f_C1R) bUseIPPL = false;

#endif

};

//////////////////////////////////////////////////////////////////////////////
// Note:  The destructor will be called on matlab exit or
//        when using matlab's "clear" function
//////////////////////////////////////////////////////////////////////////////
LinComb::~LinComb()
{
#ifdef __i386__
    if(fMwIppl  != NULL) delete fMwIppl;
#endif
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
operation_T LinComb::useIPPL(double *scalars)
{
    operation_T operation = opNone;
    
    if(bUseIPPL) //Check if IPPL is enabled on this system
    {
        if(fInputClassID == fOutputClassID)
        {
            if( (fNumImages  == 2) && (fNumScalars == 2) )
            {
                if( scalars[0] == 1  && scalars[1] == 1 )
                {
                    operation = opAdd; //I1+I2
                }
                else if( scalars[0] == 1 && scalars[1] == -1 )
                {                    
                    operation = opSubRfL; //I1-I2
                }
                else if( scalars[0] == -1 && scalars[1] == 1 )
                {
                    operation = opSubLfR; //I2-I1
                }
            }
            else if( (fNumImages == 1) && (fNumScalars == 2) )
            {
                if( scalars[0] == 1 && scalars[1] >= 0 )
                {
                    operation = opAddC; //I+C
                }
                else if( scalars[0] == 1 && scalars[1] < 0 )
                {
                    operation = opSubC; //I-C
                }
            }
        }        
    }

    return(operation);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::evaluate(double *scalars, void **inputImages, void *outputImage)
{
    mxAssert( (fInputClassID != mxUNKNOWN_CLASS),
              ERR_STRING("LinComb::fInputClassID","evaluate()"));
    mxAssert( (fOutputClassID != mxUNKNOWN_CLASS),
              ERR_STRING("LinComb::fOutputClassID","evaluate()"));
    mxAssert( (fNumElements != -1),
              ERR_STRING("LinComb::fNumElements","evaluate()"));
    mxAssert( (fNumImages != -1),
              ERR_STRING("LinComb::fNumImages","evaluate()"));
    mxAssert( (fNumScalars != -1),
              ERR_STRING("LinComb::fNumScalars","evaluate()"));    

    //Cast the input and relay the data to another template
    switch(fInputClassID)
    {
      case(mxLOGICAL_CLASS):
        castInputAndEvaluate(scalars, (uint8_T **)inputImages, outputImage);
        break;

      case(mxUINT8_CLASS):

#ifdef __i386__  //Decide if we want to utilize IPPL
        switch(useIPPL(scalars))
        {
          case opAdd:
            ipplArithInt((uint8_T *)inputImages[0], (uint8_T *)inputImages[1],
                         (uint8_T *)outputImage, ippiAdd_8u_C1RSfs);
            return;
            break;

          case opSubRfL:
            ipplArithInt((uint8_T *)inputImages[1], (uint8_T *)inputImages[0],
                         (uint8_T *)outputImage, ippiSub_8u_C1RSfs);
            return;
            break;

          case opSubLfR:
            ipplArithInt((uint8_T *)inputImages[0], (uint8_T *)inputImages[1],
                         (uint8_T *)outputImage, ippiSub_8u_C1RSfs);
            return;
            break;
            
          case opAddC:
            ipplArithCInt((uint8_T *)inputImages[0],
                          scalars[1],
                          (uint8_T *)outputImage,
                          ippiAddC_8u_C1RSfs);
            return;
            break;
            
          case opSubC:
            {
                double constVal = -1*scalars[1];
                double intPart  = (int)constVal;
                
                if( (constVal-intPart) == 0.5)
                {
                    constVal = intPart;
                }
                ipplArithCInt((uint8_T *)inputImages[0],
                              constVal,
                              (uint8_T *)outputImage,
                              ippiSubC_8u_C1RSfs);
            }
            return;          
            break;
            
          case opNone:
          default:
            //Let our code handle this case
            break;

        }
#endif
        castInputAndEvaluate(scalars, (uint8_T **)inputImages, outputImage);
        break;

      case(mxINT8_CLASS):
        castInputAndEvaluate(scalars, (int8_T **)inputImages, outputImage);
        break;

      case(mxUINT16_CLASS):
        castInputAndEvaluate(scalars, (uint16_T **)inputImages, outputImage);
        break;

      case(mxINT16_CLASS):

#ifdef __i386__  //Decide if we want to utilize IPPL
        switch(useIPPL(scalars))
        {
          case opAdd:
            ipplArithInt((int16_T *)inputImages[0], 
                         (int16_T *)inputImages[1],
                         (int16_T *)outputImage, 
                         ippiAdd_16s_C1RSfs);
            return;
            break;

          case opSubRfL:
            ipplArithInt((int16_T *)inputImages[1], 
                         (int16_T *)inputImages[0],
                         (int16_T *)outputImage,
                         ippiSub_16s_C1RSfs);
            return;
            break;

          case opSubLfR:
            ipplArithInt((int16_T *)inputImages[0],
                         (int16_T *)inputImages[1],
                         (int16_T *)outputImage,
                         ippiSub_16s_C1RSfs);
            return;
            break;

          case opAddC:
            ipplArithCInt((int16_T *)inputImages[0],
                          scalars[1],
                          (int16_T *)outputImage,
                          ippiAddC_16s_C1RSfs);
            return;
            break;
            
          case opSubC:
            {
                double constVal = scalars[1];
                double intPart  = (int)constVal;
                
                if( (constVal-intPart) == -0.5)
                {
                    constVal = intPart;
                }
                
                ipplArithCInt((int16_T *)inputImages[0],
                              constVal,
                              (int16_T *)outputImage,
                              ippiAddC_16s_C1RSfs);
            }
            return;
            break;
            
          case opNone:
          default:
            //Let our code handle this case
            break;
        }
#endif
        castInputAndEvaluate(scalars, (int16_T **)inputImages, outputImage);
        break;

      case(mxUINT32_CLASS):
        castInputAndEvaluate(scalars, (uint32_T **)inputImages, outputImage);
        break;

      case(mxINT32_CLASS):
        castInputAndEvaluate(scalars, (int32_T **)inputImages, outputImage);
        break;

      case(mxSINGLE_CLASS):
        
#ifdef __i386__  //Decide if we want to utilize IPPL
        switch(useIPPL(scalars))
        {
          case opAdd:
            ipplArithFlP((float *)inputImages[0], 
                         (float *)inputImages[1],
                         (float *)outputImage, 
                         ippiAdd_32f_C1R);
            return;
            break;

          case opSubRfL:
            ipplArithFlP((float *)inputImages[1], 
                         (float *)inputImages[0],
                         (float *)outputImage,
                         ippiSub_32f_C1R);
            return;
            break;

          case opSubLfR:
            ipplArithFlP((float *)inputImages[0],
                         (float *)inputImages[1],
                         (float *)outputImage,
                         ippiSub_32f_C1R);
            return;
            break;

          case opSubC:
          case opAddC:
            ipplArithCFlP((float *)inputImages[0],
                          (float  )scalars[1],
                          (float *)outputImage,
                          ippiAddC_32f_C1R);
            return;
            break;

          case opNone:
          default:
            //Let our code handle this case
            break;
        }
#endif

        castInputAndEvaluate(scalars, (float **)inputImages, outputImage);
        break;

      case(mxDOUBLE_CLASS):
        castInputAndEvaluate(scalars, (double **)inputImages, outputImage);
        break;

      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:imlincombc:unsuppDataType", "%s",
                          "Unsupported data type.");
        break;

    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::setInputClassID(mxClassID classID)
{
    fInputClassID = classID;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::setOutputClassID(mxClassID classID)
{
    fOutputClassID = classID;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::setNumElements(int numElements)
{
    fNumElements = numElements;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::setNumImages(int numImages)
{
    fNumImages = numImages;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void LinComb::setNumScalars(int numScalars)
{
    fNumScalars = numScalars;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

//Instantiate the class responsible for all the computations
LinComb linComb;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    mxClassID output_class = linComb.checkInputs(nlhs, plhs, nrhs, prhs);

    /* Allocate memory for pointers to images */
    int    num_images  = mxGetNumberOfElements(IMAGES);
    void **inputImages = (void **) mxMalloc(num_images * sizeof(void *));

    /* Loop to assign values to pointers */
    for (int k = 0; k < num_images; k++)
    {
        inputImages[k] = mxGetData(mxGetCell(IMAGES, k));
    }

    double *scalars     = (double *) mxGetData(SCALARS);  
    int     num_scalars = mxGetNumberOfElements(SCALARS);

    plhs[0] = 
        mxCreateNumericArray(mxGetNumberOfDimensions(mxGetCell(IMAGES,0)),
                             mxGetDimensions(mxGetCell(IMAGES,0)),
                             output_class,
                             mxREAL);

    void *outputImage = (double *) mxGetData(plhs[0]);

    int       num_pixels  = mxGetNumberOfElements(mxGetCell(IMAGES, 0));
    mxClassID input_class = mxGetClassID(mxGetCell(IMAGES, 0));


    linComb.setInputClassID(input_class);
    linComb.setOutputClassID(output_class);
    linComb.setNumElements(num_pixels);
    linComb.setNumImages(num_images);
    linComb.setNumScalars(num_scalars);
    linComb.evaluate(scalars, inputImages, outputImage);

    mxFree(inputImages);
}
