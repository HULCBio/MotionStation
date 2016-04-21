/* 
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:59:13 $
 * 
 * Core algorithms for binary dilation and erosion.
 */

static char rcsid[] = "$Id: dilate_erode_binary.cpp,v 1.1.6.1 2003/01/26 05:59:13 batserve Exp $";

#include "morphmex.h"

/*
 * dilate_logical
 * Perform binary dilation on a logical array.
 *
 * Inputs
 * ======
 * In            - pointer to first element of input array
 * num_elements  - number of elements in input and output arrays
 * walker        - neighborhood walker representing the structuring element
 *
 * Output
 * ======
 * Out           - pointer to first element of output array
 */
void dilate_logical(mxLogical *In, mxLogical *Out, int num_elements,
                         NeighborhoodWalker_T walker)
{
    int p;
    int q;

    for (p = 0; p < num_elements; p++)
    {
        if (In[p])
        {
            nhSetWalkerLocation(walker, p);
            while (nhGetNextInboundsNeighbor(walker, &q, NULL))
            {
                Out[q] = 1;
            }
        }
    }
}


/*
 * erode_logical
 * Perform binary erosion on a logical array.
 *
 * Inputs
 * ======
 * In            - pointer to first element of input array
 * num_elements  - number of elements in input and output arrays
 * walker        - neighborhood walker representing the structuring element
 *
 * Output
 * ======
 * Out           - pointer to first element of output array
 */
void erode_logical(mxLogical *In, mxLogical *Out, int num_elements,
                        NeighborhoodWalker_T walker)
{
    int p;
    int q;

    for (p = 0; p < num_elements; p++)
    {
        Out[p] = 1;
        nhSetWalkerLocation(walker, p);
        while (nhGetNextInboundsNeighbor(walker, &q, NULL))
        {
            if (In[q] == 0)
            {
                Out[p] = 0;
                break;
            }
        }
    }
}
