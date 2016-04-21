/* 
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.4.4.1 $
 */

#ifndef UNIONFIND_H
#define UNIONFIND_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ufType 
{
    int *id;
    int *sz;
    int allocated_length;
    int num_nodes;
    int num_sets;
    int finalized;
}
ufType;

extern ufType *uf_init(int hint);
void uf_new_node(ufType *uf);
void uf_new_pair(ufType *uf, int p, int q);
int uf_renumber(ufType *uf, int first);
int uf_query_set(ufType *uf, int p);
void uf_destroy(ufType *uf);

#ifdef __cplusplus
}   /* extern "C" */
#endif

#endif /* UNIONFIND_H */
