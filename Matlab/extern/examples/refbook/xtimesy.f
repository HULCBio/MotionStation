








C






C     
C     xtimesy.f
C
C     multiple the first input by the second input
      
C     This is a MEX file for MATLAB.
C     Copyright 1984-2004 The MathWorks, Inc. 
C     $Revision: 1.12.2.1 $
      
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      integer plhs(*), prhs(*)
      integer mxCreateDoubleMatrix
      integer mxGetPr
      integer x_pr, y_pr, z_pr
C-----------------------------------------------------------------------
C

      integer nlhs, nrhs
      integer m, n, size
      integer mxGetM, mxGetN, mxIsNumeric 
      real*8  x, y(100), z(100)

C     Check for proper number of arguments. 
      if (nrhs .ne. 2) then
         call mexErrMsgTxt('Two inputs required.')
      elseif (nlhs .ne. 1) then
         call mexErrMsgTxt('One output required.')
      endif

C     Check to see both inputs are numeric.
      if (mxIsNumeric(prhs(1)) .ne. 1) then
         call mexErrMsgTxt('Input # 1 is not a numeric.')
      elseif (mxIsNumeric(prhs(2)) .ne. 1) then
         call mexErrMsgTxt('Input #2 is not a numeric array.')
      endif
      
C     Check that input #1 is a scalar.
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      if(n .ne. 1 .or. m .ne. 1) then
         call mexErrMsgTxt('Input #1 is not a scalar.')
      endif

C     Get the size of the input matrix.
      m = mxGetM(prhs(2))
      n = mxGetN(prhs(2))
      size = m*n
      if(size .gt. 100) then
         call mexErrMsgTxt('Input #2 number of elements exceeds buffer')
      endif

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(m,n,0)
      x_pr = mxGetPr(prhs(1))
      y_pr = mxGetPr(prhs(2))
      z_pr = mxGetPr(plhs(1))

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(x_pr,x,1)
      call mxCopyPtrToReal8(y_pr,y,size)

C     Call the computational subroutine
      call xtimesy(x,y,z,m,n)

C     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(z,z_pr,size)

      return
      end

      subroutine xtimesy(x,y,z,m,n)
      real*8  x, y(m,n), z(m,n)
      integer m, n
      do 20 i=1,m
         do 10 j=1,n
            z(i,j)=x*y(i,j)
 10      continue
 20   continue
      return
      end

      
