C  /* $Revision: 1.3 $ */
C Changes for Microsoft fortran compiler on PC.
C
C Create interface blocks to prototype all subroutines and functions
C which use  %VAL and are called from this gateway routine.
C
C Also reset the floating point exception word as it gets initialized when
C a Fortran program is called. 
C
C-----------------------------------------------------------------------
C Interface blocks used for %VAL.
C   
C
      INTERFACE 
      SUBROUTINE CAIRY(Z, ID, KODE, AI, NZ, IERR)
      INTEGER ID, KODE, NZ, IERR
      COMPLEX*16  Z, AI
      END SUBROUTINE CAIRY
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE CBIRY(Z, ID, KODE, BI, IERR)
      INTEGER ID, KODE,IERR
      COMPLEX*16  Z, BI
      END SUBROUTINE CBIRY
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE CBESJ(Z, FNU, KODE, N, CY, NZ, IERR)
      INTEGER KODE, N, NZ, IERR
      COMPLEX*16  Z, CY
      REAL*8 FNU
      END SUBROUTINE CBESJ
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE BESSSET(A,I,B)
      INTEGER I
      COMPLEX*16  A, B
      END SUBROUTINE BESSSET
      END INTERFACE
C
      INTERFACE 
      FUNCTION BESSGET(A, I)
      INTEGER I
      COMPLEX*16  A
      END FUNCTION BESSGET
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE CBESY(Z, FNU, KODE, N, CY, NZ, CWRK, IERR)
      INTEGER KODE,N, NZ, IERR
      COMPLEX*16  Z, CY, CWRK 
      REAL*8 FNU 
      END SUBROUTINE CBESY
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE CBESI(Z, FNU, KODE, N, CY, NZ, IERR)
      INTEGER  KODE, N, NZ, IERR
      COMPLEX*16  Z, CY
      REAL*8 FNU
      END SUBROUTINE CBESI
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE CBESK(Z, FNU, KODE, N, CY, NZ, IERR)
      INTEGER KODE,IERR, N,NZ
      COMPLEX*16  Z, CY
      REAL*8 FNU
      END SUBROUTINE CBESK
      END INTERFACE
C
      INTERFACE 
      SUBROUTINE CBESH(Z, FNU, KODE, M, N, CY, NZ, IERR)
      INTEGER KODE,M, N, NZ, IERR
      COMPLEX*16  Z, CY
      REAL*8 FNU
      END SUBROUTINE CBESH
      END INTERFACE
C
C Set the floating point control word to allow divide by zero etc.
C
	INTEGER(2) CONTROL, NEWCONTROL
	CALL GETCONTROLFPQQ(CONTROL)
	NEWCONTROL = CONTROL .OR. FPCW$ZERODIVIDE
	CALL SETCONTROLFPQQ(NEWCONTROL)

