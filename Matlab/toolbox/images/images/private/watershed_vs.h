/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.2 $  $Date: 2003/01/26 06:01:05 $
 */

/*
 * This file contains the function body for the watershed algorithm.
 * By #defining TYPE and #including this file, a module can instantiate
 * this function for a particular numeric type.  #define DO_NAN_CHECK
 * before #including this file to enable runtime checks for NaNs, which
 * are not allowed.  DO_NAN_CHECK is only recommended if TYPE is float
 * or double.
 *
 * Algorithm reference: L. Vincent and P. Soille, "Watershed in digital 
 * spaces: An efficient algorithm based on immersion simulations," IEEE
 * Transactions on Pattern Analysis and Machine Intelligence, vol. 13,
 * n. 6, 1990, pp. 583-598.  That algorithm has been modified as noted
 * below.
 */

/*
 * void compute_watershed_vs(TYPE *I, int N, NeighborWalker_T walker,
 *                           double *sort_index, double *L)
 */
{
    int current_label = 0;
    Queue_T pixel_queue;
    int32_T *dist;
    int32_T closest_dist;
    int32_T closest_label_value;
    bool closest_label_value_is_unique;
    int32_T fictitious = FICTITIOUS;
    int32_T wshed = WSHED;
    int k;
    int num_processed_pixels;
    int k1;
    int k2;
    int mask = MASK;
    int p;
    int q;
    int r;
    int current_distance;
    TYPE current_level;
    

#ifdef DO_NAN_CHECK
    for (k = 0; k < N; k++)
    {
        if (mxIsNaN(I[k]))
        {
            mexErrMsgIdAndTxt("Images:watershed:expectedNonnan", "%s",
                              "Input image may not contain NaNs.");
        }
    }
#endif /* DO_NAN_CHECK */

    /*
     * If the input array is empty, there's nothing to do here.
     */
    if (N == 0)
    {
        return;
    }
    
    /*
     * Initialize output array.
     */
    for (k = 0; k < N; k++)
    {
        L[k] = INIT;
    }
    
    /*
     * Initialize the pixel queue.
     */
    pixel_queue = queue_init(sizeof(int32_T), 32);

    /*
     * Initialize the distance array, filling it with zeros via mxCalloc.
     */
    dist = (int32_T *)mxCalloc(N, sizeof(*dist));

    num_processed_pixels = 0;
    while (num_processed_pixels < N)
    {
        /*
         * Find the next set of pixels that all have the same value.
         */
        k1 = num_processed_pixels;
        current_level = I[(int) sort_index[k1]];
        k2 = k1;
        do
        {
            k2++;
        } 
        while ((k2 < N) && (I[(int) sort_index[k2]] == current_level));
        k2--;

        /*
         * Mask all image pixels whose value equals current_level.
         */
        for (k = k1; k <= k2; k++)
        {
            p = (int) sort_index[k];
            L[p] = mask;
            nhSetWalkerLocation(walker, p);
            while (nhGetNextInboundsNeighbor(walker, &q, NULL))
            {
                if ((L[q] > 0) || (L[q] == wshed))
                {
                    /*
                     * Initialize queue with neighbors at current_level
                     * of current basins or watersheds.
                     */
                    dist[p] = 1;
                    queue_put(pixel_queue, &p);
                    break;
                }
            }
            num_processed_pixels++;
        }

        current_distance = 1;
        queue_put(pixel_queue, &fictitious);

        /*
         * Extend the basins.
         */
        while (true)
        {
            queue_get(pixel_queue, &p);
            if (p == fictitious)
            {
                if (queue_length(pixel_queue) == 0)
                {
                    break;
                }
                else
                {
                    queue_put(pixel_queue, &fictitious);
                    current_distance++;
                    queue_get(pixel_queue, &p);
                }
            }

            /*
             * NOTE: the code from here down to "detect and process
             * new minima" is a modified version of the algorithm originally 
             * published in Vincent and Soille's paper.  That algorithm
             * could make several changes to L[p] during a single
             * sweep of its neighbors, which sometimes results in incorrect
             * labeling.  This seems to be particularly a problem in
             * higher dimensions with the correspondingly larger number
             * of neighbors.  Here the algorithm is changed to make a
             * sweep of the neighborhood, accumulating key information
             * about it configuration, and then, after the neighborhood
             * sweep is finished, make one and only one change to L[p].
             */

            /*
             * Find the labeled or watershed neighbors with the closest
             * distance.  At the same time, put any masked neighbors
             * whose distance is 0 onto the queue and reset their distance
             * to 1.
             */
            closest_dist = MAX_int32_T;
            closest_label_value = 0;
            closest_label_value_is_unique = true;
            nhSetWalkerLocation(walker, p);
            while (nhGetNextInboundsNeighbor(walker, &q, NULL))
            {
                if ((L[q] > 0) || (L[q] == WSHED))
                {
                    if (dist[q] < closest_dist)
                    {
                        closest_dist = dist[q];
                        if (L[q] > 0)
                        {
                            closest_label_value = (int32_T)L[q];
                        }
                    }
                    else if (dist[q] == closest_dist)
                    {
                        if (L[q] > 0)
                        {
                            if ((closest_label_value > 0) &&
                                (L[q] != closest_label_value))
                            {
                                closest_label_value_is_unique = false;
                            }
                            closest_label_value = (int32_T)L[q];
                        }
                    }
                }

                else if ((L[q] == MASK) && (dist[q] == 0))
                {
                    /*
                     * q is a plateau pixel.
                     */
                    dist[q] = current_distance + 1;
                    queue_put(pixel_queue, &q);
                }
            }

            /*
             * Label p.
             */
            if ((closest_dist < current_distance) && (closest_label_value > 0))
            {
                if (closest_label_value_is_unique && 
                    ((L[p] == MASK) || (L[p] == WSHED)))
                {
                    L[p] = closest_label_value;
                }
                else if (! closest_label_value_is_unique ||
                         (L[p] != closest_label_value))
                {
                    L[p] = WSHED;
                }
            }
            else if (L[p] == MASK)
            {
                L[p] = WSHED;
            }
        }

        /*
         * Detect and process new minima at current_level.
         */
        for (k = k1; k <= k2; k++)
        {
            p = (int) sort_index[k];
            dist[p] = 0;
            if (L[p] == mask)
            {
                /*
                 * p is inside a new minimum.
                 */
                current_label++;  /* create a new label */
                queue_put(pixel_queue, &p);
                L[p] = current_label;
                while (queue_length(pixel_queue) > 0)
                {
                    queue_get(pixel_queue, &q);

                    /*
                     * Inspect neighbors of q.
                     */
                    nhSetWalkerLocation(walker, q);
                    while (nhGetNextInboundsNeighbor(walker, &r, NULL))
                    {
                        if (L[r] == mask)
                        {
                            queue_put(pixel_queue, &r);
                            L[r] = current_label;
                        }
                    }
                }
            }
        }
    }

    mxAssert(queue_length(pixel_queue) == 0, "");
    queue_free(pixel_queue);
    mxFree(dist);
}

#undef TYPE
#undef DO_NAN_CHECK
