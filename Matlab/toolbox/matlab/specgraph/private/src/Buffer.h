/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
*/

/* $Revision: 1.4 $ */

#ifndef GFXTOOLS_BUFFER_INCLUDED // -*- C++ -*-
#define GFXTOOLS_BUFFER_INCLUDED

#include "Array.h"

template<class T>
class buffer : public array<T> {
protected:
    int fill;
public:
    buffer() { init(8); }
    buffer(int l) { init(l); }
    
    inline void init(int l) { array<T>::init(l); fill=0; }

    inline int add(const T& t);
    inline void reset();
    inline int find(const T&);
    inline T remove(int i);
    inline int addAll(const buffer<T>& buf);
    inline void removeDuplicates();

    inline int length() const { return fill; }
    inline int maxLength() const { return array<T>::len; } 
    //array<T>:: added here and 9 other places in this file 
    //because hp700 compiler complaining
};


template<class T>
inline int buffer<T>::add(const T& t)
{
    if( fill == array<T>::len )
	resize( array<T>::len*2 );

    array<T>::data[fill] = t;

    return fill++;
}

template<class T>
inline void buffer<T>::reset()
{
    fill = 0;
}

template<class T>
inline int buffer<T>::find(const T& t)
{
    for(int i=0;i<fill;i++)
	if( array<T>::data[i] == t )
	    return i;

    return -1;
}

template<class T>
inline T buffer<T>::remove(int i)
{
#ifdef SAFETY
    assert( i>=0 );
    assert( i<fill );
#endif

    fill--;
    T temp = array<T>::data[i];
    array<T>::data[i] = array<T>::data[fill];

    return temp;
}

template<class T>
inline int buffer<T>::addAll(const buffer<T>& buf)
{
    for(int i=0; i<buf.fill; i++)
	add(buf(i));

    return fill;
}

template<class T>
inline void buffer<T>::removeDuplicates()
{
    for(int i=0; i<fill; i++)
    {
	for(int j=i+1; j<fill; )
	{
	    if( array<T>::data[j] ==array<T>:: data[i] )
		remove(j);
	    else
		j++;
	}
    }
}

// GFXTOOLS_BUFFER_INCLUDED
#endif
