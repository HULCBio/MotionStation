/*
 * Copyright (c) 1990-2002 The MathWorks, Inc.
 *
 * File: simstruc_types.h     $Revision: 1.1.6.6.2.1 $
 *
 * Abstract:
 *   The embedded RTW code formats do not include simstruc.h, but
 *   needs these common types.
 *   Generated from simstruc_types.tpl.
 */

#ifndef __SIMSTRUC_TYPES_H__
#define __SIMSTRUC_TYPES_H__

#include "tmwtypes.h"

#define UNUSED_ARG(arg)  (void)arg

/* Additional types required for Simulink External Mode */
#ifndef fcn_call_T
# define fcn_call_T real_T
#endif
#ifndef action_T
# define action_T real_T
#endif


/*
 * UNUSED_PARAMETER(x)
 *   Used to specify that a function parameter (argument) is required but not
 *   accessed by the function body.
 */
#ifndef UNUSED_PARAMETER
# if defined(__LCC__)
#   define UNUSED_PARAMETER(x)  /* do nothing */
# else
/*
 * This is the semi-ANSI standard way of indicating that a
 * unused function parameter is required.
 */
#   define UNUSED_PARAMETER(x) (void) (x)
# endif
#endif

typedef enum {
  SS_SIMMODE_NORMAL,            /* Running a "normal" Simulink simulation     */
  SS_SIMMODE_SIZES_CALL_ONLY,   /* Block edit eval to obtain number of ports  */
  SS_SIMMODE_RTWGEN,            /* Generating code                            */
  SS_SIMMODE_EXTERNAL          /* External mode simulation                   */
} SS_SimMode;

/* Must be used when SS_SimMode is SS_SIMMODE_RTWGEN */
typedef enum {
    SS_RTWGEN_UNKNOWN,
    SS_RTWGEN_RTW_CODE,           /* Code generation for RTW */
    SS_RTWGEN_ACCELERATOR,         /* Code generation for accelerator */
    SS_RTWGEN_MODELREFERENCE_SIM_TARGET, /*Code Generation for Model Reference Sim Target*/
    SS_RTWGEN_MODELREFERENCE_RTW_TARGET /*Code Generation for Model Reference RTW Target*/		
} RTWGenMode;

/* States of an enabled subsystem */
typedef enum {
    SUBSYS_DISABLED          = 0,
    SUBSYS_ENABLED           = 2,
    SUBSYS_BECOMING_DISABLED = 4,
    SUBSYS_BECOMING_ENABLED  = 8,
    SUBSYS_TRIGGERED         = 16
} CondStates;

/* Subsystem run state -- used by Model Reference simulation target */
typedef enum {
    SUBSYS_RAN_BC_DISABLE,
    SUBSYS_RAN_BC_ENABLE,
    SUBSYS_RAN_BC_DISABLE_TO_ENABLE,
    SUBSYS_RAN_BC_ENABLE_TO_DISABLE,
    SUBSYS_RAN_BC_ONE_SHOT
} SubSystemRanBCTransition;

/* Trigger directions: falling, either, and rising */
typedef enum {
    FALLING_ZERO_CROSSING = -1,
    ANY_ZERO_CROSSING     = 0,
    RISING_ZERO_CROSSING  = 1
} ZCDirection;

/* Previous state of a trigger signal */
typedef enum {
    NEG_ZCSIG             = -1,
    ZERO_ZCSIG            = 0,
    POS_ZCSIG             = 1,
    ZERO_RISING_EV_ZCSIG  = 100, /* zero and had a rising event  */
    ZERO_FALLING_EV_ZCSIG = 101, /* zero and had a falling event */
    UNINITIALIZED_ZCSIG   = INT_MAX
} ZCSigState;

/* Current state of a trigger signal */
typedef enum {
    FALLING_ZCEVENT = -1,
    NO_ZCEVENT      = 0,
    RISING_ZCEVENT  = 1
} ZCEventType;

/* Enumeration of built-in data types */
typedef enum {
    SS_DOUBLE  =  0,    /* real_T    */
    SS_SINGLE  =  1,    /* real32_T  */
    SS_INT8    =  2,    /* int8_T    */
    SS_UINT8   =  3,    /* uint8_T   */
    SS_INT16   =  4,    /* int16_T   */
    SS_UINT16  =  5,    /* uint16_T  */
    SS_INT32   =  6,    /* int32_T   */
    SS_UINT32  =  7,    /* uint32_T  */
    SS_BOOLEAN =  8     /* boolean_T */
} BuiltInDTypeId;

#define SS_NUM_BUILT_IN_DTYPE ((int)SS_BOOLEAN+1)

typedef enum {
    SS_INTERNAL_DTYPE1 = 9, 
    SS_INTEGER = 10,
    SS_POINTER = 11,
    SS_INTERNAL_DTYPE2 = 12, 
    SS_TIMER_UINT32_PAIR = 13

    /* if last in list changes also update define below */

} PreDefinedDTypeId;

#define SS_DOUBLE_UINT32  SS_TIMER_UINT32_PAIR

#define SS_NUM_PREDEFINED_DTYPES  5

#define SS_START_MTH_PORT_ACCESS_UNSET 2

#ifndef _DTYPEID
#  define _DTYPEID
   typedef int_T DTypeId;
#endif
#include "rtw_matlogging.h"
#include "rtw_extmode.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"

typedef int_T CSignal_T;

/* DimsInfo_T structure is for S-functions */
#ifndef _DIMSINFO_T
#define _DIMSINFO_T
struct DimsInfo_tag{
    int                        width;        /* number of elements    */
    int                        numDims;      /* number of dimensions  */
    int                        *dims;        /* dimensions            */
    struct DimsInfo_tag        *nextSigDims; /* for composite signals */
};

typedef struct DimsInfo_tag DimsInfo_T;


/*
 * DECL_AND_INIT_DIMSINFO(variableName):
 *    Macro for setting up a DimsInfo in an S-function to DYNAMIC_DIMENSION.
 *    This macro must be placed at the start of a deceleration, for example:
 *
 *           static void mdlInitializeSizes(SimStruct *S)
 *           {
 *               DECL_AND_INIT_DIMSINFO(diminfo1);
 *
 *               ssSetNumSFcnParams(S, 0);
 *               <snip>
 *           }
 *
 *    The reason that this macro must be placed in the deceleration section of a
 *    function or other scope is that this macro **creates** a local variable of
 *    the specified name with type DimsInfo_T. The variable is initialized
 *    to DYNAMIC_DIMENSION.
 */
#define DECL_AND_INIT_DIMSINFO(variableName) \
   DimsInfo_T variableName = {-1,-1,NULL,NULL}
#endif /* _DIMSINFO_T */


/*
 * Enumeration of work vector used as flag values.
 */
typedef enum {
    SS_DWORK_USED_AS_DWORK  = 0,  /* default */
    SS_DWORK_USED_AS_DSTATE,      /* will be logged, loaded, etc */
    SS_DWORK_USED_AS_SCRATCH,     /* will be reused */
    SS_DWORK_USED_AS_MODE         /* replace mode with dwork */
} ssDWorkUsageType;

#define SS_NUM_DWORK_USAGE_TYPES 3

/*
 * DWork structure for S-Functions, one for each dwork.
 */
struct _ssDWorkRecord {
    int_T            width;
    DTypeId          dataTypeId;
    CSignal_T        complexSignal;
    void             *array;
    const char_T     *name;
    ssDWorkUsageType usedAs;
};

/*
 * INHERITED_SAMPLE_TIME      - Specify for blocks that inherit their sample
 *                              time from the block that feeds their input.
 *
 * CONTINUOUS_SAMPLE_TIME     - A continuous sample time indicates that the
 *                              block executes every simulation step.
 *
 * VARIABLE_SAMPLE_TIME       - Specifies that this sample time is discrete
 *                              with a varying period.
 *
 * FIXED_IN_MINOR_STEP_OFFSET - This can be specified for the offset of either
 *                              the inherited or continuous sample time
 *                              indicating that the output does not change
 *                              in minor steps.
 */

#define INHERITED_SAMPLE_TIME      ((real_T)-1.0)
#define CONTINUOUS_SAMPLE_TIME     ((real_T)0.0)
#define VARIABLE_SAMPLE_TIME       ((real_T)-2.0)
#define MODEL_EVENT_SAMPLE_TIME    ((real_T)-3.0)
#define FIXED_IN_MINOR_STEP_OFFSET ((real_T)1.0)


/* ========================================================================== */

/*
 * Lightweight structure for holding a real, sparse matrix
 * as used by the analytical Jacobian methods.
 */
typedef struct SparseHeader_Tag {
    int_T   mRows;                  /* number of rows   */
    int_T   nCols;                  /* number of cols   */
    int_T   nzMax;                  /* size of *pr, *ir */
    int_T   *Ir;                    /* row indices      */
    int_T   *Jc;                    /* column offsets   */
#ifndef NO_FLOATS
    real_T  *Pr;                    /* nonzero entries  */
#else
    void    *Pr;
#endif
} SparseHeader;

/*========================*
 * Setup for multitasking *
 *========================*/

/*
 * Let MT be synonym for MULTITASKING (to shorten command line for DOS)
 */
#if defined(MT)
# if MT == 0
#   undef MT
# else
#   define MULTITASKING 1
# endif
#endif

#if defined(MULTITASKING) && MULTITASKING == 0
# undef MULTITASKING
#endif

#if defined(MULTITASKING) && !defined(TID01EQ)
# define TID01EQ 0
#endif

/*
 * Undefine MULTITASKING if there is only one task or there are two
 * tasks and the sample times are equal (case of continuous and one discrete
 * with equal rates).
 */
#if defined(NUMST) && defined(MULTITASKING)
# if NUMST == 1 || (NUMST == 2 && TID01EQ == 1)
#  undef MULTITASKING
# endif
#endif

#ifdef ERT_CORE
#undef ERT_CORE
#endif

#ifdef USE_RTMODEL
#ifndef RT_MALLOC
# define ERT_CORE 1
#endif
#endif

#endif /* __SIMSTRUC_TYPES_H__ */
