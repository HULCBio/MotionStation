/* Static rtwtypes.h to support non RTW based cases. */
#ifndef __RTWTYPES_H__  
  #define __RTWTYPES_H__  
  #include "simstruc_types.h"  
  #ifndef POINTER_T
  # define POINTER_T
    typedef void * pointer_T;
  #endif
  #ifndef TRUE  
  # define TRUE (1)  
  #endif  
  #ifndef FALSE  
  # define FALSE (0)  
  #endif    
#endif  
