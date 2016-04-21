/*
 * File: ccp_build_mode.h
 *
 * Abstract:
 *    CCP utility functions
 *
 *
 * $Revision: 1.1.6.1 $
 * $Date: 2003/07/31 18:03:52 $
 *
 * Copyright 2003 The MathWorks, Inc.
 */
#ifndef _CCP_BUILD_MODE_H
#define _CCP_BUILD_MODE_H

/* work out the build mode by inspecting preprocessor defines */
#ifdef MATLAB_MEX_FILE
   #ifdef SIL_S_FUNCTION
      /* SIL S-function build - part of PIL RTW build 
       *
       * We will use the ccp struct to share data between the blocks 
       * No memory operations are allowed. */
       #define CCP_STRUCT
   #endif
   #ifdef PIL_S_FUNCTION
      /* PIL S-function build - part of PIL RTW build 
       *
       * We will use the ccp struct to share data between the blocks 
       * No memory operations are allowed. */
       #define CCP_STRUCT
   #endif
   /* Normal Simulation, or Accelerator mode build 
    *
    * No memory operations are allowed, and we share data via mex function */
#else
   /* either PIL mode or RT */
   /* Use the ccp struct to share data */
   #define CCP_STRUCT
   #include "ccp_code_gen_mode.h"
   #ifdef CCP_CODE_GEN_FOR_SIM
      /* PIL mode */
      /* No memory operations are allowed */
   #else
      /* RT mode - full memory operations are allowed */
      #define CCP_MEMORY_OPERATIONS
   #endif
#endif

#endif
