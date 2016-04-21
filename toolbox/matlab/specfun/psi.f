








C     Fortran MEX gateway function for the Psi function.
C
C     Computes, for real x:
C         Psi function, aka digamma function, psi(x).
C         Higher order derivatives, psi_sup_k(x).
C     MATLAB usage:
C         y = psi(x) computes y = psi(x) = digamma(x)
C         y = psi(k0:k1,x) computes y(k,j) = psi_sup_(k-1+k0)(x(j))
C
C     $Revision: 1.4.4.3 $ $Date: 2004/03/17 20:05:36 $
C
      subroutine mexfunction(nlhs, plhs, nrhs, prhs)
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
c
      integer mxcreatenumericarray, mxgetdata, mxgetdimensions
      integer mxcalloc
      integer mxissingle, mxisdouble, mxiscomplex, mxissparse
      integer mxgetclassid, mxgetm, mxgetn
      integer mxgetnumberofdimensions, mxgetnumberofelements
c
c-----------------------------------------------------------------------
c
      integer i,j,numelk,numelx,intval,ndimsx,ndimsy
      integer issngl,isdble,classid
      integer pk,px,py,pdimsx,pdimsy,ptmp
      real*4 sx
      real*8 x,y
c
      integer referintval
      real*4 getsnglval
      real*8 getdbleval
c
      if (nrhs .lt. 1) call mexerrmsgtxt('Not enough input arguments.')
      if (nrhs .gt. 2) call mexerrmsgtxt('Too many input arguments.')
      if (nlhs .gt. 1) call mexerrmsgtxt('Too many output arguments.')
C
      do i = 1,nrhs
          issngl = mxissingle(prhs(i))
          isdble = mxisdouble(prhs(i))
          if (issngl .ne. 1 .and. isdble .ne. 1)
     +          call mexerrmsgtxt('Input must be single or double.')
          if (mxiscomplex(prhs(i)) .ne. 0)
     +          call mexerrmsgtxt('Input must be real.')
          if (mxissparse(prhs(i)) .eq. 1)
     +          call mexerrmsgtxt('Input must be full.')
      enddo
C
      classid = mxgetclassid(prhs(nrhs))
      ndimsx = mxgetnumberofdimensions(prhs(nrhs))
      pdimsx = mxgetdimensions(prhs(nrhs))
C
      if (nrhs .eq. 1) then
C     
C        psi(x)
C        Allow single or double, multidimensional x.  Result is same shape.
C
C        Allocate output
C
         plhs(1) = mxcreatenumericarray(ndimsx,%val(pdimsx),classid,0)
C
C        Pointers to input and output arrays
C
         px = mxgetdata(prhs(1))
         py = mxgetdata(plhs(1))
c
c        Loop over elements
c
         numelx = mxgetnumberofelements(prhs(1))
         if (isdble .eq. 1) then
            do i = 1, numelx
c
c              Evaluate function
c
               call mxcopyptrtoreal8(px,x,1)
               call dpsifn(x, 0, 1, 1, y)
c
c              Undo the scaling done by dspifn
c
               call mxcopyreal8toptr(-y,py,1)
c
c              Increment pointers
c
               px = px + 8
               py = py + 8
            enddo
         else
            do i = 1, numelx
               call mxcopyptrtoreal4(px,sx,1)
               call dpsifn(dble(sx), 0, 1, 1, y)
c
c              Cast back to single and undo the scaling done by dspifn
c
               call mxcopyreal4toptr(sngl(-y),py,1)
               px = px + 4
               py = py + 4
            enddo
         endif
c
      else
c
c        psi(k0:k1,x)
c        k0:k1 is a consecutive range of integer values.
c        k0:k1 may be either single or double in data type.
c        Allow single or double x, multidimensionsal x.
c        If k is a scalar: output is of size(x).
c        If k is not a scalar:
c        Output is of numel(k)-by-length(x) is x is a vector.
c        Output is of numel(k)-by-size(x) if x is not a vector.
c
         if (mxgetnumberofdimensions(prhs(1)) .ne. 2)
     +      call mexerrmsgtxt('Order must be a scalar or a vector.')
         if (mxgetm(prhs(1)) .ne. 1 .and. mxgetn(prhs(1)) .ne. 1)
     +      call mexerrmsgtxt('Order must be a scalar or a vector.')
         numelk = mxgetnumberofelements(prhs(1))
         if (numelk .gt. 0) then
            pk = mxgetdata(prhs(1))
            if (mxisdouble(prhs(1)) .eq. 1) then
               k0 = getdbleval(%val(pk),1)
               k1 = getdbleval(%val(pk),numelk)
            else
               k0 = getsnglval(%val(pk),1)
               k1 = getsnglval(%val(pk),numelk)
            endif
            if (k0 .lt. 0)
     +         call mexerrmsgtxt('Order must be nonnegative.')
            if (k1 .ne. k0+numelk-1)
     +         call mexerrmsgtxt('Order must be consecutive integers.')
         endif
c
         numelx = mxgetnumberofelements(prhs(2))
         if (numelk .eq. 1) then
            ndimsy = ndimsx
            pdimsy = pdimsx
         else
            intval = referintval(%val(pdimsx),1)
            if (ndimsx .eq. 2 .and. intval .eq. 1) then
               ndimsy = ndimsx
               pdimsy = mxcalloc(ndimsy,4)
               call assignintval(%val(pdimsy),1,numelk)
               intval = referintval(%val(pdimsx),2)
               call assignintval(%val(pdimsy),2,intval)
            else
               ndimsy = ndimsx+1
               pdimsy = mxcalloc(ndimsy,4)
               call assignintval(%val(pdimsy),1,numelk)
               do i = 1,ndimsx
                  intval = referintval(%val(pdimsx),i)
                  call assignintval(%val(pdimsy),i+1,intval)
               enddo
            endif
         endif
         plhs(1) = mxcreatenumericarray(ndimsy,%val(pdimsy),classid,0)
c
         if (numelk .gt. 0 .and. numelx .gt. 0) then
            py = mxgetdata(plhs(1))
            px = mxgetdata(prhs(2))
            if (isdble .eq. 1) then
               do j = 1, numelx
                  call dpsifn(%val(px),k0,1,numelk,%val(py))
                  px = px + 8
                  py = py + 8*numelk
               enddo
               py = mxgetdata(plhs(1))
               call unscale(k0,numelk,numelx,%val(py))
            else
               ptmp = mxcalloc(numelk,8)
               do j = 1, numelx
                  call mxcopyptrtoreal4(px,sx,1)
                  call dpsifn(dble(sx),k0,1,numelk,%val(ptmp))
                  call unscale(k0,numelk,1,%val(ptmp))
                  call dble2sngl(%val(ptmp),%val(py),numelk)
                  px = px + 4
                  py = py + 4*numelk
               enddo
               call mxfree(ptmp)
            endif
         endif
c
      endif
      return
      end
c
      subroutine printintval(x,n)
      integer n
      integer x(n)
      do i = 1, n
         write(*,*) 'x(',i,') = ',x(i)
      enddo
      end
c
      integer function referintval(x,k)
      integer k
      integer x(k)
      referintval = x(k)
      return
      end
c
      subroutine assignintval(x,k,val)
      integer val
      integer k
      integer x(k)
      x(k) = val
      end
c
      real*8 function getdbleval(x,k)
      integer k
      real*8 x(k)
      getdbleval = x(k)
      if (dint(x(k)) .ne. x(k))
     +      call mexerrmsgtxt('Order must be integer valued.')
      return
      end
c
      real*4 function getsnglval(x,k)
      integer k
      real*4 x(k)
      getsnglval = x(k)
      if (dint(dble(getsnglval)) .ne. dble(getsnglval))
     +      call mexerrmsgtxt('Order must be integer valued.')
      return
      end
c
      subroutine dble2sngl(t,y,m)
      integer i,m
      real*8 t(m)
      real*4 y(m)
      do i = 1, m
         y(i) = t(i)
      enddo
      end
C
      SUBROUTINE UNSCALE(K0,M,N,Y)
C     UNDO THE SCALING INTRODUCED BY DPSIFN
      INTEGER I,J,K,K0,M,N
      REAL*8 S,Y(M,N)
      S = -1.0D0
      DO K = 1, K0
         S = -K*S
      ENDDO
      K = K0
      DO I = 1, M
         DO J = 1, N
            Y(I,J) = S*Y(I,J)
         ENDDO
         K = K+1
         S = -K*S
      ENDDO
      RETURN
      END

      SUBROUTINE DPSIFN(X, N, KODE, M, ANS)
C
C     WRITTEN BY D.E. AMOS, JUNE, 1982.
C     Obtained from NETLIB: http://www.netlib.org/toms/610.
C     Modified for use with MATLAB, C. Moler, August, 2001.
C
C     REFERENCES
C         HANDBOOK OF MATHEMATICAL FUNCTIONS, AMS 55, NATIONAL BUREAU
C         OF STANDARDS BY M. ABRAMOWITZ AND I.A. STEGUN, 1964, PP.
C         258-260, EQTNS. 6.3.5, 6.3.18, 6.4.6, 6.4.9, 6.4.10
C
C         ACM TRANS. MATH SOFTWARE, 1983.
C
C     ABSTRACT     *** A DOUBLE PRECISION ROUTINE ***
C         DPSIFN COMPUTES M MEMBER SEQUENCES OF SCALED DERIVATIVES OF
C         THE PSI FUNCTION
C
C              W(K,X)=(-1)**(K+1)*PSI(K,X)/GAMMA(K+1)
C
C         K=N,...,N+M-1 WHERE PSI(K,X) IS THE K-TH DERIVATIVE OF THE PSI
C         FUNCTION.  ON KODE=1, DPSIFN RETURNS THE SCALED DERIVATIVES
C         AS DESCRIBED.  KODE=2 IS OPERATIVE ONLY WHEN K=0 AND DPSIFN
C         RETURNS -PSI(X) + LN(X).  THAT IS, THE LOGARITHMIC BEHAVIOR
C         FOR LARGE X IS REMOVED WHEN KODE=2 AND K=0. WHEN SUMS OR
C         DIFFERENCES OF PSI FUNCTIONS ARE COMPUTED, THE LOGARITHMIC
C         TERMS CAN BE COMBINED ANALYTICALLY AND COMPUTED SEFARATELY
C         TO HELP RETAIN SIGNIFICANT DIGITS.
C
C         THE BASIC METHOD OF EVALUATION IS THE ASYMPTOTIC EXPANSION
C         FOR LARGE X.GE.XMIN FOLLOWED BY BACKWARD RECURSION ON A TWO
C         TERM RECURSION RELATION
C
C                  W(X+1) + X**(-N-1) = W(X).
C
C         THIS IS SUPPLEMENTED BY A SERIES
C
C                  SUM( (X+K)**(-N-1) , K=0,1,2,... )
C
C         WHICH CONVERGES RAPIDLY FOR LARGE N. BOTH XMIN AND THE
C         NUMBER OF TERMS OF THE SERIES ARE CALCULATED FROM THE UNIT
C         ROUND OFF OF THE MACHINE ENVIRONMENT.
C
C     DESCRIPTION OF ARGUMENTS
C
C         INPUT      X IS DOUBLE PRECISION
C           X      - ARGUMENT, X.GT.0.0D0
C           N      - FIRST MEMBER OF THE SEQUENCE, 0.LE.N.LE.100
C                    N=0 GIVES ANS(1) = -PSI(X)       ON KODE=1
C                                       -PSI(X)+LN(X) ON KODE=2
C           KODE   - SELECTION PARAMETER
C                    KODE=1 RETURNS SCALED DERIVATIVES OF THE PSI
C                    FUNCTION
C                    KODE=2 RETURNS SCALED DERIVATIVES OF THE PSI
C                    FUNCTION EXCEPT WHEN N=0. IN THIS CASE,
C                    ANS(1) = -PSI(X) + LN(X) IS RETURNED.
C           M      - NUMBER OF MEMBERS OF THE SEQUENCE, M.GE.1
C
C         OUTPUT     ANS IS DOUBLE PRECISION
C           ANS    - A VECTOR OF LENGTH AT LEAST M WHOSE FIRST M
C                    COMPONENTS CONTAIN THE SEQUENCE OF  DERIVATIVES
C                    SCALED ACCORDING TO KODE
C***END PROLOGUE
      INTEGER I, J, K, KODE, M, MX, N, NMAX, NN, NP, NX
      DOUBLE PRECISION ANS, ARG, B, DEN, EPS, FLN, FN, FNP, FNS,
     * FX, RLN, RXSQ, R1M4, R1M5, S, SLOPE, T, TA, TK, TOL, TOLS, TRM,
     * TRMR, TSS, TST, TT, T1, T2, WDTOL, X, XDMLN, XDMY, XINC, XLN,
     * XM, XMIN, XQ, YINT, XINF
      DIMENSION B(22), TRM(22), TRMR(100), ANS(1)







      DATA NMAX /100/

      DATA XINF/'7FF0000000000000'X/

C-----------------------------------------------------------------------
C             BERNOULLI NUMBERS
C-----------------------------------------------------------------------
      DATA B(1), B(2), B(3), B(4), B(5), B(6), B(7), B(8), B(9), B(10),
     * B(11), B(12), B(13), B(14), B(15), B(16), B(17), B(18), B(19),
     * B(20), B(21), B(22) /1.00000000000000000D+00,
     * -5.00000000000000000D-01,1.66666666666666667D-01,
     * -3.33333333333333333D-02,2.38095238095238095D-02,
     * -3.33333333333333333D-02,7.57575757575757576D-02,
     * -2.53113553113553114D-01,1.16666666666666667D+00,
     * -7.09215686274509804D+00,5.49711779448621554D+01,
     * -5.29124242424242424D+02,6.19212318840579710D+03,
     * -8.65802531135531136D+04,1.42551716666666667D+06,
     * -2.72982310678160920D+07,6.01580873900642368D+08,
     * -1.51163157670921569D+10,4.29614643061166667D+11,
     * -1.37116552050883328D+13,4.88332318973593167D+14,
     * -1.92965793419400681D+16/
C



C
      IF (X.LT.0.0D0) CALL MEXERRMSGTXT('X must be nonnegative.')
      IF (N.LT.0) CALL MEXERRMSGTXT('Internal error (N).')
      IF (KODE.NE.1) CALL MEXERRMSGTXT('Internal error (KODE).')
      IF (M.LT.1)  CALL MEXERRMSGTXT('Internal error (M).')
C
      IF (X .EQ. 0.0D0) THEN
         DO I = 1, M
            ANS(I) = XINF
         ENDDO
         RETURN
      ELSEIF (X .EQ. XINF) THEN
         DO I = 1, M
            ANS(I) = XINF
         ENDDO
         IF (N .EQ. 0) ANS(1) = -XINF
         RETURN
      ELSEIF (X .EQ. X) THEN
         X = X
      ELSE
C        NaN
         DO I = 1, M
            ANS(I) = X
         ENDDO
         RETURN
      ENDIF
C
      NN = N + M - 1
      FN = DBLE(FLOAT(NN))
      FNP = FN + 1.0D0
      R1M5 = DLOG10(2.0D0)
      R1M4 = 1.110223D-16
      WDTOL = DMAX1(R1M4,0.5D-18)
      XLN = DLOG(X)
      IF (X.LT.WDTOL) GO TO 260
C-----------------------------------------------------------------------
C     COMPUTE XMIN AND THE NUMBER OF TERMS OF THE SERIES, FLN+1
C-----------------------------------------------------------------------
      RLN = R1M5*DBLE(53)
      RLN = DMIN1(RLN,18.06D0)
      FLN = DMAX1(RLN,3.0D0) - 3.0D0
      YINT = 3.50D0 + 0.40D0*FLN
      SLOPE = 0.21D0 + FLN*(0.0006038D0*FLN+0.008677D0)
      XM = YINT + SLOPE*FN
      MX = INT(SNGL(XM)) + 1
      XMIN = DBLE(FLOAT(MX))
      IF (N.EQ.0) GO TO 50
      XM = -2.302D0*RLN - DMIN1(0.0D0,XLN)
      FNS = DBLE(FLOAT(N))
      ARG = XM/FNS
      ARG = DMIN1(0.0D0,ARG)
      EPS = DEXP(ARG)
      XM = 1.0D0 - EPS
      IF (DABS(ARG).LT.1.0D-3) XM = -ARG
      FLN = X*XM/EPS
      XM = XMIN - X
      IF (XM.GT.7.0D0 .AND. FLN.LT.15.0D0) GO TO 200
   50 CONTINUE
      XDMY = X
      XDMLN = XLN
      XINC = 0.0D0
      IF (X.GE.XMIN) GO TO 60
      NX = INT(SNGL(X))
      XINC = XMIN - DBLE(FLOAT(NX))
      XDMY = X + XINC
      XDMLN = DLOG(XDMY)
   60 CONTINUE
C-----------------------------------------------------------------------
C     GENERATE W(N+M-1,X) BY THE ASYMPTOTIC EXPANSION
C-----------------------------------------------------------------------
      T = FN*XDMLN
      T1 = XDMLN + XDMLN
      T2 = T + XDMLN
      TSS = DEXP(-T)
      TT = 0.5D0/XDMY
      T1 = TT
      TST = WDTOL*TT
      IF (NN.NE.0) T1 = TT + 1.0D0/FN
      RXSQ = 1.0D0/(XDMY*XDMY)
      TA = 0.5D0*RXSQ
      T = FNP*TA
      S = T*B(3)
      IF (DABS(S).LT.TST) GO TO 80
      TK = 2.0D0
      DO 70 K=4,22
        T = T*((TK+FN+1.0D0)/(TK+1.0D0))*((TK+FN)/(TK+2.0D0))*RXSQ
        TRM(K) = T*B(K)
        IF (DABS(TRM(K)).LT.TST) GO TO 80
        S = S + TRM(K)
        TK = TK + 2.0D0
   70 CONTINUE
   80 CONTINUE
      S = (S+T1)*TSS
      IF (XINC.EQ.0.0D0) GO TO 100
C-----------------------------------------------------------------------
C     BACKWARD RECUR FROM XDMY TO X
C-----------------------------------------------------------------------
      NX = INT(SNGL(XINC))
      NP = NN + 1
      IF (NX.GT.NMAX) CALL MEXERRMSGTXT('Internal error (NMAX)')
      IF (NN.EQ.0) GO TO 160
      XM = XINC - 1.0D0
      FX = X + XM
C-----------------------------------------------------------------------
C     THIS LOOP SHOULD NOT BE CHANGED. FX IS ACCURATE WHEN X IS SMALL
C-----------------------------------------------------------------------
      DO 90 I=1,NX
        TRMR(I) = FX**(-NP)
        S = S + TRMR(I)
        XM = XM - 1.0D0
        FX = X + XM
   90 CONTINUE
  100 CONTINUE
      ANS(M) = S
      IF (FN.EQ.0.0D0) GO TO 180
C-----------------------------------------------------------------------
C     GENERATE LOWER DERIVATIVES, J.LT.N+M-1
C-----------------------------------------------------------------------
      IF (M.EQ.1) RETURN
      DO 150 J=2,M
        FNP = FN
        FN = FN - 1.0D0
        TSS = TSS*XDMY
        T1 = TT
        IF (FN.NE.0.0D0) T1 = TT + 1.0D0/FN
        T = FNP*TA
        S = T*B(3)
        IF (DABS(S).LT.TST) GO TO 120
        TK = 3.0D0 + FNP
        DO 110 K=4,22
          TRM(K) = TRM(K)*FNP/TK
          IF (DABS(TRM(K)).LT.TST) GO TO 120
          S = S + TRM(K)
          TK = TK + 2.0D0
  110   CONTINUE
  120   CONTINUE
        S = (S+T1)*TSS
        IF (XINC.EQ.0.0D0) GO TO 140
        IF (FN.EQ.0.0D0) GO TO 160
        XM = XINC - 1.0D0
        FX = X + XM
        DO 130 I=1,NX
          TRMR(I) = TRMR(I)*FX
          S = S + TRMR(I)
          XM = XM - 1.0D0
          FX = X + XM
  130   CONTINUE
  140   CONTINUE
        MX = M - J + 1
        ANS(MX) = S
        IF (FN.EQ.0.0D0) GO TO 180
  150 CONTINUE
      RETURN
C-----------------------------------------------------------------------
C     RECURSION FOR N = 0
C-----------------------------------------------------------------------
  160 CONTINUE
      DO 170 I=1,NX
        S = S + 1.0D0/(X+DBLE(FLOAT(NX-I)))
  170 CONTINUE
  180 CONTINUE
      IF (KODE.EQ.2) GO TO 190
      ANS(1) = S - XDMLN
      RETURN
  190 CONTINUE
      IF (XDMY.EQ.X) RETURN
      XQ = XDMY/X
      ANS(1) = S - DLOG(XQ)
      RETURN
C-----------------------------------------------------------------------
C     COMPUTE BY SERIES (X+K)**(-(N+1)) , K=0,1,2,...
C-----------------------------------------------------------------------
  200 CONTINUE
      NN = INT(SNGL(FLN)) + 1
      NP = N + 1
      T1 = (FNS+1.0D0)*XLN
      T = DEXP(-T1)
      S = T
      DEN = X
      DO 210 I=1,NN
        DEN = DEN + 1.0D0
        TRM(I) = DEN**(-NP)
        S = S + TRM(I)
  210 CONTINUE
      ANS(1) = S
      IF (N.NE.0) GO TO 220
      IF (KODE.EQ.2) ANS(1) = S + XLN
  220 CONTINUE
      IF (M.EQ.1) RETURN
C-----------------------------------------------------------------------
C     GENERATE HIGHER DERIVATIVES, J.GT.N
C-----------------------------------------------------------------------
      TOL = WDTOL/5.0D0
      DO 250 J=2,M
        T = T/X
        S = T
        TOLS = T*TOL
        DEN = X
        DO 230 I=1,NN
          DEN = DEN + 1.0D0
          TRM(I) = TRM(I)/DEN
          S = S + TRM(I)
          IF (TRM(I).LT.TOLS) GO TO 240
  230   CONTINUE
  240   CONTINUE
        ANS(J) = S
  250 CONTINUE
      RETURN
C-----------------------------------------------------------------------
C     SMALL X.LT.UNIT ROUND OFF
C-----------------------------------------------------------------------
  260 CONTINUE
      ANS(1) = X**(-N-1)
      IF (M.EQ.1) GO TO 280
      K = 1
      DO 270 I=2,M
        ANS(K+1) = ANS(K)/X
        K = K + 1
  270 CONTINUE
  280 CONTINUE
      IF (N.NE.0) RETURN
      IF (KODE.EQ.2) ANS(1) = ANS(1) + XLN
      RETURN
      END
