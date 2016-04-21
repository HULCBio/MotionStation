C=======================================================================






C     
C     dblmat.f
C     example for illustrating how to use %VAL
C     doubles the input matrix. The demo only handles real part of input.
C     NOTE: if your FORTRAN compiler does not support %VAL, 
C     use mxCopy_routine.
C
C     NOTE: The subroutine compute() is in the file called compute.f. 
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2000 The MathWorks, Inc. 
C     $Revision: 1.13.2.1 $
C=======================================================================










C     gateway subroutine

      subroutine mexfunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      integer plhs(*), prhs(*)
      integer pr_in, pr_out
      integer mxGetPr, mxCreateDoubleMatrix
C-----------------------------------------------------------------------
C
      integer nlhs, nrhs, mxGetM, mxGetN
      integer m_in, n_in, size

      if(nrhs .ne. 1) then
         call mexErrMsgTxt('One input required.')
      endif
      if(nlhs .gt. 1) then
         call mexErrMsgTxt('Less than one output required.')
      endif
         
      m_in = mxGetM(prhs(1))
      n_in = mxGetN(prhs(1))
      size = m_in * n_in
      pr_in = mxGetPr(prhs(1))
      plhs(1) = mxCreateDoubleMatrix(m_in, n_in, 0)
      pr_out = mxGetPr(plhs(1))

C     call the computational routine
      call compute(%VAL(pr_out), %VAL(pr_in), size)

      return
      end
      
    

