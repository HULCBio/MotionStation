/* $Revision: 1.6 $ $Date: 2002/03/25 04:03:33 $ */
/* canac2pcisetup_mb2.c - xPC Target, non-inlined S-function driver for CAN-AC2-PCI from Softing (multi board)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define DEBUG 0

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME canac2pcisetup_mb2

#include <stddef.h>
#include <stdlib.h>

#ifndef MATLAB_MEX_FILE
#include "can_def.h"
#include "canlay2_pci_mb2.h" 
#endif

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          	(9)
#define CAN1_BAUDRATE_ARG           ssGetSFcnParam(S,0)
#define CAN1_USER_BAUDRATE_ARG      ssGetSFcnParam(S,1)
#define CAN2_BAUDRATE_ARG           ssGetSFcnParam(S,2)
#define CAN2_USER_BAUDRATE_ARG      ssGetSFcnParam(S,3)
#define CAN1_SEND_ARG               ssGetSFcnParam(S,4)
#define CAN1_RECEIVE_ARG            ssGetSFcnParam(S,5)
#define CAN2_SEND_ARG               ssGetSFcnParam(S,6)
#define CAN2_RECEIVE_ARG            ssGetSFcnParam(S,7)
#define PCI_DEV_ARG                 ssGetSFcnParam(S,8)



#define NO_I_WORKS                  (0)


#define NO_R_WORKS                  (0)

#define MAX_OBJECTS 				200
#define MAX_IDS						2031
#define MAX_IDS_EXT  				536870911

// Acceptance filter
#define	ACCEPT_MASK_1			0x0000
#define	ACCEPT_CODE_1 			0x0000
#define	ACCEPT_MASK_XTD_1		0x00000000L
#define	ACCEPT_CODE_XTD_1		0x00000000L

#define	ACCEPT_MASK_2			0x0000
#define	ACCEPT_CODE_2 			0x0000
#define	ACCEPT_MASK_XTD_2		0x00000000L
#define	ACCEPT_CODE_XTD_2		0x00000000L
                                           

// Resynchronization
#define	SLEEPMODE_1				0
#define	SPEEDMODE_1				0
                                           
#define	SLEEPMODE_2				0
#define	SPEEDMODE_2				0


// Phys. layer (-1: default - CAN High Speed)
#define	OUTPUT_CONTROL_1		-1                                           
#define	OUTPUT_CONTROL_2		-1  


static char_T msg[256];

#ifndef MATLAB_MEX_FILE

extern int CANAC2_FIRMWARE_LOADED_mb2;

extern int CANAC2_1_send_mb2[MAX_OBJECTS];
extern int CANAC2_1_receive_mb2[MAX_OBJECTS];
extern int CANAC2_2_send_mb2[MAX_OBJECTS];
extern int CANAC2_2_receive_mb2[MAX_OBJECTS];

extern int CANAC2_1_sendmaxindex_mb2;
extern int CANAC2_1_sendindex_mb2[MAX_OBJECTS];
extern int CANAC2_1_receivemaxindex_mb2;
extern int CANAC2_1_receiveindex_mb2[MAX_OBJECTS];
extern int CANAC2_2_sendmaxindex_mb2;
extern int CANAC2_2_sendindex_mb2[MAX_OBJECTS];
extern int CANAC2_2_receivemaxindex_mb2;
extern int CANAC2_2_receiveindex_mb2[MAX_OBJECTS];

typedef struct CANAC2_type_templ {
	int port;
	int identifier;
	unsigned char data[8];
	int no_bytes;
	int wait_ms;
} CANAC2_type;



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
         printf("Resource access error");
         break;
     case  INIPC_IB_ERR_VC_PHYSMEMORYOVERRUN:
         printf("invalid phys.mem-access");
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

// Routine to evaluate error codes of CANPC_reset_board_mb2
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


static int Initialize_can_parameter(SimStruct *S)
{
	int sw_version;
	int fw_version;
	int hw_version;
	int license;
	int can_chip_type[2];
	int presc, sjw, tseg1, tseg2;
	int baud;


   // Reset CAN chips of CAN 1 and 2
   if (CANPC_reset_chip_mb2() != 0) {
      printf("-->Error in CANPC_reset_chip_mb2 \n");
      return(-1);
   }
   //printf("CANPC_reset_chip_mb2 OK\n\n");

   // Display SW and HW version, chip type and licence (optionally)
   if (CANPC_get_version_mb2(&sw_version,&fw_version,&hw_version,&license,can_chip_type) != 0) {
      printf("-->Error in CANPC_get_version_mb2 \n\n\n");
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
   	baud=(int)mxGetPr(CAN1_BAUDRATE_ARG)[0];
   	switch (baud) {
		case 1:
			presc=1; sjw=1; tseg1=4; tseg2=3; break;
		case 2:
			presc=1; sjw=1; tseg1=6; tseg2=3; break;
		case 3:
			presc=1; sjw=1; tseg1=8; tseg2=7; break;
		case 4:
			presc=2; sjw=1; tseg1=8; tseg2=7; break;
		case 5:
			presc=4; sjw=1; tseg1=8; tseg2=7; break;
		case 6:
			presc=4; sjw=4; tseg1=11; tseg2=8; break;
		case 7:
			presc=32; sjw=4; tseg1=16; tseg2=8; break;
		case 8:
			presc=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[0];
			sjw=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[1];
			tseg1=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[2];
			tseg2=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[3];
			break;
		default:
			break;
	}

   	if (CANPC_initialize_chip_mb2(presc, sjw, tseg1, tseg2, 0) != 0) {
      	printf("-->Error in CANPC_initialize_chip_mb2 \n");
      	return(-1);
    }
   	//printf("CANPC_initialize_chip_mb2 OK\n");

	baud=(int)mxGetPr(CAN2_BAUDRATE_ARG)[0];
   	switch (baud) {
		case 1:
			presc=1; sjw=1; tseg1=4; tseg2=3; break;
		case 2:
			presc=1; sjw=1; tseg1=6; tseg2=3; break;
		case 3:
			presc=1; sjw=1; tseg1=8; tseg2=7; break;
		case 4:
			presc=2; sjw=1; tseg1=8; tseg2=7; break;
		case 5:
			presc=4; sjw=1; tseg1=8; tseg2=7; break;
		case 6:
			presc=4; sjw=4; tseg1=11; tseg2=8; break;
		case 7:
			presc=32; sjw=4; tseg1=16; tseg2=8; break;
		case 8:
			presc=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[0];
			sjw=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[1];
			tseg1=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[2];
			tseg2=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[3];
			break;
		default:
			break;
	}

   	if (CANPC_initialize_chip2_mb2(presc, sjw, tseg1, tseg2, 0) != 0) {
      	printf("-->Error in CANPC_initialize_chip2_mb2 \n");
      	return(-1);
    }
   	//printf("CANPC_initialize_chip2_mb2 OK\n");

   
	// Set acceptance filter for CAN 1 and 2   

   	if (CANPC_set_acceptance_mb2(ACCEPT_MASK_1, ACCEPT_CODE_1, ACCEPT_MASK_XTD_1, ACCEPT_CODE_XTD_1) != 0) {
     	printf("-->Error in CANPC_set_acceptance_mb2 \n");
      	return(-1);
    }
   	//printf("CANPC_set_acceptance_mb2 OK\n");

   	if (CANPC_set_acceptance2_mb2(ACCEPT_MASK_2, ACCEPT_CODE_2, ACCEPT_MASK_XTD_2, ACCEPT_CODE_XTD_2) != 0) {
      	printf("-->Error in CANPC_set_acceptance2_mb2 \n");
      	return(-1);
    }
	//printf("CANPC_set_acceptance2_mb2 OK\n");


   	// Set resynchronization
   	if (CANPC_set_mode_mb2(SLEEPMODE_1, SPEEDMODE_1) != 0) {
      	printf("-->Error in CANPC_set_mode_mb2 \n");
      	return(-1);
    }
   	//printf("CANPC_set_mode_mb2 OK\n");

   	if (CANPC_set_mode2_mb2(SLEEPMODE_2, SPEEDMODE_2) != 0) {
      	printf("-->Error in CANPC_set_mode2_mb2 \n");
      	return(-1);
    }
	//printf("CANPC_set_mode2_mb2 OK\n");

   	// Set output control (phys. layer -1: default  CAN High Speed)                               
   	if (CANPC_set_output_control_mb2(OUTPUT_CONTROL_1) != 0) {
      	printf("-->Error in CANPC_set_output_control_mb2 \n");
      	return(-1);
    }
	//printf("CANPC_set_output_control_mb2 OK\n");

   	if (CANPC_set_output_control2_mb2(OUTPUT_CONTROL_2) != 0) {
      	printf("-->Error in CANPC_set_output_control2_mb2 \n");
      	return(-1);
    }
	//printf("CANPC_set_output_control2_mb2 OK\n");

	return(0);

}

#endif


static void mdlInitializeSizes(SimStruct *S)
{

   	int_T baud, temp_mb2, presc, sjw, tseg1, tseg2;
	int_T i, id;

     
#ifdef MATLAB_MEX_FILE

  	ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    	sprintf(msg,"Wrong number of input arguments passed.\nNine arguments are expected\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	baud=(int)mxGetPr(CAN1_BAUDRATE_ARG)[0];
	if (baud==8) {
    	if ( mxGetM(CAN1_USER_BAUDRATE_ARG)!=1 &&  mxGetN(CAN1_USER_BAUDRATE_ARG)!=4) {
     		sprintf(msg,"argument for user defined baudrate of CAN1 must be a row vector with 4 elements\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		presc=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[0];
		sjw=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[1];
		tseg1=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[2];
		tseg2=(int)mxGetPr(CAN1_USER_BAUDRATE_ARG)[3];
		if ( presc < 1 || presc > 32) {
     		sprintf(msg,"Prescaler value for CAN1 must be in the range of 1..32\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( sjw < 1 || sjw > 4) {
     		sprintf(msg,"Synchronisation-Jump-Width value for CAN1 must be in the range of 1..4\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( tseg1 < 1 || tseg1 > 16) {
     		sprintf(msg,"Time-Segment 1 value for CAN1 must be in the range of 1..16\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( tseg2 < 1 || tseg2 > 8) {
     		sprintf(msg,"Time-Segment 2 value for CAN1 must be in the range of 1..8\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
	    temp_mb2= 1 + tseg1 + tseg2;
	    if ( temp_mb2 < 8 || temp_mb2 > 25) {
     		sprintf(msg,"The value: 1 + tseg1 + tseg2 for CAN1 must be in the range of 8..25\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( (tseg1+tseg2) < 2*sjw ) {
     		sprintf(msg,"CAN1: the value tseg1 + tseg2 must be greater or equal than the value 2* sjw\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( sjw < 2 || sjw > tseg2) {
     		sprintf(msg,"CAN1: the value sjw must be in the range of 2..tseg2\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
	}

	baud=(int)mxGetPr(CAN2_BAUDRATE_ARG)[0];
	if (baud==8) {
    	if ( mxGetM(CAN2_USER_BAUDRATE_ARG)!=1 &&  mxGetN(CAN2_USER_BAUDRATE_ARG)!=4) {
     		sprintf(msg,"argument for user defined baudrate of CAN2 must be a row vector with 4 elements\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		presc=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[0];
		sjw=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[1];
		tseg1=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[2];
		tseg2=(int)mxGetPr(CAN2_USER_BAUDRATE_ARG)[3];
		if ( presc < 1 || presc > 32) {
     		sprintf(msg,"Prescaler value for CAN2 must be in the range of 1..32\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( sjw < 1 || sjw > 4) {
     		sprintf(msg,"Synchronisation-Jump-Width value for CAN2 must be in the range of 1..4\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( tseg1 < 1 || tseg1 > 16) {
     		sprintf(msg,"Time-Segment 1 value for CAN2 must be in the range of 1..16\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( tseg2 < 1 || tseg2 > 8) {
     		sprintf(msg,"Time-Segment 2 value for CAN2 must be in the range of 1..8\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
	    temp_mb2= 1 + tseg1 + tseg2;
	    if ( temp_mb2 < 8 || temp_mb2 > 25) {
     		sprintf(msg,"The value: 1 + tseg1 + tseg2 for CAN2 must be in the range of 8..25\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( (tseg1+tseg2) < 2*sjw ) {
     		sprintf(msg,"CAN2: the value tseg1 + tseg2 must be greater or equal than the value 2* sjw\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
		if ( sjw < 2 || sjw > tseg2) {
     		sprintf(msg,"CAN2: the value sjw must be in the range of 2..tseg2\n");
        	ssSetErrorStatus(S,msg);
        	return;
  		}
	}

    
	if (mxGetM(CAN1_SEND_ARG)>1 ) {
      	sprintf(msg,"CAN1 send: identifier argument must be a row vector\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	for (i=0;i<mxGetN(CAN1_SEND_ARG);i++) {
		id=(int)mxGetPr(CAN1_SEND_ARG)[i];
		if (id >= 0) { // standard identifiers  
			if (id > MAX_IDS) {
				sprintf(msg,"CAN1 send: the standard identifiers must be in the range of 0..2031\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		} else { // extended identifiers
		    id= -id;
			if (id > MAX_IDS_EXT + 1) {														  
				sprintf(msg,"CAN1 send: the extended identifiers must be in the range of -1..-536870912\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		}
	}
	if (mxGetM(CAN1_RECEIVE_ARG)>1 ) {
      	sprintf(msg,"CAN1 receive: identifier argument must be a row vector\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	for (i=0;i<mxGetN(CAN1_RECEIVE_ARG);i++) {
		id=(int)mxGetPr(CAN1_RECEIVE_ARG)[i];
		if (id >= 0) { // standard identifiers  
			if (id > MAX_IDS) {
				sprintf(msg,"CAN1 receive: the standard identifiers must be in the range of 0..2031\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		} else { // extended identifiers
		    id= -id;
			if (id > MAX_IDS_EXT + 1) {
				sprintf(msg,"CAN1 receive: the extended identifiers must be in the range of -1..-536870912\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		}
	}
	if (mxGetM(CAN2_SEND_ARG)>1 ) {
      	sprintf(msg,"CAN2 send: identifier argument must be a row vector\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	for (i=0;i<mxGetN(CAN2_SEND_ARG);i++) {
		id=(int)mxGetPr(CAN2_SEND_ARG)[i];
		if (id >= 0) { // standard identifiers  
			if (id > MAX_IDS) {
				sprintf(msg,"CAN2 send: the standard identifiers must be in the range of 0..2031\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		} else { // extended identifiers
		    id= -id;
			if (id > MAX_IDS_EXT + 1) {
				sprintf(msg,"CAN2 send: the extended identifiers must be in the range of -1..-536870912\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		}
	}
	if (mxGetM(CAN2_RECEIVE_ARG)>1 ) {
      	sprintf(msg,"CAN2 receive: identifier argument must be a row vector\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	for (i=0;i<mxGetN(CAN2_RECEIVE_ARG);i++) {
		id=(int)mxGetPr(CAN2_RECEIVE_ARG)[i];
		if (id >= 0) { // standard identifiers  
			if (id > MAX_IDS) {
				sprintf(msg,"CAN2 receive: the standard identifiers must be in the range of 0..2031\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		} else { // extended identifiers
		    id= -id;
			if (id > MAX_IDS_EXT + 1) {
				sprintf(msg,"CAN2 receive: the extended identifiers must be in the range of -1..-536870912\n");
        		ssSetErrorStatus(S,msg);
        		return;
			}
		}
	}
     

#endif


        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, 0);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
        //ssSetNumInputArgs(S, NUMBER_OF_ARGS);
        ssSetNumIWork(S, NO_I_WORKS); 
        ssSetNumRWork(S, NO_R_WORKS);
        ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
        ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
        ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
        ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */

        
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
		ssSetOffsetTime(S, 0, 0.0);

}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{


        int_T msg_id;
        int_T i,j,n;
        
#ifndef MATLAB_MEX_FILE

		CANPC_RESSOURCES crRessources;
		int ret;

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
		int				a;
		

#ifndef XPCMSVISUALC
#pragma disable_message(1055) 
#include "CANAC2_setup.c"
#pragma enable_message(1055) 
#endif

#endif

#ifndef MATLAB_MEX_FILE

   
		//printf("        initializing CAN-AC2 board...\n");

	
		//crRessources.uInterrupt   = CANPC_NO_IRQ;
		//crRessources.ulDPRMemBase = CANPC_BASE_AUTO; 
		//crRessources.ulDPRMemSize = CANPC_SIZE_AUTO;
		//crRessources.uSocket      = CANPC_SOCKET_AUTO;
		//crRessources.ulDPRMemBase=((int)mxGetPr(BASE_ADDRESS_ARG)[0])-1;


		if ((ret = INIPC_initialize_board_mb2(&crRessources,(int)mxGetPr(PCI_DEV_ARG)[0])) != 0) {
			printf("-->Error in INIPC_initialize_board_mb2: ");
			printInitErrorText(ret); 
			return;
		}

        if (!CANAC2_FIRMWARE_LOADED_mb2) {
		   	// Load firmware
		   	printf("        downloading CAN-AC2-PCI firmware...\n");
			if ((ret = CANPC_reset_board_mb2()) != 0) {
   				printf("-->Error in CANPC_reset_board_mb2: ");
   				printResetErrorText(ret);
   				//INIPC_close_board_mb2();
   				return;
			}
			printf("        downloading CAN-AC2-PCI firmware finished\n");
		    CANAC2_FIRMWARE_LOADED_mb2=1;
	    }

		// 	Initialization of the CAN parameters for CAN channel 1 and 2
		if (Initialize_can_parameter(S)) {
   			printf("-->Initialization failed \n");
   			return;
		}

		//1.  Enable dynamic object buffer mode
		if (CANPC_enable_dyn_obj_buf_mb2() != 0) {
      		printf("-->Error in CANPC_enable_dyn_obj_buf_mb2 \n");
      		return;
   		}
		//printf("CANPC_enable_dyn_obj_buf_mb2 OK\n");

		// Configuration of the object buffer
	    ReceiveFifoEnable         = 1;  
	    ReceivePollAll            = 0;
	    ReceiveEnableAll          = 0;
	    ReceiveIntEnableAll       = 0;
	    AutoRemoteEnableAll       = 0;
	    TransmitReqFifoEnable     = 1;  
	    TransmitPollAll           = 0;
	    TransmitAckEnableAll      = 0;
	    TransmitAckFifoEnableAll  = 1;  
	    TransmitRmtFifoEnableAll  = 1; 
	    if (CANPC_initialize_interface_mb2(ReceiveFifoEnable,
	                                   ReceivePollAll,
	                                   ReceiveEnableAll,
	                                   ReceiveIntEnableAll,
	                                   AutoRemoteEnableAll,
	                                   TransmitReqFifoEnable,
	                                   TransmitPollAll,
	                                   TransmitAckEnableAll,
	                                   TransmitAckFifoEnableAll,
	                                   TransmitRmtFifoEnableAll) != 0) {
	    	printf("-->Error in CANPC_initialize_interface_mb2 \n");
	        return;
	    }
		//printf("CANPC_initialize_interface_mb2 OK\n");


	    // Define send and receive objects for CAN1 and CAN2


		for (i=0;i<MAX_OBJECTS;i++) {
			CANAC2_1_sendindex_mb2[i]=-1;
			CANAC2_1_receiveindex_mb2[i]=-1;
			CANAC2_2_sendindex_mb2[i]=-1;
			CANAC2_2_receiveindex_mb2[i]=-1;
		}


		ReceiveIntEnable  = 1;  
		AutoRemoteEnable  = 1;
		TransmitAckEnable = 0;

		for (i=0;i<mxGetN(CAN1_SEND_ARG);i++) {
	   		msg_id=(int_T)mxGetPr(CAN1_SEND_ARG)[i];
			CANAC2_1_sendindex_mb2[i]=msg_id;
			//printf("%d\n",CANAC2_1_sendindex_mb2[i]);
			if (msg_id >= 0) {  // standard identifiers
				Type=1;
			} else {
				Type=3;
				msg_id= -msg_id -1 ;
			}				
			if (CANPC_define_object_mb2(msg_id,
	                                &CANAC2_1_send_mb2[i],
	                                Type,
	                                ReceiveIntEnable,
	                                AutoRemoteEnable,
	                                TransmitAckEnable) != 0) {
	       		printf("-->Error in CANPC_define_object_mb2 for send objects CAN 1\n");
	            return;
	      	}
	  	}
		CANAC2_1_sendmaxindex_mb2=mxGetN(CAN1_SEND_ARG);
		//printf("CAN 1 send: CANPC_define_object_mb2 OK\n");

		for (i=0;i<mxGetN(CAN1_RECEIVE_ARG);i++) {
	   		msg_id=(int_T)mxGetPr(CAN1_RECEIVE_ARG)[i];
			CANAC2_1_receiveindex_mb2[i]=msg_id;
			if (msg_id >= 0) {  // standard identifiers
				Type=0;
			} else {
				Type=2;
				msg_id= -msg_id -1 ;
			}				
			if (CANPC_define_object_mb2(msg_id,
	                                &CANAC2_1_receive_mb2[i],
	                                Type,
	                                1, //ReceiveIntEnable,
	                                AutoRemoteEnable,
	                                TransmitAckEnable) != 0) {
	       		printf("-->Error in CANPC_define_object_mb2 for receive objects CAN 1\n");
	            return;
	      	}
	  	}
		CANAC2_1_receivemaxindex_mb2=mxGetN(CAN1_RECEIVE_ARG);
		//printf("CAN 1 receive: CANPC_define_object_mb2 OK\n");

		for (i=0;i<mxGetN(CAN2_SEND_ARG);i++) {
	   		msg_id=(int_T)mxGetPr(CAN2_SEND_ARG)[i];
			CANAC2_2_sendindex_mb2[i]=msg_id;
			if (msg_id >= 0) {  // standard identifiers
				Type=1;
			} else {
				Type=3;
				msg_id= -msg_id -1 ;
			}				
			if (CANPC_define_object2_mb2(msg_id,
	                                &CANAC2_2_send_mb2[i],
	                                Type,
	                                ReceiveIntEnable,
	                                AutoRemoteEnable,
	                                TransmitAckEnable) != 0) {
	       		printf("-->Error in CANPC_define_object_mb2 for send objects CAN 2\n");
	            return;
	      	}
	  	}
		CANAC2_2_sendmaxindex_mb2=mxGetN(CAN2_SEND_ARG);
		//printf("CAN 2 send: CANPC_define_object_mb2 OK\n");

		for (i=0;i<mxGetN(CAN2_RECEIVE_ARG);i++) {
	   		msg_id=(int_T)mxGetPr(CAN2_RECEIVE_ARG)[i];
			CANAC2_2_receiveindex_mb2[i]=msg_id;
			if (msg_id >= 0) {  // standard identifiers
				Type=0;
			} else {
				Type=2;
				msg_id= -msg_id -1 ;
			}				
			if (CANPC_define_object2_mb2(msg_id,
	                                &CANAC2_2_receive_mb2[i],
	                                Type,
	                                ReceiveIntEnable,
	                                AutoRemoteEnable,
	                                TransmitAckEnable) != 0) {
	       		printf("-->Error in CANPC_define_object_mb2 for receive objects CAN 2\n");
	            return;
	      	}
	  	}
		CANAC2_2_receivemaxindex_mb2=mxGetN(CAN2_RECEIVE_ARG);
		//printf("CAN 2 receive: CANPC_define_object_mb2 OK\n");

   		// Start Chip

		if (CANPC_start_chip_mb2() != 0) {
   		 	printf("-->Error in CANPC_start_chip_mb2 \n");
		  	return;
		}
   		//printf("CANPC_start_chip_mb2 OK\n");

		//printf("        initializing CAN-AC2 board finished\n");

#		ifdef CANAC2_setup_present
		// init

		for (i=0;i<CANAC2_init_number;i++) {

			if (CANAC2_init[i].port==1) {
			
				msg_id=CANAC2_init[i].identifier;
				for (j=0;j<CANAC2_1_sendmaxindex_mb2;j++) {
					if (msg_id==CANAC2_1_sendindex_mb2[j]) { // found
						index=j;
					}
				}

#				ifdef DEBUG_CANAC2
		    		printf("Port: %d, Id: %d, Data: %x %x %x %x %x %x %x %x, NoBytes: %d, Wait: %d\n",
						CANAC2_init[i].port,
						CANAC2_init[i].identifier,
						CANAC2_init[i].data[0],
						CANAC2_init[i].data[1],
						CANAC2_init[i].data[2],
						CANAC2_init[i].data[3],
						CANAC2_init[i].data[4],
						CANAC2_init[i].data[5],
						CANAC2_init[i].data[6],
						CANAC2_init[i].data[7],
						CANAC2_init[i].no_bytes,
						CANAC2_init[i].wait_ms);
					//printf("Index: %d\n",index);
					//printf("Index: %d\n",CANAC2_1_sendindex_mb2[index]);
#				endif

            	frc = CANPC_write_object_mb2(CANAC2_1_send_mb2[index], CANAC2_init[i].no_bytes, CANAC2_init[i].data);
				if (frc<0) {
					printf("ERROR:  CANPC_write_object_mb2: %d\n",frc);
					return;
				} 

            	//wait specified ms
				for (j=0;j<1000000;j++) a=j;

				//start_time_mes();
				//timetmp=get_act_time()/BASE_FREQUENCY;
				//while ((get_act_time()/BASE_FREQUENCY-timetmp) < (1/1000.0*(double)CANAC2_init[i].wait_ms));
				//get_time_mes();


         	}

			if (CANAC2_init[i].port==2) {
			
				msg_id=CANAC2_init[i].identifier;
				for (j=0;j<CANAC2_2_sendmaxindex_mb2;j++) {
					if (msg_id==CANAC2_2_sendindex_mb2[j]) { // found
						index=j;
					}
				}

#				ifdef DEBUG_CANAC2
		    		printf("Port: %d, Id: %d, Data: %x %x %x %x %x %x %x %x, NoBytes: %d, Wait: %d\n",
						CANAC2_init[i].port,
						CANAC2_init[i].identifier,
						CANAC2_init[i].data[0],
						CANAC2_init[i].data[1],
						CANAC2_init[i].data[2],
						CANAC2_init[i].data[3],
						CANAC2_init[i].data[4],
						CANAC2_init[i].data[5],
						CANAC2_init[i].data[6],
						CANAC2_init[i].data[7],
						CANAC2_init[i].no_bytes,
						CANAC2_init[i].wait_ms);
					//printf("Index: %d\n",index);
					//printf("Index: %d\n",CANAC2_1_sendindex_mb2[index]);
#				endif

            	frc = CANPC_write_object2_mb2(CANAC2_2_send_mb2[index], CANAC2_init[i].no_bytes, CANAC2_init[i].data);
				if (frc<0) {
					printf("ERROR:  CANPC_write_object2_mb2: %d\n",frc);
					return;
				} 

            	//wait specified ms
				for (j=0;j<1000000;j++) a=j;

				//start_time_mes();
				//timetmp=get_act_time()/BASE_FREQUENCY;
				//while ((get_act_time()/BASE_FREQUENCY-timetmp) < (1/1000.0*(double)CANAC2_init[i].wait_ms));
				//get_time_mes();


         	}

		}

#endif

		

	        
#endif

}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{        
}

/* Function to compute model update */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to compute derivatives */
static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
            
#ifndef MATLAB_MEX_FILE

   	// Reinitialize

	if (CANPC_reinitialize_mb2() != 0) {
    	printf("-->Error in CANPC_start_chip_mb2 \n");
		return;
	}
   	//printf("CANPC_reinitialize_mb2 OK\n");

    
#endif
  
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif