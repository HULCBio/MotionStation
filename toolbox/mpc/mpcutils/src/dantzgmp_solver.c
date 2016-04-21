/* DANTZGMP QP optimizer - Source for generating Mex file

      Author: N.L. Ricker, A. Bemporad
      Copyright 1986-2003 The MathWorks, Inc. 
      $Revision: 1.1.10.2 $  $Date: 2003/09/01 09:15:44 $   
*/

#include "dantzgmp.h"

/* Subroutine */  
int dantzg(doublereal *a, int *ndim, int *n, 
	int *nuc, doublereal *bv, integer *ib, integer *il, integer *maxiter)
{
    /* System generated locals */
    integer a_dim1, a_offset, i__1;

    /* Local variables */
    integer ichk, iter;
    doublereal rmin, test;
    integer iout, i, ichki, ic, ir, nt, istand, irtest;
    extern /* Subroutine */ int trsimp_(doublereal *, int *, integer *, 
	    int *, doublereal *, integer *, integer *);
    integer iad;
    doublereal val, rat;
	int iret=-1;


/* 	******************************************* */

/*    VERSION MODIFIED 1/88 BY NL RICKER */
/* 	  Modified 12/98 by NL Ricker for use as MATLAB MEX file */
/* 	  Modified 03/01 by A Bemporad to introduce MAXITER */

/* 	******************************************* */

/*    DANTZIG QUADRATIC PROGRAMMING ALGORITHM. */

/*    N.L. RICKER    6/83 */

/*    ASSUMES THAT THE INPUT VARIABLES REPRESENT A FEASIBLE INITIAL */
/*    BASIS SET. */

/*    N       NUMBER OF CONSTRAINED VARIABLES (INCLUDING SLACK VARIABLES).*/

/*    NUC     NUMBER OF UNCONSTRAINED VARIABLES, IF ANY */

/*    BV      VECTOR OF VALUES OF THE BASIS VARIABLES.  THE LAST NUC */
/*            ELEMENTS WILL ALWAYS BE KEPT IN THE BASIS AND WILL NOT */
/*            BE CHECKED FOR FEASIBILITY. */

/*    IB      INDEX VECTOR, N ELEMENTS CORRESPONDING TO THE N VARIABLES. */
/*            IF IB(I) IS POSITIVE, THE ITH */
/*            VARIABLE IS BASIC AND BV(IB(I)) IS ITS CURRENT VALUE. */
/*            IF IB(I) IS NEGATIVE, THE ITH VARIABLE IS NON-BASIC */
/*            AND -IB(I) IS ITS COLUMN NUMBER IN THE TABLEAU. */

/*    IL      VECTOR DEFINED AS FOR IB BUT FOR THE N LAGRANGE MULTIPLIERS.*/

/*    A       THE TABLEAU -- SEE TRSIMP DESCRIPTION. */

/*    IRET    IF SUCCESSFUL, CONTAINS NUMBER OF ITERATIONS REQUIRED. */
/*            OTHER POSSIBLE VALUES ARE: */
/*            - I     NON-FEASIBLE BV(I) */
/*            -2N     NO WAY TO ADD A VARIABLE TO BASIS */
/*            -3N     NO WAY TO DELETE A VARIABLE FROM BASIS */
/*            NOTE:  THE LAST TWO SHOULD NOT OCCUR AND INDICATE BAD INPUT*/
/*            OR A BUG IN THE PROGRAM. */



/*       CHECK FEASIBILITY OF THE INITIAL BASIS. */

    /* Parameter adjustments */
    --il;
    --ib;
    --bv;
    a_dim1 = *ndim;
    a_offset = a_dim1 + 1;
    a -= a_offset;

    /* Function Body */
    iter = 1;
    nt = *n + *nuc;
    i__1 = *n;
    for (i = 1; i <= i__1; ++i) {
	if (ib[i] < 0 || bv[ib[i]] >= 0.f) {
	    goto L50;
	}
	iret = -i;
	goto L900;
L50:
	;
    }
    istand = 0;
L100:

/*       SEE IF WE ARE AT THE SOLUTION. */

    if (istand != 0) {
	goto L120;
    }
    val = 0.f;
    iret = iter;

    i__1 = *n;
    for (i = 1; i <= i__1; ++i) {
	if (il[i] < 0) {
	    goto L110;
	}

/*       PICK OUT LARGEST NEGATIVE LAGRANGE MULTIPLIER. */

	test = bv[il[i]];
	if (test >= val) {
	    goto L110;
	}
	val = test;
	iad = i;
	ichk = il[i];
	ichki = i + *n;
L110:
	;
    }

/*       IF ALL LAGRANGE MULTIPLIERS WERE NON-NEGATIVE, ALL DONE. */
/*       ELSE, SKIP TO MODIFICATION OF BASIS */

    if (val >= 0.f) {
		iret=iter;
	goto L900;
    }
    ic = -ib[iad];
    goto L130;

/*       PREVIOUS BASIS WAS NON-STANDARD.  MUST MOVE LAGRANGE */
/*       MULTIPLIER ISTAND INTO BASIS. */

L120:
    iad = istand;
    ic = -il[istand - *n];

/*       CHECK TO SEE WHAT VARIABLE SHOULD BE REMOVED FROM BASIS. */

L130:
    ir = 0;

/*       FIND SMALLEST POSITIVE RATIO OF ELIGIBLE BASIS VARIABLE TO */
/*       POTENTIAL PIVOT ELEMENT.  FIRST TYPE OF ELIGIBLE BASIS VARIABLE 
*/
/*       ARE THE REGULAR N VARIABLES AND SLACK VARIABLES IN THE BASIS. */

    i__1 = *n;
    for (i = 1; i <= i__1; ++i) {
	irtest = ib[i];

/*       NO GOOD IF THIS VARIABLE ISN'T IN BASIS OR RESULTING PIVOT WOULD */
/*       BE ZERO. */

	if (irtest < 0 || a[irtest + ic * a_dim1] == 0.f) {
	    goto L150;
	}
	rat = bv[irtest] / a[irtest + ic * a_dim1];

/*          THE FOLLOWING IF STATEMENT WAS MODIFIED 7/88 BY NL RICKER */
/*          TO CORRECT A BUG IN CASES WHERE RAT=0. */

	if (rat < 0.f || rat == 0.f && a[irtest + ic * a_dim1] < 0.f) {
	    goto L150;
	}
	if (ir == 0) {
	    goto L140;
	}
	if (rat > rmin) {
	    goto L150;
	}
L140:
	rmin = rat;
	ir = irtest;
	iout = i;
L150:
	;
    }

/*      SECOND POSSIBLITY IS THE LAGRANGE MULTIPLIER OF THE VARIABLE ADDED*/
/*       TO THE MOST RECENT STANDARD BASIS. */

    if (a[ichk + ic * a_dim1] == 0.f) {
	goto L170;
    }
    rat = bv[ichk] / a[ichk + ic * a_dim1];
    if (rat < 0.f) {
	goto L170;
    }
    if (ir == 0) {
	goto L160;
    }
    if (rat > rmin) {
	goto L170;
    }
L160:
    ir = ichk;
    iout = ichki;

L170:
    if (ir != 0) {
	goto L200;
    }
    iret = *n * -3;
    /* printf("** Fatal error in QP solver!\n"); */
    goto L900;

L200:

/*       SET INDICES AND POINTERS */

    if (iout > *n) {
	goto L220;
    }
    ib[iout] = -ic;
    goto L230;
L220:
    il[iout - *n] = -ic;
L230:
    if (iad > *n) {
	goto L240;
    }
    ib[iad] = ir;
    goto L250;
L240:
    il[iad - *n] = ir;
L250:

/*       TRANSFORM THE TABLEAU */

    trsimp_(&a[a_offset], ndim, &nt, n, &bv[1], &ir, &ic);
    ++iter;
    if (iter > *maxiter) {  /* No solution found within MAXITER iterations */
        iret = iter;
        goto L900;
    }

/*       WILL NEXT TABLEAU BE STANDARD? */

    istand = 0;
    i__1 = *n;
    for (i = 1; i <= i__1; ++i) {
/* L260: */
	if (ib[i] > 0 && il[i] > 0) {
	    goto L270;
	}
    }
    goto L280;
L270:
    istand = iout + *n;
L280:
    goto L100;

L900:
    return iret;
} /* dantzg_ */

/* Subroutine */ int trsimp_(doublereal *a, int *ndim, integer *m, 
	int *n, doublereal *bv, integer *ir, integer *ic)
{
    /* System generated locals */
    integer a_dim1, a_offset, i__1, i__2;

    /* Local variables */
    integer i, j;
    doublereal ap;


/*       TRANSFORM SIMPLEX TABLEAU.  SWITCH ONE BASIS VARIABLE FOR ONE */
/*       NON-BASIC VARIABLE. */

/*       N.L. RICKER 6/83 */

/*       A       SIMPLEX TABLEAU.  ACTUALLY DIMENSIONED FOR NDIM ROWS IN 
*/
/*               THE CALLING PROGRAM.  IN THIS PROCEDURE, ONLY THE A(M,N) 
*/
/*               SPACE IS USED. */

/*       NDIM    ACTUAL ROW DIMENSION OF A IN THE CALLING PROGRAM */

/*       M       NUMBER OF ROWS IN THE TABLEAU */

/*       N       NUMBER OF COLUMNS IN THE TABLEAU */

/*       BV      VECTOR OF M BASIS VARIABLE VALUES */

/*       IR      ROW IN TABLEAU CORRESPONDING TO THE BASIC VARIABLE THAT 
*/
/*               IS TO BECOME NON-BASIC */

/*       IC      COLUMN IN TABLEAU CORRESPONDING TO THE NON-BASIC VARIABLE
 */
/*               THAT IS TO BECOME BASIC. */



/*       FIRST CALCULATE NEW VALUES FOR THE NON-PIVOT ELEMENTS. */

    /* Parameter adjustments */
    --bv;
    a_dim1 = *ndim;
    a_offset = a_dim1 + 1;
    a -= a_offset;

    /* Function Body */
    i__1 = *m;
    for (i = 1; i <= i__1; ++i) {
	if (i == *ir) {
	    goto L110;
	}
	ap = a[i + *ic * a_dim1] / a[*ir + *ic * a_dim1];
	bv[i] -= bv[*ir] * ap;
	i__2 = *n;
	for (j = 1; j <= i__2; ++j) {
	    if (j == *ic) {
		goto L100;
	    }
	    a[i + j * a_dim1] -= a[*ir + j * a_dim1] * ap;
L100:
	    ;
	}
L110:
	;
    }

/*       NOW TRANSFORM THE PIVOT ROW AND PIVOT COLUMN. */

    ap = a[*ir + *ic * a_dim1];
    i__1 = *m;
    for (i = 1; i <= i__1; ++i) {
	a[i + *ic * a_dim1] = -a[i + *ic * a_dim1] / ap;
/* L120: */
    }

    bv[*ir] /= ap;
    i__1 = *n;
    for (j = 1; j <= i__1; ++j) {
	a[*ir + j * a_dim1] /= ap;
/* L130: */
    }
    a[*ir + *ic * a_dim1] = 1.f / ap;

    return 0;
} /* trsimp_ */
