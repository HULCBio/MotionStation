/*
 * MRANKP.C
 * "Posix" C main program illustrating the use of the MATLAB Math Library.
 * Calls mlfMrank, obtained by using MCC to compile mrank.m.
 *
 * $Revision: 1.3.6.3 $
 *
 */

#include <stdio.h>
#include <math.h>
#include "libPkg.h"

int main( int argc, char **argv )
{
    mxArray *N;    /* Matrix containing n. */
    mxArray *R = NULL;    /* Result matrix. */
    int      n;    /* Integer parameter from command line. */

    /* Get any command line parameter. */
    if (argc >= 2) {
        n = atoi(argv[1]);
    } else {
        n = 12;
    }

    /* Call the mclInitializeApplication routine. Make sure that the application
     * was initialized properly by checking the return status. This initialization
     * has to be done before calling any MATLAB API's or MATLAB Compiler generated
     * shared library functions. */
    if( !mclInitializeApplication(NULL,0) )
    {
        fprintf(stderr, "Could not initialize the application.\n");
        exit(1);
    }
    /* Call the library intialization routine and make sure that the
     * library was initialized properly */
    if (!libPkgInitialize())
    {
        fprintf(stderr,"Could not initialize the library.\n");
        exit(1);
    }
    
    /* Create a 1-by-1 matrix containing n. */
    N = mxCreateScalarDouble(n);
    
    /* Call mlfMrank, the compiled version of mrank.m. */
    mlfMrank(1, &R, N);
    
    /* Print the results. */
    mlfPrintmatrix(R);
    
    /* Free the matrices allocated during this computation. */
    mxDestroyArray(N);
    mxDestroyArray(R);

    libPkgTerminate();    /* Terminate the library of M-functions */
    mclTerminateApplication();
    return 0;
}
