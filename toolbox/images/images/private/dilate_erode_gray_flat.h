/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/01/26 05:59:15 $
 *
 * This file contains a function body for implementing flat grayscale
 * erosion and dilation.  It can be used to instantiate various
 * functions for erosion and dilation on different numeric types
 * by #defining TYPE, COMPARE_OP, and INIT_VAL.  Note that implementing
 * dilation properly with this function body requires passing in
 * a neighborhood walker constructed from a reflected neighborhood.
 */

(TYPE *In, TYPE *Out, int num_elements, NeighborhoodWalker_T walker)
{
    int p;
    int q;
    TYPE val;
    TYPE init_val = INIT_VAL;
    TYPE new_val;
    
    for (p = 0; p < num_elements; p++)
    {
        val = INIT_VAL;
        nhSetWalkerLocation(walker, p);
        while (nhGetNextInboundsNeighbor(walker, &q, NULL))
        {
            new_val = In[q];
            if (new_val COMPARE_OP val)
            {
                val = new_val;
            }
        }
        Out[p] = val;
    }
}

#undef TYPE
#undef COMPARE_OP
#undef INIT_VAL
