C===================================================================















C     mxcreatecellmatrixf.f 
C 
C     mxcreatecellmatrix takes the input arguments and places them in a
C     cell. It then displays the contents of the cell through a
C     mexCallMATLAB call.
C 
C 
C     This is a MEX-file for MATLAB.  
C     Copyright 1984-2004 The MathWorks, Inc.
C     All rights reserved.
C     $Revision: 1.2.2.1 $
C===================================================================

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 64-bit platforms
C
      integer plhs(*), prhs(*)
      integer mxCreateCellMatrix, mxDuplicateArray
      integer cell_array_ptr, rhs(1)
      
C-----------------------------------------------------------------------

      integer i
    
C     Check for proper number of input and output arguments    
      if (nrhs .lt. 1) then
         call mexErrMsgTxt('One input argument required.')
      end if
      if (nlhs .gt. 1) then
         call mexErrMsgTxt('Too many output arguments.')
      end if

C     Create a nrhs x 1 cell mxArray.  
      cell_array_ptr = mxCreateCellMatrix(nrhs,1)
    
C     Fill cell matrix with input arguments
      do 10 i=1,nrhs
        call mxSetCell(cell_array_ptr,i,
     +                     mxDuplicateArray(prhs(i)))
   10 continue  
           
      rhs(1) = cell_array_ptr
    
C     Call mexCallMATLAB to display the cell 
      call mexPrintf('The contents of the created cell is:')
      call mexPrintf(char(10))
      call mexCallMATLAB(0,NULL,1,rhs,'disp')

C     Cleanup the un-freed memory after calling mexCallMATLAB.
      call mxDestroyArray(rhs(1))
    
      return
      end





















































