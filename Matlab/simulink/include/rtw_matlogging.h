/*
 * Copyright 1990-2004 The MathWorks, Inc.
 *
 * File: rtw_matlogging.h     $Revision: 1.1.6.3.2.1 $
 *
 * Abstract:
 *   Type definitions for MAT-file logging support.
 */

#ifndef __RTW_MATLOGGING_H__
#define __RTW_MATLOGGING_H__

/*
 * The RTWLogSignalInfo and RTWLogInfo structures are for use by
 * the Real-Time Workshop and should not be used by S-functions.
 */
typedef const int8_T * const * LogSignalPtrsType;

#ifndef NO_FLOATS /* ERT integer-only */

typedef struct RTWLogDataTypeConvert_tag {

    int conversionNeeded;
    BuiltInDTypeId dataTypeIdLoggingTo;
    DTypeId        dataTypeIdOriginal;
    real_T         fracSlope;
    int            fixedExp;
    real_T         bias;

} RTWLogDataTypeConvert;


typedef struct RTWLogSignalInfo_tag {
    int_T                numSignals;
    int_T          *numCols;
    int_T          *numDims;
    int_T          *dims;
    BuiltInDTypeId *dataTypes;
    int_T          *complexSignals;
    int_T          *frameData;
    const char_T   **labels;
    char_T         *titles;
    int_T          *titleLengths;
    int_T          *plotStyles;
    const char_T   **blockNames;
    boolean_T      *crossMdlRef;

    RTWLogDataTypeConvert *dataTypeConvert;

} RTWLogSignalInfo;

/* =============================================================================
 * Logging object
 * =============================================================================
 */
typedef struct _RTWLogInfo_tag {
  void              *logInfo;      /* Pointer to a book keeping structure    *
                                    * used in rtwlog.c                       */

  LogSignalPtrsType logXSignalPtrs;/* Pointers to the memory location        *
                                    * of the data to be logged into the      *
                                    * states structure. Not used if logging  *
                                    * data in matrix format.                 */

  LogSignalPtrsType logYSignalPtrs;/* Pointers to the memory location        *
                                    * of the data to be logged into the      *
                                    * outputs structure. Not used if logging *
                                    * data in matrix format.                 */
  int_T         logFormat;          /* matrix=0, struct=1, or strut_wo_time=2 */

  int_T         logMaxRows;         /* Max number of rows (0 for no limit)    */
  int_T         logDecimation;      /* Data logging interval                  */

  const char_T  *logVarNameModifier;/* pre(post)fix string modifier for the   *
                                     * log variable names                     */

  const char_T  *logT;              /* Name of variable to log time           */
  const char_T  *logX;              /* Name of variable to log states         */
  const char_T  *logXFinal;         /* Name of varaible to log final state    */
  const char_T  *logY;              /* Name of variable(s) to log outputs     */

  const RTWLogSignalInfo *logXSignalInfo;/* Info about the states             */
  const RTWLogSignalInfo *logYSignalInfo;/* Info about the outptus            */

  void (*mdlLogData)(void *rtli, void *tPtr);

  const void * mmi;    /* Add the ModelMapping Info to the LogInfo 
                        * so we can get at it for state logging */


} RTWLogInfo;

#endif

/* Macros associated with RTWLogInfo */
#define rtliGetLogInfo(rtli)     ((LogInfo*)(rtli)->logInfo)
#define rtliSetLogInfo(rtli,ptr) ((rtli)->logInfo = ((void *)ptr))

#define rtliGetLogFormat(rtli)   (rtli)->logFormat
#define rtliSetLogFormat(rtli,f) ((rtli)->logFormat = (f))

#define rtliGetLogVarNameModifier(rtli)      (rtli)->logVarNameModifier
#define rtliSetLogVarNameModifier(rtli,name) ((rtli)->logVarNameModifier=(name))

#define rtliGetLogMaxRows(rtli)     (rtli)->logMaxRows
#define rtliSetLogMaxRows(rtli,num) ((rtli)->logMaxRows = (num))

#define rtliGetLogDecimation(rtli)   (rtli)->logDecimation
#define rtliSetLogDecimation(rtli,l) ((rtli)->logDecimation = (l))

#define rtliGetLogT(rtli)     (rtli)->logT
#define rtliSetLogT(rtli,lt)  ((rtli)->logT = (lt))

#define rtliGetLogX(rtli)     (rtli)->logX
#define rtliSetLogX(rtli,lx)  ((rtli)->logX = (lx))

#define rtliGetLogY(rtli)     (rtli)->logY
#define rtliSetLogY(rtli,ly)  ((rtli)->logY = (ly))

#define rtliGetLogXFinal(rtli)     (rtli)->logXFinal
#define rtliSetLogXFinal(rtli,lxf) ((rtli)->logXFinal = (lxf))

#define rtliGetLogXSignalInfo(rtli)     (rtli)->logXSignalInfo
#define rtliSetLogXSignalInfo(rtli,lxi) ((rtli)->logXSignalInfo = (lxi))

#define rtliGetLogYSignalInfo(rtli)     (rtli)->logYSignalInfo
#define rtliSetLogYSignalInfo(rtli,lyi) ((rtli)->logYSignalInfo = (lyi))

#define rtliGetLogXSignalPtrs(rtli)     (rtli)->logXSignalPtrs
#define rtliSetLogXSignalPtrs(rtli,lxp) ((rtli)->logXSignalPtrs = (lxp))

#define rtliGetLogYSignalPtrs(rtli)     (rtli)->logYSignalPtrs
#define rtliSetLogYSignalPtrs(rtli,lyp) ((rtli)->logYSignalPtrs = (lyp))
#define rtliGetMMI(rtli)     (rtli)->mmi
#define rtliSetMMI(rtli,mmiIn) ((rtli)->mmi = ((void *)mmiIn))

/* ========================================================================== */

#endif /* __RTW_MATLOGGING_H__ */

