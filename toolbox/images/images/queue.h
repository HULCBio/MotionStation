/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/01/26 06:01:16 $
 */

#ifndef QUEUE_H
#define QUEUE_H

#include "sequence.h"

#ifdef __cplusplus
    extern "C" {
#endif

typedef Sequence_T Queue_T;

Queue_T queue_init(int itemsize, int hint);
void queue_free(Queue_T queue);
int queue_length(Queue_T queue);
void queue_put(Queue_T queue, void *item);
void queue_get(Queue_T queue, void *item);

#ifdef __cplusplus
    }   /* extern "C" */
#endif

#endif /* QUEUE_H */
