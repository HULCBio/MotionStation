/*
    gf_mex  --> MEX file for doing arithmetic in MATLAB over
    the field GF(2^m)

    Author: T. Krauss, 11/22/99

    Copyright 1996-2002 The MathWorks, Inc.
    $Revision: 1.4 $  $Date: 2002/03/27 00:07:08 $ 
*/

#include <stdio.h>
#include <math.h>
#include "mex.h"

int gf_mul( int a, int b, int m, int p )
/*
 gf_mul.c  multiply two field elements in GF(2^m)
 p is the primitive (irreducible) polynomial.
*/
{
  int y,x,r,k,out; 
  if (m==1)
     return(a&b);
 
  /* algorithm:
      "convolve" a,b together as though they are polynomials over GF(2)
      take the result and decompose it as
          y = a*b = p*x + r, 
      return the result r which is the remainder of y upon division
             by the polynomial p
  */
  /* first get y: */
  y = 0;
  for (k=0; k<=(m-1); k++) {
     y = y ^ ( (a * ((b>>k)&1)) <<k);
  }
  /* now find remainder of y upon division by p */
  r = (y>>(m-1));  /* initialize shift register */
  
  for (k=1; k<=(m-1); k++) {
     out = (r>>(m-1))&1;
     r = (out*p) ^ ( (r<<1) | ((y>>(m-1-k))&1) );
     r = r%(1<<m);  /* zero out the m^th bit */
  }
  return(r);

}

void mexFunction(
  int nlhs,
  mxArray *plhs[],
  int nrhs,
  const mxArray *prhs[]
)
{
  /* calling sequence: x,y,m,msg 
      x - first uint16 matrix
      y - second uint16 matrix
      m - double - number of bits per element
      msg - string - message indicating what to do:
          'plus' ==> add x+y (element-wise) --> same as subtraction
          'times' ==> multiply: x.*y (element-wise)
          'mtimes' ==> multiply: x*y (matrix fashion)
          'rdivide' ==> multiplicative inverse: 1./x (element-wise)
          'power' ==> raise x to the y power: x.^y  (element-wise)
      p - uint32 scalar - primitive polynomial.  OPTIONAL - 
          The following default primitive polynomials are used
             m    polynomial
             2     1+D+D^2
             3     1+D+D^3
             4     1+D+D^4
             5     1+D^2+D^5
             6     1+D+D^6
             7     1+D^3+D^7
             8     1+D^2+D^3+D^4+D^8
             9     1+D^4+D^9
            10     1+D^3+D^10
            11     1+D^2+D^11
            12     1+D+D^4+D^6+D^12
            13     1+D+D^3+D^4+D^13
            14     1+D+D^6+D^10+D^14 
            15     1+D+D^15
            16     1+D+D^3+D^12+D^16
           Multiplication is implemented as polynomial multiplication
           over GF(2), mod the primitive polynomial defined above.
           An element in GF(2^m) is stored in the least significant m bits 
           of an integer variable
      table1 - uint16 array - length 2^m-1, maps exponents to polynomials
      table2 - uint16 array - length 2^m-1, maps polynomials to exponents
      The last two arguments are optional.  If provided, they
       will be used to perform multiplication, exponentiation, and
       inversion.  If not provided, or if table1 has zero elements,
       these operations will be performed with the gf_mul function.  
 */
   int k,kx,ky;
   unsigned short *x = (unsigned short *)mxGetData(prhs[0]);
   unsigned short *y = (unsigned short *)mxGetData(prhs[1]);
   int m = (int)mxGetScalar(prhs[2]);
   char msg[20];
   int Mx,Nx,My,Ny;  /* num rows, cols resp. of x, y resp. */
   unsigned short *z;  /* the output matrix */
   int temp;
   int dims[2];
   int p;  /* primitive polynomial */
   unsigned short *table1, *table2;
   int TABLE_FLAG = (nrhs>=6);
   int N = (1<<m);  /* 2^m, just 1 right shifted m times */

   if (nrhs < 4) {
      mexErrMsgTxt("must have at least 4 inputs: x,y,m,msg.");
   }
   mxGetString(prhs[3], msg, 20);

   if (nrhs < 5) { /* use default primitive poly */
      switch (m) {
        case 2: p = 7;  break;
        case 3: p = 11;  break;
        case 4: p = 19;  break;
        case 5: p = 37;  break;
        case 6: p = 67;  break;
        case 7: p = 137;  break;
        case 8: p = 285;  break;
        case 9: p = 529;  break;
        case 10: p = 1033;  break;
        case 11: p = 2053;  break;
        case 12: p = 4179;  break;
        case 13: p = 8219;  break;  
        case 14: p = 17475;  break;
        case 15: p = 32771;  break;
        case 16: p = 69643;  break; } 
   } else { /* use specified primitive poly */
        p = (int)mxGetScalar(prhs[4]);
   }
   if (TABLE_FLAG) {
        if (mxGetNumberOfElements(prhs[5])==0) {
            TABLE_FLAG = 0;
        }
   }
   if (TABLE_FLAG) {
        table1 = (unsigned short *)mxGetData(prhs[5]);
        table2 = (unsigned short *)mxGetData(prhs[6]);
   }
   
   if ( !mxIsUint16(prhs[0]) || !mxIsUint16(prhs[1]) ) {
      mexErrMsgTxt("Inputs x, y must be uint16.");
   }
   Mx = mxGetM(prhs[0]);
   Nx = mxGetN(prhs[0]);
   My = mxGetM(prhs[1]);
   Ny = mxGetN(prhs[1]);
  
   if (strcmp(msg,"plus")==0) {  /* element-wise add (or subtract) */
      if ((Mx != My) || (Nx != Ny)) {
         mexErrMsgTxt("sizes of x, y don't match");
      }  
      plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
                                     mxGetDimensions(prhs[0]),mxUINT16_CLASS,0);
      z = (unsigned short *)mxGetData(plhs[0]);
      for (k=1; k<=(Mx*Nx); k++) {
         z[k-1] = x[k-1]^y[k-1];  /* addition is just xor */
      }
   } else if (strcmp(msg,"times")==0) { /* element-wise multiply */
      if ((Mx != My) || (Nx != Ny)) {
         mexErrMsgTxt("sizes of x, y don't match");
      }
      plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
                                     mxGetDimensions(prhs[0]),mxUINT16_CLASS,0);
      z = (unsigned short *)mxGetData(plhs[0]);
      for (k=1; k<=(Mx*Nx); k++) {
         if (TABLE_FLAG) {
            if ((x[k-1]==0)||(y[k-1]==0)) {
               z[k-1]=0;
            } else {
               temp = ((int)table2[x[k-1]-1]+(int)table2[y[k-1]-1])%(N-1);
               if (temp==0) {temp=(N-1);}
               z[k-1]=table1[ temp-1 ];
            } 
         } else {
            z[k-1] = gf_mul(x[k-1],y[k-1],m,p);       
         }
      }
   } else if (strcmp(msg,"mtimes")==0) {  /* matrix multiply */
      if (Nx != My) {
         mexErrMsgTxt("Sizes of x, y don't match");
      }
      dims[0] = Mx;  dims[1] = Ny;
      plhs[0] = mxCreateNumericArray(2,dims,mxUINT16_CLASS,0);
      z = (unsigned short *)mxGetData(plhs[0]);
      for (kx=1; kx<=Mx; kx++) {
        for (ky=1; ky<=Ny; ky++) {
          z[(ky-1)*Mx+(kx-1)] = 0;
          for (k=1; k<=Nx; k++) {
            if (TABLE_FLAG) {
              if ((x[(k-1)*Mx+(kx-1)]==0)||(y[(ky-1)*My+(k-1)]==0)) {
                z[(ky-1)*Mx+(kx-1)] ^= 0;
              } else {
                temp = (table2[(int)x[(k-1)*Mx+(kx-1)]-1]+
                        table2[(int)y[(ky-1)*My+(k-1)]-1])%(N-1);
                if (temp==0) {temp=(N-1);}
                z[(ky-1)*Mx+(kx-1)] ^= table1[ temp-1 ];
              } 
            } else {
              z[(ky-1)*Mx+(kx-1)] ^= gf_mul(x[(k-1)*Mx+(kx-1)],y[(ky-1)*My+(k-1)],m,p);
            }
          }
        }
      }
   } else if (strcmp(msg,"rdivide")==0) { /* mult. inverse of x*/ 
    /* technique is to raise each element to the 2^m-2 */
      plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
                                     mxGetDimensions(prhs[0]),mxUINT16_CLASS,0);
      z = (unsigned short *)mxGetData(plhs[0]);
      for (k=1; k<=(Mx*Nx); k++) {
         if (x[k-1]==0) {
            mexErrMsgTxt("Divide by 0 error");
         }
         if (TABLE_FLAG) {
            z[k-1] = table1[(N-1)-(int)table2[x[k-1]-1]-1];
         } else {
            z[k-1] = x[k-1];
            for (kx=2; kx<=((1<<m)-2); kx++) { 
               temp = z[k-1];
               z[k-1] = gf_mul(z[k-1],x[k-1],m,p);
               if (z[k-1]==1) {   /* found an inverse early */
                  z[k-1] = temp;
                  break;
               }
            }
         }
      }
   } else if (strcmp(msg,"power")==0) { /* raise x to the y */
      if ((Mx != My) || (Nx != Ny)) {
         mexErrMsgTxt("sizes of x, y don't match");
      }
      plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
                                     mxGetDimensions(prhs[0]),mxUINT16_CLASS,0);
      z = (unsigned short *)mxGetData(plhs[0]);
      for (k=1; k<=(Mx*Nx); k++) {
         if (x[k-1]==0) {
            if (y[k-1]==0)
              z[k-1] = 1;
            else
              z[k-1] = 0;
         } else {
            if (TABLE_FLAG) {
               temp = (table2[(int)x[k-1]-1]*(int)y[k-1]) %(N-1);
	       /* if temp is below zero,we went out of bounds, need to recompute */
	       if(temp<0)
	       {
		   /* recalculating modulo, to handle the integer overflow */
		   double foo = (double)table2[(int)x[k-1]-1]*(double)y[k-1];
		   int N1 = N-1;
		   while(foo > N1) { 
		       foo -= (N1);
		   }
		   temp = (int)foo;
	       }


               if (temp==0) {temp=(N-1);}
               z[k-1] = table1[ temp-1 ];
            } else {
               z[k-1] = 1;
               for (kx=1; kx<=y[k-1]; kx++) {
                  z[k-1] = gf_mul(z[k-1],x[k-1],m,p);
               }
            }
         }
      }
   } else {
      mexErrMsgTxt("msg must be 'plus','times','mtimes','rdivide', or 'power'.");   
   }

}

