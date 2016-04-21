/* 
 * File: gfTables.h
 *       Header file for the gfTables class
 *       This class will store the tables needed for arithmetic
 *       operations over a gf2m field 
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 * $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:01:57 $
*/

#include <math.h>

#ifndef _gfTables_HEADER_
#define _gfTables_HEADER_

class gfTables {

public:

    gfTables(int M, int prim_poly);    
    ~gfTables();
    int  * getTable1() { return table1; };
    int  * getTable2() { return table2; };

    int getM() {return m_table;};
    void setM(int newM) {m_table = newM;};

    int getPrim_Poly() { return prim_poly_table;};
    void setPrim_Poly(int newPoly) { prim_poly_table = newPoly;};

private:
    
    /* Pointers to the 2 tables */
    int *table1;
    int *table2;


    /* store the M and prim_poly that identify this table */
    int m_table;
    int prim_poly_table;
    

    void createTables(int M, int prim_poly);
   

    /* Need a multiplication function, since the tables are generated
     *  using multiplication in a gf2m field. 
     */
   int gf2m_mul( int a,int b,int m, int p) const;
   
};

inline gfTables::gfTables(int M, int prim_poly)
{

    /* create the tables */
    createTables(M,prim_poly);

   setM(M);
   setPrim_Poly(prim_poly);
}

inline gfTables::~gfTables()
{

    if(table1!=0) { delete[] table1; table1=0;}
    if(table2!=0) { delete[] table2; table2=0;}
     
}

inline void gfTables::createTables(int M, int prim_poly)
{
    /* gfTables calculates the 2 tables needed for GF2M field operations */
    int pow2M = (int)pow((double)2,M);
    int i;
   table1 = new int[pow2M-1];
   table2 = new int [pow2M-1];


    int* ind;
    ind = new int[pow2M];
    
    //M: x1 = gf2m(zeros(1,2^m),m); ';  
    int * x1;
    x1  = new int[pow2M];

    // M:  x=gf2m(0:2^m-1,m)';  
    int * x;
    x=  new int[pow2M];
  
    //M: x=gf2m(0:2^m-1,m)'    
    for( i=0;i<pow2M;i++ ) { x[i]= i;}; 

    //M: x1(1)=1;
    x1[0] = 1;
    

    //M:   for k=1:2^m-1  x1(k+1)=x1(k)*x(3);  end 
    for(i=0;i<pow2M-1;i++){
	x1[i+1] = gf2m_mul(x1[i],x[2],M,prim_poly);
	}


    //M: ind=x1.x; ind=double(ind);ind(end)=[];
    for(i=0;i<pow2M-1;i++) {ind[i] = x1[i];}
    
    //M: x=0*ind;   //just set x = 0 here, do I even need to do this?
    for(i=0;i<pow2M;i++){ 
	x[i]=0;
	}

    //M: i=0:2^m-2; x(ind)=i;
    for(i=0;i<pow2M-1;i++){
	x[(int)ind[i]]=i;
	}

    for(i=1;i<pow2M;i++){
	table2[i-1] = x[i];
	table1[i-1] = x1[i];
	}    

delete[] x1;
delete[] x;
delete[] ind;
}

inline int gfTables::gf2m_mul(int a, int b, int m, int p) const
{

/*
 gf2m_mul multiply two field elements in GF(2^m)
 p is the primitive (irreducible) polynomial.
*/

 int y,r,k,out; 
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

#endif   

