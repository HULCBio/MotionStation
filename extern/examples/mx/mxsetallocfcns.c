/*=================================================================
 * mxsetallocfcns.c
 * 
 * This example demonstrates mxSetAllocFcns.
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2000 The MathWorks, Inc.
 * All rights reserved.
 *=================================================================*/

/* $Revision: 1.4 $ */
#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"

void *my_calloc(size_t n, size_t  size)
{
  void  *ptr;
  
  printf("Calloc Proc.\n");
  
  if ((n <= 0) || (size <= 0))
    return NULL;
  else  {
    ptr = calloc(n, size);
    return(ptr);
  }
}

void my_free(void *ptr)
{
  printf("Free Proc.\n");
  if (ptr == NULL)
    return;
  else
    free(ptr);
}

void *my_realloc(void *ptr, size_t  size)
{
  printf("Realloc Proc.\n");
  
  if (size == 0)
    free(ptr);

  if (size <= 0)
    return NULL;

  if (ptr == NULL)
    ptr = malloc(size);
  else
    ptr = realloc(ptr, size);

  return(ptr);
}

void *my_malloc(size_t  size)
{
  void  *ptr;
  
  printf("Malloc Proc.\n");
  
  if (size <= 0)
    return NULL;
  else  {
    ptr = malloc(size);
    return(ptr);
  }
}

int
main(void)
{
  char *x;
  mxArray *pa;

  mxSetAllocFcns(my_calloc,
		 my_free,
		 my_realloc,
		 my_malloc);

  /*
   * Allocate and free some memory, to see that our routines are indeed
   * being called.
   */
  printf("Creating an array...\n");
  pa = mxCreateString("This is an example of a string.");

  printf("Creating a character buffer...\n");
  x = mxCalloc(255, sizeof(char));

  mxGetString(pa, x, 255);
  printf("String variable contained: %s\n", x);

  printf("Freeing allocated buffer...\n");
  mxFree(x);

  printf("Freeing the array...\n");
  mxDestroyArray(pa);

  return EXIT_SUCCESS; 
}
