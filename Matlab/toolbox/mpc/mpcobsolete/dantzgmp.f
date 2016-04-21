C DANTZGMP.F - Gateway function for DANTZG.F, QP function in Matlab 
c (in .MEX file format).
c
c	This version is for Matlab 4.x.  It is incompatible with Matlab 3.5.
c
c  	Copyright (c) 1994-1999 The MathWorks, Inc. All Rights Reserved.
c       $Revision: 1.1.6.1 $  $Date: 2003/12/04 01:35:31 $
C
C This subroutine is the main gateway to MATLAB.  When a MEX function
C  is executed MATLAB calls the mexFunction subroutine in the corresponding
C  MEX file.  
C
      SUBROUTINE mexFunction(NLHS, PLHS, NRHS, PRHS)
      INTEGER PLHS(*), PRHS(*)
      INTEGER NLHS, NRHS
C
      INTEGER mxCreateFull, mxGetPr
C
C THE ABOVE SUBROUTINE, ARGUMENT, AND FUNCTION DECLARATIONS ARE STANDARD
C IN FORTRAN MEX FILES.
C---------------------------------------------------------------------
C

c	Now we define the interface to DANTZG

c	The following are pointers to the Matlab input
c	and output variables:

      INTEGER tabi,basi,ibi,ili,baso,ibo,ilo,itero,tabo,tabtmp

c	The following are local storage

	PARAMETER (mmax=1000)
	INTEGER ib(mmax), il(mmax)
	DOUBLE PRECISION temp(mmax)
      INTEGER M, N, nuc, iret, rows, cols, len, i, rflag

	data nuc/0/, rflag/0/
	
C
C 		CHECK FOR PROPER NUMBER OF ARGUMENTS
C
      IF (NRHS .NE. 4) THEN
        CALL mexErrMsgTxt('DANTZGMP requires 4 input arguments')
      ELSE IF (NLHS .lt. 3) THEN
        CALL mexErrMsgTxt(
     +	'DANTZGMP requires at least 3 output arguments')
      END IF
	
c		Check the input variables and allocate storage for the outputs.


	M=mxGetM(PRHS(1))      			! get size of tabi.
	N=mxGetN(PRHS(1)) 
	if (m .gt. mmax) then
		call mexErrMsgTxt
     +		('QP problem too large for allocated memory.')
	end if
	tabi=mxGetPr(PRHS(1))			! points to tabi.
	tabtmp=mxCreateFull(M,N,0)		! allocates tabo
	tabo=mxGetPr(tabtmp)			! points to tabo
	call mxCopyReal8ToPtr(%val(tabi),tabo,M*N)	! copies tabi to tabo.  Note that the
							! %val() is needed here because tabi 
							! is just a pointer, not a real array.				
		
	rows=mxGetM(PRHS(2))      		! get size of basi.
	cols=mxGetN(PRHS(2)) 
	len=max(rows,cols)
	basi=mxGetPr(PRHS(2))			! points to basi.
	if (rows.ne.1 .and. cols.ne.1) then
		call mexErrMsgTxt('basi input must be a vector')
	else if (len.ne.m) then
		call mexErrMsgTxt('# elements in basi must = rows  in tabi')
	end if
	PLHS(1)=mxCreateFull(M,1,0)		! allocates baso
	baso=mxGetPr(PLHS(1))			! points to baso
	call mxCopyReal8ToPtr(%val(basi),baso,M)	! copies basi to baso.  Note that the
							! %val() is needed here because basi 
							! is just a pointer, not a real array.
		
	rows=mxGetM(PRHS(3))      		! get size of ibi.
	cols=mxGetN(PRHS(3)) 
	len=max(rows,cols)
	ibi=mxGetPr(PRHS(3))			! points to ibi.
	if (rows.ne.1 .and. cols.ne.1) then
		call mexErrMsgTxt('ibi input must be a vector')
	else if (len.ne.m) then
		call mexErrMsgTxt('# elements in ibi must = rows  in tabi')
	end if
	call mxCopyPtrToReal8(ibi,temp,len)	! moves ibi into temp storage.
	do i=1,m
		ib(i)=nint(temp(i))		! converts to integer
	end do
		
	rows=mxGetM(PRHS(4))      		! get size of ili.
	cols=mxGetN(PRHS(4)) 
	len=max(rows,cols)
	ili=mxGetPr(PRHS(4))			! points to ili.
	if (rows.ne.1 .and. cols.ne.1) then
		call mexErrMsgTxt('ili input must be a vector')
	else if (len.ne.m) then
		call mexErrMsgTxt('# elements in ili must = rows  in tabi')
	end if
	call mxCopyPtrToReal8(ili,temp,len)	! moves ili into temp storage.
	do i=1,m
		il(i)=nint(temp(i))		! converts to integer
	end do
	
c		All input variables have been set up.  Now call DANTZG to solve
c		the QP.  Note the use of %val() to force FORTRAN to pass the 
c		addresses of tabo and baso, which are the values of these pointers.

	call dantzg(%val(tabo),m,n,nuc,%val(baso),ib,il,iret)
	if (iret.lt.0) then
	   	call mexErrMsgTxt
     +	('Cannot solve QP.  Infeasible?  Check constraints.')
	end if

c		Move results into Matlab output variables.

	PLHS(2)=mxCreateFull(M,1,0)		! allocates ibo
	ibo=mxGetPr(PLHS(2))			! points to ibo
	do i=1,m
		temp(i)=dble(ib(i))		! converts to double precision
	end do
	call mxCopyReal8ToPtr(temp,ibo,M)	! copies results to ibo

	PLHS(3)=mxCreateFull(M,1,0)		! allocates ilo
	ilo=mxGetPr(PLHS(3))			! points to ilo
	do i=1,m
		temp(i)=dble(il(i))		! converts to double precision
	end do
	call mxCopyReal8ToPtr(temp,ilo,M)	! copies results to ilo

	if (nlhs.gt.3) then
		PLHS(4)=mxCreateFull(1,1,0)		! allocates itero
		itero=mxGetPr(PLHS(4))			! points to itero
		call mxCopyReal8ToPtr(dble(iret),itero,1)	! copies results to itero
	end if
	
	if (nlhs.gt.4) then
		PLHS(5)=tabtmp			! makes tabo a permanent output variable
	else
		CALL mxFreeMatrix(tabtmp)	! releases space allocated to tabo
	end if

      RETURN
      END
	
	
        SUBROUTINE DANTZG(A,NDIM,N,NUC,BV,IB,IL,IRET)
	  
	  implicit double precision (a-h,o-z)

C
C	*******************************************
C
C       VERSION MODIFIED 7/88 BY NL RICKER
C	  Modified 12/91 by NL Ricker for use as MATLAB MEX file
C
C	*******************************************
C
C       DANTZIG QUADRATIC PROGRAMMING ALGORITHM.
C
C       N.L. RICKER    6/83
C
C       ASSUMES THAT THE INPUT VARIABLES REPRESENT A FEASIBLE INITIAL
C       BASIS SET.
C
C       N       NUMBER OF CONSTRAINED VARIABLES (INCLUDING SLACK VARIABLES).
C
C       NUC     NUMBER OF UNCONSTRAINED VARIABLES, IF ANY
C
C       BV      VECTOR OF VALUES OF THE BASIS VARIABLES.  THE LAST NUC
C               ELEMENTS WILL ALWAYS BE KEPT IN THE BASIS AND WILL NOT
C               BE CHECKED FOR FEASIBILITY.
C
C       IB      INDEX VECTOR, N ELEMENTS CORRESPONDING TO THE N VARIABLES.
C               IF IB(I) IS POSITIVE, THE ITH
C               VARIABLE IS BASIC AND BV(IB(I)) IS ITS CURRENT VALUE.
C               IF IB(I) IS NEGATIVE, THE ITH VARIABLE IS NON-BASIC
C               AND -IB(I) IS ITS COLUMN NUMBER IN THE TABLEAU.
C
C       IL      VECTOR DEFINED AS FOR IB BUT FOR THE N LAGRANGE MULTIPLIERS.
C
C       A       THE TABLEAU -- SEE TRSIMP DESCRIPTION.
C
C       IRET    IF SUCCESSFUL, CONTAINS NUMBER OF ITERATIONS REQUIRED.
C               OTHER POSSIBLE VALUES ARE:
C               - I     NON-FEASIBLE BV(I)
C               -2N     NO WAY TO ADD A VARIABLE TO BASIS
C               -3N     NO WAY TO DELETE A VARIABLE FROM BASIS
C               NOTE:  THE LAST TWO SHOULD NOT OCCUR AND INDICATE BAD INPUT
C               OR A BUG IN THE PROGRAM.
C
C
        DIMENSION A(NDIM,NDIM),BV(NDIM)
	  INTEGER IB(NDIM),IL(NDIM)
C
C       CHECK FEASIBILITY OF THE INITIAL BASIS.
C
        ITER=0
        NT=N+NUC
        DO 50 I=1,N
        IF(IB(I).LT.0 .OR. BV(IB(I)).GE.0.0) GO TO 50
        IRET=-I
        GO TO 900
   50   CONTINUE

        ISTAND=0
  100   CONTINUE
C
C       SEE IF WE ARE AT THE SOLUTION.
C
        IF(ISTAND.NE.0) GO TO 120
        VAL=0.0
        IRET=ITER
C
        DO 110 I=1,N
        IF(IL(I).LT.0) GO TO 110
C
C       PICK OUT LARGEST NEGATIVE LAGRANGE MULTIPLIER.
C
        TEST=BV(IL(I))
        IF(TEST.GE.VAL) GO TO 110
        VAL=TEST
        IAD=I
        ICHK=IL(I)
        ICHKI=I+N
  110   CONTINUE
C
C       IF ALL LAGRANGE MULTIPLIERS WERE NON-NEGATIVE, ALL DONE.
C       ELSE, SKIP TO MODIFICATION OF BASIS
C
        IF(VAL.GE.0.0) GO TO 900
        IC=-IB(IAD)
        GO TO 130
C
C       PREVIOUS BASIS WAS NON-STANDARD.  MUST MOVE LAGRANGE
C       MULTIPLIER ISTAND INTO BASIS.
C
  120   CONTINUE
        IAD=ISTAND
        IC=-IL(ISTAND-N)
C
C       CHECK TO SEE WHAT VARIABLE SHOULD BE REMOVED FROM BASIS.
C
  130   CONTINUE
        IR=0
C
C       FIND SMALLEST POSITIVE RATIO OF ELIGIBLE BASIS VARIABLE TO
C       POTENTIAL PIVOT ELEMENT.  FIRST TYPE OF ELIGIBLE BASIS VARIABLE
C       ARE THE REGULAR N VARIABLES AND SLACK VARIABLES IN THE BASIS.
C
        DO 150 I=1,N
        IRTEST=IB(I)
C
C       NO GOOD IF THIS VARIABLE ISN'T IN BASIS OR RESULTING PIVOT WOULD
C       BE ZERO.
C
        IF(IRTEST.LT.0 .OR. A(IRTEST,IC).EQ.0.0) GO TO 150
        RAT=BV(IRTEST)/A(IRTEST,IC)
C
C          THE FOLLOWING IF STATEMENT WAS MODIFIED 7/88 BY NL RICKER
C          TO CORRECT A BUG IN CASES WHERE RAT=0.
C
        IF(RAT.LT.0.0 .OR. (RAT.EQ.0.0 .AND.
     1            A(IRTEST,IC).LT.0.0)) GO TO 150
        IF(IR.EQ.0) GO TO 140
        IF(RAT.GT.RMIN) GO TO 150
  140   CONTINUE
        RMIN=RAT
        IR=IRTEST
        IOUT=I
  150   CONTINUE
C
C       SECOND POSSIBLITY IS THE LAGRANGE MULTIPLIER OF THE VARIABLE ADDED
C       TO THE MOST RECENT STANDARD BASIS.
C
        IF(A(ICHK,IC) .EQ. 0.0) GO TO 170
        RAT=BV(ICHK)/A(ICHK,IC)
        IF(RAT.LT.0.0) GO TO 170
        IF(IR.EQ.0) GO TO 160
        IF(RAT.GT.RMIN) GO TO 170
  160   CONTINUE
        IR=ICHK
        IOUT=ICHKI
C
  170   CONTINUE
        IF(IR.NE.0) GO TO 200
        IRET=-3*N
        GO TO 900
C
  200   CONTINUE
C
C       SET INDICES AND POINTERS
C
        IF(IOUT.GT.N) GO TO 220
        IB(IOUT)=-IC
        GO TO 230
  220   CONTINUE
        IL(IOUT-N)=-IC
  230   CONTINUE
        IF(IAD.GT.N) GO TO 240
        IB(IAD)=IR
        GO TO 250
  240   CONTINUE
        IL(IAD-N)=IR
  250   CONTINUE
C
C       TRANSFORM THE TABLEAU
C
        CALL TRSIMP(A,NDIM,NT,N,BV,IR,IC)
        ITER=ITER+1
C
C       WILL NEXT TSBLEAU BE STANDARD?
C
        istand=0
        do 260 i=1,n
260     if(ib(i).gt.0.and.il(i).gt.0)go to 270
        go to 280
270     istand=iout+n
280     GO TO 100
C
  900   CONTINUE
        RETURN
        END
        SUBROUTINE TRSIMP(A,NDIM,M,N,BV,IR,IC)

	  implicit double precision (a-h,o-z)

C
C       TRANSFORM SIMPLEX TABLEAU.  SWITCH ONE BASIS VARIABLE FOR ONE
C       NON-BASIC VARIABLE.
C
C       N.L. RICKER 6/83
C
C       A       SIMPLEX TABLEAU.  ACTUALLY DIMENSIONED FOR NDIM ROWS IN
C               THE CALLING PROGRAM.  IN THIS PROCEDURE, ONLY THE A(M,N)
C               SPACE IS USED.
C
C       NDIM    ACTUAL ROW DIMENSION OF A IN THE CALLING PROGRAM
C
C       M       NUMBER OF ROWS IN THE TABLEAU
C
C       N       NUMBER OF COLUMNS IN THE TABLEAU
C
C       BV      VECTOR OF M BASIS VARIABLE VALUES
C
C       IR      ROW IN TABLEAU CORRESPONDING TO THE BASIS VARIABLE THAT
C               IS TO BECOME NON-BASIC
C
C       IC      COLUMN IN TABLEAU CORRESPONDING TO THE NON-BASIC VARIABLE
C               THAT IS TO BECOME BASIC.
C
C
        DIMENSION A(NDIM,N),BV(M)
C
C       FIRST CALCULATE NEW VALUES FOR THE NON-PIVOT ELEMENTS.
C
        DO 110 I=1,M
        IF(I.EQ.IR) GO TO 110
        AP=A(I,IC)/A(IR,IC)
        BV(I)=BV(I)-BV(IR)*AP
        DO 100 J=1,N
        IF(J.EQ.IC) GO TO 100
        A(I,J)=A(I,J)-A(IR,J)*AP
  100   CONTINUE
  110   CONTINUE
C
C       NOW TRANSFORM THE PIVOT ROW AND PIVOT COLUMN.
C
        AP=A(IR,IC)
        DO 120 I=1,M
        A(I,IC)=-A(I,IC)/AP
  120   CONTINUE
C
        BV(IR)=BV(IR)/AP
        DO 130 J=1,N
        A(IR,J)=A(IR,J)/AP
  130   CONTINUE
        A(IR,IC)=1.0/AP
C
        RETURN
        END
