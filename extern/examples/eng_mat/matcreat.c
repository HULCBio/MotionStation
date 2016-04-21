/*
 * MAT-file creation program
 *
 * See the MATLAB API Guide for compiling information.
 *
 * Calling syntax:
 *
 *   matcreat
 *
 * Create a MAT-file which can be loaded into MATLAB.
 *
 * This program demonstrates the use of the following functions:
 *
 *  matClose
 *  matGetVariable
 *  matOpen
 *  matPutVariable
 *  matPutVariableAsGlobal
 *
 * Copyright 1984-2000 The MathWorks, Inc.
 */
/* $Revision: 1.13 $ */
#include <stdio.h>
#include <string.h> /* For strcmp() */
#include <stdlib.h> /* For EXIT_FAILURE, EXIT_SUCCESS */
#include "mat.h"

#define BUFSIZE 256

int main() {
  MATFile *pmat;
  mxArray *pa1, *pa2, *pa3;
  double data[9] = { 1.0, 4.0, 7.0, 2.0, 5.0, 8.0, 3.0, 6.0, 9.0 };
  const char *file = "mattest.mat";
  char str[BUFSIZE];
  int status; 

  printf("Creating file %s...\n\n", file);
  pmat = matOpen(file, "w");
  if (pmat == NULL) {
    printf("Error creating file %s\n", file);
    printf("(Do you have write permission in this directory?)\n");
    return(EXIT_FAILURE);
  }

  pa1 = mxCreateDoubleMatrix(3,3,mxREAL);
  if (pa1 == NULL) {
      printf("%s : Out of memory on line %d\n", __FILE__, __LINE__); 
      printf("Unable to create mxArray.\n");
      return(EXIT_FAILURE);
  }

  pa2 = mxCreateDoubleMatrix(3,3,mxREAL);
  if (pa2 == NULL) {
      printf("%s : Out of memory on line %d\n", __FILE__, __LINE__);
      printf("Unable to create mxArray.\n");
      return(EXIT_FAILURE);
  }
  memcpy((void *)(mxGetPr(pa2)), (void *)data, sizeof(data));
  
  pa3 = mxCreateString("MATLAB: the language of technical computing");
  if (pa3 == NULL) {
      printf("%s :  Out of memory on line %d\n", __FILE__, __LINE__);
      printf("Unable to create string mxArray.\n");
      return(EXIT_FAILURE);
  }

  status = matPutVariable(pmat, "LocalDouble", pa1);
  if (status != 0) {
      printf("%s :  Error using matPutVariable on line %d\n", __FILE__, __LINE__);
      return(EXIT_FAILURE);
  }  
  
  status = matPutVariableAsGlobal(pmat, "GlobalDouble", pa2);
  if (status != 0) {
      printf("Error using matPutVariableAsGlobal\n");
      return(EXIT_FAILURE);
  } 
  
  status = matPutVariable(pmat, "LocalString", pa3);
  if (status != 0) {
      printf("%s :  Error using matPutVariable on line %d\n", __FILE__, __LINE__);
      return(EXIT_FAILURE);
  } 
  
  /*
   * Ooops! we need to copy data before writing the array.  (Well,
   * ok, this was really intentional.) This demonstrates that
   * matPutVariable will overwrite an existing array in a MAT-file.
   */
  memcpy((void *)(mxGetPr(pa1)), (void *)data, sizeof(data));
  status = matPutVariable(pmat, "LocalDouble", pa1);
  if (status != 0) {
      printf("%s :  Error using matPutVariable on line %d\n", __FILE__, __LINE__);
      return(EXIT_FAILURE);
  } 
  
  /* clean up */
  mxDestroyArray(pa1);
  mxDestroyArray(pa2);
  mxDestroyArray(pa3);

  if (matClose(pmat) != 0) {
    printf("Error closing file %s\n",file);
    return(EXIT_FAILURE);
  }

  /*
   * Re-open file and verify its contents with matGetVariable
   */
  pmat = matOpen(file, "r");
  if (pmat == NULL) {
    printf("Error reopening file %s\n", file);
    return(EXIT_FAILURE);
  }

  /*
   * Read in each array we just wrote
   */
  pa1 = matGetVariable(pmat, "LocalDouble");
  if (pa1 == NULL) {
    printf("Error reading existing matrix LocalDouble\n");
    return(EXIT_FAILURE);
  }
  if (mxGetNumberOfDimensions(pa1) != 2) {
    printf("Error saving matrix: result does not have two dimensions\n");
    return(EXIT_FAILURE);
  }

  pa2 = matGetVariable(pmat, "GlobalDouble");
  if (pa2 == NULL) {
    printf("Error reading existing matrix GlobalDouble\n");
    return(EXIT_FAILURE);
  }
  if (!(mxIsFromGlobalWS(pa2))) {
    printf("Error saving global matrix: result is not global\n");
    return(EXIT_FAILURE);
  }

  pa3 = matGetVariable(pmat, "LocalString");
  if (pa3 == NULL) {
    printf("Error reading existing matrix LocalString\n");
    return(EXIT_FAILURE);
  }
  
  status = mxGetString(pa3, str, sizeof(str));
  if(status != 0) {
      printf("Not enough space. String is truncated.");
      return(EXIT_FAILURE);
  }
  if (strcmp(str, "MATLAB: the language of technical computing")) {
    printf("Error saving string: result has incorrect contents\n");
    return(EXIT_FAILURE);
  }

  /* clean up before exit */
  mxDestroyArray(pa1);
  mxDestroyArray(pa2);
  mxDestroyArray(pa3);

  if (matClose(pmat) != 0) {
    printf("Error closing file %s\n",file);
    return(EXIT_FAILURE);
  }
  printf("Done\n");
  return(EXIT_SUCCESS);
}


 

