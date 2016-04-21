/* $Revision: 1.2 $ */
/* 
   disbsdig48.c - xPC Target, non-inlined S-function driver for the
   digital input section of SBS IP-Unidig-E-48

   Copyright 1996-2002 The MathWorks, Inc.
*/

#define  S_FUNCTION_LEVEL 2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME  disbsunidige48

#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "time_xpcimport.h"
#include "ipcarrier.h"
#endif

#define NUMBER_OF_ARGS       (7)
#define CARRIER_SLOT_ARG     ssGetSFcnParam(S,0) // 1 for slot A, etc.
#define CHANNEL_ARG          ssGetSFcnParam(S,1) // a vector
#define SAMPLE_TIME_ARG      ssGetSFcnParam(S,2) // seconds
#define CARRIER_TYPE_ARG     ssGetSFcnParam(S,3) // CarrierType enum
#define CARRIER_ISA_BASE_ARG ssGetSFcnParam(S,4) // if relevant
#define CARRIER_PCI_BUS_ARG  ssGetSFcnParam(S,5) // if relevant
#define CARRIER_PCI_SLOT_ARG ssGetSFcnParam(S,6) // if relevant

#define MODEL_NUM            (0x05)  // ID PROM data word offsets
#define MFGR                 (0x04)

#define MFGR_VAL             (0xf0)  // Manufacturer ID for SBS
#define MODEL_VAL            (0x65)  // Model Number for IP-Unidig-E-48

#define NUM_REGS             (4)     
#define NUM_CHANS            (48)     

#define NUM_R_WORKS          (0)
#define NUM_I_WORKS          (3 + NUM_REGS)
#define CARRIER_TYPE_I_IND   (0)
#define ISA_BASE_I_IND       (1)
#define SLOT_BASE_I_IND      (2)
#define MASK_I_IND           (3)

static char_T msg[256];

static int_T regNum[NUM_CHANS / 8] = {0, 0, 1, 2, 2, 3};
static int_T output[NUM_REGS] = {0x00, 0x01, 0x20, 0x21};
static int_T input[NUM_REGS]  = {0x02, 0x03, 0x22, 0x23};

static uint16_T bit[NUM_CHANS] = {
    0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080,
    0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x8000,
    0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080,
    0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080,
    0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x8000,
    0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080};

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
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
    ssSetNumInputPorts(S,0);

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

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
    ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[0]);

    if (mxGetN((SAMPLE_TIME_ARG)) == 1) 
        ssSetOffsetTime(S, 0, 0.0);
    else
        ssSetOffsetTime(S, 0, mxGetPr(SAMPLE_TIME_ARG)[1]);
}

#define MDL_START 
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    uint16_T    data;
    uint8_T     mfgr, model;
    uint_T      i, r, chan, slotBase;
    int_T       timeout     = 1000;
    int_T      *IWork       = ssGetIWork(S);
    uint_T      carrierSlot = mxGetPr(CARRIER_SLOT_ARG)[0];
    CarrierType carrierType = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];

    IWork[CARRIER_TYPE_I_IND] = carrierType;

    // compute mask array
    for (r = 0; r < NUM_REGS; r++)
        IWork[MASK_I_IND + r] = 0;

    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;
        r = regNum[chan / 8];
        IWork[MASK_I_IND + r] |= bit[chan];
    }

    switch (carrierType) {

        case SBS_PCI40A: {
            PCIDeviceInfo pciInfo;
            uint16_T *carrierBase, *physical;

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
            // i.e check that there acuually is an IP module present
            pci40a = rl32eGetDevicePtr(carrierBase,0x700,RT_PG_USERREADWRITE);
            data = pci40a[CNTL0];
            pci40a[CNTL0] = data | AUTO_ACK | CLR_AUTO;
            mfgr = slotBase[ID_PROM + MFGR];
            rl32eWaitDouble(0.000004); 
            if (pci40a[CNTL2] & AUTO_INT_SET) {
                pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);
                sprintf(msg, "No Unidig-48 at PCI-40A slot %c, base %03x", 
                    (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
                ssSetErrorStatus(S, msg);
                return;
            }
            pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);

            model = slotBase[ID_PROM + MODEL_NUM];

            if (mfgr != MFGR_VAL || model != MODEL_VAL) {
                sprintf(msg, "No Unidig-48 at PCI-40A slot %c, base %03x", 
                    (char) (carrierSlot + 'A' - 1), (uint_T) carrierBase);
                ssSetErrorStatus(S, msg);
                return;
            }

            // configure channels for input
            for (r = 0; r < NUM_REGS; r++) {
                if (IWork[MASK_I_IND + r]) {
                    data = *(slotBase + output[r]);
                    *(slotBase + output[r]) = data | IWork[MASK_I_IND + r];
                }
            }
            break;
        }
        case SBS_FLEX104A: {
            uint_T  isaBase  = (uint_T) mxGetPr(CARRIER_ISA_BASE_ARG)[0];
            int_T   csrReg   = CSR(isaBase);
            int_T   accReg   = ACCESS(isaBase);
            int_T   dataReg  = DATA(isaBase);
            int_T   slotCode = SLOT(carrierSlot); 
            int_T   slotBase = IOSPACE | slotCode;

            // IP reset - takes about 250ms
            rl32eOutpW(csrReg, TMRST | IPRST);
            rl32eWaitDouble(0.300); 
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

            if (timeout <= 0 || mfgr != MFGR_VAL || model != MODEL_VAL) 
            {
                sprintf(msg, "No Unidig-48 at Flex/104A slot %c base 0x%03x", 
                    (char) (carrierSlot + 'A' - 1), (uint_T) isaBase);
                ssSetErrorStatus(S, msg);
                return;
            }

            // configure channels for input
            for (r = 0; r < NUM_REGS; r++) {
                if (IWork[MASK_I_IND + r]) {
                    rl32eOutpW(accReg, slotBase | output[r]);
                    while (rl32eInpW(csrReg) & IPWAIT);
                    data = rl32eInpW(dataReg);

                    data |= IWork[MASK_I_IND + r];  

                    rl32eOutpW(accReg, slotBase | output[r]);
                    while (rl32eInpW(csrReg) & IPWAIT);
                    rl32eOutpW(dataReg, data);
                }
            }

            IWork[ISA_BASE_I_IND] = isaBase;  
            IWork[SLOT_BASE_I_IND] = slotBase;  
            break;
        }
        
        default:
            sprintf(msg, "Unsupported carrier type: %d", carrierType);
            ssSetErrorStatus(S, msg);
            return;
   }
#endif
}
    

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    uint_T i, r, chan;
    uint16_T data[NUM_REGS];
    real_T *y;
    int_T *IWork = ssGetIWork(S);
    CarrierType carrierType = (CarrierType) IWork[CARRIER_TYPE_I_IND];

    // read data from all regs containing a channel we input from
    switch (carrierType) {
        case SBS_PCI40A: {
            volatile uint16_T *slotBase = (uint16_T *) IWork[SLOT_BASE_I_IND];

            for (r = 0; r < NUM_REGS; r++) {
                if (IWork[MASK_I_IND + r]) {
                    data[r] = *(slotBase + input[r]);
                }
            }
            break;
        }
        case SBS_FLEX104A: {
            uint_T slotBase = IWork[SLOT_BASE_I_IND];
            uint_T isaBase  = IWork[ISA_BASE_I_IND];
            int_T  accReg   = ACCESS(isaBase);
            int_T  csrReg   = CSR(isaBase);
            int_T  dataReg  = DATA(isaBase);

            for (r = 0; r < NUM_REGS; r++) {
                if (IWork[MASK_I_IND + r]) {
                    rl32eOutpW(accReg, slotBase + input[r]);
                    while (rl32eInpW(csrReg) & IPWAIT);
                    data[r] = rl32eInpW(dataReg);
                }
            }
            break;
        }
    }

    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {

        chan = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        r = regNum[chan / 8];

        y = ssGetOutputPortSignal(S, i);

        y[0] = (data[r] & bit[chan]) ? 1.0 : 0.0;
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

