/* 
 * SVD_D_RT - Signal Processing Blockset Singular Value Decomposition helper functions
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.16.2.2 $  $Date: 2004/04/12 23:49:06 $
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
static void rot_real(
              int_T	n,	/* number of elements in vectors */
              real_T	c,	/* c part of transform */
              real_T	s, 	/* s part of transform */
              real_T	*x,	/* first vector */
              real_T	*y	/* second vector */
              )
{
    real_T t;
    
    if (n <= 0) {
        return;
    }
    
    while (n--) {
        t  = c * *x + s * *y;
        *y = c * *y - s * *x;
        *x++ = t;					
        y++;
    }
}


/*
 * Singular value decomposition
 */
int_T MWDSP_SVD_D
(
                   real_T	*x,
                   int_T	n,
                   int_T	p,
                   real_T	*s,
                   real_T	*e,
                   real_T	*work,
                   real_T	*u,
                   real_T	*v,
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
    real_T t, t2, r;
    real_T sm, smm1, emm1, el, sl, b, c, cs, sn, scale, t1, f;
    real_T test, ztest, snorm, g, shift;
    real_T *pxll, *pxlj, *pel, *pel1, *psl, *pull, *pvll;
    real_T *tp1, *tp2, temp, temp1;
    const real_T One = 1.0, Zero = 0.0;
    real_T eps = EPS_real_T;
    real_T  tiny = MIN_real_T / EPS_real_T;
    


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
            /*  *psl = nrm2(nml,pxll)  */
            *psl = Zero;
            tp1 = pxll;
            for (ii=0; ii<nml; ii++) {
                CHYPOT(*psl,*tp1,*psl);
                tp1++;
            }
            /*  *psl = nrm2(nml,pxll)  */
            if (fabs(*psl) != Zero) {
                if (fabs(*pxll) != Zero) {
                    /*  *psl = sign(*psl,*pxll)  */
                    *psl = (*pxll >= Zero) ? fabs(*psl) : -fabs(*psl);
                    /*  *psl = sign(*psl,*pxll)  */
                }
                /*  scal(nml,One / *psl,pxll)  */
                temp1 = One / *psl;
                tp1 = pxll;
                for(ii=0; ii<nml; ii++) {
                    *tp1++ *= temp1;
                }
                /*  scal(nml,One / *psl,pxll)  */
                *pxll += One;
            }
            *psl = -*psl;
        } 
        for (j=lp1; j<p; j++) { 
            plj = j * n + l;	
            pxlj = x + plj;	/* x(l,j) */ 
            if (l < nct && fabs(*psl) != Zero) {
            /*
            *	Apply the transformation.
                */
                /*  t = -dot(nml,pxll,pxlj)  */
                tp1 = pxll;
                tp2 = pxlj;
                t = Zero;
                for(ii=0; ii<nml; ii++) {
                    t += *tp1++ * *tp2++;
                }
                t = -t;
                /*  t = -dot(nml,pxll,pxlj)  */
                t /= *pxll;
                /*  axpy(nml,t,pxll,pxlj)  */
                tp1 = pxlj;
                tp2 = pxll;
                for(ii=0; ii<nml; ii++) {
                    *tp1 += t * *tp2;
                    tp1++;
                    tp2++;
                }
                /*  axpy(nml,t,pxll,pxlj)  */
            }
            /*
            * Place the l-th row of x into  e for the
            * subsequent calculation of the row transformation.
            */
            *(e+j) = *pxlj;
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
            *pel = Zero;
            tp1 = pel1;
            for(ii=0; ii<p-lp1; ii++) {
                CHYPOT(*pel,*tp1,*pel);
                tp1++;
            }
            /*  psl->re = nrm2(p-lp1,pel1)  */
            if (fabs(*pel) != Zero) {
                if (fabs(*pel1) != Zero) {
                    /*  *pel = sign(*pel,*pel1)  */
                    *pel = (*pel1 >= Zero) ? fabs(*pel) : -fabs(*pel);
                    /*  *pel = sign(*pel,*pel1)  */
                }
                /*  scal(p-lp1,One / *pel,pel1)  */
                temp1 = One / *pel;
                tp1 = pel1;
                for(ii=0; ii<p-lp1; ii++) {
                    *tp1 *= temp1;
                    tp1++;
                }
                /*  scal(p-lp1,One / *pel,pel1)  */
                *(pel+1) += One;
            }
            *pel = -*pel;
            if (lp1 < n && fabs(*pel) != Zero) {
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
                        *tp1++ += *(e+j) * *tp2++;
                    }
                    /*  axpy(n-lp1,*(e+j),x+plj,work+lp1)  */
                }
                for (j=lp1; j<p; j++) {
                    t2 = -*(e+j);
                    t = t2 / *pel1;
                    plj = j*n+lp1;		/* x(lp1,j) */
                    /*  axpy(n-lp1,t,work+lp1,x+plj)  */
                    tp1 = x+plj;
                    tp2 = work+lp1;
                    for(ii=0; ii<n-lp1; ii++) {
                        temp = t * *tp2++;
                        *tp1++ += temp;
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
                if (fabs(*(s+l)) != Zero) {
                    lp1 = l + 1;
                    for (j=lp1; j<ncu; j++) {
                        plj = j*n+l;	/* u(l,j) */
                        /*  t = -dot(nml,pull,u+plj)  */
                        tp1 = pull;
                        tp2 = u+plj;
                        t = Zero;
                        for(ii=0; ii<nml; ii++) {
                            t += *tp1++ * *tp2++;
                        }
                        t = -t;
                        /*  t = -dot(nml,pull,u+plj)  */
                        t /= *pull;
                        /*  axpy(nml,t,pull,u+plj)  */
                        tp1 = u+plj;
                        tp2 = pull;
                        for(ii=0; ii<nml; ii++) {
                            temp = t * *tp2++;
                            *tp1++ += temp;
                        }
                        /*  axpy(nml,t,pull,u+plj)  */
                    }
                    /*  scal(nml,MinusOne,pull)  */
                    tp1 = pull;
                    for(ii=0; ii<nml; ii++) {
                        *tp1 = -(*tp1);
                        tp1++;
                    }
                    /*  scal(nml,MinusOne,pull)  */
                    *pull += One;
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
                if (l < nrt && fabs(*(e+l)) != Zero) {
                    for (j=lp1; j<p; j++) {
                        plj = j*p+lp1;	/* v(lp1,j) */
                        /*  t = -dot(p-lp1,pvll,v+plj)  */
                        tp1 = pvll;
                        tp2 = v+plj;
                        t = Zero;
                        for(ii=0; ii<p-lp1; ii++) {
                            t += *tp1++ * *tp2++;
                        }
                        t = -t;
                        /*  t = -dot(p-lp1,pvll,v+plj)  */
                        t /= *pvll;
                        /*  axpy(p-lp1,t,pvll,v+plj)  */
                        tp1 = v+plj;
                        tp2 = pvll;
                        for(ii=0; ii<p-lp1; ii++) {
                            *tp1++ += t * *tp2++;
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
            t = fabs(*psl);
            if (t != Zero) {
                r = *psl / t;
                *psl = t;
                if (lp1 < m) {
                    *pel /= r;
                }
                if (wantv && l < n) {
                    /*  scal(n,r,u+l*n)  */
                    tp1 = u+l*n;
                    for(ii=0; ii<n; ii++) {
                        *tp1 *= r;
                        tp1++;
                    }
                    /*  scal(n,r,u+l*n)  */
                }
            }
            if (lp1 == m) break;		/*  ...exit */
            t = fabs(*pel);
            if (t != Zero) {
                temp = t;
                r = temp / *pel;
                *pel = t;
                psl++;		/* s(l+1) */
                *psl = *psl * r;
                if (wantv) {
                    /*  scal(p,r,v+p*lp1)  */
                    tp1 = v+p*lp1;
                    for(ii=0; ii<p; ii++) {
                        *tp1 *= r;
                        tp1++;
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
            snorm = MAX(snorm, MAX(fabs(*(s+l)), fabs(*(e+l))));
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
                test = fabs(*(s+l)) + fabs(*(s+l+1));
                ztest = fabs(*(e+l));
                if (!dspIsFinite(test) || !dspIsFinite(ztest)) {
                    info = -1;
                    return(info);
                }
                if ((ztest <= eps*test) || (ztest <= tiny) ||
                    (iter > 20 && ztest <= eps*snorm)) {
                    *(e+l) = Zero;
                    break;			/* ...exit */
                }
            }
            if (l == mm2) {
                kase = 4;
            } else {
                lp1 = l + 1;
                for (ls=m; ls>lp1; ls--) {
                    test = Zero;
                    if (ls != m) test += fabs(*(e+ls-1));
                    if (ls != l + 2) test += fabs(*(e+ls-2));
                    ztest = fabs(*(s+ls-1));
                    if (!dspIsFinite(test) || !dspIsFinite(ztest)) {
                        return(info);
                    }
                    if ((ztest <= eps*test) || (ztest <= tiny)) {
                        *(s+ls-1) = Zero;
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
                f = *(e+mm2);
                *(e+mm2) = Zero;
                for (k=mm2; k>=l; k--) {
                    t1 = *(s+k);
                    rotg(&t1, &f, &cs, &sn);
                    *(s+k) = t1;
                    if (k != l) {
                        f = -sn * *(e+k-1);
                        *(e+k-1) *= cs;
                    }
                    if (wantv) {
                        rot_real(p, cs, sn, v+k*p, v+mm1*p);
                    }
                }
                break;
                
            case 2:			/* split at negligible sr(l). */
                f = *(e+lm1);
                *(e+lm1) = Zero;
                for (k=l; k<m; k++) {
                    t1 = *(s+k);
                    rotg(&t1, &f, &cs, &sn);
                    *(s+k) = t1;
                    f = -sn * *(e+k);
                    *(e+k) *= cs;
                    if (wantv) {
                        rot_real(n, cs, sn, u+n*k,u+n*lm1);
                    } 
                } 
                break;
                
            case 3:				/* perform one qr step. */
                                                /*
                                                *	Calculate the shift.
                */
                scale = MAX(fabs(*(s+mm1)), MAX(fabs(*(s+mm2)), fabs(*(e+mm2))));
                scale = MAX(fabs(scale), MAX(fabs(*(s+l)), fabs(*(e+l))));
                sm = *(s+mm1) / scale;
                smm1 = *(s+mm2) / scale;
                emm1 = *(e+mm2) / scale;
                sl = *(s+l) / scale;
                el = *(e+l) / scale;
                b = ((smm1 + sm) * (smm1 - sm) + emm1 * emm1) / 2.0;
                c = sm * emm1;
                c *= c;
                shift = Zero;
                if (b != Zero || c != Zero) {
                    shift = sqrt(b * b + c);
                    if (b < Zero) shift = -shift;
                    shift = c / (b + shift);
                }
                f = (sl + sm) * (sl - sm) + shift;
                g = sl * el;
                /*
                *	Chase Zeros.
                */
                for (k=l; k<mm1; k++) {
                    kp1 = k + 1;
                    rotg(&f, &g, &cs, &sn);
                    if (k != l) *(e+k-1) = f;
                    f = cs * *(s+k) + sn * *(e+k);
                    *(e+k) = cs * *(e+k) - sn * *(s+k);
                    g = sn * *(s+kp1);
                    *(s+kp1) *= cs;
                    if (wantv) {
                        rot_real(p, cs, sn, v+k*p, v+kp1*p);
                    }
                    rotg(&f, &g, &cs, &sn);
                    *(s+k) = f;
                    f = cs * *(e+k) + sn * *(s+kp1);
                    *(s+kp1) = -sn * *(e+k) + cs * *(s+kp1);
                    g = sn * *(e+kp1);
                    *(e+kp1) *= cs;
                    if (wantv && k < nm1) {
                        rot_real(n, cs, sn, u+n*k, u+n*kp1);
                    }
                }
                *(e+mm2) = f;
                ++iter;
                break;
                
            case 4: 			/* convergence */
                                        /*
                                        *	Make the singular value positive
                */
                if (*(s+l) < Zero) {
                    *(s+l) = -*(s+l);
                    if (wantv) {
                        /*  scal(p,MinusOne,v+l*p)  */
                        tp1 = v+l*p;			    
                        for(ii=0; ii<p; ii++) {
                            *tp1 = -(*tp1);
                            tp1++;
                        }
                        /*  scal(p,MinusOne,v+l*p)  */
                    }
                }
                /*
                *	Order the singular value.
                */
                while (l != mm-1 && *(s+l) < *(s+l+1)) {
                    lp1 = l + 1;
                    t = *(s+l);
                    *(s+l) = *(s+lp1);
                    *(s+lp1) = t;
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


/* [EOF] svd_d_rt.c */
