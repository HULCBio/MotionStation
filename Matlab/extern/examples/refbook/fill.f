C ======================================================================






C     
C     fill.f
C     This is the subfunction called by sincall that fills the 
C     mxArray with data.  Your version of fill can load your data
C     however you would like.
C
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2000 The MathWorks, Inc. 
C     $Revision: 1.3 $
C ======================================================================
C     subroutine for filling up data

      subroutine fill(pr, m, n, max)
      
      real*8  pr(*)
      integer i, m, n, max
     
      m=max/2
      n=1
      do 10 i=1,m
 10      pr(i)=i*(4*3.1415926/max)

      return
      end
