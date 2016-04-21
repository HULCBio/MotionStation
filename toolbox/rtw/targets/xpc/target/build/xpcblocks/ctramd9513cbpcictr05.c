/* $Revision: 1.7.6.1 $ $Date: 2004/03/15 22:24:45 $ */
/* ctramd9513cbpcictr05.c - xPC Target, non-inlined S-function driver for AMD9513 based counter boards  */
/* Copyright 1996-2004 The MathWorks, Inc.
*/


//#define DEBUG

#define         S_FUNCTION_LEVEL    2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME     ctramd9513cbpcictr05
#include        <stddef.h>
#include        <stdlib.h>
#include        <string.h>

#include        "tmwtypes.h"
#include        "simstruc.h"

#ifdef MATLAB_MEX_FILE
#include        "mex.h"
#else
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "time_xpcimport.h"
#endif

#define         NUMBER_OF_ARGS          (8)
#define         IO_ARG                  ssGetSFcnParam(S,0)
#define         MM_ARG                  ssGetSFcnParam(S,1)
#define         CMS_ARG                 ssGetSFcnParam(S,2)
#define         INIT_ARG                ssGetSFcnParam(S,3)
#define         COMMAND_ARG             ssGetSFcnParam(S,4)
#define         TERM_ARG                ssGetSFcnParam(S,5)
#define         SAMP_TIME_ARG           ssGetSFcnParam(S,6)
#define         SLOT_ARG                ssGetSFcnParam(S,7)


#define         SAMP_TIME_IND           (0)

#define         NO_I_WORKS              (2)

#define         NO_R_WORKS              (0)

#define         THRESHOLD               0.5

#define         BASE_ADDR_I_IND         (0)
#define         ARM_STATE_I_IND         (1)

#define  DATAP       (ushort_T)(base_addr)
#define  CMDP        (ushort_T)(base_addr+0x01)

#define  MM          ((ushort_T)(0x17))
#define  LOWBYTE(x)  ((ushort_T)(((ushort_T)x) & 0xff))
#define  HIGHBYTE(x) ((ushort_T)((((ushort_T)x) >> 8) & 0xff))

#define  CMR(chan)    ((ushort_T)(chan))
#define  RWLOAD(chan) ((ushort_T)(0x08 | (ushort_T)(chan)))
#define  RWHOLD(chan) ((ushort_T)(0x10 | (ushort_T)(chan)))
#define  ARM(chan)    ((ushort_T)(0x20 | (ushort_T)(chan)))
#define  DISARM(chan) ((ushort_T)(0xc0 | (ushort_T)(chan)))
#define  LOAD(chan)   ((ushort_T)(0x40 | (ushort_T)(chan)))
#define  SAVE(chan)   ((ushort_T)(0xA0 | (ushort_T)(chan)))
#define  SETTGL(chan) ((ushort_T)(0xe8 | (ushort_T)(chan)))
#define  CLRTGL(chan) ((ushort_T)(0xe0 | (ushort_T)(chan)))

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i; // num_channels, 
    const real_T *io;
    int_T nInputs, nOutputs;


#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
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

    io= mxGetPr(IO_ARG);

    nInputs= (int_T)io[0];
    nOutputs= (int_T)io[1];

    /* define number of inputs */
    ssSetNumInputPorts(S, nInputs);
    /* define number of outputs */
    ssSetNumOutputPorts(S, nOutputs);

    /* define input ports */
    for (i=0;i<nInputs;i++) {
        ssSetInputPortWidth(S, i, (int_T)io[i+2]);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    /* define output ports */
    for (i=0;i<nOutputs;i++) {
        ssSetOutputPortWidth(S, i, (int_T)io[i+2+nInputs]);
    }


    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);


    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);

}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
        ssSetOffsetTime(S, 0, 0.0);
    } else {
        ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
    }

#ifndef MATLAB_MEX_FILE

    {
        uint_T base_addr;
        PCIDeviceInfo pciinfo;
        char devName[20];
        int  devId;

        strcpy(devName,"CB PCI-CTR05");
        devId = 0x18;  // PCI-CTR05

        if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
            /* look for the PCI-Device */
            if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
		devId = 0x6e;  // PCI-CTR10, for debugging only
		if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
		    sprintf(msg,"%s: board not present", devName);
		    ssSetErrorStatus(S,msg);
		    return;
		}
            }
        } else {
            int_T bus, slot;
            if (mxGetN(SLOT_ARG) == 1) {
                bus = 0;
                slot = (int_T)mxGetPr(SLOT_ARG)[0];
            } else {
                bus = (int_T)mxGetPr(SLOT_ARG)[0];
                slot = (int_T)mxGetPr(SLOT_ARG)[1];
            }
            // look for the PCI-Device
            if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
		devId = 0x6e;  // PCI-CTR10, for debugging only
		if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
		    sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
		    ssSetErrorStatus(S,msg);
		    return;
		}
            }
        }

        // show Device Information
        // rl32eShowPCIInfo(pciinfo);

        base_addr = (uint_T)pciinfo.BaseAddress[2];

        /* if necessary, the MM gets initailized here, because we have to do it before the counter modes */
        if (mxGetN(MM_ARG)) {
            uint16_T mm= (uint16_T)mxGetPr(MM_ARG)[0];
#ifdef DEBUG
            printf("MM: %x\n", mm);
#endif
            rl32eOutpB( CMDP, MM );
            rl32eOutpB( DATAP, LOWBYTE(mm));
            // high byte
            rl32eOutpB( DATAP, HIGHBYTE(mm));
        }

    }
#endif

}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
    int armed = 0;
    PCIDeviceInfo pciinfo;
    char devName[20];
    int  devId;
    uint_T base_addr;
    int *ioptr;
    int data;

    strcpy(devName,"CB PCI-CTR05");
    devId = 0x18;  // PCI-CTR05

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
	    devId = 0x6e;  // PCI-CTR10, for debugging only
	    if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
		sprintf(msg,"%s: board not present", devName);
		ssSetErrorStatus(S,msg);
		return;
	    }
        }
    } else {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
	    devId = 0x6e;  // PCI-CTR10, for debugging only
	    if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
		sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
		ssSetErrorStatus(S,msg);
		return;
	    }
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    ioptr = (int *)pciinfo.BaseAddress[1];
    base_addr=(uint_T)pciinfo.BaseAddress[2];

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

    // Must read/modify/write and only touch bits at 0x24
    data = rl32eInpDW( (short)ioptr + 0x50 );
    data &= ~0x24;  // Clear OUT1 and OUT2 to get 5.0 Mhz source
    rl32eOutpDW( (short)ioptr + 0x50, data );

    /* if necessary, the counter modes get initailized here */
    if (mxGetN(CMS_ARG)) {
        int i;
        uint16_T cm;
        for (i=0;i<5;i++) {
            if ((int_T)mxGetPr(CMS_ARG)[i]!=-1) {
                cm= (uint16_T)mxGetPr(CMS_ARG)[i];
#ifdef DEBUG
                printf("CM counter %d: %x\n", i+1, cm);
#endif
                rl32eOutpB( CMDP,  CMR(i+1));
                rl32eOutpB( DATAP, LOWBYTE(cm));
                rl32eOutpB( DATAP, HIGHBYTE(cm));

                if (mxGetN(INIT_ARG)) {

                    const real_T *command= mxGetPr(INIT_ARG);

                    int_T k, i, execute, counter, com, ctr;
                    int_T value;

                    /* loop over all commands */

                    k=1;

                    for  (i=0; i< (int_T)command[0]; i++) {
                        execute= (int_T)command[k+1];
                        if (execute) {
                            com = (int_T)command[k];
#ifdef DEBUG
                            printf("command: %d\n",com);
#endif
                            switch (com) {
                              case 10:  /* WriteLoad */
                              case 11:  /* WriteHold */
                                /* get first I/O element */
                                value=(int_T)command[k+9];

                                /* loop over all counters */
                                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                                    /* get counter */
                                    counter= (int_T)command[k+4+ctr];

                                    /* get value */
                                    value= (int_T)command[k+9+ctr];

                                    /* execute command */
                                    if (com==10) {
#ifdef DEBUG
                                        printf("WriteLoad, 0x%x\n", RWLOAD(counter));
#endif
                                        rl32eOutpB( CMDP, RWLOAD(counter));
                                    } else if (com==11) {
#ifdef DEBUG
                                        printf("WriteHold, 0x%x\n", RWHOLD(counter) );
#endif
                                        rl32eOutpB( CMDP, RWHOLD(counter));
                                    }
                                    rl32eOutpB( DATAP, LOWBYTE(value));
                                    rl32eOutpB( DATAP, HIGHBYTE(value));
                                }
                                break;

                              case 20:  /* Arm */
#ifdef DEBUG
                                printf("Arm, 0x%x\n", ARM(command[k+3]) );
#endif
                                rl32eOutpB( CMDP, ARM(command[k+3]));
                                armed = 1;
                                break;

                              case 21:  /* Disarm */
#ifdef DEBUG
                                printf("Disarm, 0x%x\n", DISARM(command[k+3]));
#endif
                                rl32eOutpB( CMDP, DISARM(command[k+3]));
                                armed = 0;
                                break;

                              case 22:  /* LoadAndArm */
#ifdef DEBUG
                                printf("LoadAndArm, 0x%x, 0x%x\n",
				       LOAD(command[k+3]),
				       ARM(command[k+3]) );
#endif
                                rl32eOutpB( CMDP, LOAD(command[k+3]));
                                rl32eOutpB( CMDP, ARM(command[k+3]));
                                armed = 1;
                                break;

                              case 23:  /* DisarmAndSave */
#ifdef DEBUG
                                printf("DisarmAndSave, 0x%x, 0x%x\n",
				       DISARM(command[k+3]),
				       SAVE(command[k+3]));
#endif
                                rl32eOutpB( CMDP, DISARM(command[k+3]));
                                rl32eOutpB( CMDP, SAVE(command[k+3]));
                                armed = 0;
                                break;

                              case 30:  /* Load */
#ifdef DEBUG
                                printf("Load, 0x%x\n", LOAD(command[k+3]));
#endif
                                rl32eOutpB( CMDP, LOAD(command[k+3]));
                                break;

                              case 31:  /* Save */
#ifdef DEBUG
                                printf("Save, 0x%x\n", SAVE(command[k+3]));
#endif
                                rl32eOutpB( CMDP, SAVE(command[k+3]));
                                break;

                              case 40:  /* Set Toggle */

                                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                                    /* get counter */
                                    counter = (int_T)command[k+4+ctr];

#ifdef DEBUG
                                printf("Set Toggle Output, 0x%x\n", SETTGL(counter));
#endif
                                    rl32eOutpB( CMDP, SETTGL(counter));
                                }
                                break;

                              case 41:  /* Clear Toggle */
                                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                                    /* get counter */
                                    counter= (int_T)command[k+4+ctr];

#ifdef DEBUG
                                printf("Clear Toggle Output, 0x%x\n", CLRTGL(counter));
#endif
                                    /* execute command */
                                    rl32eOutpB( CMDP, CLRTGL(counter));
                                }
                                break;
                            }
                        }
                        k+= 14;
                    }
                }
            }
        }
    }
    ssSetIWorkValue( S, ARM_STATE_I_IND, armed );
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    const real_T *command= mxGetPr(COMMAND_ARG);
    InputRealPtrsType uPtrs;
    real_T  *y;
    int armed = ssGetIWorkValue( S, ARM_STATE_I_IND );

    int_T k, i, execute, input, counter, com, ctr, isInput;
    int_T value;

    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);

    /* loop over all commands */

    k=1;
    for  (i=0; i< (int_T)command[0]; i++) {
        execute= (int_T)command[k+1];
        if (execute<0) {
            input= -execute-1;
            uPtrs= ssGetInputPortRealSignalPtrs(S,input);
            if (*uPtrs[0] < THRESHOLD) {
                execute=0;
            } else {
                execute=1;
            }
        }

        if (execute) {
            com= (int_T)command[k];
#ifdef DEBUG
            printf("command: %d\n",com);
#endif
            switch (com) {
              case 10:  /* WriteLoad */
              case 11:  /* WriteHold */
                /* get first I/O element */
                value=(int_T)command[k+9];

                isInput=0;
                if (value<0) {  /* input */
                    input= -value-1;
                    uPtrs= ssGetInputPortRealSignalPtrs(S,input);
                    isInput=1;
                }

//                if( armed == 1 )
//                {
//                    rl32eOutpB( CMDP, DISARM(command[k+3]));
//                    rl32eWaitDouble( 10e-6 );
//                }
                                        /* loop over all counters */
                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                    /* get counter */
                    counter= (int_T)command[k+4+ctr];

                    /* get value */
                    if (isInput) {
                        value= (int_T)*uPtrs[ctr];
                    } else {
                        value= (int_T)command[k+9+ctr];
                    }

                    /* execute command */
                    if (com==10) {
#ifdef DEBUG
                        printf("WriteLoad, %x\n", RWLOAD(counter));
#endif
                        rl32eOutpB( CMDP, RWLOAD(counter));
                    } else if (com==11) {
#ifdef DEBUG
                        printf("WriteHold, %x\n", RWHOLD(counter));
#endif
                        rl32eOutpB( CMDP, RWHOLD(counter));
                    }
                    rl32eOutpB( DATAP, LOWBYTE(value));
                    rl32eOutpB( DATAP, HIGHBYTE(value));
                }
//                if( armed == 1 )
//                {
//                    rl32eWaitDouble( 10e-6 );
//                    rl32eOutpB( CMDP, ARM(command[k+3]));
//                }
                break;

              case 12:  /* ReadLoad */
              case 13:  /* ReadHold */

                //printf("%d\n",-((int_T)command[k+9])-1);
                y=ssGetOutputPortSignal(S,-((int_T)command[k+9])-1);

                /* loop over all counters */
                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {


                    /* get counter */
                    counter= (int_T)command[k+4+ctr];

                    /* execute command */
                    if (com==12) {
#ifdef DEBUG
                        printf("ReadLoad CTR %d\n", counter);
#endif
                        rl32eOutpB( CMDP, RWLOAD(counter));
                    } else if (com==13) {
#ifdef DEBUG
                        printf("ReadHold CTR %d\n", counter);
#endif
                        rl32eOutpB( CMDP, RWHOLD(counter));
                    }
                    value  = rl32eInpB( DATAP ) & 0xff;
                    value |= (rl32eInpB( DATAP ) & 0xff) << 8;

                    y[ctr]= (real_T)value;
                }
                break;

              case 20:  /* Arm */
#ifdef DEBUG
                printf("Arm, 0x%x\n", ARM(command[k+3]));
#endif
                /* execute command */
                rl32eOutpB( CMDP, ARM(command[k+3]));
                armed = 1;
                break;

              case 21:  /* Disarm */
#ifdef DEBUG
                printf("Disarm, 0x%x\n", DISARM(command[k+3]));
#endif
                rl32eOutpB( CMDP, DISARM(command[k+3]));
                armed = 0;
                break;

              case 22:  /* LoadAndArm */
#ifdef DEBUG
		printf("LoadAndArm, 0x%x, 0x%x\n",
		       LOAD(command[k+3]), ARM(command[k+3]));
#endif
		rl32eOutpB( CMDP, LOAD(command[k+3]));
		rl32eOutpB( CMDP, ARM(command[k+3]));
		armed = 1;
		break;

              case 23:  /* DisarmAndSave */
#ifdef DEBUG
                printf("DisarmAndSave\n");
#endif
                rl32eOutpB( CMDP, DISARM(command[k+3]));
                rl32eOutpB( CMDP, SAVE(command[k+3]));
                armed = 0;
                break;

              case 30:  /* Load */
#ifdef DEBUG
                printf("Load\n");
#endif
                rl32eOutpB( CMDP, LOAD(command[k+3]));
                break;

              case 31:  /* Save */
#ifdef DEBUG
                printf("Save\n");
#endif
                rl32eOutpB( CMDP, SAVE(command[k+3]));
                break;

              case 40:  /* Set Toggle */
#ifdef DEBUG
                printf("Set Toggle Output\n");
#endif
                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                    /* get counter */
                    counter= (int_T)command[k+4+ctr];

                    rl32eOutpB( CMDP, SETTGL(counter));
                }
                break;

              case 41:  /* Clear Toggle */
#ifdef DEBUG
                printf("Clear Toggle Output\n");
#endif
                for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                    /* get counter */
                    counter= (int_T)command[k+4+ctr];

                    rl32eOutpB( CMDP, CLRTGL(counter));
                }
                break;
            }
        }
        k+= 14;
    }
    ssSetIWorkValue( S, ARM_STATE_I_IND, armed );
#endif
}



static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    if (mxGetN(TERM_ARG)) {
        const real_T *command= mxGetPr(TERM_ARG);
        uint_T base_addr = (uint_T)ssGetIWorkValue(S, BASE_ADDR_I_IND);

        int_T k, i, execute, counter, com, ctr;
        int_T value;

        /* loop over all commands */

        k=1;

        for  (i=0; i< (int_T)command[0]; i++) {
            execute= (int_T)command[k+1];
            if (execute) {
                com= (int_T)command[k];
#ifdef DEBUG
                printf("command: %d\n",com);
#endif
                switch (com) {
                  case 10:      /* WriteLoad */
                  case 11:      /* WriteHold */

                    /* get first I/O element */
                    value=(int_T)command[k+9];

                    /* loop over all counters */
                    for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                        /* get counter */
                        counter= (int_T)command[k+4+ctr];

                        /* get value */
                        value= (int_T)command[k+9+ctr];

                        /* execute command */
                        if (com==10) {
#ifdef DEBUG
                            printf("WriteLoad\n");
#endif
                            rl32eOutpB( CMDP, RWLOAD(counter));
                        } else if (com==11) {
#ifdef DEBUG
                            printf("WriteHold\n");
#endif
                            rl32eOutpB( CMDP, RWHOLD(counter));
                        }
//                        printf("%d, %d\n",counter, value);
                        rl32eOutpB( DATAP, LOWBYTE(value));
                        rl32eOutpB( DATAP, HIGHBYTE(value));
                    }
                    break;

                  case 20:      /* Arm */
#ifdef DEBUG
                    printf("Arm\n");
#endif
                    rl32eOutpB( CMDP, ARM(command[k+3]));
                    break;

                  case 21:      /* Disarm */
#ifdef DEBUG
                    printf("Disarm\n");
#endif
                    rl32eOutpB( CMDP, DISARM(command[k+3]));
                    break;

                  case 22:      /* LoadAndArm */
#ifdef DEBUG
                    printf("LoadAndArm\n");
#endif
                    rl32eOutpB( CMDP, LOAD(command[k+3]));
                    rl32eOutpB( CMDP, ARM(command[k+3]));
                    break;

                  case 23:      /* DisarmAndSave */
#ifdef DEBUG
                    printf("DisarmAndSave\n");
#endif
                    rl32eOutpB( CMDP, DISARM(command[k+3]));
                    rl32eOutpB( CMDP, SAVE(command[k+3]));
                    break;


                  case 30:      /* Load */
#ifdef DEBUG
                    printf("Load\n");
#endif
                    rl32eOutpB( CMDP, LOAD(command[k+3]));
                    break;


                  case 31:      /* Save */
#ifdef DEBUG
                    printf("Save\n");
#endif
                    rl32eOutpB( CMDP, SAVE(command[k+3]));
                    break;

                  case 40:      /* Set Toggle */

#ifdef DEBUG
                    printf("Set Toggle Output\n");
#endif
                    for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                        /* get counter */
                        counter= (int_T)command[k+4+ctr];

                        rl32eOutpB( CMDP, SETTGL(counter));
                    }
                    break;

                  case 41:      /* Clear Toggle */

#ifdef DEBUG
                    printf("Clear Toggle Output\n");
#endif
                    for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

                        /* get counter */
                        counter= (int_T)command[k+4+ctr];

                        rl32eOutpB( CMDP, CLRTGL(counter));
                    }
                    break;


                }
            }
            k+= 14;
        }
    }

#endif

}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
