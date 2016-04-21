/*
 * File: _gf2m.h
 *       Header file for the _gf2m class
 *
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.3.4.4 $ $Date: 2004/04/12 23:01:55 $
 *
 */


#ifndef _GF2M_HEADER_
#define _GF2M_HEADER_

#include "string.h" // for memcpy
#include <vector>
#include <deque>
#include<math.h> /*for power */
#include "gfTables.h"
#include "gfTableManager.h"

using namespace std;

template<class T>
class _gf2m    {

public:

     _gf2m();
     ~_gf2m();
     _gf2m(int width, int newM, int newPoly);
     _gf2m(const _gf2m &A) ;

    int getM() const {return m;}
    void setM(int newM);

    double* getX() const {return x;};
    void setX(double *newX);
    void setX(double *newX, int width); 

    int getPrim_Poly() const { return prim_poly;};
    void setPrim_Poly(int newPoly);

    void setMandPoly(int newM, int newPoly);

    int getWidth() const {return width;} ;

    gfTables * getTables() const { return tables;};

    gfTableManager<T>* getTableManager() const  { return tableManager; }

    _gf2m & operator+= ( const _gf2m &A);
    _gf2m & operator=  ( const _gf2m &g);
    _gf2m & operator*= ( const _gf2m &A);
    _gf2m & operator^= ( const int Yd);

    /* Roots over a Galois field */
    _gf2m gf2mRoots();

    void multInv(const _gf2m &A);

    /* convolution, deconvolution */
    void conv(const _gf2m &A, const _gf2m &B);
    void deconv( const _gf2m & A, const _gf2m &B );

    int log(void);


private:

    double *x;			/* x is the data elements of the GF2M object           */
    int    m;			/* m is the order of the GF2M object                   */
    int    prim_poly;		/* prim_poly is the primitive polynomial               */
    gfTableManager<T> * tableManager; /* Table manager, will hand out pointers to the tables */
    gfTables * tables;		/* a pointer to the gfTables object                    */
    int width;			/* the width of the array */



};

/* Element by element Addition */
template<class T>
_gf2m<T> operator+ (const _gf2m<T> &A, const _gf2m<T> &B);

/* Element by element multplication */
template<class T>
_gf2m<T> operator* (const _gf2m<T> &A, const _gf2m<T> &B);

/* Raise every element of A to the power B */
template<class T>
_gf2m<T> operator^ (const _gf2m<T> &A, const int B);

/* Elenent by element division  */
template<class T>
_gf2m<T> operator/ (const _gf2m<T> &A, const _gf2m<T> &B);



template<class T>
_gf2m<T>::_gf2m()
{
    /* intialize everything to 0 */
   //set X = 0, it will be created in the set only.
    x = 0;

    /* the default will be M=2, prim_poly=7 */
    tableManager = gfTableManager<T>::Instance();
    tables = 0;
    setMandPoly(2,7);
    width = 1;
}
template<class T>
_gf2m<T>::~_gf2m()
{
    if(tables!=0){
	tables = 0;
    }
    if(x!=0){
	delete[]  x;
	x = 0;
    }
    tableManager->RemoveInstance();
}
template<class T>
_gf2m<T>::_gf2m(int newWidth, int newM, int newPoly)
{
    /* This constructor takes 3 arguments
    *  the length of the GF2M object, the M and primitive polynomial
    *  This constructor is designed to be called from Simulink, in mdlStart
    *  The data in the GF2M object will be set in mdlOutputs
    */

   x = new double[newWidth];

    tableManager = gfTableManager<T>::Instance();

    tables = tableManager->getTables(newM,newPoly);
    width = newWidth;
    setMandPoly(newM,newPoly);

}

template<class T>
_gf2m<T> & _gf2m<T>::operator=( const _gf2m<T>& g)
{
    if(this != &g)
    {
	m = g.getM();
	prim_poly = g.getPrim_Poly();
	width = g.getWidth();
	if(x==0) {
	 x = new double[g.getWidth()];
	}
	memcpy(x,g.getX(),width*sizeof(double));
	tableManager = g.getTableManager();
	tables = tableManager->getTables(m,prim_poly);
    }

    return *this;

}
template<class T>
_gf2m<T>::_gf2m(const _gf2m<T> &A)
{
    m=A.getM();
    prim_poly = A.getPrim_Poly();

    tableManager = gfTableManager<T>::Instance();
    tables = tableManager->getTables(m,prim_poly);

    width = A.getWidth();

    if(A.getX()!=0){
	x = new double[A.getWidth()];
	memcpy(x,A.getX(),width*sizeof(double));

    }
    else x = 0;

}

template<class T>
void _gf2m<T>::setX(double *newX)
{

    if(x==0){
     	x = new double[width];
    }

    if(newX != 0) {
        if(newX != x)
            memcpy(x,newX,width*sizeof(double));
    }
    else x = 0;
}

template<class T>
void _gf2m<T>::setX(double *newX,int newWidth)
{

    newWidth = (newWidth < width) ? newWidth : width;
    if(x==0){
     	x = new double[newWidth];
    }

    if(newX != 0) {
        if(newX != x)
            memcpy(x,newX,newWidth*sizeof(double));
    }
    else x = 0;
}

template<class T>
void _gf2m<T>::setM(int newM)
{

    /* set the value of M, if M has changed, delete
    * the tables, and create new ones
    */
    m = newM;

    if( (tables != 0) && (tables->getM() != newM)   )
    {
	tables = tableManager->getTables(m,prim_poly);
    }

}
template<class T>
void _gf2m<T>::setPrim_Poly(int newPoly)
{
    prim_poly = newPoly;
    if(  (tables != 0) && (tables->getPrim_Poly() != newPoly) )
    {
	tables = tableManager->getTables(m,prim_poly);
    }
}
template<class T>
void _gf2m<T>::setMandPoly(int newM, int newPoly)
{
    m = newM;
    prim_poly = newPoly;

    if ( (tables != 0) && ( (tables->getM() != newM)  || (tables->getPrim_Poly() != prim_poly ) ) )
    {
	tables = tableManager->getTables(m,prim_poly);
    }
}

template<class T>
_gf2m<T>& _gf2m<T>:: operator +=( const _gf2m<T> &A)
{
    /* this function will implement element by element addition */

    double *Yd = A.getX();

     if ( width != A.getWidth() ) {
       // mexErrMsgTxt("sizes of x, y don't match");
      }

     for (int k=1; k<=(width); k++) {
         x[k-1] = (unsigned short)x[k-1]^(unsigned short)Yd[k-1];  /* addition is just xor */
      }

    return *this;

}

template<class T>
_gf2m<T> & _gf2m<T>::operator *=(const _gf2m<T> &A)

{

    /* this function will implement element by element multiplication */

    /*get pointer to A's data */
    double *Yd = A.getX();

    /* get pointers to both tables */

    int * table1 = A.tables->getTable1();
    int * table2 = A.tables->getTable2();

    int temp;
    int N = (1<<m);   /* 2^m, just 1 right shifted m times */

     if ( width != A.getWidth() ) {
//        mexErrMsgTxt("sizes of x, y don't match");
      }

      for (int k=1; k<=(width); k++) {

            if ((x[k-1]==0)||(Yd[k-1]==0)) {
               x[k-1]=0;
            } else {

  	    temp = ((int)table2[(int)x[k-1]-1]+(int)table2[(int)Yd[k-1]-1])%(N-1);

               if (temp==0) {temp=(N-1);}
               x[k-1]=table1[ temp-1 ];
            }
	}
    return *this;
}
template<class T>
_gf2m<T> & _gf2m<T>::operator^= (const int Yd)
{

    /* Raises every element of this to the power of Yd */


    /* get pointers to both tables */
    int * table1 = tables->getTable1();
    int * table2 = tables->getTable2();

    int N = (1<<m);   /* 2^m, just 1 right shifted m times */
    int temp,k;

      for (k=1; k<=(width); k++) {
         if (x[k-1]==0) {
            if(Yd==0)
              x[k-1] = 1;
            else
              x[k-1] = 0;
         } else {
	       temp = (table2[(int)x[k-1]-1]*Yd) %(N-1);
               if (temp==0) {temp=(N-1);}
               x[k-1] = table1[ temp-1 ];

            }
         }

    return *this;
}

template<class T>
void _gf2m<T>::multInv(const _gf2m<T> &A)
{
    /* this function will be called as follows:
    * g1.multInv(g2) will make g1 be the multiplicitave inverse of g2
    */

    /* need to do some error checkin here */

    /* mult. inverse of x                               */
    /* technique is to raise each element to the 2^m-2  */
    /* returns the mult. inverse of x                   */


    /*get pointer to the array */
    double *Xd = (getX());
    double *Ad = A.getX();

    /* get pointers to both tables */

    int * table1 = A.getTables()->getTable1();
    int * table2 = A.getTables()->getTable2();
    width = A.getWidth();

    int k;
    int N = (1<<m);   /* 2^m, just 1 right shifted m times */


      for (k=1; k<=(width); k++) {
         if (Xd[k-1]==0) {
            //mexErrMsgTxt("Divide by 0 error");
         }

            Xd[k-1] = table1[(N-1)-(int)table2[(int)Ad[k-1]-1]-1];
         }

}



template<class T>
void _gf2m<T>::conv( const _gf2m<T> & A, const _gf2m<T> & B )
{
    /* Conv will work like this: g3->conv(g1,g2) will make g3 equal to the
    *  convolution of g1 and g2 */


   /* check that A and B have the same M and prim_poly */
    if( (A.getM() != B.getM()) || (A.getPrim_Poly() != B.getPrim_Poly()) )
    {
//	mexErrMsgTxt("M, Primitive Polynomial of x,y don't match");
    }


    int retValueWidth  = A.getWidth() + B.getWidth() - 1;

    /* if the size of retValueWidth does not match the size of this object
    *  delete x and reallocate an array of the correct size */
    if(retValueWidth != getWidth())
    {
	delete[] x;
	x = new double[retValueWidth];
	width = retValueWidth;
    }


    double * retX = getX();
    /* initialize retX to zero */
    for(int i=0;i<retValueWidth; i++){ retX[i] =0 ; }

    double * Ax = A.getX();
    double * Bx = B.getX();

    /* get pointers to both tables */

    int * table1 = A.getTables()->getTable1();
    int * table2 = A.getTables()->getTable2();
    int N = (1<<A.getM());



    int temp = 0;

    for (int k=0;k<A.getWidth();k++)
    {
    	for(int j=0;j<B.getWidth();j++)
    	{
    
    	    /* Multiply Ax[k] * Bx[j] */
    	    if( (Ax[k] == 0) || (Bx[j] == 0) ) temp = 0;
    
    	    else { temp = ((int)table2[(int)Ax[k]-1]+(int)table2[(int)Bx[j]-1])%(N-1);
    
    	    if (temp==0) {temp=(N-1);}
                temp=table1[ (int)temp-1 ];
    	    }
    
    	    retX[k+j] = (int)temp^(int)retX[k+j];
    	}
    }
}



template<class T>
_gf2m<T> operator+ (const _gf2m<T> &A, const  _gf2m<T> &B)
{
    _gf2m<T> R = A;
    return R+=B;
}
template<class T>
_gf2m<T> operator* (const _gf2m<T> &A, const _gf2m<T> &B)
{
    /* element by element multiplication */
    /* corresponds to  .* in MATLAB      */
    _gf2m<T> R = A;
    return R*=B;
}
template<class T>
_gf2m<T> operator^ (const _gf2m<T>&A, const int B)
{
    /* element by element power     */

    /* corresponds to .^ in MATLAB  */
    _gf2m<T> R = A;

    if(B<0) R.multInv(R);

    return R^=abs(B);
}
template<class T>
_gf2m<T> operator/ (  const _gf2m<T> &A, const _gf2m<T> &B)
{

    /* implements element by element right division   */
    /* corresponds to ./ in MATLAB                    */

    _gf2m<T> R=B;
    R.multInv(B);
    R = R*A;
    return R;
}


template<class T>
_gf2m<T> _gf2m<T>::gf2mRoots()
{
    /* This function will return the roots of the _gf2m object
    *  Usage:  _gf2m roots = A.roots();
    *  roots will be a _gf2m object containing the roots of A(also a _gf2m object) */

    vector<double> roots; /* roots will be a vector of doubles, to store the roots in */
    int currWidth = getWidth();

    /* make a dummy _gf2m object, to use to intialize some of the others */
    _gf2m dummy(1,getM(), getPrim_Poly());
    double temp = 0;
    dummy.setX(&temp);

    /* make an array of _gf2m objects to hold the values of i */
    _gf2m * d = new _gf2m[currWidth];
    /* set the arrays M and Poly, width and x */
    for(int n=0;n<currWidth;n++) { d[n] = dummy; }

    /* make an array of _gf2m objects, to hold the individual values of this _gf2m
    *  object. Needed in order to implement matrix multiplication */
    _gf2m *xx = new _gf2m[currWidth];

    for(int k=0;k<currWidth;k++){
    	xx[k] = dummy;
    	xx[k].setX(&getX()[k]);
    }

    _gf2m newPoly = *this;

    int i = 0;
    while(i< (pow((double)2,getM() ) ))
    {

    	_gf2m isRoot(1,getM(),getPrim_Poly());
    	isRoot.setX(&temp);
    
    	/* set all d's elements to i */
    	double *d_i;
    	for(int j=0;j<currWidth;j++)
    	{
    	    d_i= d[j].getX();
    	    *d_i = (double)i;
    	}
    
    	/* exponentiate each element of d */
    	for(int mpow=0;mpow<currWidth;mpow++) { d[mpow]^=mpow; }
    
    
    	/* multiply element by element, sum the results */
    	for(int q=0;q<currWidth;q++) { isRoot = isRoot + (d[q]*xx[q]); }
    
    	if(*isRoot.getX() == 0) {
    	    /* add it to the roots vector */
    	    roots.push_back(i);
    
    
    	    // deconvolve the root, and check again
    	    double factor[2] = {1, i};
    	    _gf2m theFactor(2,getM(),getPrim_Poly());
    	    theFactor.setX(factor);
    
            // Deconvolve by the inverse of factor
    	    theFactor.multInv(theFactor);
    	    newPoly.deconv(newPoly, theFactor);
    
    
    	    // set x to be the newPoly
    	    currWidth--;
    	    for(int q=0;q<currWidth;q++)
    	    {
        		double * newX = newPoly.getX();
        		xx[q].setX(&newX[q]);
    	    }
    	  i--;
    	}

	i++;
    }

    _gf2m retValue(roots.size(), getM(), getPrim_Poly());
    retValue.setX(&roots[0]);

    retValue.multInv(retValue);
    /* clean up, delete d and x */
    delete[] d;
    delete[] xx;
    return retValue;
}
template<class T>
void _gf2m<T>::deconv(const _gf2m<T> & A, const _gf2m<T> & B)
{
    /* deconv will work like this: C->conv(A,B) will make C equal to the
    *  deconvolution of A from B. - it does not find the remainder... only the quotient */


//    mexPrintf("Make a dummy _gf2m object, to use to intialize some of the others  \n");
    _gf2m dummy(1,getM(), getPrim_Poly());
    double temp = 0;
    dummy.setX(&temp);

    /* make an array of _gf2m objects to hold the individual values of A */
    int Awidth =  A.getWidth();
    deque<_gf2m> newA;
    /* set the arrays M and Poly, width and x */
    for(int n=0;n<Awidth;n++) {
    	newA.push_back(dummy);
    	newA[n].setX(&A.getX()[n]);
    
    }

    /* make an array of _gf2m objects to hold the individual values of B */
    int Bwidth = B.getWidth();
    _gf2m * newB = new _gf2m[B.getWidth()];
    /* set the arrays M and Poly, width and x */
    for(int m=0;m<Bwidth;m++) {
    	newB[m] = dummy;
    	newB[m].setX(&B.getX()[m]);
    }



    /* a vector to hold the values of the quotient */
//   int q_size = Awidth - Bwidth+1;
   vector<double> quotient;
//   quotient.reserve(q_size);
//   quotient[q_size-1] = 0;  // set the last one 

   for(int i=0;i<(Awidth - Bwidth+1); i++)
   {
        _gf2m tempA = newA[1];
        _gf2m tempB = newB[1];
        _gf2m coeff = newA[0]/newB[0];
    
    
    	quotient.push_back(*coeff.getX());
        for(int j=0;j<B.getWidth();j++)
        {
        	newA[j]= newA[j]+ coeff*newB[j];
        }
  	    newA.pop_front();
	}

	setX(&quotient[0],quotient.size());
	delete[] newB;

	width = quotient.size();
}

template<class T>
int _gf2m<T>::log()
{
	/* log returns the logarithm of the first element of A */
	int * tab1 = getTables()->getTable2();
        return  tab1[(int)getX()[0]-1];
}
#endif
