/*
 * File: gfTableManger.h
 *       Header and Implementation for the gfTablemanager class.
 *
 *   This class will manage the gfTables, it will ensure that only 
 *   1 table of any type is in memory at any given time 
 *   The table manager will hold a list of all the tables.
 *   The GF2M objects will ask for pointers to the these tables
 *   If the tables don't exist, the manager will create the tables
 *   If the tables do exist, the table manager will return a pointer to them
 *
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.3.4.2 $ $Date: 2004/04/12 23:01:56 $
 */

#ifndef _GFTABLEMANAGER_HEADER_
#define _GFTABLEMANAGER_HEADER_

/* disable msvc's warning */
#pragma warning (disable: 4786)
#include <map>
#include <algorithm>
using namespace std;

#include "gfTables.h"

typedef map <pair<int, int >, gfTables *> gfTableMap;

template<class T>
class gfTableManager
{
public:
    static gfTableManager * Instance();
    gfTables * getTables(int M, int Prim_Poly);
    static void RemoveInstance();
    ~gfTableManager();  // non-virtual

protected:
    gfTableManager();
    gfTableManager(const gfTableManager&);
    gfTableManager & operator= (const gfTableManager &);
private:
    static gfTableManager * theInstance;
    static int numInstances;

    gfTableMap tableMap;
  
    

};

template<class T>
    gfTableManager<T> *gfTableManager<T>::theInstance = 0;
template<class T>
int gfTableManager<T>::numInstances = 0;

template<class T>
gfTableManager<T> *gfTableManager<T>::Instance()
{
    numInstances++;
    if(theInstance == 0)
    {
    	theInstance = new gfTableManager;
    }

    return theInstance;
}
template<class T>
gfTableManager<T>::gfTableManager()
{
    theInstance = 0;  // just to be sure upon reconstruction of this class
}

template<class T>
gfTableManager<T>::~gfTableManager()
{
    /* destroy all the tables (in two steps: delete and clear, see Josuttis, page 205) */    
  
    //erase the entire map.
    if(--numInstances == 0)
    {
	    // First: delete the table entries that the gfTables pointers are pointing to
    	for( gfTableMap::iterator tblMapItr = tableMap.begin(); 
    	     tblMapItr != tableMap.end() ;  tblMapItr++ )
    	{
    		delete tblMapItr->second; 
    	}
    	
    	// Second: clear out the collection. This is necessary map maintainance
    	tableMap.clear();
    	
    	// reset this instance
        theInstance  = 0; 
    }
}

template<class T>
gfTables * gfTableManager<T>::getTables(int M, int Prim_Poly)
{

    /* find the index that has the contains the M, prim_poly pair we're looking for */
   gfTableMap::iterator Index  = tableMap.find( make_pair(M, Prim_Poly) );
    

    /* if Index == tableMap.end, then the tables we want don't exist yet 
     *  create them and return a pointer to them 
     */
    if( Index == tableMap.end())
    {
	gfTables * newTable = new gfTables(M, Prim_Poly);	
	tableMap.insert( gfTableMap::value_type ( make_pair(M,Prim_Poly), newTable));	
	return newTable;
    }

     else return tableMap[ make_pair(M,Prim_Poly)];

}
template<class T>
void gfTableManager<T>::RemoveInstance()
{
    if(numInstances==1)
    {	
	delete theInstance;
    }
    else numInstances--;
}

#endif





