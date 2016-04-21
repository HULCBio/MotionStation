








C






C     
C     matsq.f
C
C     squares the input matrix
      
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2004 The MathWorks, Inc. 
C     $Revision: 1.13.2.1 $

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      integer plhs(*), prhs(*)
      integer mxCreateDoubleMatrix, mxGetPr
      integer x_pr, y_pr
C-----------------------------------------------------------------------
C

      integer nlhs, nrhs
      integer mxGetM, mxGetN, mxIsNumeric
      integer m, n, size
      real*8  x(1000), y(1000)

C     Check for proper number of arguments. 
      if(nrhs .ne. 1) then
         call mexErrMsgTxt('One input required.')
      elseif(nlhs .ne. 1) then
         call mexErrMsgTxt('One output required.')
      endif

C     Get the size of the input array.
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      size = m*n

C     Column * row should be smaller than 1000
      if(size.gt.1000) then
         call mexErrMsgTxt('Row * column must be <= 1000.')
      endif
      
C     Check to insure the array is numeric (not strings).
      if(mxIsNumeric(prhs(1)) .eq. 0) then
         call mexErrMsgTxt('Input must be a numeric array.')
      endif

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(m,n,0)
      x_pr = mxGetPr(prhs(1))
      y_pr = mxGetPr(plhs(1))
      call mxCopyPtrToReal8(x_pr,x,size)

C     Call the computational subroutine.
      call matsq(y, x, m, n)

C     Load the data into y_pr, which is the output to MATLAB
      call mxCopyReal8ToPtr(y,y_pr,size)     

      return
      end

      subroutine matsq(y, x, m, n)
      real*8 x(m,n), y(m,n)
      integer m, n
C     
      do 20 i=1,m
         do 10 j=1,n
            y(i,j)= x(i,j)**2
 10      continue
 20   continue
      return
      end
C     



