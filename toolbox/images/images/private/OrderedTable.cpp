//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/01/26 05:57:36 $
//

#include "OrderedTable.h"

//
// Constructor
//
// newTable        - array of table values; values must be monotonically increasing.
//                   The monotonically increasing restriction is NOT checked.
//
// newTableLength  - number of elements in the table.
//
OrderedTable::OrderedTable(const double *newTable, int newTableLength)
{
    setTable(newTable);
    setTableLength(newTableLength);
    setLastPosition(0);
}

//
// Given value, find k such that table[k] <= value < table[k+1].  Method returns k.
// If value is less than the first table entry, return k = -1.  If value is greater than
// or equal to the last table entry, return k = tableLength - 1.
//
int OrderedTable::findPosition(double value)
{
    const double *table = getTable();
    int tableLength = getTableLength();
    int low = getLastPosition();
    int high;
    int position;

    if (value < table[0])
    {
        position = -1;
    }
    else if (value >= table[tableLength - 1])
    {
        position = tableLength - 1;
    }
    else
    {
        //
        // Bracket the search value, looking either upward or downward in the table.
        //
        if (value >= table[low])
        {
            huntUp(table, tableLength, value, &low, &high);
        }
        else
        {
            huntDown(table, tableLength, value, &low, &high);
        }
        
        //
        // Value is now bracketed; move on the bisection search phase.
        //
        position = bisectionSearch(table, tableLength, value, low, high);
    }

    //
    // Cache the position found for use as the starting point of the next search.
    //
    setLastPosition( position < 0 ? 0 : position);

    return(position);
}

//
// Bracket a value in an ordered table by hunting upwards.
//
// Inputs:
// table          - pointer to array of table values
// tableLength    - number of table values
// value          - the value to be bracketed
// low            - starting point for the search upward
//
// Outputs:
// low            - low end of bracket interval
// high           - high end of bracket interval
// 
inline void OrderedTable::huntUp(const double *table, int tableLength, double value, int *low, int *high)
{
    int increment = 1;

    *high = *low + increment;
    while (value >= table[*high])
    {
        *low = *high;
        increment *= 2;
        *high = *low + increment;
        if (*high >= tableLength)
        {
            // The search has now reached past the end of the table.
            *high = tableLength;
            break;
        }
    }
}

//
// Bracket a value in an ordered table by hunting downwards.
//
// Inputs:
// table          - pointer to array of table values
// tableLength    - number of table values
// value          - the value to be bracketed
// low            - starting point for the search downward
//
// Outputs:
// low            - low end of bracket interval
// high           - high end of bracket interval
// 
inline void OrderedTable::huntDown(const double *table, int tableLength, double value, int *low, int *high)
{
    int increment = 1;

    *high = *low;
    *low -= 1;
    while (value < table[*low])
    {
        *high = *low;
        increment *= 2;
        *low = *high - increment;
        if (*low < 0)
        {
            // The search has now reached past the end of the table.
            *low = 0;
            break;
        }
    }
}

//
// Use bisection to find the position of a value in a table.
//
// Inputs:
// table          - pointer to array of table values
// tableLength    - number of table values
// value          - the value to be bracketed
// low, high      - interval to be searched; this method assumes that 
//                  table[low] <= value < table[high]; this assumption is
//                  not checked.
//
// Return:
// position       - such that table[position] <= value < table[position+1]
//
inline int OrderedTable::bisectionSearch(const double *table, int tableLength, double value, 
                                         int low, int high)
{
    int middle;

    while ((high - low) != 1)
    {
        middle = (high + low) / 2;
        if (value >= table[middle])
        {
            low = middle;
        }
        else
        {
            high = middle;
        }
    }

    return(low);
}

//
// Instance variable accessor methods.
//
void OrderedTable::setTable(const double * newTable)
{
    fTable = newTable;
}

void OrderedTable::setTableLength(int newTableLength)
{
    fTableLength = newTableLength;
}

void OrderedTable::setLastPosition(int newLastPosition)
{
    fLastPosition = newLastPosition;
}

inline int OrderedTable::getLastPosition(void)
{
    return fLastPosition;
}

inline const double * OrderedTable::getTable(void)
{
    return fTable;
}

inline int OrderedTable::getTableLength(void)
{
    return fTableLength;
}

