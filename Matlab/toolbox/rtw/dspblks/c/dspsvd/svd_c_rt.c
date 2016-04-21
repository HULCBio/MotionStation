/* $Revision: 1.3.2.2 $ */
/* 
 * SVD_C_RT - Signal Processing Blockset Singular Value Decomposition helper functions
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 * Abstract:
 *   Runtime implementation file for the SVD block.
 *
 * 1) The code below is based on LINPACK.
 * 2) R12 MATLAB SVD is based on LAPACK.
 * 3) LAPACK and LINPACK SVD routines are substantially different.
 *    In particular, the LAPACK routine can handle economy size
 *    properly for any case, whereas LINPACK does not.
 * 4) In order to work around this limitation, the client (caller)
 *    may transpose the input matrix to insure that the input
 *	  has more rows than columns.  If the input is transposed,
 *	  then the U and V outputs are swapped.
 */

#include "dspsvd_rt.h"
#include "dspisfinite_rt.h"
#include "dspgivensrot_rt.h"

/*
 * Apply a plane rotation to a vector pair 
 */
static void rot_cplx32(
              int_T	n,	/* number of elements in vectors */
              real32_T	c,	/* c part of transform */
              real32_T	s, 	/* s part of transform */
              creal32_T	*x,	/* first vector */
              creal32_T	*y	/* second vector */
              )
{
    creal32_T t;
    
    if (n <= 0) {
        return;
    }
    
    while (n--) {
        t.re  = c * x->re + s * y->re;
        t.im  = c * x->im + s * y->im;
        y->re = c * y->re - s * x->re;
        y->im = c * y->im - s * x->im;
        x->re = t.re;
        x->im = t.im;
        x++;
        y++;
    }
}


/*
 * Singular value decomposition
 */
int_T MWDSP_SVD_C
(
                   creal32_T	*x,
                   int_T	n,
                   int_T	p,
                   creal32_T	*s,
                   creal32_T	*e,
                   creal32_T	*work,
                   creal32_T	*u,
                   creal32_T	*v,
                   int_T	wantv
                   )
{
    int_T nm1, np1;
    int_T iter, kase, j, k, kp1;
    int_T l, lp1, lm1, ls, lu;
    int_T m, mm, mm1, mm2;
    int_T info=0;
    int_T nct, ncu, nrt, nml;
    int_T ii;
    uint_T pll, plj, pil;
    creal32_T t, t2, r;
    real32_T sm, smm1, emm1, el, sl, b, c, cs, sn, scale, t1, f;
    real32_T test, ztest, snorm, g, shift;
    creal32_T *pxll, *pxlj, *pel, *pel1, *psl, *pull, *pvll;
    creal32_T *tp1, *tp2, temp, temp1;
    real32_T rt1, rt2;
    creal32_T One = {1.0F, 0.0F}, Zero = {0.0F, 0.0F};
    real32_T eps = EPS_real32_T;
    real32_T tiny = MIN_real32_T / EPS_real32_T;
    
    /*
    *  ----------------------------------------------------------
    *	reduce x to bidiagonal form, storing the diagonal elements
    *	in s and the super-diagonal elements in e.
    */
    
    ncu   = MIN(n,p);
    np1  = n + 1;
    nm1  = n - 1;
    nct  = MIN(nm1, p);
    nrt  = MAX(0,MIN(p-2,n));
    lu   = MAX(nct,nrt);
    for (l=0; l<lu; l++) {
        nml = n - l;
        lp1 = l + 1;
        pll = l * np1;		
        pxll = x + pll;		/* pointer to x(l,l) */ 
        psl = s + l;		/* pointer to s(l)   */
        pel = e + l;		/* pointer to e(l)   */
        pel1 = pel + 1;		/* pointer to e(l+1) */
        if (l < nct) { 
        /*
        * compute the transformation for the l-th column
        * and place the l-th diagonal in s(l).
            */
            /*  psl->re = nrm2(nml,pxll)  */
            psl->re = 0.0F;
            tp1 = pxll;
            for (ii=0; ii<nml; ii++) {
                CHYPOT32(psl->re,tp1->re,psl->re);
                CHYPOT32(psl->re,tp1->im,psl->re);
                tp1++;
            }
            /*  psl->re = nrm2(nml,pxll)  */
            psl->im = 0.0F;
            if (CQABS32(*psl) != 0.0F) {
                if (CQABS32(*pxll) != 0.0F) {
                    /*  *psl = sign(*psl,*pxll)  */
                    CHYPOT32(pxll->re, pxll->im, rt1);
                    if (rt1 == 0) {
                        CHYPOT32(psl->re, psl->im, psl->re);
                        psl->im = 0.0F;
                    } else {
                        CHYPOT32(psl->re, psl->im, rt2);
                        rt2 /= rt1;
                        psl->re = rt2 * pxll->re;
                        psl->im = rt2 * pxll->im;
                    }
                    /*  *psl = sign(*psl,*pxll)  */
                }
                /*  scal(nml,One / *psl,pxll)  */
                CDIV32(One, *psl, temp1);
                tp1 = pxll;
                for(ii=0; ii<nml; ii++) {
                    temp.re = CMULT_RE(temp1, *tp1);
                    temp.im = CMULT_IM(temp1, *tp1);
                    *tp1++ = temp;
                }
                /*  scal(nml,One / *psl,pxll)  */
                pxll->re += 1.0F;
            }
            psl->re = -psl->re;
            psl->im = -psl->im;
        } 
        for (j=lp1; j<p; j++) { 
            plj = j * n + l;	
            pxlj = x + plj;	/* x(l,j) */ 
            if (l < nct && CQABS32(*psl) != 0.0F) {
            /*
            *	Apply the transformation.
                */
                /*  t = -dot(nml,pxll,pxlj)  */
                tp1 = pxll;
                tp2 = pxlj;
                t = Zero;
                for(ii=0; ii<nml; ii++) {
                    t.re += tp1->re * tp2->re + tp1->im * tp2->im;
                    t.im += tp1->re * tp2->im - tp1->im  * tp2->re;
                    tp1++;
                    tp2++;
                }
                t.re = -t.re;
                t.im = -t.im;
                /*  t = -dot(nml,pxll,pxlj)  */
                CDIV32(t, *pxll, t);
                /*  axpy(nml,t,pxll,pxlj)  */
                tp1 = pxlj;
                tp2 = pxll;
                for(ii=0; ii<nml; ii++) {
                    temp.re = CMULT_RE(t,*tp2);
                    temp.im = CMULT_IM(t,*tp2);
                    tp1->re += temp.re;
                    tp1->im += temp.im;
                    tp1++;
                    tp2++;
                }
                /*  axpy(nml,t,pxll,pxlj)  */
            }
            /*
            * Place the l-th row of x into  e for the
            * subsequent calculation of the row transformation.
            */
            CCONJ(*pxlj,*(e+j));
        }
        if (wantv && l < nct) { 
        /*
        * Place the transformation in u for 
        * subsequent back multiplication.
            */
            tp1=u+pll;
            tp2=pxll;
            for (ii=0; ii<nml; ii++) {
                *tp1++ = *tp2++;
            }
        }
        if (l < nrt) {
        /*
        *	Compute the l-th row transformation and place 
        *	the l-th super-diagonal in e(l).
            */
            /*  psl->re = nrm2(p-lp1,pel1)  */
            pel->re = 0.0F;
            tp1 = pel1;
            for(ii=0; ii<p-lp1; ii++) {
                CHYPOT32(pel->re,tp1->re,pel->re);
                CHYPOT32(pel->re,tp1->im,pel->re);
                tp1++;
            }
            /*  psl->re = nrm2(p-lp1,pel1)  */
            pel->im = 0.0F;
            if (CQABS32(*pel) != 0.0F) {
                if (CQABS32(*pel1) != 0.0F) {
                    /*  *pel = sign(*pel,*pel1)  */
                    CHYPOT32(pel1->re, pel1->im, rt1);
                    if (rt1 == 0) {
                        CHYPOT32(pel->re, pel->im, pel->re);
                        pel->im = 0.0F;
                    } else {
                        CHYPOT32(pel->re, pel->im, rt2);
                        rt2 /= rt1;
                        pel->re = rt2 * pel1->re;
                        pel->im = rt2 * pel1->im;
                    }
                    /*  *pel = sign(*pel,*pel1)  */
                }
                /*  scal(p-lp1,One / *pel,pel1)  */
                CDIV32(One, *pel, temp1);
                tp1 = pel1;
                for(ii=0; ii<p-lp1; ii++) {
                    temp.re = CMULT_RE(temp1, *tp1);
                    temp.im = CMULT_IM(temp1, *tp1);
                    *tp1++ = temp;
                }
                /*  scal(p-lp1,One / *pel,pel1)  */
                (pel+1)->re += 1.0F;
            }
            pel->re = -pel->re;
            if (lp1 < n && CQABS32(*pel) != 0.0F) {
            /*
            *	Apply the transformation.
                */
                tp1 = work+lp1;
                for(ii=0; ii<n-lp1; ii++) {
                    *tp1++ = Zero;
                }
                for (j=lp1; j<p; j++) {
                    plj = j*n+lp1;		/* x(lp1,j) */
                    /*  axpy(n-lp1,*(e+j),x+plj,work+lp1)  */
                    tp1 = work+lp1;
                    tp2 = x+plj;
                    for(ii=0; ii<n-lp1; ii++) {
                        temp.re = CMULT_RE(*(e+j),*tp2);
                        temp.im = CMULT_IM(*(e+j),*tp2);
                        tp1->re += temp.re;
                        tp1->im += temp.im;
                        tp1++;
                        tp2++;
                    }
                    /*  axpy(n-lp1,*(e+j),x+plj,work+lp1)  */
                }
                for (j=lp1; j<p; j++) {
                    t2.re = -(e+j)->re;
                    t2.im = -(e+j)->im;
                    CDIV32(t2, *pel1,t);
                    t.im = -t.im;
                    plj = j*n+lp1;		/* x(lp1,j) */
                    /*  axpy(n-lp1,t,work+lp1,x+plj)  */
                    tp1 = x+plj;
                    tp2 = work+lp1;
                    for(ii=0; ii<n-lp1; ii++) {
                        temp.re = CMULT_RE(t,*tp2);
                        temp.im = CMULT_IM(t,*tp2);
                        tp1->re += temp.re;
                        tp1->im += temp.im;
                        tp1++;
                        tp2++;
                    }
                    /*  axpy(n-lp1,t,work+lp1,x+plj)  */
                }
            }
            if (wantv) {
            /*
            * Place the transformation in v for
            * subsequent back multiplication.
                */
                pll = lp1 + l * p;  /* pointer to v(lp1,l) */
                tp1 = pel1;
                tp2 = v+pll;
                for(ii=0; ii<p-lp1; ii++) {
                    *tp2++ = *tp1++;
                }
            }
        }
        }
        
        /*
        *-------------------------------------------------------------
        *	set up the final bidiagonal matrix or order m.
        */
        
        mm1 = m = MIN(p, np1);
        mm1--;
        if (nct < p) {
            pil = nct * np1;	/* pointer to x(nct,nct) */
            *(s+nct) = *(x+pil);
        }
        if (n < m) {
            *(s+mm1) = Zero;
        }
        if (nrt < mm1) {
            pil = nrt + n * mm1;	/* pointer to x(nrt,m) */
            *(e+nrt) = *(x+pil);
        }
        *(e+mm1) = Zero;
        
        /*
        *-------------------------------------------------------------
        *	if required, generate u.
        */
        if (wantv) {
            for (j=nct; j<ncu; j++) {
                tp1 = u+j*n;
                for(ii=0; ii<n; ii++) {
                    *tp1++ = Zero;
                }
                *(u+j*np1) = One;
            }
            for (l=nct-1; l>=0; l--) {
                nml = n - l;
                pll = l * np1;	
                pull = u + pll;	/* u(l,l) */
                if (CQABS32(*(s+l)) != 0.0F) {
                    lp1 = l + 1;
                    for (j=lp1; j<ncu; j++) {
                        plj = j*n+l;	/* u(l,j) */
                        /*  t = -dot(nml,pull,u+plj)  */
                        tp1 = pull;
                        tp2 = u+plj;
                        t = Zero;
                        for(ii=0; ii<nml; ii++) {
                            t.re += tp1->re * tp2->re + tp1->im * tp2->im;
                            t.im += tp1->re * tp2->im - tp1->im  * tp2->re;
                            tp1++;
                            tp2++;
                        }
                        t.re = -t.re;
                        t.im = -t.im;
                        /*  t = -dot(nml,pull,u+plj)  */
                        CDIV32(t, *pull, t);
                        /*  axpy(nml,t,pull,u+plj)  */
                        tp1 = u+plj;
                        tp2 = pull;
                        for(ii=0; ii<nml; ii++) {
                            temp.re = CMULT_RE(t,*tp2);
                            temp.im = CMULT_IM(t,*tp2);
                            tp1->re += temp.re;
                            tp1->im += temp.im;
                            tp1++;
                            tp2++;
                        }
                        /*  axpy(nml,t,pull,u+plj)  */
                    }
                    /*  scal(nml,MinusOne,pull)  */
                    tp1 = pull;
                    for(ii=0; ii<nml; ii++) {
                        tp1->re = -tp1->re;
                        tp1->im = -tp1->im;
                        tp1++;
                    }
                    /*  scal(nml,MinusOne,pull)  */
                    pull->re += 1.0F;
                    if (l >= 1) {
                        tp1 = pull-l;
                        for(ii=0; ii<l; ii++) {
                            *tp1++ = Zero;
                        }
                    }
                } else {
                    tp1 = pull-l;
                    for(ii=0; ii<n; ii++) {
                        *tp1++ = Zero;
                    }
                    *pull = One;
                }
            }
        }
        /*
        *-------------------------------------------------------------
        *	If it is required, generate v.
        */
        if (wantv) {
            for (l=p-1; l>=0; l--) {
                lp1 = l + 1;
                pll = l*p+lp1;	
                pvll = v + pll;	/* v(lp1,l) */
                if (l < nrt && CQABS32(*(e+l)) != 0.0F) {
                    for (j=lp1; j<p; j++) {
                        plj = j*p+lp1;	/* v(lp1,j) */
                        /*  t = -dot(p-lp1,pvll,v+plj)  */
                        tp1 = pvll;
                        tp2 = v+plj;
                        t = Zero;
                        for(ii=0; ii<p-lp1; ii++) {
                            t.re += tp1->re * tp2->re + tp1->im * tp2->im;
                            t.im += tp1->re * tp2->im - tp1->im  * tp2->re;
                            tp1++;
                            tp2++;
                        }
                        t.re = -t.re;
                        t.im = -t.im;
                        /*  t = -dot(p-lp1,pvll,v+plj)  */
                        CDIV32(t, *pvll, t);
                        /*  axpy(p-lp1,t,pvll,v+plj)  */
                        tp1 = v+plj;
                        tp2 = pvll;
                        for(ii=0; ii<p-lp1; ii++) {
                            temp.re = CMULT_RE(t,*tp2);
                            temp.im = CMULT_IM(t,*tp2);
                            tp1->re += temp.re;
                            tp1->im += temp.im;
                            tp1++;
                            tp2++;
                        }
                        /*  axpy(p-lp1,t,pvll,v+plj)  */
                    }
                }
                tp1 = pvll-lp1;
                for(ii=0; ii<p; ii++) {
                    *tp1++ = Zero;
                }
                *(pvll-1) = One;		/* v(l,l) */
            }
        }
        /*
        *-------------------------------------------------------------
        *	Transform s and e so that they are real.
        */
        for (l=0; l<m; l++) {
            lp1 = l + 1;
            psl = s + l;		/* pointer to s(l)   */
            pel = e + l;		/* pointer to e(l)   */
            CHYPOT32(psl->re, psl->im, t.re);
            if (t.re != 0.0F) {
                r.re = psl->re / t.re;
                r.im = psl->im / t.re;
                psl->re = t.re;
                psl->im = 0.0F;
                if (lp1 < m) {
                    CDIV32(*pel, r, *pel);
                }
                if (wantv && l < n) {
                    /*  scal(n,r,u+l*n)  */
                    tp1 = u+l*n;
                    for(ii=0; ii<n; ii++) {
                        temp.re = CMULT_RE(r,*tp1);
                        temp.im = CMULT_IM(r,*tp1);
                        *tp1++ = temp;
                    }
                    /*  scal(n,r,u+l*n)  */
                }
            }
            if (lp1 == m) break;		/*  ...exit */
            CHYPOT32(pel->re, pel->im, t.re);
            if (t.re != 0.0F) {
                temp.re = t.re;
                temp.im = 0.0F;
                CDIV32(temp, *pel, r);
                pel->re = t.re;
                pel->im = 0.0F;
                psl++;		/* s(l+1) */
                temp.re = CMULT_RE(*psl,r);
                temp.im = CMULT_IM(*psl,r);
                *psl = temp;
                if (wantv) {
                    /*  scal(p,r,v+p*lp1)  */
                    tp1 = v+p*lp1;
                    for(ii=0; ii<p; ii++) {
                        temp.re = CMULT_RE(r,*tp1);
                        temp.im = CMULT_IM(r,*tp1);
                        *tp1++ = temp;
                    }
                    /*  scal(p,r,v+p*lp1)  */
                }
            }
        }
        
        /*
        *-------------------------------------------------------------
        *	Main iteration loop for the singular values.
        */
        mm   = m;
        iter = 0;
        snorm = 0;
        for (l=0; l<m; l++) {
            snorm = MAX(snorm, MAX(FABS32((s+l)->re), FABS32((e+l)->re)));
        }
        
        /*
        *	Quit if all the singular values have been found, or
        *	if too many iterations have been performed, set
        *	flag and return.
        */
        
        while (m != 0 && iter <= MAXIT) {
        /*
        *	This section of the program inspects for
        *	negligible elements in the s and e arrays.  On
        *	completion the variable kase is set as follows.
        *
        *	kase = 1     if sr(m) and er(l-1) are negligible 
        *			 and l < m
        *	kase = 2     if sr(l) is negligible and l < m
        *	kase = 3     if er(l-1) is negligible, l < m, and
        *			 sr(l), ..., sr(m) are not 
        *			 negligible (qr step).
        *	kase = 4     if er(m-1) is negligible (convergence).
            */
            
            mm1 = m - 1;
            mm2 = m - 2;
            for (l=mm2; l>=0; l--) {
                test = FABS32((s+l)->re) + FABS32((s+l+1)->re);
                ztest = FABS32((e+l)->re);
                if (!dspIsFinite32(test) || !dspIsFinite32(ztest)) {
                    info = -1;
                    return(info);
                }
                if ((ztest <= eps*test) || (ztest <= tiny) ||
                    (iter > 20 && ztest <= eps*snorm)) {
                    (e+l)->re = 0.0F;
                    break;			/* ...exit */
                }
            }
            if (l == mm2) {
                kase = 4;
            } else {
                lp1 = l + 1;
                for (ls=m; ls>lp1; ls--) {
                    test = 0.0F;
                    if (ls != m) test += FABS32((e+ls-1)->re);
                    if (ls != l + 2) test += FABS32((e+ls-2)->re);
                    ztest = FABS32((s+ls-1)->re);
                    if (!dspIsFinite32(test) || !dspIsFinite32(ztest)) {
                        return(info);
                    }
                    if ((ztest <= eps*test) || (ztest <= tiny)) {
                        (s+ls-1)->re = 0.0F;
                        break;					/* ...exit */
                    }
                }
                if (ls == lp1) {
                    kase = 3;
                } else if (ls == m) {
                    kase = 1;
                } else {
                    kase = 2;
                    l = ls - 1;
                }
            }
            lm1 = ++l - 1;
            
            /*
            *	Perform the task indicated by kase.
            */
            switch (kase) {
                
            case 1:			/* Deflate negligible sr(m). */
                f = (e+mm2)->re;
                (e+mm2)->re = 0.0F;
                for (k=mm2; k>=l; k--) {
                    t1 = (s+k)->re;
                    rotg32(&t1, &f, &cs, &sn);
                    (s+k)->re = t1;
                    if (k != l) {
                        f = -sn * (e+k-1)->re;
                        (e+k-1)->re *= cs;
                    }
                    if (wantv) {
                        rot_cplx32(p, cs, sn, v+k*p, v+mm1*p);
                    }
                }
                break;
                
            case 2:			/* split at negligible sr(l). */
                f = (e+lm1)->re;
                (e+lm1)->re = 0.0F;
                for (k=l; k<m; k++) {
                    t1 = (s+k)->re;
                    rotg32(&t1, &f, &cs, &sn);
                    (s+k)->re = t1;
                    f = -sn * (e+k)->re;
                    (e+k)->re *= cs;
                    if (wantv) {
                        rot_cplx32(n, cs, sn, u+n*k,u+n*lm1);
                    } 
                } 
                break;
                
            case 3:				/* perform one qr step. */
                                                /*
                                                *	Calculate the shift.
                */
                scale = MAX(FABS32((s+mm1)->re), MAX(FABS32((s+mm2)->re), FABS32((e+mm2)->re)));
                scale = MAX(FABS32(scale), MAX(FABS32((s+l)->re), FABS32((e+l)->re)));
                sm = (s+mm1)->re / scale;
                smm1 = (s+mm2)->re / scale;
                emm1 = (e+mm2)->re / scale;
                sl = (s+l)->re / scale;
                el = (e+l)->re / scale;
                b = ((smm1 + sm) * (smm1 - sm) + emm1 * emm1) / 2.0F;
                c = sm * emm1;
                c *= c;
                shift = 0.0F;
                if (b != 0.0F || c != 0.0F) {
                    shift = sqrtf(b * b + c);
                    if (b < 0.0F) shift = -shift;
                    shift = c / (b + shift);
                }
                f = (sl + sm) * (sl - sm) + shift;
                g = sl * el;
                /*
                *	Chase Zeros.
                */
                for (k=l; k<mm1; k++) {
                    kp1 = k + 1;
                    rotg32(&f, &g, &cs, &sn);
                    if (k != l) (e+k-1)->re = f;
                    f = cs * (s+k)->re + sn * (e+k)->re;
                    (e+k)->re = cs * (e+k)->re - sn * (s+k)->re;
                    g = sn * (s+kp1)->re;
                    (s+kp1)->re *= cs;
                    if (wantv) {
                        rot_cplx32(p, cs, sn, v+k*p, v+kp1*p);
                    }
                    rotg32(&f, &g, &cs, &sn);
                    (s+k)->re = f;
                    f = cs * (e+k)->re + sn * (s+kp1)->re;
                    (s+kp1)->re = -sn * (e+k)->re + cs * (s+kp1)->re;
                    g = sn * (e+kp1)->re;
                    (e+kp1)->re *= cs;
                    if (wantv && k < nm1) {
                        rot_cplx32(n, cs, sn, u+n*k, u+n*kp1);
                    }
                }
                (e+mm2)->re = f;
                ++iter;
                break;
                
            case 4: 			/* convergence */
                                        /*
                                        *	Make the singular value positive
                */
                if ((s+l)->re < 0.0F) {
                    (s+l)->re = -(s+l)->re;
                    if (wantv) {
                        /*  scal(p,MinusOne,v+l*p)  */
                        tp1 = v+l*p;			    
                        for(ii=0; ii<p; ii++) {
                            tp1->re = -tp1->re;
                            tp1->im = -tp1->im;
                            tp1++;
                        }
                        /*  scal(p,MinusOne,v+l*p)  */
                    }
                }
                /*
                *	Order the singular value.
                */
                while (l != mm-1 && (s+l)->re < (s+l+1)->re) {
                    lp1 = l + 1;
                    t.re = (s+l)->re;
                    (s+l)->re = (s+lp1)->re;
                    (s+lp1)->re = t.re;
                    if (wantv && lp1 < p) {
                        /*  swap(p,v+l*p,v+lp1*p)  */
                        tp1 = v+l*p;
                        tp2 = v+lp1*p;
                        for(ii=0; ii<p; ii++) {
                            temp = *tp1;
                            *tp1++ = *tp2;
                            *tp2++ = temp;
                        }
                        /*  swap(p,v+l*p,v+lp1*p)  */
                    }
                    if (wantv && lp1 < n) {
                        /*  swap(n,u+l*n,u+lp1*n)  */
                        tp1 = u+l*n;
                        tp2 = u+lp1*n;
                        for(ii=0; ii<n; ii++) {
                            temp = *tp1;
                            *tp1++ = *tp2;
                            *tp2++ = temp;
                        }
                        /*  swap(n,u+l*n,u+lp1*n)  */
                    }
                    ++l;
                }
                iter = 0;
                m--;
                break;
                
            default:
                break;
                }
            info = m;
        }
        
        return(info);
}


/* [EOF] svd_c_rt.c */
