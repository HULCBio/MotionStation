#include "mex.h"
#include <math.h> 
#include <string.h> 

/* linkage.c - Create hierarchical cluster tree

   This is a MEX-file for MATLAB.
   Copyright 2003-2004 The MathWorks, Inc.
    
   $Revision: 1.1.6.2 $ 
 
   This function may give the wrong answer if compiled with MSVC 6.0 or
   less in Windows  (see line 177) */

#define ISNAN(a) (a != a)
/* #define ISNAN(a) (mxIsNaN(a)) */

void mexFunction(
    int nlhs,             /* Number of left hand side (output) arguments */
    mxArray *plhs[],      /* Array  of left hand side (output) arguments */
    int nrhs,             /* Number of right hand side (input) arguments */
    const mxArray *prhs[] /* Array  of right hand side (input) arguments */
)
{ 
static double inf;
int           n,m,m2,m2m3,m2m1,bn,bc,bp,p1,p2,q,q1,q2,h,i,j,k,l,g;
int           nk,nl,ng,nkpnl,sT,N;
int           *obp,*scl,*K,*L;
double        *y,*yi,*s,*b1,*b2,*T;       
double        t1,t2,t3,rnk,rnl; 
char          method[3];
enum          method_types 
                {single,complete,average,weighted,centroid,median,ward} 
                method_key;
int           uses_scl = false,  no_squared_input = true;              

/*  check for proper number of arguments */
if(nrhs!=2) 
  mexErrMsgTxt("Two inputs required.");
if(nlhs>1)  
  mexErrMsgTxt("Too many output arguments."); 

/* check input type */ 
if (!mxIsDouble(prhs[0]))
  mexErrMsgTxt("Function linkagemex is only defined for values of class 'double'.");
if (mxIsSparse(prhs[0]))
  mexErrMsgTxt("Function linkagemex is not defined for 'sparse' matrices.");

/*  create a pointer to the input vector y */
yi = mxGetPr(prhs[0]); 

/*  get the dimensions of input vector y (pairwise distances) */
n = mxGetN(prhs[0]);

/* calculate some constants */
m2   = (int) (1+sqrt(1+8*n));  /* 2*m */
m2m3 = m2 - 3;                 /* 2*m - 3 */
m2m1 = m2 - 1;                 /* 2*m - 1 */
m    = m2 >> 1;                /* number of observations --> m */
bn   = m-1;                    /* number of branches     --> bn */
inf  = mxGetInf();             /* inf */
 
/* get the method */ 
mxGetString(prhs[1],method,3);
if       ( strcmp(method,"si") == 0 ) method_key = single;
else if  ( strcmp(method,"co") == 0 ) method_key = complete;
else if  ( strcmp(method,"av") == 0 ) method_key = average;
else if  ( strcmp(method,"we") == 0 ) method_key = weighted;
else { 
    no_squared_input = false;  
    if       ( strcmp(method,"ce") == 0 ) method_key = centroid;
    else if  ( strcmp(method,"me") == 0 ) method_key = median;
    else if  ( strcmp(method,"wa") == 0 ) method_key = ward;
    else mexErrMsgTxt("Unknown linkage method.");
}
 
/*  allocate space for the output matrix  */ 
plhs[0] = mxCreateDoubleMatrix(bn, 3, mxREAL);

/*  create pointers to the output matrix */
b1 = mxGetPr(plhs[0]);   /*leftmost  column */
b2 = b1 + bn;            /*center    column */
s  = b2 + bn;            /*rightmost column */

/* find the best value for N (size of the temporal vector of  */
/* minimuns) depending on the problem size */
if      (m>1023) N = 512;
else if (m>511)  N = 256;
else if (m>255)  N = 128;
else if (m>127)  N = 64;
else if (m>63)   N = 32;
else             N = 16;
if (method_key == single) N = N >> 2;

/* set space for the vector of minimuns (and indexes) */
T = mxMalloc(N * sizeof(double));
K = mxMalloc(N * sizeof(int));
L = mxMalloc(N * sizeof(int));
 
/* set space to copy the input */
y = mxMalloc(n * sizeof(double));
/* copy input and compute Y^2 or 0.5*Y^2 if necessary */
if (no_squared_input) memcpy(y,yi,n * sizeof(double));
else if (method_key == ward)
    for (i=0; i<n; i++) y[i] = yi[i] * yi[i] / 2; 
else /* then it is centroid or median */
    for (i=0; i<n; i++) y[i] = yi[i] * yi[i]; 

/* set space for the obs-branch pointers  */
obp = mxMalloc(m * sizeof(int));
switch (method_key) {
    case average:
    case centroid:
    case ward:
        uses_scl = true;
        /* set space for the size of clusters vector */
        scl = mxMalloc(m * sizeof(int));
        /* initialize obp and scl */
        for (i=0; i<m; obp[i]=i, scl[i++]=1);
        break;
    default: /*all other cases */
        /* only initialize obp */
        for (i=0; i<m; i++) obp[i]=i;
} /* switch (method_key) */

sT = 0;  t3 = inf;

for (bc=0,bp=m;bc<bn;bc++,bp++){
/* *** MAIN LOOP ***
bc is a "branch counter" --> bc = [ 0:bn-1]
bp is a "branch pointer" --> bp = [ m:m+bc-1 ], it is used to point  
   branches in the output since the values [0:m-1]+1 are reserved for 
   leaves. 
*/
 
    /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* 
    find the "k","l" indices of the minimum distance "t1" in the remaining 
    half matrix, the new computed distances to the new cluster will be placed
    in the row/col "l", then the leftmost column in the matrix of pairwise
    distances will be moved to the row/col "k", so the whole matrix of 
    distances is smaller at every step */

    /*  OLD METHOD: search for the minimun in the whole "y" at every branch 
    iteration 
    t1 = inf; 
    p1 = ((m2m1 - bc) * bc) >> 1; /*finds where the remaining matrix starts
    for (j=bc; j<m; j++) {
     for (i=j+1; i<m; i++) {
       t2 = y[p1++];
       if (t2<t1) { k=j, l=i, t1=t2;} 
       } 
    }  
    */ 

    /*  NEW METHOD: Keeps a sorted vector "T" with the N minimum distances, 
    at every branch iteration we only pick the first entry. Now the whole 
    "y" is not searched at every step, we will search it again only when 
    all the entries in "T" have been used or invalidated. However, we need 
    to keep track of invalid distances already sorted in "y", and also 
    update the index vectors "K" and "L" with permutations occured in the 
    half matrix "y"
    */

    /* cuts "T" so it does not contain any distance greater than any of the
       new distances computed when joined the last clusters ("t3" contains 
       the minimum new distance computed in the last iteration). */
    for (h=0;((T[h]<t3) && (h<sT));h++);
    sT = h; t3 = inf;

    /* ONLY when "T" is empty it searches again "y" for the N minimum 
       distances  */
    if (sT==0) { 
        for (h=0; h<N; T[h++]=inf);
        p1 = ((m2m1 - bc) * bc) >> 1; /* finds where the matrix starts */
        for (j=bc; j<m; j++) {
            for (i=j+1; i<m; i++) {
                t2 = y[p1++];
                /*  this would be needed to solve NaN bug in MSVC*/
                /*  if (!mxIsNaN(t2)) { */
                 if (t2 <= T[N-1]) { 
                    for (h=N-1; ((t2 <= T[h-1]) && (h>0)); h--) { 
                        T[h]=T[h-1];
                        K[h]=K[h-1];
                        L[h]=L[h-1];
                    } /* for (h=N-1 ... */ 
                    T[h] = t2; 
                    K[h] = j;
                    L[h] = i;
                    sT++;
               } /* if (t2<T[N-1]) */
               /*}*/ 
            } /*  for (i= ... */ 
        } /* for (j= ... */
        if (sT>N) sT=N;
    } /* if (sT<1) */

    /* if sT==0 but bc<bn then the remaining distances in "T" must be 
       NaN's ! we break the loop, but still need to fill the remaining 
       output rows with linkage info and NaN distances
    */
    if (sT==0) break;
    
    
    /* the first entry in the ordered vector of distances "T" is the one 
       that will be used for this branch, "k" and "l" are its indexes */
    k=K[0]; l=L[0]; t1=T[0];
  
    /* some housekeeping over "T" to inactivate all the other minimum 
       distances which also have a "k" or "l" index, and then also take 
       care of those indexes of the distances which are in the leftmost 
       column */
    for (h=0,i=1;i<sT;i++) { 
        /* test if the other entries of "T" belong to the branch "k" or "l"
           if it is true, do not move them in to the updated "T" because 
           these distances will be recomputed after merging the clusters */
        if ( (k!=K[i]) && (l!=L[i]) && (l!=K[i]) && (k!=L[i]) ) {  
            T[h]=T[i];
            K[h]=K[i];
            L[h]=L[i];
            /* test if the preserved distances in "T" belong to the 
               leftmost column (to be permutated), if it is true find out
               the value of the new indices for such entry */
            if (bc==K[h]) { 
                if (k>L[h]) { 
                    K[h] = L[h];
                    L[h] = k;
                } /* if (k> ...*/
                else K[h] = k;
            } /* if (bc== ... */
            h++;
        } /* if k!= ... */
    } /* for (h=0 ... */
    sT=h; /* the new size of "T" after the shifting */

    /* Update output for this branch, puts smaller pointers always in the 
       leftmost column */
    if (obp[k]<obp[l]) {
        *b1++ = (double) (obp[k]+1); /* +1 since Matlab ptrs start at 1 */
        *b2++ = (double) (obp[l]+1);
    } else {
        *b1++ = (double) (obp[l]+1); 
        *b2++ = (double) (obp[k]+1);
    }
    *s++ = (no_squared_input) ? t1 : sqrt(t1);

    /* Updates obs-branch pointers "obp" */
    obp[k] = obp[bc];        /* new cluster branch ptr */
    obp[l] = bp;             /* leftmost column cluster branch ptr */

    /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* 
    Merges two observations/clusters ("k" and "l") by re-calculating new 
    distances for every remaining observation/cluster and place the 
    information in the row/col "l" */

    /*

    example:  bc=2  k=5  l=8   bn=11   m=12

    0
    1    N                             Pairwise
    2    N   N                         Distance
    3    N   N   Y                     Half Matrix
    4    N   N   Y   Y
    5    N   N  p1*  *   *
    6    N   N   Y   Y   Y   +
    7    N   N   Y   Y   Y   +   Y
    8    N   N  p2*  *   *   []  +   +
    9    N   N   Y   Y   Y   o   Y   Y   o
    10   N   N   Y   Y   Y   o   Y   Y   o   Y
    11   N   N   Y   Y   Y   o   Y   Y   o   Y   Y

         0   1   2   3   4   5   6   7   8   9   10   11


    p1 is the initial pointer for the kth row-col
    p2 is the initial pointer for the lth row-col
    *  are the samples touched in the first loop
    +  are the samples touched in the second loop
    o  are the samples touched in the third loop
    N  is the part of the whole half matrix which is no longer used
    Y  are all the other samples (not touched)

    */

    /* computing some limit constants to set up the 3-loops to 
       transverse Y */
    q1 = bn - k - 1;
    q2 = bn - l - 1;

    /* initial pointers to the "k" and  "l" entries in the remaining half 
       matrix */
    p1 = ((((m2m1 - bc) * bc) ) >> 1) + k - bc - 1;
    p2 = p1 - k + l;

    if (uses_scl) {
         /* Get the cluster cardinalities  */
         nk     = scl[k]; 
         nl     = scl[l];
         nkpnl  = nk + nl;  
              
         /* Updates cluster cardinality "scl" */
         scl[k] = scl[bc];        /* letfmost column cluster cardinality */
         scl[l] = nkpnl;          /* new cluster cardinality */
        
    } /* if (uses_scl) */   
    
    /* some other values that we want to compute outside the loops */
    switch (method_key) {
        case centroid:
            t1 = t1 * (nk * nl) / (nkpnl * nkpnl);
        case average:  
            /* Computes weighting ratios */
            rnk = (double) nk / nkpnl;
            rnl = (double) nl / nkpnl;
            break;
        case median: 
            t1 = t1/4;
    } /* switch (method_key) */       
    
    switch (method_key) {
         case average:  
             for (q=bn-bc-1; q>q1; q--) {
                 t2 = y[p1] * rnk + y[p2] * rnl;
                 if (t2 < t3) t3 = t2 ;
                 y[p2] = t2;
                 p1 = p1 + q;
                 p2 = p2 + q;
             }   
             p1++;
             p2 = p2 + q;
             for (q=q1-1;  q>q2; q--) { 
                 t2 = y[p1] * rnk + y[p2] * rnl;
                 if (t2 < t3) t3 = t2 ;
                 y[p2] = t2;
                 p1++;
                 p2 = p2 + q;
             } 
             p1++; 
             p2++;  
             for (q=q2+1; q>0; q--) { 
                 t2 = y[p1] * rnk + y[p2] * rnl;
                 if (t2 < t3) t3 = t2 ;
                 y[p2] = t2;
                 p1++;
                 p2++;  
             } 
             break; /* case average */

         case single: 
             for (q=bn-bc-1; q>q1; q--) { 
                 if (y[p1] < y[p2]) y[p2] = y[p1];
                 else if (ISNAN(y[p2])) y[p2] = y[p1];
                 if (y[p2] < t3)    t3 = y[p2];
                 p1 = p1 + q;
                 p2 = p2 + q;
             }   
             p1++;
             p2 = p2 + q;
             for (q=q1-1;  q>q2; q--) {
                 if (y[p1] < y[p2]) y[p2] = y[p1];
                 else if (ISNAN(y[p2])) y[p2] = y[p1];
                 if (y[p2] < t3)    t3 = y[p2];
                 p1++;
                 p2 = p2 + q;
             } 
             p1++; 
             p2++;  
             for (q=q2+1; q>0; q--) { 
                 if (y[p1] < y[p2]) y[p2] = y[p1];
                 else if (ISNAN(y[p2])) y[p2] = y[p1];
                 if (y[p2] < t3)    t3 = y[p2];
                 p1++;
                 p2++;  
             } 
             break; /* case simple */

         case complete: 
             for (q=bn-bc-1; q>q1; q--) { 
                 if (y[p1] > y[p2]) y[p2] = y[p1];
                 else if (ISNAN(y[p2])) y[p2] = y[p1];
                 if (y[p2] < t3)    t3 = y[p2];
                 p1 = p1 + q;
                 p2 = p2 + q;
             }   
             p1++;
             p2 = p2 + q;
             for (q=q1-1;  q>q2; q--) {
                 if (y[p1] > y[p2]) y[p2] = y[p1];
                 else if (ISNAN(y[p2])) y[p2] = y[p1];
                 if (y[p2] < t3)    t3 = y[p2];
                 p1++;
                 p2 = p2 + q;
             } 
             p1++; 
             p2++;  
             for (q=q2+1; q>0; q--) { 
                 if (y[p1] > y[p2]) y[p2] = y[p1];
                 else if (ISNAN(y[p2])) y[p2] = y[p1];
                 if (y[p2] < t3)    t3 = y[p2];
                 p1++;
                 p2++;  
             } 
             break; /* case complete */

         case weighted:
             for (q=bn-bc-1; q>q1; q--) { 
                 t2 = (y[p1] + y[p2])/2;
                 if (t2<t3) t3=t2;
                 y[p2] = t2;
                 p1 = p1 + q;
                 p2 = p2 + q;
             }   
             p1++;
             p2 = p2 + q;
             for (q=q1-1;  q>q2; q--) { 
                 t2 = (y[p1] + y[p2])/2;
                 if (t2<t3) t3=t2;
                 y[p2] = t2;
                 p1++;
                 p2 = p2 + q;
             } 
             p1++; 
             p2++;  
             for (q=q2+1; q>0; q--) { 
                 t2 = (y[p1] + y[p2])/2;
                 if (t2<t3) t3=t2;
                 y[p2] = t2;
                 p1++;
                 p2++;  
             } 
             break; /* case weighted */
        
        case centroid: 
             for (q=bn-bc-1; q>q1; q--) { 
                 t2 = y[p1] * rnk + y[p2] * rnl - t1;
                 if (t2<t3) t3=t2;
                 y[p2] = t2;
                 p1 = p1 + q;
                 p2 = p2 + q;
             }   
             p1++;
             p2 = p2 + q;
             for (q=q1-1;  q>q2; q--) {
                 t2 = y[p1] * rnk + y[p2] * rnl - t1;
                 if (t2<t3) t3=t2;
                 y[p2] = t2;
                 p1++;
                 p2 = p2 + q;
             } 
             p1++; 
             p2++;  
             for (q=q2+1; q>0; q--) {
                 t2 = y[p1] * rnk + y[p2] * rnl - t1;
                 if (t2<t3) t3=t2;
                 y[p2] = t2;
                 p1++;
                 p2++;  
             } 
             break; /* case centroid */

        case median:
            for (q=bn-bc-1; q>q1; q--) { 
                t2 = (y[p1] + y[p2])/2 - t1;
                if (t2<t3) t3=t2;
                y[p2] = t2;
                p1 = p1 + q;
                p2 = p2 + q;
            }
            p1++;
            p2 = p2 + q;
            for (q=q1-1;  q>q2; q--) { 
                t2 = (y[p1] + y[p2])/2 - t1;
                if (t2<t3) t3=t2;
                y[p2] = t2;
                p1++;
                p2 = p2 + q;
            }
            p1++;
            p2++;
            for (q=q2+1; q>0; q--) { 
                t2 = (y[p1] + y[p2])/2 - t1;
                if (t2<t3) t3=t2;
                y[p2] = t2;
                p1++;
                p2++;
            }
            break; /* case median */

        case ward: 
            for (q=bn-bc-1,g=bc; q>q1; q--) {
                ng = scl[g++];
                t2 = (y[p1]*(nk+ng) + y[p2]*(nl+ng) - t1*ng) / (nkpnl+ng);
                if (t2<t3) t3=t2;
                y[p2] = t2;
                p1 = p1 + q;
                p2 = p2 + q;
            }   
            g++;
            p1++;
            p2 = p2 + q;
            for (q=q1-1;  q>q2; q--) { 
                ng = scl[g++];
                t2 = (y[p1]*(nk+ng) + y[p2]*(nl+ng) - t1*ng) / (nkpnl+ng);
                if (t2<t3) t3=t2;
                y[p2] = t2;
                p1++;
                p2 = p2 + q;
            } 
            g++;
            p1++; 
            p2++;  
            for (q=q2+1; q>0; q--) { 
                ng = scl[g++];
                t2 = (y[p1]*(nk+ng) + y[p2]*(nl+ng) - t1*ng) / (nkpnl+ng);
                if (t2<t3) t3=t2;
                y[p2] = t2;
                p1++;
                p2++;  
            } 
            break; /* case ward */
    
    } /* switch (method_key) */
 
    /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* /* 
      moves the leftmost column "bc" to row/col "k" */
    if (k!=bc) { 
        q1 = bn - k;     
  
        p1 = (((m2m3 - bc) * bc) >> 1) + k - 1;
        p2 = p1 - k + bc + 1;

        for (q=bn-bc-1; q>q1; q--) { 
            p1 = p1 + q;
            y[p1] = y[p2++];  
        } 
        p1 = p1 + q + 1;
        p2++;
        for ( ; q>0; q--) { 
            y[p1++] = y[p2++];
        }
    } /*if (k!=bc) */
} /*for (bc=0,bp=m;bc<bn;bc++,bp++) */

/* loop to fill with NaN's in case the main loop ended prematurely */
for (;bc<bn;bc++,bp++) {
    k=bc; l=bc+1;
    if (obp[k]<obp[l]) {
        *b1++ = (double) (obp[k]+1); 
        *b2++ = (double) (obp[l]+1);
    } else {
        *b1++ = (double) (obp[l]+1); 
        *b2++ = (double) (obp[k]+1);
    }
    obp[l] = bp;
    *s++ = mxGetNaN();           
}

if (uses_scl) mxFree(scl); 
mxFree(obp);
mxFree(y);
mxFree(L); 
mxFree(K);
mxFree(T);
 
} /* void mexFunction   */

