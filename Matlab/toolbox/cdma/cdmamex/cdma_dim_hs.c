/*
 * File: cdma_dim_hs.c
 *
 *  Used to implement the Dimensions handshake for CDMA Reference Blockset
 *  as defined in cdma_frm.c.
 *
 *  Typical usage:
 *    Instead of defining mdlSetInputPortDimensionInfo(), etc.,
 *     simply include:
 *          #include "cdma_dim_hs.c"
 *    Assumes 4 const macros to be defined in calling file:
 *           NUM_INPORTS_TO_SET  
 *           FIRST_INPORTIDX_TO_SET 
 *           NUM_OUTPORTS_TO_SET 
 *           TOTAL_PORTS_TO_SET  
 *
 *
 *  Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.3 $ $Date: 2002/04/14 16:33:14 $
 */
 
#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port,
                                      const DimsInfo_T *dimsInfo)
{	
	int widths[TOTAL_PORTS_TO_SET]; 
    detAllPortWidths(S, widths);

    /* Set all port dimensions */
    if(!cdmaSetAllPortsDimensions(S, port, dimsInfo, true,
                                  widths,                      /*Input widths*/
                                  NUM_INPORTS_TO_SET,                         
                                  &widths[NUM_INPORTS_TO_SET],/*Output widths*/
                                  NUM_OUTPORTS_TO_SET,   
                                  FIRST_INPORTIDX_TO_SET)) return;
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port,
                                          const DimsInfo_T *dimsInfo)
{
	int widths[TOTAL_PORTS_TO_SET]; 
    detAllPortWidths(S, widths);

    /* Set all port dimensions */
    if(!cdmaSetAllPortsDimensions(S, port, dimsInfo, false,
                                  widths,                     /*Input widths*/
                                  NUM_INPORTS_TO_SET,	
                                  &widths[NUM_INPORTS_TO_SET],/*Output widths*/
                                  NUM_OUTPORTS_TO_SET,  
                                  FIRST_INPORTIDX_TO_SET)) return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    int port = FIRST_INPORTIDX_TO_SET; 
	int widths[TOTAL_PORTS_TO_SET];

    /* initialize a dynamically-dimensioned DimsInfo_T */
    DECL_AND_INIT_DIMSINFO(dInfo); 

    detAllPortWidths(S, widths);

    /* select valid inport dimensions, sample-based mode */
    dInfo.width     = widths[port];
    dInfo.numDims   = 1;
    dInfo.dims      = &widths[port];

    /* call the input function */
    mdlSetInputPortDimensionInfo(S, port, &dInfo);
}
#endif

/* [EOF] */
