








C     Fortran MEX gateway function for the Amos Bessel function library.
C
C     Computes:
C         Airy functions: Ai(z), Ai'(z), Bi(z), Bi'(z)
C         Bessel functions: J_nu(z), Y_nu(z), I_nu(z), K_nu(z)
C         Hankel functions: H1_nu(z), H2_nu(z)
C         for real index nu and complex argument z.
C     MATLAB usage:
C         [w,<ierr>] = besselmx('FUN',nu,z,<scale>)
C     where
C         FUN = numerical ASCII value of first letter in function name
C             = 'A' 'B' 'J' 'Y' 'I' 'K' 'H' 
C             =  65  66  74  89  73  75  72
C         nu is a real scalar or vector,
C         z is a real or complex scalar, vector or matrix,
C         scale is an optional input parameter to provide exponential scaling.
C
C         w is the result.  If nu and z are the same size, or one of
C         them is a scalar, then w has the same size.  If one of nu and z
C         is a row vector and the other is a column vector, then 
C         size(w) = [length(z), length(nu)]
C         If diff(nu) == 1, the three-term recurrence is used to
C         evaluate an entire row of w at once.
C         w is always complex.  The calling M file should eliminate
C         any unwanted imaginary part.
C
C         ierr is an optional output array, the same size as w.
C            ierr = 1   Illegal arguments.
C            ierr = 2   Overflow.  Return Inf.
C            ierr = 3   Some loss of accuracy in argument reduction.
C            ierr = 4   Complete loss of accuracy, z or nu too large.
C            ierr = 5   No convergence.  Return NaN.
C
C     The Fortran Bessel library by D. E. Amos is used for nonnegative nu.
C     The extentions to negative nu are based on
C
C         J(-nu,z) = cos(nu*pi)*J(nu,z) - sin(nu*pi)*Y(nu,z)
C         Y(-nu,z) = cos(nu*pi)*Y(nu,z) + sin(nu*pi)*J(nu,z)
C         I(-nu,z) = I(nu,z) - (2/pi)*sin(nu*pi)*K(nu,z)
C         K(-nu,z) = K(nu,z)
C         H1(-nu,z) = exp(i*nu*pi)*H1(nu,z)
C         H2(-nu,z) = exp(-i*nu*pi)*H2(nu,z)
C
C     $Revision: 1.9.4.3 $
C
      subroutine mexfunction(nlhs, plhs, nrhs, prhs)





C-----------------------------------------------------------------------
C
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
C
C-----------------------------------------------------------------------
C
      integer pnu,pzr,pzi,pwr,pwi,perr
      integer pw,pw1,pw2,pwrk
      complex*16 z,w,inf,nan
      real*8 zr,zi,nu,pi,zero,d1mach
      real*8 nu0,nu1,a,b
      real*4 stmp
      integer fun,kode,unfl,ierr,kompz,mw,nw,ldbl
      integer i,j,m,n,nnu
      integer incnu,incz,incw
      integer isnusngl,iszsngl,iswsngl,classw
C
      integer mxcreatedoublematrix,mxcreatenumericmatrix
      integer mxgetdata,mxgetimagdata,mxcalloc,mxgetpr
      integer mxissingle,mxisdouble,mxiscomplex,mxissparse
      integer mxgetnumberofelements,mxgetclassid
      real*8 mxgetscalar
      complex*16 bessget


C
C-----------------------------------------------------------------------
C



c
      data pi /3.1415926535897932385d0/, zero /0.0D0/
C 
C     LDBL is the pointer increment for doubles

      data ldbl /8/
C
C     Infinity and NaN
C

      INF = DCMPLX(PI/ZERO,ZERO)
      NAN = DCMPLX(ZERO/ZERO,ZERO/ZERO)

C
C     Input arguments
C
      IF (NRHS .LT. 3) CALL MEXERRMSGTXT('Not enough input arguments.')
      IF (NRHS .GT. 4) CALL MEXERRMSGTXT('Too many input arguments.')
      IF (NLHS .GT. 2) CALL MEXERRMSGTXT('Too many output arguments.')
      isnusngl = mxissingle(prhs(2))
      if (isnusngl.ne.1 .and. mxisdouble(prhs(2)).ne. 1)
     +   call mexerrmsgtxt('Argument must be single or double.')
      IF (MXISCOMPLEX(PRHS(2)) .EQ. 1)
     +   CALL MEXERRMSGTXT('NU must be real.')
      iszsngl = mxissingle(prhs(3))
      if (iszsngl.ne.1 .and. mxisdouble(prhs(3)).ne. 1)
     +   call mexerrmsgtxt('Argument must be single or double.')
      FUN = MXGETSCALAR(PRHS(1))
      n = mxgetnumberofelements(prhs(2))
      m = mxgetnumberofelements(prhs(3))
      KOMPZ  = MXISCOMPLEX(PRHS(3))
      IF (NRHS .LT. 4) KODE = 1
      IF (NRHS .EQ. 4) KODE = MXGETSCALAR(PRHS(4)) + 1
c
      incnu = 8
      if (isnusngl.eq.1) incnu = 4
      incz = 8
      if (iszsngl.eq.1) incz = 4
      iswsngl = 0
      if (isnusngl.eq.1 .or. iszsngl.eq.1) iswsngl = 1
      incw = 8
      if (iswsngl.eq.1) incw = 4
      classw = mxgetclassid(prhs(3))
      if (isnusngl.eq.1) classw = mxgetclassid(prhs(2))
C
C     Empty
C
      IF (N .EQ. 0 .OR. M .EQ. 0) THEN
         PLHS(1) = MXCREATEDOUBLEMATRIX(N,M,0)
         IF (NLHS .GT. 1) PLHS(2) = MXCREATEDOUBLEMATRIX(N,M,0)
         RETURN
      ENDIF
C     
C     Test for special NU cases and allocate output
C
      NNU = 1
      IF (N .GT. 1) THEN
         IF (MXGETM(PRHS(2)).EQ.1 .AND. MXGETN(PRHS(3)).EQ.1) NNU = N
         IF (MXGETN(PRHS(2)).EQ.1 .AND. MXGETM(PRHS(3)).EQ.1) NNU = N
      ENDIF
      IF (NNU .EQ. 1) THEN
         MW = MXGETM(PRHS(3))
         NW = MXGETN(PRHS(3))
         plhs(1) = mxcreatenumericmatrix(mw,nw,classw,1)
         IF (NLHS .GT. 1) PLHS(2) = mxcreatedoublematrix(MW,NW,0)
      ELSE
         PNU = MXGETPR(PRHS(2))
         if (isnusngl .eq. 1) then
            call mxcopyptrtoreal4(pnu,stmp,1)
            nu0 = stmp
         else
            CALL MXCOPYPTRTOREAL8(PNU,NU0,1)
         endif
         DO I = 2,N
            PNU = PNU + incnu
            if (isnusngl .eq. 1) then
               call mxcopyptrtoreal4(pnu,stmp,1)
               nu1 = stmp
            else
               CALL MXCOPYPTRTOREAL8(PNU,NU1,1)
            endif
            IF (NU1-NU0 .NE. 1.0D0) CALL MEXERRMSGTXT
     +         ('NU must be the same size as Z or a scalar.')
            NU0 = NU1
         ENDDO
         plhs(1) = mxcreatenumericmatrix(m,n,classw,1)
         IF (NLHS .GT. 1) PLHS(2) = mxcreatedoublematrix(M,N,0)
      ENDIF
C
C     Pointers to input and output arrays
C
      PNU = MXGETDATA(PRHS(2))
      PZR = MXGETDATA(PRHS(3))
      PZI = MXGETIMAGDATA(PRHS(3))
      PWR = MXGETDATA(PLHS(1))
      PWI = MXGETIMAGDATA(PLHS(1))
      IF (NLHS .GT. 1) PERR = MXGETDATA(PLHS(2))
C
C     Allocate memory for temporary work vectors
C
      PW  = MXCALLOC(NNU,2*LDBL)
      PW1 = MXCALLOC(NNU,2*LDBL)
      PW2 = MXCALLOC(NNU,2*LDBL)
      PWRK = MXCALLOC(NNU,2*LDBL)
C
C     Loop over elements
C
      DO 200 I = 1, M
        IERR = 0
C
C       Pick up one element of nu
C
        if (isnusngl .eq. 1) then
           call mxcopyptrtoreal4(pnu,stmp,1)
           nu = stmp
        else
           CALL MXCOPYPTRTOREAL8(PNU,NU,1)
        endif
C
C       Pick up one element of z
C
        if (iszsngl .eq. 1) then
           call mxcopyptrtoreal4(pzr,stmp,1)
           zr = stmp
        else
           CALL MXCOPYPTRTOREAL8(PZR,ZR,1)
        endif
        ZI = 0.0D0
        IF (KOMPZ .EQ. 1) then
           if (iszsngl .eq. 1) then
              call mxcopyptrtoreal4(pzi,stmp,1)
              zi = stmp
           else
              CALL MXCOPYPTRTOREAL8(PZI,ZI,1)
           endif
        endif
        Z = DCMPLX(ZR,ZI)
c
c       Check d1mach
c
c       Penny: why is this commented out in Cleve's version?
c
c        if (fun .eq. 68) then
c            z = dcmplx(d1mach(i),0.0d0)
c            call bessset(%val(pw),1,z)
c        endif
C
C       Ai(z), Ai'(z), Bi(z) and Bi'(z)
C
        IF (FUN .EQ. 65) THEN
            CALL CAIRY(Z,IDINT(NU),KODE,%VAL(PW),UNFL,IERR)
        ENDIF
        IF (FUN .EQ. 66) THEN
            CALL CBIRY(Z,IDINT(NU),KODE,%VAL(PW),IERR)
        ENDIF
C
C       J_nu(z)
C
        IF (FUN .EQ. 74) THEN
           IF (NU .GE. 0.0D0) THEN
              CALL CBESJ(Z,NU,KODE,NNU,%VAL(PW),UNFL,IERR)
           ELSE IF (NU .EQ. DINT(NU)) THEN
              CALL CBESJ(Z,-NU,KODE,NNU,%VAL(PW),UNFL,IERR)
              IF (MOD(IDINT(NU),2) .NE. 0) THEN
                 DO 100 J = 1,NNU
C                   Set W(I) = -W(I)
                    CALL BESSSET(%VAL(PW),J,-BESSGET(%VAL(PW),J))
 100             CONTINUE
              ENDIF
           ELSE IF (ZR .EQ. 0.0D0 .AND. ZI .EQ. 0.0D0) THEN
              DO 101 J = 1,NNU
C                Set W(J) = -INF
                 CALL BESSSET(%VAL(PW),J,-INF)
 101          CONTINUE
           ELSE
              CALL CBESJ(Z,-NU,KODE,NNU,%VAL(PW1),UNFL,IERR)
              CALL CBESY(Z,-NU,KODE,NNU,%VAL(PW2),UNFL,%VAL(PWRK),IERR)
              A = DCOS(-NU*PI)
              B = DSIN(-NU*PI)
              DO 102 J = 1,NNU
C                Set W = DCOS(NU*PI)*W1 - DSIN(NU*PI)*W2
                 CALL BESSSET(%VAL(PW),J,
     +                A*BESSGET(%VAL(PW1),J) - B*BESSGET(%VAL(PW2),J))
 102          CONTINUE
           ENDIF
        ENDIF
C
C       Y_nu(z)
C       Y(nu,0) = -Infinity
C
        IF (FUN .EQ. 89) THEN
           IF (ZR .EQ. 0.0D0 .AND. ZI .EQ. 0.0D0) THEN
              DO 103 J = 1,NNU
C                Set W(J) = -INF
                 CALL BESSSET(%VAL(PW),J,-INF)
 103          CONTINUE
           ELSE IF (NU .GE. 0.0D0) THEN
              CALL CBESY(Z,NU,KODE,NNU,%VAL(PW),UNFL,%VAL(PWRK),IERR)
           ELSE IF (NU .EQ. DINT(NU)) THEN
              CALL CBESY(Z,-NU,KODE,NNU,%VAL(PW),UNFL,%VAL(PWRK),IERR)
              IF (MOD(IDINT(NU),2) .NE. 0) THEN
                 DO 104 J = 1,NNU
C                   Set W(J) = -W(J)
                    CALL BESSSET(%VAL(PW),J,-BESSGET(%VAL(PW),J))
 104             CONTINUE
              ENDIF
           ELSE
              CALL CBESJ(Z,-NU,KODE,NNU,%VAL(PW1),UNFL,IERR)
              CALL CBESY(Z,-NU,KODE,NNU,%VAL(PW2),UNFL,%VAL(PWRK),IERR)
              A = DCOS(-NU*PI)
              B = DSIN(-NU*PI)
              DO 105 J = 1,NNU
C                Set W = DCOS(NU*PI)*W2 + DSIN(NU*PI)*W1
                 CALL BESSSET(%VAL(PW),J,
     +                A*BESSGET(%VAL(PW2),J) + B*BESSGET(%VAL(PW1),J))
 105          CONTINUE
           ENDIF
        ENDIF
C
C       I_nu(z)
C
        IF (FUN .EQ. 73) THEN
           IF (NU .GE. 0.0D0) THEN
              CALL CBESI(Z,NU,KODE,NNU,%VAL(PW),UNFL,IERR)
           ELSE IF (NU .EQ. DINT(NU)) THEN
              CALL CBESI(Z,-NU,KODE,NNU,%VAL(PW),UNFL,IERR)
           ELSE IF (ZR .EQ. 0.0D0 .AND. ZI .EQ. 0.0D0) THEN
              DO 106 J = 1,NNU
C                Set W(J) = -INF
                 CALL BESSSET(%VAL(PW),J,-INF)
 106          CONTINUE
           ELSE
              CALL CBESI(Z,-NU,KODE,NNU,%VAL(PW1),UNFL,IERR)
              CALL CBESK(Z,-NU,   1,NNU,%VAL(PW2),UNFL,IERR)
              A = (2/PI)*DSIN(NU*PI)
              DO 107 J = 1,NNU
C                Set W(J) = W1(J) - (2/PI)*DSIN(NU*PI)*W2(J)
                 IF (KODE .EQ. 1) 
     +              CALL BESSSET(%VAL(PW),J,
     +                   BESSGET(%VAL(PW1),J) - A*BESSGET(%VAL(PW2),J))
                 IF (KODE .EQ. 2) 
     +              CALL BESSSET(%VAL(PW),J, BESSGET(%VAL(PW1),J)
     +                   - A*DEXP(-DABS(ZR))*BESSGET(%VAL(PW2),J))
 107          CONTINUE
           ENDIF
        ENDIF
C
C       K_nu(z)
C       K(nu,0) = Infinity
C
        IF (FUN .EQ. 75) THEN
           IF (ZR .EQ. 0.0D0 .AND. ZI .EQ. 0.0D0) THEN
              DO 108 J = 1,NNU
C                Set W(J) = INF
                 CALL BESSSET(%VAL(PW),J,INF)
 108          CONTINUE
           ELSE
              CALL CBESK(Z,DABS(NU),KODE,NNU,%VAL(PW),UNFL,IERR)
           ENDIF
        ENDIF
C
C       H1_nu(z) and H2_nu(z)
C       Hk(nu,0) = Complex 0/0
C
        IF (FUN .EQ. 72 .OR. FUN .EQ. 72*2) THEN
           K = FUN/72
           IF (ZR .EQ. 0.0D0 .AND. ZI .EQ. 0.0D0) THEN
              DO 109 J = 1,NNU
C                Set W(J) = Z/Z  (NaN + NaNi)
                 CALL BESSSET(%VAL(PW),J,NAN)
 109          CONTINUE
           ELSE IF (NU .GE. 0.0D0) THEN
              CALL CBESH(Z,NU,KODE,K,NNU,%VAL(PW),UNFL,IERR)
           ELSE IF (NU .EQ. DINT(NU)) THEN
              CALL CBESH(Z,-NU,KODE,K,NNU,%VAL(PW),UNFL,IERR)
              IF (MOD(IDINT(NU),2) .NE. 0) THEN
                 DO 111 J = 1,NNU
C                    Set W(J) = -W(J)
                    CALL BESSSET(%VAL(PW),J,-BESSGET(%VAL(PW),J))
 111             CONTINUE
              ENDIF
           ELSE
              CALL CBESH(Z,-NU,KODE,K,NNU,%VAL(PW),UNFL,IERR)
              IF (K .EQ. 1) THEN
                 A = DCOS(NU*PI)
                 B = DSIN(NU*PI)
                 DO 112 J = 1,NNU
C                   Set W(J) = DCMPLX(DCOS(NU*PI),-DSIN(NU*PI))*W(J)
                    CALL BESSSET(
     +                   %VAL(PW),J,DCMPLX(A,-B)*BESSGET(%VAL(PW),J))
 112             CONTINUE
              ENDIF
              IF (K .EQ. 2) THEN
                 A = DCOS(NU*PI)
                 B = DSIN(NU*PI)
                 DO 113 J = 1,NNU
C                   Set W(J)  = DCMPLX(DCOS(NU*PI),DSIN(NU*PI))*W(J)
                    CALL BESSSET(
     +                   %VAL(PW),J,DCMPLX(A,B)*BESSGET(%VAL(PW),J))
 113             CONTINUE
              ENDIF
           ENDIF
        ENDIF
C
C       Copy result(s) to output array(s)
C
        DO 114 J = 1,NNU
           W = BESSGET(%VAL(PW),J)
C
C          Illegal arguments or no convergence, return NaN.
C          Overflow, return Inf.
C          Other values of IERR, leave alone.
           IF (IERR .EQ. 1 .OR. IERR .EQ. 5) W = NAN
           IF (IERR .EQ. 2) W = INF
C
C          NaN in, NaN out
C
           IF (ZR .EQ. ZR .AND. ZI .EQ. ZI) THEN
              W = W
           ELSE
              W = NAN
              IERR = 5
              IF (ZI .EQ. 0.0D0 .AND. FUN .NE. 72
     +           .AND. FUN .NE. 72*2) W = DCMPLX(DREAL(W),0.0D0)
           ENDIF
C
C          Force real result when appropriate.
C
           IF (ZR .GT. 0.0D0 .AND. ZI .EQ. 0.0D0
     +        .AND. FUN .NE. 72 .AND. FUN .NE. 72*2)
     +        W = DCMPLX(DREAL(W),0.0D0)
C
           if (iswsngl .eq. 1) then
              stmp = dreal(w)
              call mxcopyreal4toptr(stmp, pwr+(j-1)*incw*m, 1)
              stmp = dimag(w)
              call mxcopyreal4toptr(stmp, pwi+(j-1)*incw*m, 1)
           else
              CALL MXCOPYREAL8TOPTR(DREAL(W), PWR+(J-1)*incw*M, 1)
              CALL MXCOPYREAL8TOPTR(DIMAG(W), PWI+(J-1)*incw*M, 1)
           endif
           IF (NLHS .GT. 1) CALL MXCOPYREAL8TOPTR(
     +        DFLOAT(IERR), PERR+(J-1)*8*M, 1)
 114    CONTINUE
C
C       Increment pointers
C
        IF (NNU .EQ. 1 .AND. N .GT. 1) PNU = PNU + incnu
        PZR = PZR + incz
        PZI = PZI + incz
        PWR = PWR + incw
        PWI = PWI + incw
        IF (NLHS .GT. 1) PERR = PERR + 8
  200 CONTINUE
C
C     Free the memory
C
      CALL MXFREE(PW)
      CALL MXFREE(PW1)
      CALL MXFREE(PW2)
      CALL MXFREE(PWRK)
C
      RETURN
      END
