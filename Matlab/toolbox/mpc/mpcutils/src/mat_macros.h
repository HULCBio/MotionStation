/* mat_macros.h: MPC Simulink/RTW S-Function - Macros
              
      Author: A. Bemporad, G. Bianchini
      Copyright 1986-2003 The MathWorks, Inc. 
      $Revision: 1.1.10.2 $  $Date: 2003/09/01 09:15:47 $   
*/


/* Matrix access macros */

/* Compute i-th term of matrix-by-vector product a*v adding to adder [i.e, a(i,:)*v] 
   nc: number of columns in a 
*/

#define MVP(a, v, i, nr, nc) for (j=0; j < nc; j++)  adder += a[i+j*nr] * v[j]

/* Compute i-th term of matrix-by-vector product a'*v adding to adder [i.e, a(:,i)'*v]
   nr: number of rows in a 
*/

#define MTVP(a, v, i, nr) for (j=0; j < nr; j++)  adder += a[j+i*nr] * v[j]

/* Compute i-th term of vector-by-matrix product v'*a adding to adder [i.e, v'*a(:,j)]
   nr: number of rows in a (very same thing as MTVP swapping i and j) 
*/

#define MVTP(a, v, j, nr) for (i=0; i < nr; i++)  adder += a[i+j*nr] * v[i]

/* Misc */ 

#define CLR adder=0.0


/* Misc Constants */ 

#define SOFTCONSTR 0   /* Optimization types */
#define HARDCONSTR 1
#define UNCONSTR   2


/* Debugging */

#define DISP_VEC(vec,n,name)   printf("%s=[",name); for (i=0;i<n;i++) printf("%g,",vec[i]); printf("]\n");          
#define DISP_MAT(mat,n,m,name) printf("%s=[",name); for (i=0;i<n;i++) {for (j=0;j<m;j++) printf("%g,",mat[i+n*j]); printf("\n");} printf("]\n");
#define DISP_ADDER(i)          printf("adder[%d]=%g\n",i,adder); 
