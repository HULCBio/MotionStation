/*
 * Copyright 1990-2004 The MathWorks, Inc.
 *
 * File: rtw_extmode.h     $Revision: 1.1.6.2.2.1 $
 *
 * Abstract:
 *   Type definitions for Simulink External Mode support.
 */

#ifndef __RTW_EXTMODE_H__
#define __RTW_EXTMODE_H__

/* =============================================================================
 * External mode object
 * =============================================================================
 */
typedef struct _RTWExtModeInfo_tag {

    void *subSysActiveVectorAddr;  /* Array of addresses pointing to
                                    * the active vector slots for sub-systems.
                                    * Sub-systems store information about their
                                    * state in thier extmode active vector.
                                    */
    uint32_T *checksumsPtr;        /* Pointer to the model's checksums array
                                    */
    const void **mdlMappingInfoPtr;/* Pointer to the model's mapping info
                                    * pointer
                                    */
    void       *tPtr;              /* Copy of model's time pointer
                                    */
    int32_T tFinalTicks;           /* Used with integer only code, holds the
                                    * number of base rate ticks representing
                                    * the final time (final time in seconds
                                    * divided by base rate step size).
                                    */

} RTWExtModeInfo;

/* gnat 3.12a2 doesn't like use "/" as line continuation here */
#define rteiSetSubSystemActiveVectorAddresses(E,addr) ((E)->subSysActiveVectorAddr = ((void *)addr))
#define rteiGetSubSystemActiveVectorAddresses(E)    ((E)->subSysActiveVectorAddr)
#define rteiGetAddrOfSubSystemActiveVector(E,idx)   ((int8_T*)((int8_T**)((E)->subSysActiveVectorAddr))[idx])

#define rteiSetModelMappingInfoPtr(E,mip) ((E)->mdlMappingInfoPtr = (mip))
#define rteiGetModelMappingInfo(E) (*((E)->mdlMappingInfoPtr))

#define rteiSetChecksumsPtr(E,cp) ((E)->checksumsPtr = (cp))
#define rteiGetChecksum0(E) (E)->checksumsPtr[0]
#define rteiGetChecksum1(E) (E)->checksumsPtr[1]
#define rteiGetChecksum2(E) (E)->checksumsPtr[2]
#define rteiGetChecksum3(E) (E)->checksumsPtr[3]

#define rteiSetTPtr(E,p) ((E)->tPtr = (p))
#define rteiGetT(E)      ((time_T *)(E)->tPtr)[0]

#define rteiGetTFinalTicks(E) ((int32_T)((E)->tFinalTicks))
#define rteiGetPtrTFinalTicks(E) ((int32_T *)(&((E)->tFinalTicks)))

#endif /* __RTW_EXTMODE_H__ */

