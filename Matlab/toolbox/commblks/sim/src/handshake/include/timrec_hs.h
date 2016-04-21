/*
 *  File: timrec_hs.h
 * 
 *  Header for the Attribute propagation functions for Timing phase recovery 
 *  blocks.
 *
 *  Copyright 1996-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2003/06/03 15:52:06 $
 */

#ifndef timrec_hs_h
#define timrec_hs_h

#include <math.h>
#include "comm_defs.h"

/* List input & output ports */
enum {INPORT = 0, RSTPORT};   /* RESET is an optional port */
enum {OUTPORT1 = 0, OUTPORT2,  NUM_OUTPORTS};

/* Reset options */
enum {NO_RESET = 1, RESET_EVERY_FRAME, RESET_PORT};

/* List the common mask parameters */
enum {SAMP_PER_SYMB_ARGC = 0, PROP_GAIN_ARGC, RESET_ARGC}; 

#define SAMP_PER_SYMB_ARG(S) (ssGetSFcnParam(S, SAMP_PER_SYMB_ARGC))
#define PROP_GAIN_ARG(S)     (ssGetSFcnParam(S, PROP_GAIN_ARGC))
#define RESET_ARG(S)         (ssGetSFcnParam(S, RESET_ARGC))

#define HAS_RST_PORT(S)      ((int_T)(mxGetPr(RESET_ARG(S))[0]) == RESET_PORT)


/* Propagation Function prototypes */
void timRecSetInputPortSampleTime(SimStruct *S,
                                  int_T     portIdx,
                                  real_T    sampleTime,
                                  real_T    offsetTime);
                                  
void timRecSetOutputPortSampleTime(SimStruct *S,
                                   int_T     portIdx,
                                   real_T    sampleTime,
                                   real_T    offsetTime);
                                   
void timRecSetInputPortFrameData(SimStruct *S,
                                 int_T portIdx,
                                 Frame_T frameData);
                                 
void setInputPortDimensions(SimStruct *S, int_T portIdx, 
                            int_T numDims, int_T inRows, int_T inCols);

void setOutputPortDimensions(SimStruct *S, int_T portIdx,
                             int_T numDims, int_T outRows, int_T outCols);    

void timRecSetInputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo);

void timRecSetOutputPortDimensionInfo(SimStruct *S, int_T portIdx,
                                      const DimsInfo_T *dimsInfo);

#endif /* EOF */
