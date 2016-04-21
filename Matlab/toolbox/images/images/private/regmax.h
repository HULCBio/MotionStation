/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/05/03 17:52:16 $
 */

/*
 * This file contains the function body for the image regional maximum
 * algorithm.  By #defining TYPE and T_MIN and #including this file,
 * a module can instantiate this function for a particular numeric
 * type.  To instantiate this function for doubles, for example, #define
 * TYPE to be double.  #define DO_NAN_CHECK to enable runtime checks for
 * NaNs, which are not allowed.  The NaN check is only necessary if TYPE
 * is #defined to be float or double.
 *
 * Algorithm reference: E. Breen and R. Jones, "Attribute openings,
 * thinnings, and granulometries," Computer Vision and Image Understanding,
 * vol 64 n 3, pp. 337-389.  Implementation here follows the description
 * in P. Soille, Morphological Image Analysis:  Principles and Applications,
 * Springer, 1999, p. 169.
 *
 * "A fast algorithm for setting the minimum image value t_min all image
 * pixels which does [sic] not belong to a regional maximum has been
 * proposed in (Breen & Jones, 1996).  The input image f is first copied
 * into the output image g (step 1).  The procedure continues by scanning
 * the image (step 2) and checking, for each pixel of g having a value
 * different from t_min (step 3), whether it has a neighbor of higher
 * intensity value (step 4).  If yes, then all pixels connected to this
 * pixel and having the same intensity are set ot zero (step 5)."
 *
 * 13-Jul-2000 --- I found a problem with the algorithm described above.
 * Basically, using t_min as a flag to indicate which pixels have already
 * been processed leads to some problems with pixels that start out equal
 * to t_min.  Now I initialize BW to be all ones, and then I use BW[p] == 0
 * as the flag to indicate that pixel p has already been processed.
 * -SLE
 */

{
    TYPE *F = (TYPE *) prF_in;
    TYPE val;
    Stack_T stack;
    int p;
    int q;
    int pp;
    int qq;
    bool found;
    
#ifdef DO_NAN_CHECK
    for (p = 0; p < num_elements; p++)
    {
        if (mxIsNaN(F[p]))
        {
            mexErrMsgIdAndTxt("Images:imregionalmax:expectedNonNaN",
                              "%s",
                              "Input image may not contain NaNs.");
        }
    }
#endif /* DO_NAN_CHECK */

    stack = stack_init(sizeof(q), 0);

    /*
     * Initialize output to all ones.
     */
    for (p = 0; p < num_elements; p++)
    {
        BW[p] = 1;
    }

    /*
     * Scan F in raster order.
     *
     * "For each pixel p in G"
     */
    for (p = 0; p < num_elements; p++)
    {
        /*
         * "If pixel p hasn't already been processed"
         */
        if (BW[p] != 0)
        {
            /*
             * See if any neighbors of p have a higher intensity.
             */
            found = false;
            nhSetWalkerLocation(walker, p);
            while (nhGetNextInboundsNeighbor(walker, &q, NULL))
            {
                if (F[q] > F[p])
                {
                    found = true;
                    break;
                }
            }
            
            /*
             * "If there is a neighbor q such that F[q] > F[p] ..."
             */
            if (found)
            {
                /*
                 * "... then set all BW pixels connected to p and having
                 * the same intensity to 0."
                 */
                val = F[p];
                stack_push(stack, &p);
                BW[p] = 0;
                while (stack_length(stack) > 0)
                {
                    stack_pop(stack, &pp);
                    nhSetWalkerLocation(walker, pp);
                    while (nhGetNextInboundsNeighbor(walker, &qq, NULL))
                    {
                        if ((BW[qq] != 0) && (F[qq] == val))
                        {
                            stack_push(stack, &qq);
                            BW[qq] = 0;
                        }
                    }
                }
            }
        }
    }

    stack_free(stack);
}
