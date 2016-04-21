/*
 * MRANKWIN
 * Windows C main program illustrating the use of the MATLAB Math Library.
 * Calls mlfMrank, obtained by using MCC to compile mrank.m.
 *
 * $Revision: 1.3.6.4 $ 
 */

#include <stdio.h>
#include <math.h>
#include "libPkg.h"
#include <windows.h>

static int totalcnt  = 0;
static int upperlim  = 0;
static int firsttime = 1;
char *OutputBuffer;

int WinPrint( char *text )
{
    int cnt = 0;
    
    if (firsttime) {
        OutputBuffer = (char *)mxCalloc(1028, 1);
        upperlim += 1028;
        firsttime = 0;
    }
    
    cnt = strlen(text);
    if (totalcnt + cnt >= upperlim) {
        char *TmpOut;
        TmpOut = (char *)mxCalloc(upperlim + 1028, 1);
        memcpy(TmpOut, OutputBuffer, upperlim);
        upperlim += 1028;
        mxFree(OutputBuffer);
        OutputBuffer = TmpOut;
    }
    strncat(OutputBuffer, text, cnt);
    return cnt;
}

void WinFlush(void)
{
    MessageBox(NULL, OutputBuffer, "MRANK", MB_OK);
    mxFree(OutputBuffer);
    totalcnt = 0;
    firsttime = 1;
    upperlim = 0;
}

WINAPI
WinMain( HANDLE hInstance, HANDLE hPrevInstance, LPSTR lpszCmdLine, int nCmdShow )
{
#define MAXCMDTOKENS 128

    LPSTR argv[MAXCMDTOKENS];
    int   argc = 0;
    
    mxArray *N;    /* matrix containing n. */
    mxArray *R = NULL;    /* Result matrix.       */
    int      n;    /* Integer parameter from command line. */
    
    /* Call the mclInitializeApplication routine. Make sure that the application
     * was initialized properly by checking the return status. This initialization
     * has to be done before calling any MATLAB API's or MATLAB Compiler generated
     * shared library functions.  */
    if( !mclInitializeApplication(NULL,0) )
    {
        fprintf(stderr, "Could not initialize the application.\n");
        exit(1);
    }

    /* Initialize the library with a print handler. Check the return status
     * to make sure that the library initialized without errors.  */
    if (!libPkgInitializeWithHandlers(WinPrint, WinPrint) )
    {
        fprintf(stderr, "Could not initialize the library.\n");
        exit(1);
    }
    
    
    /* Get any command line parameter. */
    argv[argc] = "mrank.exe";
    argv[++argc] = strtok(lpszCmdLine, " ");
    while (argv[argc] != NULL) argv[++argc] = strtok(NULL, " ");
    if (argc >= 2) {
        n = atoi(argv[1]);
    } else {
        n = 12;
    }
    
    /* Create a 1-by-1 matrix containing n. */
    N = mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(N) = n;
    
    /* Call mlfMrank, the compiled version of mrank.m. */
    mlfMrank(1, &R, N);
    
    /* Print the results. */
    mlfPrintmatrix(R);
    WinFlush();
    
    /* Free the matrices allocated during this computation. */
    mxDestroyArray(N);
    mxDestroyArray(R);
    
    libPkgTerminate();    /* Terminate the library of M-functions */
    mclTerminateApplication();
    return(0);
}
