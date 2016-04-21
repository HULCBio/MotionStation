//   srsbsipsynchro.c - xPC Target, non-inlined S-function driver for the
//   SBS IP-Synchro IP module
//
//   Copyright 1996-2003 The MathWorks, Inc.

#define  S_FUNCTION_LEVEL 2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME  srsbsipsynchro

#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "util_xpcimport.h"
#include "time_xpcimport.h"
#include "ipcarrier.h"
#endif

#define NUMBER_OF_ARGS       (10)
#define CARRIER_SLOT_ARG     ssGetSFcnParam(S, 0) // 1:slot A, 2:slot B, etc.
#define CHANNEL_ARG          ssGetSFcnParam(S, 1) // vector of {1, 2}
#define PRECISION_ARG        ssGetSFcnParam(S, 2) // vector of {10, 12, 14, 16}
#define AUTO_PRECISION_ARG   ssGetSFcnParam(S, 3) // 0: off; 1: on
#define FORMAT_ARG           ssGetSFcnParam(S, 4) // format_T (defined below)
#define SAMPLE_TIME_ARG      ssGetSFcnParam(S, 5) // seconds
#define CARRIER_TYPE_ARG     ssGetSFcnParam(S, 6) // CarrierType enum
#define CARRIER_ISA_BASE_ARG ssGetSFcnParam(S, 7) // for ISA carriers
#define CARRIER_PCI_BUS_ARG  ssGetSFcnParam(S, 8) // for PCI carriers
#define CARRIER_PCI_SLOT_ARG ssGetSFcnParam(S, 9) // for PCI carriers

#define MODEL_NUM            (0x05)  // ID PROM data word offsets
#define MFGR                 (0x04)

#define MFGR_VAL             (0xf0)  // Manufacturer ID for SBS
#define MODEL_VAL            (0x50)  // Model Number for IP-Synchro

#define CONTROL              (0x00)  // register word offsets
#define VECTOR               (0x01)
#define XMLED                (0x02)
#define STATUS1              (0x03)
#define XMCONTROL            (0x04)
#define POS_COMPARE_A        (0x05)
#define POS_COMPARE_B        (0x06)
#define STATUS2              (0x07)
#define INT_CLEAR_A          (0x09)
#define INT_CLEAR_B          (0x0A)
#define BIT_INT_CLEAR_A      (0x0C)
#define BIT_INT_CLEAR_B      (0x0D)
#define POS_DATA_A           (0x0E)
#define POS_DATA_B           (0x0F)

#define NUM_R_WORKS          (0)
#define NUM_I_WORKS          (3)
#define CARRIER_TYPE_I_IND   (0)
#define ISA_BASE_I_IND       (1)
#define SLOT_BASE_I_IND      (2)

#define NUM_CHANS            (2) 

typedef enum { // possible values of FORMAT_ARG
    POSITION = 1, 
    POSITION_AND_STATUS } format_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    format_T format = (format_T) mxGetPr(FORMAT_ARG)[0];
    int_T    nChans = mxGetN(CHANNEL_ARG);

    int_T    i, width;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "util_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input arguments expected, %d passed",
            NUMBER_OF_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);

    ssSetNumInputPorts(S, 0);
    ssSetNumOutputPorts(S, nChans);

    width = (format == POSITION) ? 1 : 2;

    for (i = 0; i < nChans; i++) 
        ssSetOutputPortWidth(S, i, width);

    ssSetNumSampleTimes(S,1);
    ssSetNumRWork(S,NUM_R_WORKS);
    ssSetNumIWork(S,NUM_I_WORKS);
    ssSetNumPWork(S,0);
    ssSetNumModes(S,0);
    ssSetNumNonsampledZCs(S,0);

    for (i = 0; i < NUMBER_OF_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMPLE_TIME_ARG)[0] <= 0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}

#define MDL_START 
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T    *IWork         = ssGetIWork(S);
    int_T     carrierSlot   = mxGetPr(CARRIER_SLOT_ARG)[0];
    int_T     autoPrecision = mxGetPr(AUTO_PRECISION_ARG)[0];
    int_T     nChans        = mxGetN(CHANNEL_ARG);
    int_T     timeout       = 1000;
    uint16_T  control       = 0;

    uint8_T   mfgr, model;
    int_T     i, chan, precision;

    CarrierType carrierType   = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];

    IWork[CARRIER_TYPE_I_IND] = carrierType;

    // control register: 
    //   set chan A and B resolution from PRECISION_ARG
    //   disable all interrupts
    //   set auto precision from AUTO_PRECISION_ARG

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        precision = mxGetPr(PRECISION_ARG)[i];

        switch (precision){
            case 10: control |= (0 << 2*chan) << 6; break;
            case 12: control |= (1 << 2*chan) << 6; break;
            case 14: control |= (2 << 2*chan) << 6; break;
            case 16: control |= (3 << 2*chan) << 6; break;
        }
    }

    if (autoPrecision == 0)
        control |= 1;


    switch (carrierType) {

        case SBS_PCI40A: {
            PCIDeviceInfo pciInfo;
            uint16_T *carrierBase, *physical, data;

            volatile uint16_T *slotBase, *pci40a;

            int_T pciSlot = mxGetPr(CARRIER_PCI_SLOT_ARG)[0];
            int_T pciBus  = mxGetPr(CARRIER_PCI_BUS_ARG)[0];
            
            if (pciSlot < 0) {
                if (rl32eGetPCIInfo((uint16_T) SBS_VENDOR_ID, 
                    (uint16_T) PCI40A_DEVICE_ID, &pciInfo)) {
                    sprintf(msg, "No PCI-40A carrier board found");
                    ssSetErrorStatus(S, msg);
                    return;
                }
            } 
            else if (rl32eGetPCIInfoAtSlot(SBS_VENDOR_ID, PCI40A_DEVICE_ID, 
                pciSlot + pciBus * 256, &pciInfo)) {
                sprintf(msg, "No PCI-40A at bus %d slot %d", pciBus, pciSlot);
                ssSetErrorStatus(S, msg);
                return;
            }

            carrierBase = (uint16_T *) pciInfo.BaseAddress[2];
            physical = carrierBase + carrierSlot * SLOT_OFS;
            slotBase = rl32eGetDevicePtr(physical,SLOT_LEN,RT_PG_USERREADWRITE);

            IWork[SLOT_BASE_I_IND] = (int_T) slotBase;

            // for the first read from the slot, check for IP bus time-out,
            // i.e check that there actually is an IP module present

            pci40a = rl32eGetDevicePtr(carrierBase,0x700,RT_PG_USERREADWRITE);
            data = pci40a[CNTL0];
            pci40a[CNTL0] = data | AUTO_ACK | CLR_AUTO;
            mfgr = slotBase[ID_PROM + MFGR];
            rl32eWaitDouble(0.000004); 
            if (pci40a[CNTL2] & AUTO_INT_SET) {
                pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);
                sprintf(msg, "No IP-Synchro at PCI-40A slot %c, base %03x", 
                    (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
                ssSetErrorStatus(S, msg);
                return;
            }
            pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);

            model = slotBase[ID_PROM + MODEL_NUM];

            if (mfgr != MFGR_VAL || model != MODEL_VAL) {
                sprintf(msg, "No IP-Synchro at PCI-40A slot %c, base %03x", 
                    (char) (carrierSlot + 'A' - 1), (uint_T) carrierBase);
                ssSetErrorStatus(S, msg);
                return;
            }

            // set up control register
            slotBase[CONTROL] = control;

            break;
        }
        case SBS_FLEX104A: {
            uint_T isaBase  = (uint_T) mxGetPr(CARRIER_ISA_BASE_ARG)[0];
            int_T  csrReg   = CSR(isaBase);
            int_T  accReg   = ACCESS(isaBase);
            int_T  dataReg  = DATA(isaBase);
            int_T  slotCode = SLOT(carrierSlot); 
            int_T  slotBase = IOSPACE | slotCode;

            if (xpceIsModelInit()) {

                /////////////////////////////////// 
                // printf("version 15-Jan-2003\n");
                /////////////////////////////////// 

                // IP reset takes about 250ms
                rl32eOutpW(csrReg, TMRST | IPRST);
                rl32eWaitDouble(0.500); 
                if (~rl32eInpW(csrReg) & RSTSTAT) {
                    sprintf(msg, "timeout waiting for IP reset on Flex/104A");
                    ssSetErrorStatus(S, msg);
                    return;
                }

                // read Manufacturer from ID PROM
                rl32eOutpW(accReg, IDSPACE | slotCode | MFGR);
                while (--timeout > 0 && (rl32eInpW(csrReg) & IPWAIT));
                mfgr = rl32eInpW(dataReg);

                // read Model Number from ID PROM
                rl32eOutpW(accReg, IDSPACE | slotCode | MODEL_NUM);
                while (--timeout > 0 && (rl32eInpW(csrReg) & IPWAIT));
                model = rl32eInpW(dataReg);

                if (timeout <= 0 || mfgr != MFGR_VAL || model != MODEL_VAL) {
                    sprintf(msg, "No IP-Synchro at Flex/104A slot %c base 0x%03x", 
                        (char) (carrierSlot + 'A' - 1), (uint_T) isaBase);
                    ssSetErrorStatus(S, msg);
                    return;
                }

            } else {
                // set up control register
                rl32eOutpW(accReg, slotBase | CONTROL);
                while (rl32eInpW(csrReg) & IPWAIT);
                rl32eOutpW(dataReg, control);
            
                IWork[ISA_BASE_I_IND] = isaBase;  
                IWork[SLOT_BASE_I_IND] = slotBase;  
                break;
            }
        }
        
        default:
            sprintf(msg, "Unsupported carrier type: %d", carrierType);
            ssSetErrorStatus(S, msg);
            return;
   }
   rl32eWaitDouble(0.001); 
#endif
}
    

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T      *IWork       = ssGetIWork(S);
    int_T       nChans      = mxGetN(CHANNEL_ARG);
    format_T    format      = (format_T) mxGetPr(FORMAT_ARG)[0];
    CarrierType carrierType = (CarrierType) IWork[CARRIER_TYPE_I_IND];

    uint16_T    temp, status[NUM_CHANS];
    int_T       i, chan;
    real_T     *y;
   
    switch (carrierType) {

        case SBS_PCI40A: {
            volatile uint16_T *slotBase = (uint16_T *) IWork[SLOT_BASE_I_IND];

            // get status if requested
            if (format == POSITION_AND_STATUS) {
                temp = slotBase[STATUS1] >> 4;
                status[0] = temp & 3;
                status[1] = (temp >> 2) & 3;
            }
            
            for (i = 0; i < nChans; i++) {
                y = ssGetOutputPortSignal(S, i);
                chan = mxGetPr(CHANNEL_ARG)[i] - 1;
                y[0] = (real_T) slotBase[POS_DATA_A + chan];
                if (format == POSITION_AND_STATUS)
                    y[1] = (real_T) status[chan];
            }
            break;
        }

        case SBS_FLEX104A: {
            int_T slotBase = IWork[SLOT_BASE_I_IND];
            int_T isaBase  = IWork[ISA_BASE_I_IND];
            int_T accReg   = ACCESS(isaBase);
            int_T csrReg   = CSR(isaBase);
            int_T dataReg  = DATA(isaBase);

            // get status if requested
            if (format == POSITION_AND_STATUS) {
                rl32eOutpW(accReg, slotBase | STATUS1);
                while (rl32eInpW(csrReg) & IPWAIT);
                temp = rl32eInpW(dataReg) >> 4;
                status[0] = temp & 3;
                status[1] = (temp >> 2) & 3;
            }

            for (i = 0; i < nChans; i++) {
                y = ssGetOutputPortSignal(S, i);
                chan = mxGetPr(CHANNEL_ARG)[i] - 1;
                rl32eOutpW(accReg, slotBase | POS_DATA_A + chan);
                while (rl32eInpW(csrReg) & IPWAIT);
                y[0] = (real_T) rl32eInpW(dataReg);
                if (format == POSITION_AND_STATUS)
                    y[1] = (real_T) status[chan];
            }
        
            break;
        }
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif  
}

#ifdef  MATLAB_MEX_FILE     /* Is this file being compiled as a MEX-file? */
#include "simulink.c"       /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"        /* Code generation registration function */
#endif

