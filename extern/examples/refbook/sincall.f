
C ======================================================================






C     
C     sincall.f
C
C     example for illustrating how to use mexCallMATLAB
C     
C     creates an mxArray and passes its associated  pointers (in this 
C     demo, only pointer to its real part, pointer to number of rows,
C     pointer to number of columns) to subfunction fill() to get data
C     filled up, then calls mexCallMATLAB to calculate sin function and
C     plot the result.
C
C     NOTE: The subfunction fill() is in the file called fill.f.
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2004 The MathWorks, Inc. 
C     $Revision: 1.10.2.2 $
C ======================================================================










C     gateway subroutine

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      integer nlhs, nrhs
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platform
C
      integer plhs(*), prhs(*)
      integer rhs(1), lhs(1)
      integer mxGetPr, mxCreateDoubleMatrix
C-----------------------------------------------------------------------
C
      integer m, n, max
      
C     initializition
      m=1
      n=1
      max=1000

      rhs(1) = mxCreateDoubleMatrix(max, 1, 0)
 
C     pass the pointer and variable and let fill() fill up data
      call fill(%VAL(mxGetPr(rhs(1))), m, n, max)
      call mxSetM(rhs(1), m)
      call mxSetN(rhs(1), n)

      call mexCallMATLAB(1, lhs, 1, rhs, 'sin')
      call mexCallMATLAB(0, NULL, 1, lhs, 'plot')

C     cleanup the un-freed memory after calling mexCallMATLAB.
      call mxDestroyArray(rhs(1))
      call mxDestroyArray(lhs(1))

      return
      end  





