/* $Revision: 1.11.4.3 $ */
/*  
 *  cv_sfinterface.h
 *
 *  Routines to interface with cv.dll by way of function pointers 
 *  locally stored.
 */

#ifndef __cv_sfinterface__
#define __cv_sfinterface__


#include <stdio.h>


/******************************************************************************
 *                          OLD ENUMERATIONS                                  *
 ******************************************************************************/

/* 
 * Most state decisions are coded only once, as needed.  The
 * following enumeration identifies these decisions.  Since 
 * these decisions occur only once per state it is not necessary
 * to differentiate multiple occrences.  
 */

typedef enum {
    UNKNOWM_MISC_CALL = 0,
    ACTIVE_ON_ENTRY,
    ENTER_FROM_TRANSITION,
    INACTIVE_CHILDREN,
    INACTIVE_PARENT,
    INACTIVE_PARENT_AFTER_ENTRY,
    INACTIVE_PARENT_AFTER_SIB_ENTRY,
    INACTIVE_AFTER_ENTRY_EVENT,
    ENTER_FROM_OUTSIDE,
    PREV_ACTIVE_CHILD,
    HIST_CHILD_CALL,
    INACTIVE_AFTER_CHILD_ENTRY,
    INACTIVE_CHILD_FROM_HIST,
    ENTER_SET_FROM_OUTSIDE,
    INACTIVE_AFTER_DEFAULT,
    INACTIVE_BEFORE_DURING,
    INACTIVE_CHILDREN_DURING,
    ACTIVE_CHILD_CALL,
    INACTIVE_BEFORE_EXIT,
    ACTIVE_CHILD_AT_EXIT,
    ACTIVE_CHILD_EXIT,
    INACTIVE_AFTER_CHILD_EXIT
} CvStateDecisionType;


typedef enum {
    TRIGGER_CONDITION,
    GUARD_CONDITION
} CvTransitionConditionType;


typedef enum {
    MISCELLANEOUS_DECISION = -1,
    UNKNOWN_REPEAT_TYPE = 0,
    ON_EVENT_TEST,
    INACTIVE_FROM_BROADCAST,
    ACTIVE_CHILD_FROM_BROADCAST,
    INACTIVE_FROM_CHILD_ENTRY
} CvRepeatableDecisionType;

#ifndef CV_EML_CHECK_TYPE_DEF
#define CV_EML_CHECK_TYPE_DEF

typedef enum {
    CV_EML_FCN_CHECK = 0,
    CV_EML_IF_CHECK,
    CV_EML_FOR_CHECK,
    CV_EML_WHILE_CHECK,
    CV_EML_COND_CHECK,
    CV_EML_MCDC_CHECK,
    CV_EML_SWITCH_CHECK,
    CV_EML_CHECK_CNT
}SfCvEmlCheckType;

#endif

#define NUM_REPEAT_TYPES 4

/******************************************************************************/

typedef struct CvSfInterfaceInfoStruct {
    bool covEnabled;
    
    int (*transInitFcn)       ( unsigned int cvId, 
                                int predicateCnt, 
                                unsigned int *txtStartIdx, 
                                unsigned int *txtEndIdx,
                                unsigned int postFixPredicateTreeCount,
                                int *postFixPredicateTree);

    int (*stateInitFcn)       ( unsigned int cvId, 
                                unsigned int numChild, 
                                bool hasDuringSwitch,
                                bool hasExitSwitch,
                                bool hasHistSwitch,
                                unsigned int onDecCnt,
                                unsigned int *decStartInd,
                                unsigned int *decEndInd);

    int (*chartInitFcn)       ( unsigned int cvId, 
                                unsigned int numChild, 
                                bool hasDuringSwitch,
                                bool hasExitSwitch,
                                bool hasHistSwitch);

    int (*decUpdateFcn)       ( unsigned int cvId,
                                unsigned int objectIndex,
                                unsigned int retValue);

    int (*condUpdateFcn)      ( unsigned int cvId,
                                unsigned int objectIndex,
                                unsigned int retValue);

    int (*sigUpdateFcn)       ( unsigned int cvId, 
                                unsigned int dataNumber, 
                                double equivValue);

    int (*emlScriptInitFcn)   ( unsigned int cvId, 
                                unsigned int fcnCnt,
                                unsigned int ifCnt,
                                unsigned int switchCnt,
                                unsigned int forCnt,
                                unsigned int whileCnt,
                                unsigned int condCnt,
                                unsigned int mcdcCnt);

    int (*emlFcnInitFcn)      ( unsigned int cvId, 
                                unsigned int fcnIdx,
                                const char *name,
                                int charStart,
                                int charExprEnd,
                                int charEnd);

    int (*emlIfInitFcn)       ( unsigned int cvId, 
                                unsigned int ifIdx,
                                int charStart,
                                int charExprEnd,
                                int charElseStart,
                                int charEnd);

    int (*emlSwitchInitFcn)   ( unsigned int cvId, 
                                unsigned int switchIdx,
                                int charStart,
                                int charExprEnd,
                                int charEnd,
                                unsigned int caseCnt,
                                int *caseStart,
                                int *caseExprEnd);

    int (*emlForInitFcn)      ( unsigned int cvId, 
                                unsigned int forIdx,
                                int charStart,
                                int charExprEnd,
                                int charEnd);

    int (*emlWhileInitFcn)    ( unsigned int cvId, 
                                unsigned int whileIdx,
                                int charStart,
                                int charExprEnd,
                                int charEnd);

    int (*emlMCDCInitFcn)     ( unsigned int cvId, 
                                unsigned int mcdcIdx,
                                int charStart,
                                int charEnd,
                                unsigned int condCnt,
                                unsigned int firstCondIdx,
                                int *condStart,
                                int *condEnd,
                                unsigned int pfxLength,
                                int *pfixExpr);

    int (*emlFcnEval)         ( unsigned int cvId, unsigned int index);

    int (*emlIfEval)          ( unsigned int cvId, unsigned int index, int val);

    int (*emlForEval)         ( unsigned int cvId, unsigned int index, int val);

    int (*emlWhileEval)       ( unsigned int cvId, unsigned int index, int val);

    int (*emlSwitchEval)      ( unsigned int cvId, unsigned int index, int val); 

    int (*emlCondEval)        ( unsigned int cvId, unsigned int index, int val);

    int (*emlMcdcEval)        ( unsigned int cvId, unsigned int index, int val); 



} CvSfInterfaceInfo;

#define STATIC_INIT_CVSF_INTERFACE {false, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,\
                                    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL}


/*
 * Gateway Functions
 */

extern void cv_init_trans(unsigned int cvId, 
                    int predicateCnt, 
                    unsigned int *txtStartIdx, 
                    unsigned int *txtEndIdx,
                    unsigned int postFixPredicateTreeCount,
                    int *postFixPredicateTree);


extern void cv_init_state(unsigned int cvId, 
                          unsigned int numChild, 
                          bool hasDuringSwitch,
                          bool hasExitSwitch,
                          bool hasHistSwitch,
                          unsigned int onDecCnt,
                          unsigned int *decStartInd,
                          unsigned int *decEndInd);

extern void cv_init_chart(unsigned int cvId, 
                          unsigned int numChild, 
                          bool hasDuringSwitch,
                          bool hasExitSwitch,
                          bool hasHistSwitch);

extern void cv_dec_update_call(unsigned int cvId,
                           unsigned int objectIndex,
                           unsigned int retValue);

extern void cv_sigrange_update( unsigned int cvId, 
                                unsigned int dataNumber, 
                                double equivValue);


/*
 * EML Gateway Functions
 */

extern void cvsf_eml_eval( unsigned int cvId,
                         SfCvEmlCheckType checkType,
                         unsigned int objectIndex,
                         int retValue);

extern void cvsf_eml_init_script( unsigned int cvId,
                                  unsigned int fcnCnt,
                                  unsigned int ifCnt,
                                  unsigned int switchCnt,
                                  unsigned int forCnt,
                                  unsigned int whileCnt,
                                  unsigned int condCnt,
                                  unsigned int mcdcCnt);

extern void cvsf_eml_init_fcn( unsigned int cvId,
                               unsigned int fcnIdx,
                               const char *name,
                               int charStart,
                               int charExprEnd,
                               int charEnd);

extern void cvsf_eml_init_if( unsigned int cvId,
                              unsigned int ifIdx,
                              int charStart,
                              int charExprEnd,
                              int charElseStart,
                              int charEnd);

extern void cvsf_eml_init_switch( unsigned int cvId,
                                  unsigned int switchIdx,
                                  int charStart,
                                  int charExprEnd,
                                  int charEnd,
                                  unsigned int caseCnt,
                                  int *caseStart,
                                  int *caseExprEnd);

extern void cvsf_eml_init_for( unsigned int cvId,
                               unsigned int forIdx,
                               int charStart,
                               int charExprEnd,
                               int charEnd);


extern void cvsf_eml_init_while( unsigned int cvId,
                                 unsigned int whileIdx,
                                 int charStart,
                                 int charExprEnd,
                                 int charEnd); 

extern void cvsf_eml_init_mcdc( unsigned int cvId,
                                unsigned int mcdcIdx,
                                int charStart,
                                int charEnd,
                                unsigned int condCnt,
                                unsigned int firstCondIdx,
                                int *condStart,
                                int *condEnd,
                                unsigned int pfxLength,
                                int *pfixExpr);

/*
 * Initialization Functions
 */
extern void cv_create_interface(const char *machName);
extern void cv_destroy_interface(void);
extern void cv_create_instance_objects(unsigned int *states, 
                                unsigned int stateCount,
                                unsigned int *transitions,
                                unsigned int transCount,
										unsigned int *dataIdx,
										unsigned int dataCount,
                                unsigned int *chartId,
                                unsigned int chartSfId, 
                                const char *fullPath);

/* Opaque type */
typedef struct SfDebugInstanceStruct DBInstanceStruct;


extern void sf_debug_cv_initialize_instance(DBInstanceStruct *debugInstance,
                                     unsigned int machineNumber,
                                     unsigned int chartNumber,
                                     unsigned int instanceNumber);

extern void sf_debug_cv_terminate_chart(DBInstanceStruct *debugInstance,
                                    unsigned int machineNumber,
                                    unsigned int chartNumber);


extern bool cv_is_enabled(void);


/* Obsolete functions needed for compiling only */
extern void cv_call_trans_test(unsigned int id, unsigned int value, unsigned int codeInstance);
extern void cv_call_sub_cond_test(unsigned int id, unsigned int value, unsigned int index, CvTransitionConditionType condType);

#endif
