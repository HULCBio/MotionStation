C======================================================================
C






C     
C     loadsparse.f
C     This is the subfunction called by fulltosparse that fills the 
C     mxArray with the sparse data.  Your version of
C     loadsparse can operate however you would like it to on the data.
C
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2000 The MathWorks, Inc.
C     $Revision: 1.4 $ 
C======================================================================

C     load sparse data subroutine
      function loadsparse(a,b,ir,jc,m,n,nzmax)
      integer nzmax, m, n
      integer ir(*), jc(*)
      real*8 a(*), b(*)

      integer i, j, k

C     Copy nonzeros
      k = 1
      do 100 j=1,n
C        NOTE: Sparse indexing is zero based
         jc(j) = k-1
         do 200 i=1,m
            if (a((j-1)*m+i).ne. 0.0) then
               if (k .gt. nzmax) then
                  jc(n+1) = nzmax
                  loadsparse = 1
                  goto 300
               endif
               b(k) = a((j-1)*m+i)
C              NOTE: Sparse indexing is zero based
               ir(k) = i-1
               k = k+1
            endif
 200     continue
 100  continue
C     NOTE: Sparse indexing is zero based
      jc(n+1) = k-1
      loadsparse = 0
 300  return
      end
