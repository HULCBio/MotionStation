/*
 * $Revision: 1.4.6.4 $
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "libMultpkg.h"

/*
 * Function prototype; the MATLAB Compiler creates mlfMultarg 
 *  from multarg.m
 */

int PrintHandler( const char *text )
{
    return printf(text);
}

int main( )   /* Programmer written coded to call mlfMultarg */
{
#define ROWS  3 
#define COLS  3
    mxArray *a = NULL, *b = NULL, *x, *y; 
    double  x_pr[ROWS * COLS] = {1, 2, 3, 4, 5, 6, 7, 8, 9}; 
    double  x_pi[ROWS * COLS] = {9, 2, 3, 4, 5, 6, 7, 8, 1}; 
    double  y_pr[ROWS * COLS] = {1, 2, 3, 4, 5, 6, 7, 8, 9}; 
    double  y_pi[ROWS * COLS] = {2, 9, 3, 4, 5, 6, 7, 1, 8}; 
    double *a_pr, *a_pi, value_of_scalar_b;

    /* Call the mclInitializeApplication routine. Make sure that the application
     * was initialized properly by checking the return status. This initialization
     * has to be done before calling any MATLAB API's or MATLAB Compiler generated
     * shared library functions. */
    if( ! mclInitializeApplication(NULL,0) )
    {
        fprintf(stderr, "Could not initialize the application.\n");
        exit(1);
    }
    /* Initialize with a print handler to tell mlfPrintmatrix
     * how to display its output.
     */
    if (! libMultpkgInitializeWithHandlers(PrintHandler, PrintHandler) )
    {
        fprintf(stderr,"Could not initialize the library.\n");
        exit(1);
    }

    
    /* Create input matrix "x" */ 
    x = mxCreateDoubleMatrix(ROWS, COLS, mxCOMPLEX); 
    memcpy(mxGetPr(x), x_pr, ROWS * COLS * sizeof(double));
    memcpy(mxGetPi(x), x_pi, ROWS * COLS * sizeof(double));
    
    /* Create input matrix "y" */ 
    y = mxCreateDoubleMatrix(ROWS, COLS, mxCOMPLEX); 
    memcpy(mxGetPr(y), y_pr, ROWS * COLS * sizeof(double));
    memcpy(mxGetPi(y), y_pi, ROWS * COLS * sizeof(double));
    
    /* Call the mlfMultarg function. */
    mlfMultarg(2, &a, &b, x, y); 
    
    /* Display the entire contents of output matrix "a". */
    mlfPrintmatrix(a);
    
    /* Display the entire contents of output scalar "b" */
    mlfPrintmatrix(b);
    
    /* Deallocate temporary matrices. */
    mxDestroyArray(a);
    mxDestroyArray(b);
    libMultpkgTerminate();
    mclTerminateApplication();
    return(0);
}
