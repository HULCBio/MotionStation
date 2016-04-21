/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/01/26 06:01:15 $
 */

/*
 * Implementation of Queue_T abstract data type.
 *
 * In this implementation the Queue_T is actually a
 * Sequence_T.
 *
 * Initialize a queue with queue_init, whose inputs
 * are the itemsize (in bytes) and a hint about how
 * many items to allocate space for initially.
 * 
 * Add an item to the back of the queue using queue_put().
 *
 * Remove the item at the front of the queue using queue_get().
 *
 * queue_length() returns the number of items currently in the
 * queue.
 *
 * queue_free() deallocates the queue.
 */

static char rcsid[] = "$Id: queue.c,v 1.4.4.1 2003/01/26 06:01:15 batserve Exp $";

#include "queue.h"
#include "mex.h"

Queue_T queue_init(int itemsize, int hint)
{
    return(seq_init(itemsize, hint));
}

void queue_free(Queue_T queue)
{
    seq_free(queue);
}

int queue_length(Queue_T queue)
{
    return(seq_length(queue));
}

void queue_put(Queue_T queue, void *item)
{
    seq_addhi(queue, item);
}

void queue_get(Queue_T queue, void *item)
{
    seq_remlo(queue, item);
}
