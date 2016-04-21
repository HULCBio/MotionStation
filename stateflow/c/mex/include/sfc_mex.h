/*
 *   SFC_MEX.H  Stateflow mex header file.
 *
 *   Copyright 1995-2004 The MathWorks, Inc.
 *
 *   $Revision: 1.28.4.10 $  $Date: 2004/04/14 23:54:46 $
 */

#ifndef SFC_MEX_H

#define SFC_MEX_H

#include "mex.h"
#include <setjmp.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "tmwtypes.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_DIMENSIONS 16

typedef enum {
    SF_DOUBLE  = 0,
    SF_SINGLE,
    SF_INT8,
    SF_UINT8,
    SF_INT16,
    SF_UINT16,
    SF_INT32,
    SF_UINT32,
    SF_CHAR,
    SF_BOOL,
    SF_MATLAB,
    SF_UNKNOWN,
    SF_TOTAL_DATA_TYPES
}SfDataType;

/*
typedef enum {
        SF_UNKNOWN_TYPE,
        SF_BOOLEAN_TYPE,
        SF_STATE_TYPE,
        SF_UINT8_TYPE,
        SF_INT8_TYPE,
        SF_UINT16_TYPE,
        SF_INT16_TYPE,
        SF_UINT32_TYPE,
        SF_INT32_TYPE,
        SF_SINGLE_TYPE,
        SF_DOUBLE_TYPE,
        SF_FIXPT_TYPE,
        SF_MATLAB_TYPE,
        SF_VOID_TYPE,
        SF_NONVOID_TYPE,
        SF_ANY_INTEGER_TYPE,
        SF_DATA_TYPE_COUNT
}sfDataType;
*/

typedef enum {
     SF_CONTIGUOUS
    ,SF_NON_CONTIGUOUS
}SfArrayType;

typedef enum {
    SF_ROW_MAJOR,
    SF_COLUMN_MAJOR
} SfIndexScheme;

#define MATLAB_CLASSES(X) \
    X(LOGICAL,boolean_T,int) \
    X(CHAR,char_T,int)    \
    X(DOUBLE,real_T,double)  \
    X(SINGLE,real32_T,double)  \
    X(INT8,int8_T,int)    \
    X(UINT8,uint8_T,int)   \
    X(INT16,int16_T,int)   \
    X(UINT16,uint16_T,int)  \
    X(INT32,int32_T,int)   \
    X(UINT32,uint32_T,unsigned int)

typedef enum {
#define DEFINE_ENUM(NAME,CTYPE,CTYPE2) ML_##NAME = mx##NAME##_CLASS,
   MATLAB_CLASSES(DEFINE_ENUM)
#undef DEFINE_ENUM
   ML_MX_ARRAY,
   ML_STRING,
   ML_VOID,
   ML_LAST_DATA_TYPE
} MatlabDataType; /* useful for passing arguments to sf_mex_call*/

typedef enum {
    BASE_WORKSPACE,
    CALLER_WORKSPACE,
    GLOBAL_WORKSPACE,
    ALL_WORKSPACES} MatlabWorkspaceType;

typedef void (*DebuggerSimStatusListenerFcn)(unsigned int);

extern int strcmp_ignore_ws( const char *string1, const char *string2 );
extern bool sf_mex_get_halt_simulation(void);
extern void sf_mex_clear_error_message(void);
extern const char* sf_mex_get_error_message_for_read(void);
extern unsigned int sf_mex_get_error_message_buffer_length(void);
void sf_mex_printf(const char *msg, ...);

/*
 * Is array temporary
 */

/*
#ifndef mxIsTemp
extern int mxIsTemp(const mxArray *pa);
#endif

#if defined(ARRAY_ACCESS_INLINING)
#define mxIsTemp(pa)     (mxGetArrayScope(pa) == mxTEMPORARY_SCOPE)
#endif */ /* defined(ARRAY_ACCESS_INLINING) */


#define SF_DUPLICATE_ARRAY


/*
 * Calls to the following functions and macros should always be followed immediately by either RETURN_ON_ERROR
 * or RETURN_VALUE_ON_ERROR to propagate errors up the call stack.
 * Technically, these are not necessary if the call is followed immediately by an
 * unconditional return.  However, any failure to follow this regime is likely to produce
 * very subtle and difficult bugs so I urge rigid adherence to the discipline of adding
 * the macros.  It's also good documentation that you know what you're doing.
 *
 * Sometimes these macros don't work well with sf_mex_call_matlab() because you need to
 * clean up mxArrays etc before returning (to avoid leaks).  So sf_mex_call_matlab traps the error
 * and also returns it.  Test the result for non-zero and do the right thing.
 */
extern int sf_mex_call_matlab(int nlhs, mxArray* plhs[], int nrhs, mxArray* prhs[], const char* fcnName);
extern const mxArray *sf_mex_evalin(MatlabWorkspaceType workspaceType, unsigned int numReturn, const char *evalFormatStr, ...);
extern const mxArray *sf_mex_call(const char *functionName, unsigned int numReturn, unsigned int numArguments,...);
extern const mxArray *sf_mex_get_ml_var(const char *variableName, MatlabWorkspaceType workspaceType);

extern void sf_mex_set_halt_simulation(bool halt);
extern void sf_mex_error_message(const char *msg, ...);
extern void sf_mex_error_direct_call(const char *fcnName, const char *fileName);
extern void sf_mex_stop_simulation_abruptly_wo_error(void);
extern void sf_mex_warning_message(const char *msg, ...);
extern void sf_mex_long_jump_on_error(unsigned int longJumpType);
extern void sf_assertion_failed(const char *expr, const char *in_file, int at_line, const char *msg);
extern void sf_clear_error_manager_info(void);
extern void sf_set_error_prefix_string(const char *errorPrefixString);
extern void sf_mex_set_debugger_sim_status_listener_fcn(DebuggerSimStatusListenerFcn listenerFcn);
extern void sf_set_error_debugger_context_message_fcn(void (*debuggerContextMessageFcn)(char *));
extern char * sf_get_error_prefix_string(void);
extern void sf_echo_expression(const char *expr, real_T value);
extern const mxArray *sf_mex_create(void *dataPtr,     /* src: data to create mxArray */
                                     const char *nameStr,       /* name: name to use for errors */
                                     SfDataType dataType,       /* src: input data type */
                                     unsigned int isComplex,    /* src: is complex data? */
                                     SfIndexScheme indexScheme, /* src: index scheme for input data */
                                     int numDims,               /* src: number of dimensions */
                                     ...);                      /* src: dimension sizes */
extern double sf_mex_ml_var_sub(const char *wsDataName,         /* workspace data name */
                                 MatlabWorkspaceType workspaceType, /* workspace type */
                                 int numDims,                       /* desired number of dimensions */
                                 ...);                              /* desired index for each dimension */
extern void sf_mex_ml_var_subsasgn(const char *wsDataName,
                               MatlabWorkspaceType workspaceType,
                               double value,
                               int numDims,
                               ...);
extern void sf_mex_assign(const mxArray **sfMatlabDataPtr,
                                               const mxArray *srcMxArray);
extern const mxArray *sf_mex_dup(const mxArray *srcMxArray);
extern void sf_mex_destroy(const mxArray **sfMatlabDataPtr);
extern mxClassID sf_mex_get_mx_datatype_from_sf_datatype(SfDataType dataType);
extern void sf_mex_export(const char *vectName,
                          const mxArray *mxArrayPtr,
                          MatlabWorkspaceType workspaceType);
extern void sf_mex_import(const mxArray *mxArrayPtr,  /* src:  mxArray to copy from */
                          const char *nameStr,        /* name: name to use for errors */
                          void *dataPtr,              /* dest: memory place to put array data */
                          SfDataType dataType,        /* dest: array data type */
                          unsigned int isComplex,     /* dest: complex data or not */
                          SfIndexScheme indexScheme,  /* dest: index scheme, row-major or column major */
                          int numDims,                /* dest: desired number of dimensions */
                          ...);                       /* dest: desired length for each dimension */
extern const mxArray *sf_mex_lower_fixpt_mx_array(const mxArray *mxArrayPtr,
                                           int fixptExponent,
                                           double fixptSlope,
                                           double fixPtBias,
                                           unsigned int nBits,
                                           unsigned int isSigned);
extern double sf_mex_sub(const mxArray *mxArrayPtr, /* pointer to SF MATLAB data */
                                               const char *nameStr,       /* name: name to use for errors */
                                               int numDims,               /* desired number of dimensions */
                                               ...);                      /* desired index for each dimension */
extern void sf_mex_subsasgn(const mxArray *mxArrayPtr,  /* pointer to SF MATLAB data */
                                             const char *nameStr,       /* name: name to use for errors */
                                            double value,
                                            int numDims,                /* desired number of dimensions */
                                            ...);                       /* desired index for each dimension */
extern void ml_set_element_value_in_array(const mxArray *mxArrayPtr,
										  const char *nameStr,
										  unsigned int index,
										  double value,
										  bool setImaginary);

extern jmp_buf *sf_get_current_jmp_buf_ptr(void);
extern void sf_set_current_jmp_buf_ptr(jmp_buf *jumpbufPtr);

#define sf_assertion(expr) ((expr)?(void)0:sf_assertion_failed(#expr,__FILE__,__LINE__,NULL))
#define sf_assertion_msg(expr,msg) ((expr)?(void)0:sf_assertion_failed(#expr,__FILE__,__LINE__,msg))


#ifdef TRUE
#undef TRUE
#endif

#ifdef FALSE
#undef FALSE
#endif

#define mexPrintf sf_mex_printf
#ifdef printf
#undef printf
#endif
#define printf sf_mex_printf

#ifndef min
#define min(a,b)    (((a) < (b)) ? (a) : (b))
#endif
#ifndef max
#define max(a,b)    (((a) > (b)) ? (a) : (b))
#endif

#ifdef __cplusplus
}
#endif

#endif /*SF_MEX_H */

