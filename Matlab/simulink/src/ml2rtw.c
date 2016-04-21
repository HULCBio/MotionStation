/*
 * ml2rtw.c : Contains utility function to write a ML structure to rtw file.
 *
 * Author(s): Murali Yeddanapudi, 13-Nov-1997
 *
 * Copyright 1990-2002 The MathWorks, Inc.
 *
 * $Revision: 1.11 $
 * $Author: batserve $
 * $Date: 2002/04/11 12:16:29 $
 *
 */

#ifndef __ml2rtw__
#define __ml2rtw__

#ifndef S_FUNCTION_NAME
# define S_FUNCTION_NAME
#endif

#ifndef S_FUNCTION_LEVEL
# define S_FUNCTION_LEVEL 2
#endif

#include <stdio.h>    /* for sprintf() */
#include <string.h>   /* for strlen()  */
#include "simstruc.h"


/* Function: WriteMatlabStructureToRTWFile =====================================
 * Abstract:
 *      This routine writes out a matlab structure to the the rtw file. Nested
 *      structures inside structures are also supported, i.e., any field(s) of
 *      the mxArray passed in can be structures.  However, the basic atomic
 *      units have to be either row strings or non-sparse, numeric vectors or
 *      matrices. For example, fields cannot be things like a matrix of strings
 *      or nd arrays.
 *
 *      In order to avoid name clashes with records (espeically ones that might
 *      be added in future) written out by Simulink, your structure name should
 *      start with the string "SFcn". For example, instead of naming your
 *      structure "ParseTree" you should name it "SFcnParseTree".
 *
 * Returns:
 *      1 -on success
 *      0 -on failure
 */
bool WriteMatlabStructureToRTWFile(SimStruct      *S,
                                   const mxArray  *mlStruct,
                                   const char     *structName,
                                   char           *strBuffer,
                                   const int      strBufferLen)
{
    int numStructs;
    int numFields;
    int i;

    if (mlStruct == NULL) {
        return(1);
    }
    numStructs = mxGetNumberOfElements(mlStruct);
    numFields  = mxGetNumberOfFields(mlStruct);

    /* make sure strBuffer is long enough for sprintf, be conservative */
    if ( strlen(structName)+5 >= ((size_t) strBufferLen) ) {
        return(0);
    }

    for (i=0; i<numStructs; i++) {
        int  j;

        (void) sprintf(strBuffer, "%s {",structName);
        if ( !ssWriteRTWStr(S, strBuffer) ) {
            return(0);
        }

        for (j=0; j<numFields; j++) {
            const char    *fieldName = mxGetFieldNameByNumber(mlStruct, j);
            const mxArray *field     = mxGetFieldByNumber(mlStruct, i, j);
            int           nRows;
            int           nCols;
            int           nElements;
            int           nDims;

            if (field == NULL) {
                continue;
            }

            nRows      = mxGetM(field);
            nCols      = mxGetN(field);
            nElements  = mxGetNumberOfElements(field);
            nDims      = mxGetNumberOfDimensions(field);

            if ( mxIsStruct(field) ) {                       /* struct param */
                if ( !WriteMatlabStructureToRTWFile(S,
                                                    field,
                                                    fieldName,
                                                    strBuffer,
                                                    strBufferLen) ) {
                    return(0);
                }

            } else if ( mxIsChar(field) ) {                  /* string param */

                /* can handle only "row" strings */
                if ( nDims > 2 || nRows > 1 ) {
                    return(0);
                }

                if ( mxGetString(field,strBuffer,strBufferLen) ) {
                    return(0);
                }

                if ( !ssWriteRTWStrParam(S,fieldName,strBuffer) ) {
                    return(0);
                }

            } else if ( mxIsNumeric(field) ) {              /* numeric param */

                const void *rval   = mxGetData(field);
                int        isCmplx = mxIsComplex(field);
                DTypeId    dTypeId = ssGetDTypeIdFromMxArray(field);
                int        dtInfo  = DTINFO(dTypeId, isCmplx);
                const void *ival   = (isCmplx) ? mxGetImagData(field) : NULL;

                /* can handle only non-sparse, numeric vectors or matrices */
                if (nDims > 2 || nRows*nCols != nElements || mxIsSparse(field)){
                    return(0);
                }

                if (nRows == 1 || nCols == 1) {              /* vector param */
                    if ( !ssWriteRTWMxVectParam(S, fieldName, rval, ival,
                                                dtInfo, nElements) ) {
                        return(0);
                    }
                } else {                                     /* matrix param */
                    if ( !ssWriteRTWMx2dMatParam(S, fieldName, rval, ival,
                                                 dtInfo, nRows, nCols) ) {
                        return(0);
                    }
                }
            } else {
                return(0);
            }
        }

        if ( !ssWriteRTWStr(S, "}") ) {
            return(0);
        }
    }
    return(1);

} /* end WriteMatlabStructureToRTWFile */


#endif /* __ml2rtw__ */
