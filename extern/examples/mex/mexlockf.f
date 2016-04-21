C=================================================================















C     mexlockf.f
C 
C     This example demonstrates how to use mexLock, mexUnlock, and 
C     mexIsLocked.
C 
C     You must call mexlock with one argument.  If you pass in a 1, it
C     will lock the MEX-file. If you pass in a -1, it will unlock the
C     MEX-file. If you pass in 0, it will report lock status.   It uses
C     mexIsLocked to check the status of the MEX-file. If the file is
C     already in the state you requested, the MEX-file errors out.
C 
C     This is a MEX-file for MATLAB.  
C     Copyright 1984-2004 The MathWorks, Inc.
C     All rights reserved.
C     $Revision: 1.3.2.1 $
C=================================================================

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 64-bit platforms
C
      integer plhs(*), prhs(*)

C-----------------------------------------------------------------------
    
      integer mexIsLocked
      real*8  mxGetScalar
      real*8  lock
      
C     Check for proper number of input and output arguments    
      if (nrhs .ne. 1) then
 	    call mexErrMsgTxt(
     +   'Input argument must be a real scalar double')
      else if ((mxIsDouble(prhs(1)) .ne. 1) .or.
     +    (mxGetN(prhs(1))*mxGetM(prhs(1)) .ne. 1)  .or.
     +    (mxIsComplex(prhs(1)) .eq. 1)) then
	    call mexErrMsgTxt(
     +   'Input argument must be a real scalar double')
      end if
      if (nlhs .gt. 0) then
	    call mexErrMsgTxt('No output arguments expected.')
      end if
    
      lock = mxGetScalar(prhs(1))
    
      if ((lock .ne. 0.0) .and. (lock .ne. 1.0) .and. 
     +    (lock .ne. -1.0)) then
	    call mexErrMsgTxt('Input argument must be either 1 
     +      to lock or -1 to unlock or 0 for lock status.')
      end if
      
      if (mexIsLocked() .eq. 1) then
	    if (lock .gt. 0.0) then
	      call mexErrMsgTxt('MEX-file is already locked')
	    else if (lock .lt. 0.0) then
	      call mexUnlock()
	      call mexPrintf('MEX-file is unlocked')
	    else 
	      call mexPrintf('MEX-file is locked')
	    end if    
      else 
	    if (lock .lt. 0.0) then
	      call mexErrMsgTxt('MEX-file is already unlocked')
	    else if (lock .gt. 0.0) then
	      call mexLock()
	      call mexPrintf('MEX-file is locked')
	    else 
	      call mexPrintf('MEX-file is unlocked')
	    end if    
      end if
       return
       end
