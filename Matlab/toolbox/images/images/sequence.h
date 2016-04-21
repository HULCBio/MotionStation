/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/01/26 06:01:32 $
 */

#ifndef SEQUENCE_H
#define SEQUENCE_H

#include "mex.h"

#ifdef __cplusplus
    extern "C" {
#endif

typedef struct Sequence_tag
{
    uint8_T *array;
    int itemsize;
    int seqlength;
    int arraylength;
    int head;
} *Sequence_T;

Sequence_T seq_init(int itemsize, int hint);
void seq_free(Sequence_T seq);
int seq_length(Sequence_T seq);

void seq_get(Sequence_T seq, int i, void *x);
void seq_set(Sequence_T seq, int i, void *x);

void seq_addlo(Sequence_T seq, void *x);
void seq_addhi(Sequence_T seq, void *x);

void seq_remlo(Sequence_T seq, void *x);
void seq_remhi(Sequence_T seq, void *x);

#ifdef __cplusplus
    }   /* extern "C" */
#endif


#endif /* SEQUENCE_H */

