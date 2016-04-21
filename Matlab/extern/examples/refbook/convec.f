C======================================================================
C






C     
C     convec.f
C     example for illustrating how to pass complex data from MATLAB
C     to FORTRAN (using COMPLEX data type) and back again
C
C     convolves two complex input vectors
C      
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2004 The MathWorks, Inc.
C     $Revision: 1.15.2.1 $
C======================================================================










C     computational subroutine
      subroutine convec(x,y,z,nx,ny)
      complex*16 x(*), y(*), z(*)
      integer nx, ny

C     Initialize the output array
      do 10 i=1,nx+ny-1
         z(i) = (0.0,0.0)
 10   continue

      do 30 i=1,nx
         do 20 j=1,ny
            z(i+j-1) = z(i+j-1) + x(i) * y(j)
 20      continue
 30   continue
      return
      end

C     The gateway routine.
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      integer nlhs, nrhs
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      integer plhs(*), prhs(*)
      integer mxGetPr, mxGetPi, mxCreateDoubleMatrix
C-----------------------------------------------------------------------
C
      integer mx, nx, my, ny, nz
      integer mxGetM, mxGetN, mxIsComplex
      complex*16 x(100), y(100), z(199)


C     Check for proper number of arguments. 
      if (nrhs .ne. 2) then
         call mexErrMsgTxt('Two inputs required.')
      elseif (nlhs .gt. 1) then
         call mexErrMsgTxt('Too many output arguments.')
      endif

C     Check that inputs are both row vectors.
      mx = mxGetM(prhs(1))
      nx = mxGetN(prhs(1))
      my = mxGetM(prhs(2))
      ny = mxGetN(prhs(2))
      nz = nx+ny-1

C     Only handle row vector input
      if(mx .ne. 1 .or. my .ne. 1) then
         call mexErrMsgTxt('Both inputs must be row vector.')
C     Check sizes of the two input
      elseif(nx .gt. 100 .or. ny .gt. 100) then
         call mexErrMsgTxt('Inputs must have less than 100 elements.')
C     Check to see both inputs are complex.
      elseif ((mxIsComplex(prhs(1)) .ne. 1) .or.           
     +        (mxIsComplex(prhs(2)) .ne. 1)) then
         call mexErrMsgTxt('Inputs must be complex.')
      endif

C     Create the output array
      plhs(1) = mxCreateDoubleMatrix(1, nz, 1)

C     Load the data into Fortran arrays(native COMPLEX data).
      call mxCopyPtrToComplex16(mxGetPr(prhs(1)),mxGetPi(prhs(1)),x,nx)
      call mxCopyPtrToComplex16(mxGetPr(prhs(2)),mxGetPi(prhs(2)),y,ny)

C     Call the computational subroutine
      call convec(x,y,z,nx,ny)

C     Load the output into a MATLAB array.
      call mxCopyComplex16ToPtr(z,mxGetPr(plhs(1)),mxGetPi(plhs(1)),nz)

      return
      end





      
