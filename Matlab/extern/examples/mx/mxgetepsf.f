C=================================================================















C     mxgetepsf.f 
C
C     This is an example of how to use mxGetEps.  The function takes two
C     real double arrays and does an element-by-element compare of each
C     element for equality within eps. Eps is the distance from 1.0 to
C     the next largest floating point number and is used as the default
C     tolerance.  If all the elements are equal within eps, a 1 is returned.
C     If they are not all equal within eps, a 0 is returned.
C
C     This is a MEX-file for MATLAB.  
C     Copyright 1984-2004 The MathWorks, Inc.
C     All rights reserved.
C     $Revision: 1.1.2.2 $
C=================================================================

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platform
C
      integer plhs(*), prhs(*)
      integer mxCreateDoubleMatrix, mxGetDimensions, mxGetPr
      integer dims_first_ptr, dims_second_ptr
      integer first_ptr, second_ptr
      
C-----------------------------------------------------------------------
 
      integer mxGetNumberOfElements, mxIsDouble, mxIsComplex
      integer mxGetNumberOfDimensions
      real*8  mxGetEps

      integer c, elements, j, dims_first(10), dims_second(10)
      real*8 first(10000), second(10000), eps, TRUE
      data TRUE /1.0/
    
C     Check for proper number of input and output arguments    
      if (nrhs .ne. 2) then
	    call mexErrMsgTxt('Two input arguments required.')
      end if
      if (nlhs .gt. 1) then
        call mexErrMsgTxt('Too many output arguments.')
      end if
    
C     Check data type of first input argument
      if ((mxIsDouble(prhs(1)) .ne. 1) .or.
     +    (mxIsDouble(prhs(2)) .ne. 1) .or.
     +    (mxIsComplex(prhs(1)).ne. 0) .or.
     +    (mxIsComplex(prhs(2)).ne. 0)) then
        call mexErrMsgTxt(
     +      'Input arguments must be real of type double.')
      end if
    
C     Check that dimensions are the same for input arguments.
      if ( mxGetNumberOfDimensions(prhs(1)) .ne. 
     +     mxGetNumberOfDimensions(prhs(2))) then
        call mexErrMsgTxt(
     +   'Inputs must have the same number of dimensions.')
      end if

      dims_first_ptr = mxGetDimensions(prhs(1))
      dims_second_ptr = mxGetDimensions(prhs(2))

      call mxCopyPtrtoInteger4(dims_first_ptr, dims_first, 
     +                         mxGetNumberOfDimensions(prhs(1)))
      call mxCopyPtrtoInteger4(dims_second_ptr, dims_second, 
     +                         mxGetNumberOfDimensions(prhs(2)))
      
C     Check that inputs have the same dimensions.
      do 10 c=1,mxGetNumberOfDimensions(prhs(1))
        if (dims_first(c) .ne. dims_second(c)) then
	      call mexErrMsgTxt(
     +     'Inputs must have the same dimensions.')
	    end if
   10 continue
    
C     Get the number of elements in the input argument
      elements = mxGetNumberOfElements(prhs(1))

C     Get the input values 
      first_ptr = mxGetPr(prhs(1))
      second_ptr = mxGetPr(prhs(2))
      
      call mxCopyPtrtoReal8(first_ptr, first, 
     +                      mxGetNumberOfElements(prhs(1)))
      call mxCopyPtrtoReal8(second_ptr, second,
     +                      mxGetNumberOfElements(prhs(2)))
    
C     Create output 
      plhs(1)=mxCreateDoubleMatrix(1,1,0)
    
C     Get the value of eps 
      eps = mxGetEps()

C     Check for equality within eps 
      do 20 j=1,elements
    	 if ((abs(first(j) - second(j))).gt.(abs(second(j)*eps))) then
	      call mexWarnMsgTxt(
     +     'Inputs are not the same within eps.')
    	    go to 21
	     end if
   20 continue

   21 if (j .gt. elements ) then
	    call mxCopyReal8toPtr(TRUE,mxGetPr(plhs(1)),1)
      end if

      return
      end
