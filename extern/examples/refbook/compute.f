C=======================================================================






C     
C     compute.f
C
C     This subroutine doubles the input matrix. Your version of 
C     compute() may do whaveter you would like it to do.
C
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2000 The MathWorks, Inc. 
C     $Revision: 1.3 $
C=======================================================================

C     computational subroutine
      subroutine compute(out_mat, in_mat, size)
      integer size, i
      real*8  out_mat(*), in_mat(*)

      do 10 i=1,size
         out_mat(i) = 2*in_mat(i)
 10   continue

      return
      end
