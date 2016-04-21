/* $Revision: 1.3 $ $Date: 2002/03/25 04:01:54 $ */
/* canac2104setup_mb1.c - xPC Target, non-inlined S-function driver for CAN-AC2-104 from Softing (multi board)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define DEBUG 0

#define MB_BOARD 3

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	canac2104setup_mb3

#include 	<stddef.h>
#include 	<stdlib.h>

#ifndef 	MATLAB_MEX_FILE
#define 	WIN32
#include 	"can_def_mb3.h"
#include 	"canlay2_mb3.h" 
#undef 		WIN32
#endif

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"time_xpcimport.h"
#endif


#define 	NUMBER_OF_ARGS          	(19)
#define 	CAN1_USER_BAUDRATE_ARG      ssGetSFcnParam(S,0)
#define 	CAN2_USER_BAUDRATE_ARG      ssGetSFcnParam(S,1)
#define 	CAN1_SEND_ARG               ssGetSFcnParam(S,2)
#define 	CAN1_RECEIVE_ARG            ssGetSFcnParam(S,3)
#define 	CAN2_SEND_ARG               ssGetSFcnParam(S,4)
#define 	CAN2_RECEIVE_ARG            ssGetSFcnParam(S,5)
#define 	CAN1_SENDE_ARG              ssGetSFcnParam(S,6)
#define 	CAN1_RECEIVEE_ARG           ssGetSFcnParam(S,7)
#define 	CAN2_SENDE_ARG              ssGetSFcnParam(S,8)
#define 	CAN2_RECEIVEE_ARG           ssGetSFcnParam(S,9)
#define 	CAN1_INTS_ARG           	ssGetSFcnParam(S,10)
#define 	CAN1_INTE_ARG           	ssGetSFcnParam(S,11)
#define 	CAN2_INTS_ARG           	ssGetSFcnParam(S,12)
#define 	CAN2_INTE_ARG           	ssGetSFcnParam(S,13)
#define 	CAN_INIT_ARG           		ssGetSFcnParam(S,14)
#define 	CAN_TERM_ARG           		ssGetSFcnParam(S,15)
#define 	IO_BASE_ADDRESS_ARG         ssGetSFcnParam(S,16)
#define 	MEM_BASE_ADDRESS_ARG        ssGetSFcnParam(S,17)
#define 	INTNO_ARG        			ssGetSFcnParam(S,18)

#define 	NO_I_WORKS                  (0)
#define 	NO_R_WORKS                  (0)

#define 	MAX_OBJECTS 				200
#define 	MAX_IDS						2031
#define 	MAX_IDS_EXT  				536870911

// Acceptance filter
#define		ACCEPT_MASK_1				0x0000
#define		ACCEPT_CODE_1 				0x0000
#define		ACCEPT_MASK_XTD_1			0x00000000L
#define		ACCEPT_CODE_XTD_1			0x00000000L

#define		ACCEPT_MASK_2				0x0000
#define		ACCEPT_CODE_2 				0x0000
#define		ACCEPT_MASK_XTD_2			0x00000000L
#define		ACCEPT_CODE_XTD_2			0x00000000L
                                           

// Resynchronization
#define		SLEEPMODE_1					0
#define		SPEEDMODE_1					0
                                           
#define		SLEEPMODE_2					0
#define		SPEEDMODE_2					0


// Phys. layer (-1: default - CAN High Speed)
#define		OUTPUT_CONTROL_1			-1                                           
#define		OUTPUT_CONTROL_2			-1  


static char_T msg[256];

#ifndef MATLAB_MEX_FILE

static int CANAC2_FIRMWARE_LOADED_mb3;

// Routine to evaluate error codes of CANPC_initialize_board
static void printInitErrorText(int iErrorCode)
{
    printf("ErrorCode=%x  Error Text:", iErrorCode);
    switch((unsigned int)iErrorCode)
    {
      case  INIPC_IB_PNP_NO_DEVICE_FOUND:
         printf("no can device found ");
         break;
     case  INIPC_IB_ERR_VC_INTERNALERROR:
         printf("internal error ");
         break;
     case  INIPC_IB_ERR_VC_GENERALERROR:
         printf("general error ");
         break;
     case  INIPC_IB_ERR_VC_TIMEOUT:
         printf("Timeout ");
         break;
     case  INIPC_IB_ERR_VC_IOPENDING:
         printf("driver call pending ");
         break;
     case  INIPC_IB_ERR_VC_IOCANCELLED:
         printf("driver call cancelled ");
         break;
     case  INIPC_IB_ERR_VC_ILLEGALCALL:
         printf("illegal driver call ");
         break;
     case  INIPC_IB_ERR_VC_NOTSUPPORTED:
         printf("driver call not supported ");
         break;
     case  INIPC_IB_ERR_VC_VERSIONERROR:
         printf("wrong driver-dll version ");
         break;
     case  INIPC_IB_ERR_VC_DRIVERVERSIONERROR:
         printf("wrong driver version ");
         break;
     case  INIPC_IB_ERR_VC_DRIVERNOTFOUND:
         printf("driver not found ");
         break;
     case  INIPC_IB_ERR_VC_NOTENOUGHMEMORY:
         printf("not enough memory ");
         break;
     case  INIPC_IB_ERR_VC_TOOMANYDEVICES:
         printf("too many devices ");
         break;
     case  INIPC_IB_ERR_VC_UNKNOWNDEVICE:
         printf("unknown device ");
         break;
     case  INIPC_IB_ERR_VC_DEVICEALREADYEXISTS:
         printf("Device ardy exists ");
         break;
     case  INIPC_IB_ERR_VC_DEVICEACCESSERROR:
         printf("device ardy open ");
         break;
     case  INIPC_IB_ERR_VC_RESOURCEALREADYREGISTERED:
         printf("Resource in use");
         break;
     case  INIPC_IB_ERR_VC_RESOURCECONFLICT:
         printf("Resource-conflict ");
         break;
     case  INIPC_IB_ERR_VC_RESOURCEACCESSERROR:
         printf("Resource access_mb3 error");
         break;
     case  INIPC_IB_ERR_VC_PHYSMEMORYOVERRUN:
         printf("invalid phys.mem-access_mb3");
         break;
     case  INIPC_IB_ERR_VC_TOOMANYPORTS:
         printf("too many I/O ports ");
         break;
     case  INIPC_IB_ERR_VC_UNKNOWNRESOURCE:
         printf("unknown resource ");
         break;
     default:
         printf("unknown return value !");
         break;
     }
     printf ("\n");
}

// Routine to evaluate error codes of CANPC_reset_board_mb3
static void printResetErrorText(int iErrorCode)
{
    printf("ErrorCode=%d  Error Text:", iErrorCode);
    switch(iErrorCode)
    {
     case CANPC_RB_INI_FILE:
          printf(" can't open IniFile       ");              
     case CANPC_RB_ERR_FMT_INI:
          printf(" format error in INI-file ");    
     case CANPC_RB_ERR_OP_BIN:
          printf(" error opening binary-file");    
     case CANPC_RB_ERR_RD_BIN: 
          printf(" error reading binary-file");    
     case CANPC_RB_BIN_TOO_LONG:
          printf(" binary-file too long     ");    

     case CANPC_RB_ERR_BIN_FMT: 
          printf(" binary-data format error ");    
         break;
     case CANPC_RB_ERR_BIN_CS:
          printf(" binary-data checksum error      ");   
         break;
     case CANPC_RB_NO_CARD:  
          printf(" no card present          ");    
         break;
     case CANPC_RB_NO_PHYS_MEM:
          printf(" no physical memory       ");    
         break;
     case CANPC_RB_INVLD_IRQ:  
          printf(" invalid IRQ-number       ");    
         break;
     case CANPC_RB_ERR_DPRAM_ACCESS:
          printf(" error accessing dpram    ");    
         break;
     case CANPC_RB_ERR_CRD_RESP: 
          printf(" bad response from card   ");    
         break;
     case CANPC_RB_ERR_SRAM:
          printf(" sram seems to be damaged ");    
         break;
     case CANPC_RB_ERR_PRG:
          printf(" invalid program start address   ");   
         break;
     case CANPC_RB_ERR_REC:
          printf(" invalid record type      ");    
         break;
     case CANPC_RB_ERR_NORESP:
          printf(" no response after program start ");   
         break;
     case CANPC_RB_ERR_BADRESP:
          printf(" bad response after program start");   
         break;
     case CANPC_RB_PCMCIA_NSUPP:
          printf(" pcmcia chip not supported");    
         break;
     case CANPC_RB_ERR_RD_PCMCIA:
          printf(" error reading ocmcia parameters ");   
         break;
     case CANPC_RB_INIT_CHIP:
          printf(" error initializing chip  ");    
         break;
     default:
         printf("return value ");
         break;
    }
    printf("\n");
}


static int  Initialize_can_parameter(SimStruct *S)
{
	int sw_version;
	int fw_version;
	int hw_version;
	int license;
	int can_chip_type[2];
	int presc, sjw, tseg1, tseg2;
	int baud;


   	// Reset CAN chips of CAN 1 and 2
   	if (CANPC_reset_chip_mb3() != 0) {
    	printf("-->Error in CANPC_reset_chip_mb3 \n");
      	return(-1);
   	}

   	// Display SW and HW version, chip type and licence (optionally)
   	if (CANPC_get_version_mb3(&sw_version,&fw_version,&hw_version,&license,can_chip_type) != 0) {
      	printf("-->Error in CANPC_get_version_mb3 \n\n\n");
      	return(-1);
   	} else {
      	//printf("Software version: %u.%02u \n", sw_version / 100, sw_version % 100);
      	//printf("Firmware version: %u.%02u \n", fw_version / 100, fw_version % 100);
      	//printf("Hardware version: %x.%02x \n", hw_version % 0x100, hw_version / 0x100);
      	if (license & 0x02)
      		printf("CANcard licensed for CANalyzer \n");
      	if (license & 0x04)
         	printf("CANcard licensed for DDE Server \n");
      	//printf("CAN chip 1: %03d CAN chip 2: %03d \n\n", can_chip_type[0], can_chip_type[1]);
   	}                                         
	        
   	// Set Bit timing for CAN 1 and 2
	presc=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[0];
	sjw=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[1];
	tseg1=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[2];
	tseg2=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[3];
	
	if (CANPC_initialize_chip_mb3(presc, sjw, tseg1, tseg2, 0) != 0) {
      	printf("-->Error in CANPC_initialize_chip_mb3 \n");
      	return(-1);
    }

	presc=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[0];
	sjw=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[1];
	tseg1=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[2];
	tseg2=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[3];

   	if (CANPC_initialize_chip2_mb3(presc, sjw, tseg1, tseg2, 0) != 0) {
      	printf("-->Error in CANPC_initialize_chip2_mb3 \n");
      	return(-1);
    }

	// Set acceptance filter for CAN 1 and 2   
   	if (CANPC_set_acceptance_mb3(ACCEPT_MASK_1, ACCEPT_CODE_1, ACCEPT_MASK_XTD_1, ACCEPT_CODE_XTD_1) != 0) {
     	printf("-->Error in CANPC_set_acceptance_mb3 \n");
      	return(-1);
    }

   	if (CANPC_set_acceptance2_mb3(ACCEPT_MASK_2, ACCEPT_CODE_2, ACCEPT_MASK_XTD_2, ACCEPT_CODE_XTD_2) != 0) {
      	printf("-->Error in CANPC_set_acceptance2_mb3 \n");
      	return(-1);
    }

   	// Set resynchronization
   	if (CANPC_set_mode_mb3(SLEEPMODE_1, SPEEDMODE_1) != 0) {
      	printf("-->Error in CANPC_set_mode_mb3 \n");
      	return(-1);
    }

   	if (CANPC_set_mode2_mb3(SLEEPMODE_2, SPEEDMODE_2) != 0) {
      	printf("-->Error in CANPC_set_mode2_mb3 \n");
      	return(-1);
    }

   	// Set output control (phys. layer -1: default  CAN High Speed)                               
   	if (CANPC_set_output_control_mb3(OUTPUT_CONTROL_1) != 0) {
      	printf("-->Error in CANPC_set_output_control_mb3 \n");
      	return(-1);
    }

   	if (CANPC_set_output_control2_mb3(OUTPUT_CONTROL_2) != 0) {
      	printf("-->Error in CANPC_set_output_control2_mb3 \n");
      	return(-1);
    }

	return(0);

}

#endif



static void mdlInitializeSizes(SimStruct *S)
{

	int_T i;

#ifndef MATLAB_MEX_FILE
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumInputPorts(S, 0);
    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	for (i=0;i<NUMBER_OF_ARGS;i++) {
		ssSetSFcnParamNotTunable(S,i);
	}

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

        
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
	ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

	int_T 			msg_id;
    int_T 			i,j,n;
	CANPC_RESSOURCES crRessources;
	int 			ret;

	int  			ReceiveFifoEnable;
	int  			ReceivePollAll;
	int  			ReceiveEnableAll;
	int  			ReceiveIntEnableAll;
	int  			AutoRemoteEnableAll;
	int  			TransmitReqFifoEnable;
	int  			TransmitPollAll;
	int  			TransmitAckEnableAll;
	int  			TransmitAckFifoEnableAll;
	int  			TransmitRmtFifoEnableAll;

	int  			Type;
	int  			ReceiveIntEnable;
	int  			AutoRemoteEnable;
	int  			TransmitAckEnable;

	unsigned long	Identifier;

	int				index;
	int				frc;
	double			timetmp;
	int				test;
	int_T 			intNo_mb3;

		

	crRessources.uIOAdress= (int_T)mxGetPr(IO_BASE_ADDRESS_ARG)[0];
	crRessources.uInterrupt= (int_T)mxGetPr(INTNO_ARG)[0];
	crRessources.uRegisterBase= 1;
	crRessources.ulDPRMemBase= (int_T)mxGetPr(MEM_BASE_ADDRESS_ARG)[0];

	if (!CANAC2_FIRMWARE_LOADED_mb3) {

		if ((ret = INIPC_initialize_board_mb3(&crRessources)) != 0) {
    		sprintf(msg,"CAN-AC-104: I/O Base Address may be wrong");
        	ssSetErrorStatus(S,msg);
			return;
		}

		// Load firmware
		printf("        downloading CAN-AC2-104 firmware on B3...\n");
		if ((ret = CANPC_reset_board_mb3()) != 0) {
   			printf("-->Error in CANPC_reset_board_mb3: ");
   			printResetErrorText(ret);
   			return;
		}
		printf("        downloading CAN-AC2-104 firmware finished\n");
		CANAC2_FIRMWARE_LOADED_mb3=1;
	    
	}

	// Initialization of the CAN parameters for CAN channel 1 and 2
	if (Initialize_can_parameter(S)) {
   		printf("-->Initialization failed \n");
   		return;
	}

	// Enable dynamic object buffer mode
	if (CANPC_enable_dyn_obj_buf_mb3() != 0) {
    	printf("-->Error in CANPC_enable_dyn_obj_buf_mb3 \n");
    	return;
   	}
	
	// Configuration of the object buffer
	ReceiveFifoEnable         = 0;  
	ReceivePollAll            = 0;
	ReceiveEnableAll          = 0;
	ReceiveIntEnableAll       = 0;
	AutoRemoteEnableAll       = 0;
	TransmitReqFifoEnable     = 1;  
	TransmitPollAll           = 0;
	TransmitAckEnableAll      = 0;
	TransmitAckFifoEnableAll  = 1;  
	TransmitRmtFifoEnableAll  = 1;

	 
	if (CANPC_initialize_interface_mb3(ReceiveFifoEnable,
	                               ReceivePollAll,
	                               ReceiveEnableAll,
	                               ReceiveIntEnableAll,
	                               AutoRemoteEnableAll,
	                               TransmitReqFifoEnable,
	                               TransmitPollAll,
	                               TransmitAckEnableAll,
	                               TransmitAckFifoEnableAll,
	                               TransmitRmtFifoEnableAll) != 0) {
		printf("-->Error in CANPC_initialize_interface_mb3 \n");
	    return;
	}

    // Define send and receive objects for CAN1 and CAN2

	ReceiveIntEnable  = 1;  
	AutoRemoteEnable  = 1;
	TransmitAckEnable = 0;

	test=0;
    // CAN1 send standard identifiers
	Type=1;
	for (i=0;i<mxGetN(CAN1_SEND_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN1_SEND_ARG)[i];
		if (CANPC_define_object_mb3(msg_id,
	                           	&index,
	                            Type,
	                            ReceiveIntEnable,
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	    	printf("-->Error in CANPC_define_object_mb3 for send objects CAN 1\n");
	        return;
	    }
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}
    // CAN1 send extended identifiers
	Type=3;
	for (i=0;i<mxGetN(CAN1_SENDE_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN1_SENDE_ARG)[i];
		if (CANPC_define_object_mb3(msg_id,
	                           	&index,
	                            Type,
	                            ReceiveIntEnable,
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	    	printf("-->Error in CANPC_define_object_mb3 for send objects CAN 1\n");
	        return;
	 	}
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}
	test=0;
    // CAN1 receive standard identifiers
	Type=0;
	for (i=0;i<mxGetN(CAN1_RECEIVE_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN1_RECEIVE_ARG)[i];
		if (CANPC_define_object_mb3(msg_id,
	                            &index,
	                          	Type,
	                            (int_T)mxGetPr(CAN1_INTS_ARG)[i],
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	   		printf("-->Error in CANPC_define_object_mb3 for receive objects CAN 1\n");
	        return;
	  	}
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}
    // CAN1 receive extended identifiers
	Type=2;
	for (i=0;i<mxGetN(CAN1_RECEIVEE_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN1_RECEIVEE_ARG)[i];
		if (CANPC_define_object_mb3(msg_id,
	                            &index,
	                          	Type,
	                            (int_T)mxGetPr(CAN1_INTE_ARG)[i],
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	   		printf("-->Error in CANPC_define_object_mb3 for receive objects CAN 1\n");
	        return;
	  	}
	}

	test=0;
    // CAN2 send standard identifiers
	Type=1;
	for (i=0;i<mxGetN(CAN2_SEND_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN2_SEND_ARG)[i];
		if (CANPC_define_object2_mb3(msg_id,
	                           	&index,
	                            Type,
	                            ReceiveIntEnable,
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	    	printf("-->Error in CANPC_define_object_mb3 for send objects CAN 2\n");
	        return;
	    }
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}
    // CAN2 send extended identifiers
	Type=3;
	for (i=0;i<mxGetN(CAN2_SENDE_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN2_SENDE_ARG)[i];
		if (CANPC_define_object2_mb3(msg_id,
	                           	&index,
	                            Type,
	                            ReceiveIntEnable,
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	    	printf("-->Error in CANPC_define_object_mb3 for send objects CAN 2\n");
	        return;
	 	}
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}
	test=0;
    // CAN2 receive standard identifiers
	Type=0;
	for (i=0;i<mxGetN(CAN2_RECEIVE_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN2_RECEIVE_ARG)[i];
		if (CANPC_define_object2_mb3(msg_id,
	                            &index,
	                          	Type,
	                            (int_T)mxGetPr(CAN2_INTS_ARG)[i],
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	   		printf("-->Error in CANPC_define_object_mb3 for receive objects CAN 2\n");
	        return;
	  	}
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}
    // CAN2 receive extended identifiers
	Type=2;
	for (i=0;i<mxGetN(CAN2_RECEIVEE_ARG);i++) {
		msg_id=(int_T)mxGetPr(CAN2_RECEIVE_ARG)[i];
		if (CANPC_define_object2_mb3(msg_id,
	                            &index,
	                          	Type,
	                            (int_T)mxGetPr(CAN2_INTE_ARG)[i],
	                            AutoRemoteEnable,
	                            TransmitAckEnable) != 0) {
	   		printf("-->Error in CANPC_define_object_mb3 for receive objects CAN 2\n");
	        return;
	  	}
		if (index!=test) {
			ssSetErrorStatus(S,"indexing assumption failed");
			return;
		}
		test++;
	}

	// Start Chip
	if (CANPC_start_chip_mb3() != 0) {
	 	printf("-->Error in CANPC_start_chip_mb3 \n");
	  	return;
	}

	// Excute Initialization if necessary

	{
		int_T 	start;
		uchar_T data[8];

		if ((int_T)mxGetPr(CAN_INIT_ARG)[0]) {

			start=1;

			for (i=0;i<(int_T)mxGetPr(CAN_INIT_ARG)[0];i++) {

				for(j=0;j<(int_T)mxGetPr(CAN_INIT_ARG)[start+3];j++) {
					data[j]=(uchar_T)mxGetPr(CAN_INIT_ARG)[start+4+j];
				}
				
				if (((int_T)mxGetPr(CAN_INIT_ARG)[start])==1) {  //CAN port 1
					frc = CANPC_write_object_mb3((int_T)mxGetPr(CAN_INIT_ARG)[start+2], (int_T)mxGetPr(CAN_INIT_ARG)[start+3], data);
					if (frc<0) {
						printf("ERROR:  CANPC_write_object_mb3 CAN 1: %d\n",frc);
						return;
					} 
				} else {
					frc = CANPC_write_object2_mb3((int_T)mxGetPr(CAN_INIT_ARG)[start+2], (int_T)mxGetPr(CAN_INIT_ARG)[start+3], data);
					if (frc<0) {
						printf("ERROR:  CANPC_write_object_mb3 CAN 1: %d\n",frc);
						return;
					} 
				}

            	//wait specified ms
				rl32eWaitDouble(mxGetPr(CAN_INIT_ARG)[start+12]);

				start+=13;

			}

		}

	}
				
					
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{        
}

/* Function to compute model update */
 
static void mdlTerminate(SimStruct *S)
{
            
#ifndef MATLAB_MEX_FILE

	// Excute Termination if necessary

	{
		int_T 	i,j,frc,start;
		uchar_T data[8];

		if ((int_T)mxGetPr(CAN_TERM_ARG)[0]) {

			start=1;

			for (i=0;i<(int_T)mxGetPr(CAN_TERM_ARG)[0];i++) {

				for (j=0;j<(int_T)mxGetPr(CAN_TERM_ARG)[start+3];j++) {
					data[j]=(uchar_T)mxGetPr(CAN_TERM_ARG)[start+4+j];
				}

				if (((int_T)mxGetPr(CAN_TERM_ARG)[start])==1) {  //CAN port 1
					frc = CANPC_write_object_mb3((int_T)mxGetPr(CAN_TERM_ARG)[start+2], (int_T)mxGetPr(CAN_TERM_ARG)[start+3], data);
					if (frc<0) {
						printf("ERROR:  CANPC_write_object_mb3 CAN 1: %d\n",frc);
						return;
					} 
				} else {
					frc = CANPC_write_object2_mb3((int_T)mxGetPr(CAN_TERM_ARG)[start+2], (int_T)mxGetPr(CAN_TERM_ARG)[start+3], data);
					if (frc<0) {
						printf("ERROR:  CANPC_write_object_mb3 CAN 1: %d\n",frc);
						return;
					} 
				}

            	//wait specified ms
				rl32eWaitDouble(mxGetPr(CAN_TERM_ARG)[start+12]);

				start+=13;

			}

		}

	}

 	// Reinitialize
	if (CANPC_reinitialize_mb3() != 0) {
    	printf("-->Error in CANPC_start_chip_mb3 \n");
		return;
	}

#endif
  
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif