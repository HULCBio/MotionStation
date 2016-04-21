/* $Revision: 1.2 $ */
/*  Header : maxmin.h
    Author : Richard A. O'Keefe (ok@goanna.cs.rmit.edu.au)
    Updated: 19907-04-08
    Defines: *max(_,_) and *min(_,_) functions for scalars. 

    Note:  if your compiler requires an `inline' keyword other than GCC's
    __inline__ you will need to provide an additional definition.  The
    author would appreciate hearing what change is required.

    The prefixes i, u, l, ul, ll, ull, f, d, ld, and p
    stand for int, unsigned, long, unsigned long, long long,
    unsigned long long, float, double, long double, and pointer
    respectively.

    Note:  if you want long long, you will have to #define HAS_LONG_LONG.
    That's not in the current ISO C standard, and although 64-bit integers
    will be in C9X, they will probably NOT use 'long long' but will use the
    features in the new <inttypes.h> header instead.

    This has been tested under SPARCompiler C 4.2 and GCC 2.7.2
    on a SuperSPARC running Solaris 2.5.

    There is no copyright on this file.  There is nothing in it that is not
    obvious to any good C programmer.  Do what you please with it.
*/

#ifndef	MAXMIN_H_
#define MAXMIN_H_ 1997

#ifdef __GNUC__
#define MM(n,r,t) \
    static __inline__ t n(t x, t y) { return x r y ? x : y; }
#else
#define MM(n,r,t) \
    static t n(t x, t y) { return x r y ? x : y; }
#endif

MM(pmax,   >, void *)
MM(fmax,   >, float)
MM(dmax,   >, double)
MM(ldmax,  >, long double)
MM(imax,   >, int)
MM(umax,   >, unsigned)
MM(lmax,   >, long)
MM(ulmax,  >, unsigned long)
#ifdef HAS_LONG_LONG
MM(llmax,  >, long long)
MM(ullmax, >, unsigned long long)
#endif

MM(pmin,   <, void *)
MM(fmin,   <, float)
MM(dmin,   <, double)
MM(ldmin,  <, long double)
MM(imin,   <, int)
MM(umin,   <, unsigned)
MM(lmin,   <, long)
MM(ulmin,  <, unsigned long)
#ifdef HAS_LONG_LONG
MM(llmin,  <, long long)
MM(ullmin, <, unsigned long long)
#endif

#undef	MM
#endif/*MAXMIN_H_*/

