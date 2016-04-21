/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $  $Date: 2003/01/26 06:01:34 $
 */

#ifndef STACK_H
#define STACK_H

#include "sequence.h"

#ifdef __cplusplus
    extern "C" {
#endif

typedef Sequence_T Stack_T;

Stack_T stack_init(int itemsize, int hint);
void stack_free(Stack_T stack);
int stack_length(Stack_T stack);
void stack_push(Stack_T stack, void *item);
void stack_pop(Stack_T stack, void *item);

#ifdef __cplusplus
    }   /* extern "C" */
#endif

#endif /* STACK_H */
