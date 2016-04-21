/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:11:39 $
 */

/*
 * Implementation of Sequence_T abstract data type.
 *
 * A sequence is a homogeneous dynamic array.  When you
 * create the sequence using seq_init() you specify the
 * size of each item in bytes as well as a desired starting
 * size for the array.
 *
 * You can set and get items at a particular zero-based
 * array offset using seq_set() and seq_get().
 *
 * You can remove array items from either the beginning
 * of the array (seq_remlo) or the end (seq_remhi).  You
 * can add array items from either the beginning of the array
 * (seq_addlo) or the end (seq_addhi).
 *
 * The array used for storing the sequence dynamically grows
 * itself as necessary when items are added.  It does not
 * (in the current implementation) ever shrink itself when
 * items are removed.
 *
 * seq_get, seq_set, seq_addhi, seq_addlo, seq_remhi, and
 * seq_remlo are all constant time operations on average.
 *
 * Destroy a Sequence_T with seq_free() when finished with it.
 */

static char rcsid[] = "$Id: sequence.c,v 1.4.4.2 2003/08/01 18:11:39 batserve Exp $";

#include <string.h>
#include "sequence.h"
#include "mex.h"

/*
 * Initialize sequence.  Inputs are itemsize (size of each item
 * stored in the sequence, in bytes) and hint (initially allocated
 * length (number of items, not bytes) of the sequence array.
 */
Sequence_T seq_init(int itemsize, int hint)
{
    Sequence_T new_seq;

    mxAssert(itemsize > 0, "");
    mxAssert(hint >= 0, "");

    if (hint == 0)
    {
        hint = 16;
    }
    
    new_seq = (Sequence_T) mxMalloc(sizeof(*new_seq));
    new_seq->array = (uint8_T *) mxMalloc(itemsize * hint);
    new_seq->seqlength = 0;
    new_seq->head = 0;
    new_seq->arraylength = hint;
    new_seq->itemsize = itemsize;
    
    return new_seq;
}

/*
 * Free sequence.
 */
void seq_free(Sequence_T seq)
{
    mxAssert(seq != NULL,"");
    mxAssert(seq->array != NULL,"");

    mxFree((void *) seq->array);
    seq->array = NULL;
    mxFree((void *) seq);
}

/*
 * Number of items currently stored in sequence.
 */
int seq_length(Sequence_T seq)
{
    mxAssert(seq != NULL,"");

    return seq->seqlength;
}

/*
 * Return the memory address of the sequence item whose
 * array index is i.
 */
static
void * seq_get_item_address(Sequence_T seq, int i)
{
    mxAssert(seq != NULL,"");
    mxAssert(seq->array != NULL,"");

    return (void *) (seq->array + ((seq->head + i)%seq->arraylength) *
                     seq->itemsize);
}

/*
 * Get the i-th sequence item.
 */
void seq_get(Sequence_T seq, int i, void *x)
{
    void *item_address;
    
    mxAssert(seq != NULL,"");
    mxAssert(x != NULL,"");
    mxAssert(i >= 0 && i < seq->seqlength,"");

    item_address = seq_get_item_address(seq, i);
    memcpy(x, item_address, seq->itemsize);
}

/*
 * Set the i-th sequence item.
 */
void seq_set(Sequence_T seq, int i, void *x)
{
    void *item_address;
    
    mxAssert(seq != NULL,"");
    mxAssert(x != NULL,"");
    mxAssert(i >= 0 && i < seq->seqlength,"");

    item_address = seq_get_item_address(seq, i);
    memcpy(item_address, x, seq->itemsize);
}

/*
 * Remove the last item in the sequence. This has
 * the effect of decrementing the sequence length.
 */
void seq_remhi(Sequence_T seq, void *x)
{
    void *item_address;
    int i;
    
    mxAssert(seq != NULL,"");
    mxAssert(x != NULL,"");
    mxAssert(seq->seqlength > 0,"");
    
    i = --seq->seqlength;
    item_address = seq_get_item_address(seq, i);
    memcpy(x, item_address, seq->itemsize);
}

/*
 * Remove the first item in the sequence. This has
 * the effect of decrementing the sequence length.
 * Item i becomes item i-1 after this operation.
 */
void seq_remlo(Sequence_T seq, void *x)
{
    int i = 0;
    void *item_address;
    
    mxAssert(seq != NULL,"");
    mxAssert(x != NULL,"");
    mxAssert(seq->seqlength > 0,"");
    
    item_address = seq_get_item_address(seq, i);
    seq->head = (seq->head + 1)%seq->arraylength;
    --seq->seqlength;
    memcpy(x, item_address, seq->itemsize);
}

/*
 * Grow the sequence storage array by a factor of 2.
 */
static
void seq_expand(Sequence_T seq)
{
    int n;
    void *realloc_result;
    
    mxAssert(seq != NULL,"");
    
    n = seq->arraylength;
    realloc_result = mxRealloc(seq->array, 2*n*seq->itemsize);
    if (realloc_result == NULL)
    {
        mexErrMsgIdAndTxt("Images:sequence:outOfMemory",
                          "%s", "Out of memory.");
    }
    
    seq->array = realloc_result;
    seq->arraylength = 2*n;

    if (seq->head > 0)
    {
        /*
         * Move items that were at the tail end of the array
         * to the tail end of the reallocated array.
         */
        void *old = seq_get_item_address(seq, 0);
        memcpy((uint8_T *) old + n*seq->itemsize, old, (n - seq->head)*seq->itemsize);
        seq->head += n;
    }
}

/*
 * Add item to the end of the sequence. This increments
 * the sequence length by 1.
 */
void seq_addhi(Sequence_T seq, void *x)
{
    int i;
    void *item_address;
    
    mxAssert(seq != NULL,"");
    mxAssert(x != NULL,"");
    
    if (seq->seqlength == seq->arraylength)
    {
        seq_expand(seq);
    }
    
    i = seq->seqlength++;
    item_address = seq_get_item_address(seq, i);
    memcpy(item_address, x, seq->itemsize);
}

/*
 * Add item to the beginning of the sequence. This
 * increments the sequence length by 1.  Item i
 * becomes item i+1 after this operation.
 */
void seq_addlo(Sequence_T seq, void *x)
{
    int i = 0;
    void *item_address;
    
    mxAssert(seq != NULL,"");
    mxAssert(x != NULL,"");
    
    if (seq->seqlength == seq->arraylength)
    {
        seq_expand(seq);
    }
    
    if (--seq->head < 0)
    {
        seq->head = seq->arraylength - 1;
    }
    
    seq->seqlength++;
    
    item_address = seq_get_item_address(seq, i);
    memcpy(item_address, x, seq->itemsize);
}
