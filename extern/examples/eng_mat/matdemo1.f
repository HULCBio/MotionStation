








C






C
C     matdemo1.f
C
C     This is a simple program that illustrates how to call the MATLAB
C     MAT-file functions from a FORTRAN program.  This demonstration
C     focuses on writing MAT-files.
C
C Copyright 1984-2000 The MathWorks, Inc.
C=====================================================================
C $Revision: 1.9.4.1 $

C     matdemo1 - create a new MAT-file from scratch.
C
      program matdemo1
C--------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC alpha
C     64-bit platform
C
      integer matOpen, mxCreateDoubleMatrix, mxCreateString 
      integer matGetVariable, mxGetPr
      integer mp, pa1, pa2, pa3, pa0
C--------------------------------------------------------------------
C
C     Other variable declarations here
C     
      integer status, matClose, mxIsFromGlobalWS
      integer matPutVariable, matPutVariableAsGlobal, matDeleteVariable
      double precision dat(9)
      data dat / 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0 /

C
C     Open MAT-file for writing
C
      write(6,*) 'Creating MAT-file matdemo.mat ...'
      mp = matOpen('matdemo.mat', 'w')
      if (mp .eq. 0) then
         write(6,*) 'Can''t open ''matdemo.mat'' for writing.'
         write(6,*) '(Do you have write permission in this directory?)'
         stop
      end if
C
C     Create variables
C
      pa0 = mxCreateDoubleMatrix(3,3,0)
      call mxCopyReal8ToPtr(dat, mxGetPr(pa0), 9)
C
      pa1 = mxCreateDoubleMatrix(3,3,0)
C
      pa2 = mxCreateString('MATLAB: The language of computing')
C
      pa3 = mxCreateString('MATLAB: The language of computing')
C
      status = matPutVariableAsGlobal(mp, 'NumericGlobal', pa0)
      if (status .ne. 0) then
         write(6,*) 'matPutVariableAsGlobal ''Numeric Global'' failed'
         stop
      end if
      status = matPutVariable(mp, 'Numeric', pa1)
      if (status .ne. 0) then
         write(6,*) 'matPutVariable ''Numeric'' failed'
         stop
      end if
      status = matPutVariable(mp, 'String', pa2)
      if (status .ne. 0) then
         write(6,*) 'matPutVariable ''String'' failed'
         stop
      end if
      status = matPutVariable(mp, 'String2', pa3)
      if (status .ne. 0) then
         write(6,*) 'matPutVariable ''String2'' failed'
         stop
      end if

C
C     Whoops! Forgot to copy the data into the first matrix -- 
C     it is now blank.  Well, ok, this was deliberate.  This 
C     demonstrates that matPutVariable will overwrite existing 
C     matrices.
C
      call mxCopyReal8ToPtr(dat, mxGetPr(pa1), 9)
      status = matPutVariable(mp, 'Numeric', pa1)
      if (status .ne. 0) then
         write(6,*) 'matPutVariable ''Numeric'' failed 2nd time'
         stop
      end if

C
C     We will delete String2 from the MAT-file.
C
      status = matDeleteVariable(mp, 'String2')
      if (status .ne. 0) then
         write(6,*) 'matDeleteVariable ''String2'' failed'
         stop
      end if
C     
C     Finally, read back in MAT-file to make sure we know what we put
C     in it.
C
      status = matClose(mp)
      if (status .ne. 0) then
         write(6,*) 'Error closing MAT-file'
         stop
      end if
C
      mp = matOpen('matdemo.mat', 'r')
      if (mp .eq. 0) then
         write(6,*) 'Can''t open ''matdemo.mat'' for reading.'
         stop
      end if
C
      pa0 = matGetVariable(mp, 'NumericGlobal')
      if (mxIsFromGlobalWS(pa0) .eq. 0) then
         write(6,*) 'Invalid non-global matrix written to MAT-file'
         stop
      end if
C
      pa1 = matGetVariable(mp, 'Numeric')
      if (mxIsNumeric(pa1) .eq. 0) then
         write(6,*) 'Invalid non-numeric matrix written to MAT-file'
         stop
      end if
C

      pa2 = matGetVariable(mp, 'String')

      if (mxIsChar(pa2) .eq. 0) then
         write(6,*) 'Invalid non-string matrix written to MAT-file'
         stop
      end if
C
      pa3 = matGetVariable(mp, 'String2')
      if (pa3 .ne. 0) then
         write(6,*) 'String2 not deleted from MAT-file'
         stop
      end if
C
C     clean up memory
      call mxDestroyArray(pa0)
      call mxDestroyArray(pa1)
      call mxDestroyArray(pa2)
      call mxDestroyArray(pa3)

      status = matClose(mp)
      if (status .ne. 0) then
         write(6,*) 'Error closing MAT-file'
         stop
      end if
C
      write(6,*) 'Done creating MAT-file'
      stop
      end
