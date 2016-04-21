/* 
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $
 */

#include "unionfind.h"
#include "mex.h"

#define DEFAULT_ALLOCATED_LENGTH 16
#define REALLOC_FACTOR 2

static char rcsid[] = "$Id: unionfind.c,v 1.4.4.1 2003/01/26 06:01:00 batserve Exp $";

ufType *uf_init(int hint)
{
    ufType *uf = NULL;

    if (hint <= 0)
    {
        hint = DEFAULT_ALLOCATED_LENGTH;
    }

    uf = (ufType *) mxCalloc(1, sizeof(*uf));
    uf->id = (int *) mxCalloc(hint, sizeof(*(uf->id)));
    uf->sz = (int *) mxCalloc(hint, sizeof(*(uf->sz)));
    uf->allocated_length = hint;
    uf->num_nodes = 0;
    uf->num_sets = 0;
    uf->finalized = false;

    return uf;
}

void uf_new_node(ufType *uf)
{
    if (uf->num_nodes >= uf->allocated_length)
    {
        uf->allocated_length *= REALLOC_FACTOR;
        uf->id = (int *) mxRealloc(uf->id, uf->allocated_length * sizeof(int));
        uf->sz = (int *) mxRealloc(uf->sz, uf->allocated_length * sizeof(int));
    }

    uf->num_nodes++;
    uf->id[uf->num_nodes - 1] = uf->num_nodes - 1;
    uf->sz[uf->num_nodes - 1] = 1;
}

int uf_find(ufType *uf, int p)
{
    int i;
    int t;
    int *id = uf->id;

    mxAssert(p < uf->num_nodes,"");
    
    for (i = p; i != id[i]; i = id[i])
    {
        t = i;
        i = id[id[t]];
        id[t] = i;
    }

    return i;
}

static
void uf_union(ufType *uf, int p, int q)
{
    if (uf->sz[p] < uf->sz[q])
    {
        uf->id[p] = q;
        uf->sz[q] += uf->sz[p];
    }
    else
    {
        uf->id[q] = p;
        uf->sz[p] += uf->sz[q];
    }
}

void uf_new_pair(ufType *uf, int p, int q)
{
    int i;
    int j;

    mxAssert(p >= 0,"");
    mxAssert(q >= 0,"");
    mxAssert(uf,"");
    mxAssert(! uf->finalized,"");

    i = uf_find(uf, p);
    j = uf_find(uf, q);
    if (i != j)
    {
	uf_union(uf, i, j);
    }
}

int uf_renumber(ufType *uf, int first)
{
    int k;
    int counter = first;

    uf->finalized = true;

    for (k = 0; k < uf->num_nodes; k++)
    {
        if (uf->id[k] == k)
        {
            uf->sz[k] = counter++;
        }
    }

    uf->num_sets = counter - first;

    return uf->num_sets;
}

int uf_query_set(ufType *uf, int p)
{
    int k;
    int *id = uf->id;

    mxAssert(uf->finalized,"");

    k = uf_find(uf, p);
    return uf->sz[k];
}

void uf_destroy(ufType *uf)
{
    mxAssert(uf, "");

    uf->id = NULL;
    uf->sz = NULL;
    
    mxFree(uf->id);
    mxFree(uf->sz);
}
