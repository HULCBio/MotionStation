/*
 * File: can_frame_splitter.c
 *
 * Abstract:
 *   S-function to take a CAN frame & output its data and/or ID fields.
 *
 * Design ref:  A157
 *
 * Author:      Chris Thorpe, The MathWorks Ltd
 *
 * $Revision: 1.9.4.2 $
 * $Date: 2004/04/19 01:20:01 $
 *
 * Copyright 2001-2003 The MathWorks, Inc.
 */


#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
#endif       // defined within this scope                     

#define S_FUNCTION_NAME sfun_can_frame_splitter
#define S_FUNCTION_LEVEL 2


#include "simstruc.h"
#include "can_msg.h"
#include "sfun_can_util.h"
#include "endian_test.hpp"


    /* -----DIRECTIVES----------------------------------------------- */


    enum {SHOW_DATA=0,SHOW_ID,SHOW_LENGTH,E_ENDIAN,NUM_PARAMS};

#define P_REF(pID)     mxGetPr(ssGetSFcnParam(S,(pID)))
#define P_INT(pID,idx) ( (int_T)mxGetPr(ssGetSFcnParam(S,(pID)))[(idx)] )
#define P_LEN(pID)     ( mxGetNumberOfElements(ssGetSFcnParam(S,(pID))) )

#define P_SHOW_DATA     P_INT(SHOW_DATA,0)
#define P_SHOW_ID       P_INT(SHOW_ID,0)
#define P_SHOW_LENGTH   P_INT(SHOW_LENGTH,0)
#define P_ENDIAN        P_INT(E_ENDIAN,0)

#define MAX_PAYLOAD_LEN 8

    /* -----LOCAL DECLARATIONS-------------------------------------- */

    static boolean_T isAcceptableDataType(SimStruct *, DTypeId);
    static boolean_T isAcceptableOutputDataType(SimStruct *, DTypeId,int portWidth);



    /* -----OPTIONAL FUNCTIONS-------------------------------------- */


    static boolean_T isAcceptableDataType(SimStruct * S, DTypeId dataType) {

        int_T     canExDT      = ssGetDataTypeId(S,SL_CAN_EXTENDED_FRAME_DTYPE_NAME );
        int_T     canStDT      = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );
        boolean_T isAcceptable = (dataType == canExDT || dataType == canStDT );

        return isAcceptable;
    }

    /*====================*
     * User - Methods
     *====================*/
    static boolean_T isAcceptableOutputDataType(SimStruct * S, DTypeId dataType,int portWidth){
        switch ( dataType ){
            case SS_UINT8:
            case SS_INT8:
                if (portWidth<=8){
                    return true;
                }else{
                    return false;
                }
            case SS_UINT16:
            case SS_INT16:
                if(portWidth<=4){
                    return true;
                }else{
                    return false;
                }
            case SS_UINT32:
            case SS_INT32:
                if(portWidth<=2){
                    return true;
                }else{
                    return false;
                }
            case SS_SINGLE:
                if(portWidth<=2){
                    return true;
                }else{
                    return false;
                }
            default:
                return false;
        }
    }

#ifdef MATLAB_MEX_FILE

#define MDL_SET_INPUT_PORT_DATA_TYPE
    static void mdlSetInputPortDataType(SimStruct *S, int_T port, DTypeId dataType) {

        if ( port == 0 ) {
            if( isAcceptableDataType( S, dataType ) ) {
                /*
                 * Accept proposed data type if it is an unsigned integer type
                 * force all data ports to use this data type.
                 */
                ssSetInputPortDataType(  S, 0, dataType );

            } else {
                /* Reject proposed data type */
                ssSetErrorStatus(S,"Invalid input signal data type.");
                goto EXIT_POINT;
            }
        } else {
            /*
             * Should not end up here.  Simulink will only call this function
             * for existing input ports whose data types are unknown.
             */
            ssSetErrorStatus(S, "Error setting input port data type.");
            goto EXIT_POINT;
        }

EXIT_POINT:
        return;
    } /* mdlSetInputPortDataType */


    /* Function: mdlSetOutputPortDataType ==========================================
     * Abstract:
     *
     */
#define MDL_SET_OUTPUT_PORT_DATA_TYPE
    static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dType)
    {
        int portWidth;
        
		  // set up the data-port data type 
		  if (P_SHOW_DATA) {
				// data port is port 0
				if (port == 0) {
					portWidth = ssGetOutputPortWidth(S,port);
            	if (isAcceptableOutputDataType(S,dType,portWidth)){
               	ssSetOutputPortDataType(S,port,dType);
	            }else{
   	             ssSetErrorStatus(S,"Incompatible DataType or Size specified");
      	      }
				}
		  }
    }



#define MDL_SET_DEFAULT_PORT_DATA_TYPES
    static void mdlSetDefaultPortDataTypes(SimStruct *S) {

        int_T canStDT = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );
        int dataPort;
        if ( ssGetInputPortDataType(S,0) == DYNAMICALLY_TYPED ){
            ssSetInputPortDataType(  S, 0, canStDT );
        }

        if (P_SHOW_DATA ){
            dataPort = 0;
            if ( ssGetOutputPortDataType(S,dataPort)==DYNAMICALLY_TYPED){
                ssSetOutputPortDataType(S,dataPort,SS_UINT8);
            }
        }

    } /* mdlSetDefaultPortDataTypes */

#endif /* MATLAB_MEX_FILE */


    /* -----MANDATORY FUNCTIONS--------------------------------------- */


    /* mdlInitializeSizes() */
    static void mdlInitializeSizes(SimStruct *S) {

        // A counting variable
        int idx;

        // The number of output ports required
        int nOP = 0;

        // The current output port
        int cOP = 0;


        /* Register the custom CAN data types */
        CAN_Common_MdlInitSizes(S);

        ssSetNumSFcnParams(S,NUM_PARAMS);

        // No parameters will be tunable
        for(idx=0; idx<NUM_PARAMS; idx++){
            ssSetSFcnParamNotTunable(S,idx);
        }

#if defined (MATLAB_MEX_FILE)

        if(ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            return; /* Simulink will report a mismatch error */
        }

#endif /* MATLAB_MEX_FILE */

        ssSetNumInputPorts               (S,1);
        ssSetInputPortWidth              (S,0,1);
        ssSetInputPortDirectFeedThrough  (S,0,1);
        ssSetInputPortDataType           (S,0,DYNAMICALLY_TYPED);

        nOP += P_SHOW_ID;       
        nOP += P_SHOW_LENGTH;
        nOP += P_SHOW_DATA;
        ssSetNumOutputPorts(S,nOP);

        // Set the current output port to zero
        cOP = 0; 

		  if(P_SHOW_DATA){
            ssSetOutputPortDataType(S,cOP,DYNAMICALLY_TYPED);
            ssSetOutputPortWidth(S,cOP++,DYNAMICALLY_SIZED);
        }
		  
        if(P_SHOW_ID){
            ssSetOutputPortDataType (S,cOP,SS_UINT32);
            ssSetOutputPortWidth(S,cOP++,1);
        }

        if(P_SHOW_LENGTH){
            ssSetOutputPortDataType (S,cOP,SS_UINT32);
            ssSetOutputPortWidth(S,cOP++,1);
        }

        

        ssSetNumSampleTimes              (S,1);
        /* currently accelerator mode does not provide the endian
         * and word size settings required - this should change in the future */
         //ssSetOptions                     (S,SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_USE_TLC_WITH_ACCELERATOR);
         ssSetOptions                     (S,SS_OPTION_EXCEPTION_FREE_CODE);
    }


    /* mdlInitializeSampleTimes() */
    static void mdlInitializeSampleTimes(SimStruct *S) {

        ssSetSampleTime                  (S,0,INHERITED_SAMPLE_TIME);
        ssSetOffsetTime                  (S,0,0.0);
    }


    /* mdlOutputs() */
    static void mdlOutputs(SimStruct *S, int_T tid) {

        CAN_FRAME **  frames  = (CAN_FRAME **)ssGetInputPortSignalPtrs(S,0);

        uint8_T *      data_output;
        uint32_T *    id_output;
        uint32_T *    length_output;

        int_T         payload_len;


        // The number of output ports required
        int nOP = 0;

        // The current output port
        int cOP = 0;

        // Check that the payload is a valid size
        payload_len = frames[0]->LENGTH;
        if (payload_len < 0 || payload_len > MAX_PAYLOAD_LEN) {
            ssSetErrorStatus(S,"Invalid input frame payload length.");
            return;
        }

        if ( P_SHOW_DATA){
            DTypeId dtypeID = ssGetOutputPortDataType(S,cOP);
            int_T outWidth  = ssGetDataTypeSize(S, dtypeID) * ssGetOutputPortWidth(S,cOP);
            int_T idx_end = payload_len < outWidth ? payload_len : outWidth;
            int idx;

            data_output = (unsigned char * ) ssGetOutputPortSignal(S,cOP);
            if (P_ENDIAN == CPU_ENDIAN ){
                memcpy(data_output,&(frames[0]->DATA[0]),idx_end);
            }else{
                int idx;
                int dataTypeSize,portWidth,signals,offset;

                dataTypeSize = ssGetDataTypeSize(S,ssGetOutputPortDataType(S,cOP));
                portWidth = ssGetOutputPortWidth(S,cOP);

                for ( signals = 0; signals < portWidth; signals ++ ){
                    offset = signals * dataTypeSize;
                    for ( idx=0;idx< dataTypeSize;idx++ ){
                        ((uint8_T *)(data_output))[idx+offset]=
                            frames[0]->DATA[offset+dataTypeSize-idx-1];
                    }
                }
            }

            /* Zero the remaining elements in the output if there are any */
            for ( idx=idx_end; idx < outWidth; idx++ ){
                ((uint8_T *)(data_output))[idx]=0;
            }
            cOP++;
        }
		  
		  if(P_SHOW_ID){
            id_output = (uint32_T *)ssGetOutputPortSignal(S,cOP);
            *id_output = frames[0]->ID;
            cOP++;
        }

        if(P_SHOW_LENGTH){
            length_output = (uint32_T *)ssGetOutputPortSignal(S,cOP);
            *length_output = frames[0]->LENGTH;
            cOP++;
        }
    }

#define MDL_RTW  /* Change to #undef to remove function */
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
    static void mdlRTW(SimStruct *S)
    {
        boolean_T showData   = P_SHOW_DATA;
        boolean_T showID     = P_SHOW_ID;
        boolean_T showLength = P_SHOW_LENGTH;
        uint32_T       endian     = P_ENDIAN;
        ssWriteRTWParamSettings(S,4,

                SSWRITE_VALUE_DTYPE_NUM, "ShowID",
                &showID,
                DTINFO(SS_BOOLEAN,0),

                SSWRITE_VALUE_DTYPE_NUM, "ShowLength",
                &showLength,
                DTINFO(SS_BOOLEAN,0),

                SSWRITE_VALUE_DTYPE_NUM, "ShowData",
                &showData,
                DTINFO(SS_BOOLEAN,0),

                SSWRITE_VALUE_DTYPE_NUM, "Endian",
                &endian,
                DTINFO(SS_UINT32,0)

                );
    }
#endif

    /* mdlTerminate() is called at the end of the simulation run to clean up.
       A stub function must be provided even if it is not actually used.  */
    static void mdlTerminate(SimStruct *S) {
        /* empty */
    }


    /*----FINAL DIRECTIVES------------------------------------------ */

    /* These preprocessor directives are always required at the end of the file. */

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif

#ifdef __cplusplus
} // end of extern "C" scope
#endif

/* [EOF] */
