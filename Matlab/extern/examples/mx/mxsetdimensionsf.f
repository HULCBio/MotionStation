C=================================================================















C     mxsetdimensionsf.f 
C 
C     mxsetdimensions reshapes your input array according to the the new
C     dimensions specified as input. For example,
C     mxsetdimensions(X,M,N,P,...) returns an N-D array with the same
C     elements as X but reshaped to have the size M-by-N-by-P-by-...
C     M*N*P*... must contain the same number of elements as X.
C 
C     This is a MEX-file for MATLAB.  
C     Copyright 1984-2004 The MathWorks, Inc.
C     All rights reserved.
C     $Revision: 1.2.2.1 $
C=================================================================

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platform
C
      integer plhs(*), prhs(*)
      integer mxDuplicateArray
     
C-----------------------------------------------------------------------
    
      integer mxGetNumberOfElements, mxIsSparse
      
      real*8  mxGetScalar
      
      integer number_new_dims, number_input_elements
      integer number_new_elements, i
      integer new_dims(10)
      
      number_new_elements = 1
          
C     Check for proper number of input and output arguments    
      if (nrhs .lt. 3) then
        call mexErrMsgTxt('At least 3 input arguments required.')
      end if
      if (nlhs .gt. 1) then
        call mexErrMsgTxt('Too many output arguments.')
      end if
      
      number_new_dims = nrhs-1
      
      if (mxIsSparse(prhs(1)) .eq. 1) then
	    call mexErrMsgTxt(
     +     'Sparse arrays are not supported.')
      end if

      number_input_elements = mxGetNumberOfElements(prhs(1)) 
    
C     Create the dimensions array and check to make sure total 
C     number of elements for the input array is the same for the 
C     reshaped array. 

      do 10 i=1,number_new_dims
	    if(mxGetNumberOfElements(prhs(i+1)) .ne. 1) then
	      call mexErrMsgTxt('Size arguments must be integer scalars.')
	    end if
	    
	  new_dims(i) = int(mxGetScalar(prhs(i+1)))
	  number_new_elements = new_dims(i)*number_new_elements 
   10 continue

      if (number_new_elements .ne. number_input_elements) then
        call mexErrMsgTxt('Both arrays must have same # of elements.')
      end if
      
C     Duplicate the array 
      plhs(1) = mxDuplicateArray(prhs(1)) 
    
C     Use mxSetDimensions to reshape
C     Set the new dimensions
	    call mxSetDimensions(plhs(1),new_dims, number_new_dims)

      return
      end
