/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/01/26 06:01:33 $
 */

/*
 * Implementation of Stack_T abstract data type.
 *
 * In this implementation the Stack_T is actually a
 * Sequence_T.
 *
 * Initialize a stack with stack_init, whose inputs
 * are the itemsize (in bytes) and a hint about how
 * many items to allocate space for initially.
 * 
 * Push an item on the stack using stack_push().
 *
 * Pop an item off the stack using stack_pop().
 *
 * stack_length() returns the number of items currently in the
 * stack.
 *
 * queue_free() deallocates the queue.
 */

static char rcsid[] = "$Id: stack.c,v 1.4.4.1 2003/01/26 06:01:33 batserve Exp $";

#include "stack.h"
#include "mex.h"

Stack_T stack_init(int itemsize, int hint)
{
    return(seq_init(itemsize, hint));
}

void stack_free(Stack_T stack)
{
    seq_free(stack);
}

int stack_length(Stack_T stack)
{
    return(seq_length(stack));
}

void stack_push(Stack_T stack, void *item)
{
    seq_addhi(stack, item);
}

void stack_pop(Stack_T stack, void *item)
{
    seq_remhi(stack, item);
}
