/* $Revision: 1.2.4.2 $ */
#ifndef __SFC_TELEMETRY_H__
#define __SFC_TELEMETRY_H__

 /* Copyright 1995-2003 The MathWorks, Inc. */

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {     
     STATE_LOG_NONE           =0
    ,STATE_LOG_INITIAL        =1
    ,STATE_LOG_FINAL          =2
    ,STATE_LOG_PROCESSED      =4
}SFTelemetryStateLogOptionEnum;

typedef enum {
     TRANSITION_LOG_NONE      =0
    ,TRANSITION_LOG_TAKEN     =1
}SFTelemetryTransitionLogOptionEnum;

typedef enum {
     DATA_LOG_NONE                =0 
    ,DATA_LOG_ALL                 =1 
    ,DATA_LOG_TOUCHED_LHS         =2 
    ,DATA_LOG_TOUCHED_RHS         =4 
    ,DATA_LOG_TOUCHED_PREDICATE   =8
    ,DATA_LOG_INITIAL             =16
    ,DATA_LOG_FINAL               =32
}SFTelemetryDataLogOptionEnum;
#define SF_IS_BIT_SET(bitVector,index)  (((bitVector)[(index)>>3] & (1 << ((index)&7)))!=0)
#define SF_SET_BIT(bitVector,index)     ((bitVector)[(index)>>3] |= (1 << ((index)&7)))
#define SF_CLEAR_BIT(bitVector,index)   ((bitVector)[(index)>>3] &= ~(1 << ((index)&7)))
#define sf_telemetry_flags(var,flag) ((var&(flag))!=0) 

typedef enum {
    SF_UNKNOWN_TYPE=0,
	SF_BOOLEAN_TYPE,
	SF_STATE_TYPE,
	SF_UINT8_TYPE,
	SF_INT8_TYPE,
	SF_UINT16_TYPE,
	SF_INT16_TYPE,
	SF_UINT32_TYPE,
	SF_INT32_TYPE,
	SF_SINGLE_TYPE,
    SF_DOUBLE_TYPE
}SfDataTypeEnum;

#ifdef __cplusplus
}
#endif

#endif
