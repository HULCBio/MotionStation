








C






C
C     matdemo2.f
C
C     This is a simple program that illustrates how to call the MATLAB
C     MAT-file functions from a FORTRAN program.  This demonstration
C     focuses on reading MAT-files. It reads in the MAT-file created 
C     by matdemo1.f, and describe its contents.
C
C Copyright 1984-2000 The MathWorks, Inc.
C=====================================================================
C $Revision: 1.11.4.1 $
C
      program matdemo2
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      integer matOpen, matGetDir, matGetNextVariable
      integer matGetVariableInfo, matGetNextVariableInfo
      integer mp, dir, adir(100), pa
C----------------------------------------------------------------------
C
C     Other variable declarations here
C     
      integer   mxGetM, mxGetN, matClose
      integer   ndir, i, stat
      character*32 names(100), name

C
C-------------------------------------------------------------
C     Open file and read directory
C-------------------------------------------------------------
C
      mp = matOpen('matdemo.mat', 'r')
      if (mp .eq. 0) then
         write(6,*) 'Can''t open ''matdemo.mat''.'
         stop
      end if
C
C     Read directory
C
      dir = matgetdir(mp, ndir)
      if (dir .eq. 0) then
         write(6,*) 'Can''t read directory.'
         stop
      endif
C
C     Copy pointer into an array of pointers
C
      call mxCopyPtrToPtrArray(dir, adir, ndir)
C
C     Copy pointer to character string
C
      do 20 i=1,ndir
         call mxCopyPtrToCharacter(adir(i), names(i), 32)
   20 continue
C
      write(6,*) 'Directory of Mat-file:'
      do 30 i=1,ndir
         write(6,*) names(i)
   30 continue
C
      stat = matClose(mp)
      if (stat .ne. 0) then
         write(6,*) 'Error closing ''matdemo.mat''.'
         stop
      end if
C
C-------------------------------------------------------------
C     Reopen file and read full arrays
C-------------------------------------------------------------
C
      mp = matOpen('matdemo.mat', 'r')
      if (mp .eq. 0) then
         write(6,*) 'Can''t open ''matdemo.mat''.'
         stop
      end if
C
C     Get Information on first array in mat file
C
      write(6,*) 'Getting Header info from first array.'
      pa = matGetVariableInfo(mp, names(1))
      write(6,*) 'Retrieved ', names(1)
      write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
      call mxDestroyArray(pa)
      
      write(6,*) 'Getting Header info from next array.'
      pa = matGetNextVariableInfo(mp, name)
      write(6,*) 'Retrieved ', name
      write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
      call mxDestroyArray(pa)
C
C     Read directory
C
      write(6,*) 'Getting rest of array contents:'
      pa = matGetNextVariable(mp, name)
      do while (pa .ne. 0)
C
C     Copy name to character string
C
         i=mxGetM(pa)
         write(*, *) i 
         write(6,*) 'Retrieved ', name
         write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
         call mxDestroyArray(pa)
         pa = matGetNextVariable(mp, name)
      end do
C
      stat = matClose(mp)
      if (stat .ne. 0) then
         write(6,*) 'Error closing ''matdemo.mat''.'
         stop
      end if
      stop
C
      end



