/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2003/05/03 17:52:15 $
 */

/*
 * This file contains the function body for the image reconstruction
 * algorithm.  By #defining TYPE and #including this file, a module can
 * instantiate this function for a particular numeric type.  To
 * instantiate this function for doubles, for example, #define TYPE to
 * be double.  #define DO_NAN_CHECK to enable runtime checks for NaNs,
 * which are not allowed.  The NaN check is only necessary if TYPE
 * is #defined to be float or double.
 *
 * Algorithm reference: Luc Vincent, "Morphological Grayscale Reconstruction
 * in Image Analysis: Applications and Efficient Algorithms," IEEE
 * Transactions on Image Processing, vol. 2, no. 2, April 1993, pp. 176-201.
 *
 * The algorithm used here is "fast hybrid grayscale reconstruction,"
 * described as follows on pp. 198-199:
 *
 * I: mask image (binary or grayscale)
 * J: marker image, defined on domain D_I, J <= I.
 *    Reconstruction is determined directly in J.
 *
 * Scan D_I in raster order:
 *   Let p be the current pixel;
 *   J(p) <- (max{J(q),q member_of N_G_plus(p) union {p}}) ^ I(p)
 *       [Note that ^ here refers to "pointwise minimum.]
 *
 * Scan D_I in antiraster order:
 *   Let p be the current pixel;
 *   J(p) <- (max{J(q),q member_of N_G_minus(p) union {p}}) ^ I(p)
 *       [Note that ^ here refers to "pointwise minimum.]
 *   If there exists q member_of N_G_minus(p) such that J(q) < J(p) and
 *       J(q) < I(q), then fifo_add(p)
 *
 * Propagation step:
 *   While fifo_empty() is false
 *   p <- fifo_first()
 *   For every pixel q member_of N_G(p):
 *     If J(q) < J(p) and I(q) ~= J(q), then
 *       J(q) <- min{J(p),I(q)}
 *       fifo_add(q)
 */

{
    TYPE *J = (TYPE *) prJ_in;
    TYPE *I = (TYPE *) prI_in;
    TYPE Jp;
    TYPE Jq;
    TYPE Iq;
    TYPE maxpixel;
    int p;
    int q;
    int k;
    Queue_T queue;

#ifdef DO_NAN_CHECK
    for (k = 0; k < num_elements; k++)
    {
        if (mxIsNaN(J[k]) || mxIsNaN(I[k]))
        {
            mexErrMsgIdAndTxt("Images:imreconstruct:containsNaN",
                              "%s",
                              "MARKER and MASK may not contain NaNs.");
        }
    }
#endif /* DO_NAN_CHECK */

    /*
     * Enforce the requirement that J <= I.  We need to check this here,
     * because if it isn't true the algorithm might not terminate.
     */
    for (k = 0; k < num_elements; k++)
    {
        if (J[k] > I[k])
        {
            mexErrMsgIdAndTxt("Images:imreconstruct:markerGreaterThanMask",
                              "%s", "MARKER pixels must be <= MASK pixels.");
        }
    }
    
    queue = queue_init(sizeof(p), 0);

    /*
     * First pass,  Scan D_I in raster order (upper-left to lower-right,
     * along the columns):
     */
    for (p = 0; p < num_elements; p++)
    {
        /*
         * "Let p be the current pixel"
         * "J(p) <- (max{J(q),q member_of N_G_plus(p) union {p}}) ^ I(p)"
         */

        /*
         * Find the maximum value of the (y,x) pixel
         * plus all the pixels in the "plus" neighborhood 
         * of (y,x).
         */
        maxpixel = J[p];
        nhSetWalkerLocation(trailing_walker, p);
        while (nhGetNextInboundsNeighbor(trailing_walker, &q, NULL))
        {
            if (J[q] > maxpixel)
            {
                maxpixel = J[q];
            }
        }

        /*
         * Now set the (y,x) pixel of image J to the minimum
         * of maxpixel and the (y,x) pixel of image I.
         */
        if (maxpixel < I[p])
        {
            J[p] = maxpixel;
        }
        else
        {
            J[p] = I[p];
        }
    }

    /*
     * Second pass,  Scan D_I in antiraster order (lower-right to upper-left,
     * along the columns):
     */
    for (p = num_elements - 1; p >= 0; p--)
    {
        /*
         * "Let p be the current pixel"
         * "J(p) <- (max{J(q),q member_of N_G_minus(p) union {p}}) ^ I(p)"
         */

        /*
         * Find the maximum value of the (y,x) pixel
         * plus all the pixels in the "minus" neighborhood 
         * of (y,x).
         */
        maxpixel = J[p];
        nhSetWalkerLocation(leading_walker, p);
        while (nhGetNextInboundsNeighbor(leading_walker, &q, NULL))
        {
            if (J[q] > maxpixel)
            {
                maxpixel = J[q];
            }
        }
    
        /*
         * Now set the (y,x) pixel of image J to the minimum
         * of maxpixel and the (y,x) pixel of image I.
         */
        if (maxpixel < I[p])
        {
            J[p] = maxpixel;
        }
        else
        {
            J[p] = I[p];
        }
        
        /* 
         * "If there exists q member_of N_G_minus(p) 
         * such that J(q) < J(p) and J(q) < I(q), then fifo_add(p)"
         */
        nhSetWalkerLocation(leading_walker, p);
        while (nhGetNextInboundsNeighbor(leading_walker, &q, NULL))
        {
            if ((J[q] < J[p]) &&
                (J[q] < I[q]))
            {
                queue_put(queue, &p);
                break;
            }
        }
    }

    /*
     * "Propagation step:
     * While fifo_empty() is false"
     */
    while (queue_length(queue) > 0)
    {
        /*
         * "p <= fifo_first()"
         */
        queue_get(queue, &p);
        Jp = J[p];

        /*
         * "For every pixel q member_of N_g(p):"
         */
        nhSetWalkerLocation(walker, p);
        while (nhGetNextInboundsNeighbor(walker, &q, NULL))
        {
            /* 
             * "If J(q) < J(p) and I(q) ~= J(q), then
             *    J(q) <- min{J(p),I(q)}
             *    fifo_add(q)"
             */
            Jq = J[q];
            Iq = I[q];
            if ((Jq < Jp) && (Iq != Jq))
            {
                if (Jp < Iq)
                {
                    J[q] = Jp;
                }
                else
                {
                    J[q] = Iq;
                }
                queue_put(queue, &q);
            }
        }
    }

    queue_free(queue);
}
