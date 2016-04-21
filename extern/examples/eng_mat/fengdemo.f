








C






C
C     fengdemo.f
C
C     This is a simple program that illustrates how to call the MATLAB
C     Engine functions from a FORTRAN program.
C
C Copyright 1984-2000 The MathWorks, Inc.
C======================================================================
C $Revision: 1.9 $

      program main
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      integer engOpen, engGetVariable, mxCreateDoubleMatrix
      integer mxGetPr
      integer ep, T, D 
C----------------------------------------------------------------------
C
C     Other variable declarations here
      double precision time(10), dist(10)
      integer engPutVariable, engEvalString, engClose
      integer temp, status
      data time / 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0 /
C
      ep = engOpen('matlab ')
C
      if (ep .eq. 0) then
         write(6,*) 'Can''t start MATLAB engine'
         stop
      endif
C
      T = mxCreateDoubleMatrix(1, 10, 0)
      call mxCopyReal8ToPtr(time, mxGetPr(T), 10)
C
C
C     Place the variable T into the MATLAB workspace
C
      status = engPutVariable(ep, 'T', T)
C
      if (status .ne. 0) then 
         write(6,*) 'engPutVariable failed'
         stop
      endif
C
C
C     Evaluate a function of time, distance = (1/2)g.*t.^2
C     (g is the acceleration due to gravity)
C     
      if (engEvalString(ep, 'D = .5.*(-9.8).*T.^2;') .ne. 0) then
         write(6,*) 'engEvalString failed'
         stop
      endif
C
C
C     Plot the result
C
      if (engEvalString(ep, 'plot(T,D);') .ne. 0) then 
       write(6,*) 'engEvalString failed'
         stop
      endif

      if (engEvalString(ep, 'title(''Position vs. Time'')') .ne. 0) then
          write(6,*) 'engEvalString failed'
          stop
      endif

      if (engEvalString(ep, 'xlabel(''Time (seconds)'')') .ne. 0) then
          write(6,*) 'engEvalString failed'
          stop
      endif
      if (engEvalString(ep, 'ylabel(''Position (meters)'')') .ne. 0)then
          write(6,*) 'engEvalString failed'
          stop
      endif
C     
C     
C     read from console to make sure that we pause long enough to be
C     able to see the plot
C     
      print *, 'Type 0 <return> to Exit'
      print *, 'Type 1 <return> to continue'

      read(*,*) temp
C
      if (temp.eq.0) then
         print *, 'EXIT!'
         stop
      end if
C
      if (engEvalString(ep, 'close;') .ne. 0) then
         write(6,*) 'engEvalString failed'
         stop
      endif 
C      
      D = engGetVariable(ep, 'D')
      call mxCopyPtrToReal8(mxGetPr(D), dist, 10)
      print *, 'MATLAB computed the following distances:'
      print *, '  time(s)  distance(m)'
      do 10 i=1,10
         print 20, time(i), dist(i)
 20      format(' ', G10.3, G10.3)
 10   continue
C	
C     
      call mxDestroyArray(T)
      call mxDestroyArray(D)
      status = engClose(ep)
C      
      if (status .ne. 0) then 
         write(6,*) 'engClose failed'
         stop
      endif
C
      stop
      end
