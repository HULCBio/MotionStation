/* $Revision: 1.1.6.1 $  $Date: 2003/07/11 15:52:38 $ */

#include <windows.h>
#include <vfw.h>
#include "mex.h"

#ifdef __cplusplus
   extern "C"
   {
#endif


void aviopen(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[]);

 
void addframe(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[]);

void aviclose(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[]);


#ifdef __cplusplus
    }   /* extern "C" */
#endif

