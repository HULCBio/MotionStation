/* 
  dasbsipdac.c - xPC Target, non-inlined S-function driver for the 
  IP-DAC IP module by SBS GreenSpring Modular I/O

  with initial value and reset parameters

  Copyright 1996-2002 The MathWorks, Inc.
*/

#define  S_FUNCTION_LEVEL  2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME   dasbsipdac

#include "simstruc.h" 

#ifdef   MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "time_xpcimport.h"
#include "ipcarrier.h"
#endif

#define NUMBER_OF_ARGS       (10)
#define CARRIER_SLOT_ARG     ssGetSFcnParam(S,0) // 1 for slot A, etc.
#define CHANNEL_ARG          ssGetSFcnParam(S,1) // subset of {1,2,3,4,5,6}
#define RANGE_ARG            ssGetSFcnParam(S,2) // vector of -2.5,-5,-10,5,10
#define RESET_ARG            ssGetSFcnParam(S,3) // vector of boolean
#define INIT_VALUE_ARG       ssGetSFcnParam(S,4) // vector of double
#define SAMPLE_TIME_ARG      ssGetSFcnParam(S,5) // seconds
#define CARRIER_TYPE_ARG     ssGetSFcnParam(S,6) // CarrierType enum
#define CARRIER_ISA_BASE_ARG ssGetSFcnParam(S,7) // if relevant
#define CARRIER_PCI_BUS_ARG  ssGetSFcnParam(S,8) // if relevant
#define CARRIER_PCI_SLOT_ARG ssGetSFcnParam(S,9) // if relevant 

#define MFGR_VAL             (0xf0) // value of Manufacturer ID for SBS
#define MODEL_VAL            (0x16) // value of Model No for IP-DAC
#define MAX_COUNT            (4095) // max count for IP-DAC
#define NUM_CHANS            (6)    // number of channels on an IP-DAC

#define DAC1_GAIN            (0x12) // ID PROM word offsets
#define DAC1_OFFSET          (0x0c) 
#define DRIVER_ID            (0x08)  
#define MODEL_NUM            (0x05)
#define MFGR                 (0x04)

#define NUM_R_WORKS          (NUM_CHANS * 2)
#define OFFSET_R_IND         (0)    
#define GAIN_R_IND           (NUM_CHANS)

#define NUM_I_WORKS          (NUM_CHANS)
#define CHAN_I_IND           (0)             // access reg data (Flex/104A)
                                             // channel addresses (PCI-40A)

static char_T msg[256];

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
        sprintf(msg,"%d input arguments were expected, but %d were passed\n",
            NUMBER_OF_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

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
    int_T       timeout      = 1000;
    int_T      *IWork        = ssGetIWork(S);
    real_T     *RWork        = ssGetRWork(S);
    int_T       nChannels    = mxGetN(CHANNEL_ARG);
    int_T       carrierSlot  = mxGetPr(CARRIER_SLOT_ARG)[0];
    CarrierType carrierType  = (CarrierType)mxGetPr(CARRIER_TYPE_ARG)[0];
    int_T       dacIndex[NUM_CHANS]  = {2, 1, 6, 5, 10, 9};

    int_T       i, data, chan, count, code, driverId, mfgr, model;
    int_T       pciSlot, pciBus, isaBase, slotCode, csrReg, accReg, dataReg; 
    real_T      voltage, size, gError[NUM_CHANS], oError[NUM_CHANS];
    
    PCIDeviceInfo pciInfo;
    uint16_T *carrierBase;

    volatile uint16_T *ipdac, *pci40a;

    switch (carrierType) {

    case SBS_PCI40A: 
        pciSlot = mxGetPr(CARRIER_PCI_SLOT_ARG)[0];
        pciBus  = mxGetPr(CARRIER_PCI_BUS_ARG)[0];

        if (pciSlot < 0) {
            if (rl32eGetPCIInfo((uint16_T)SBS_VENDOR_ID, 
                (uint16_T)PCI40A_DEVICE_ID, &pciInfo)) {
                sprintf(msg, "no PCI-40A carrier board found");
                ssSetErrorStatus(S, msg);
                return;
            }
        } 
        else if (rl32eGetPCIInfoAtSlot(SBS_VENDOR_ID, PCI40A_DEVICE_ID, 
            pciSlot + pciBus * 256, &pciInfo)) {
            sprintf(msg, "no PCI-40A at PCI bus %d slot %d", pciBus, pciSlot);
            ssSetErrorStatus(S, msg);
            return;
        }

        // set ipdac = slot base address
        carrierBase = (uint16_T *)pciInfo.BaseAddress[2];
        ipdac = rl32eGetDevicePtr(carrierBase + carrierSlot * SLOT_OFS,
                SLOT_LEN, RT_PG_USERREADWRITE);

        // for the first read from the slot, check for IP bus time-out,
        // i.e check that there actually is an IP module present
        pci40a = rl32eGetDevicePtr(carrierBase, 0x700, RT_PG_USERREADWRITE);
        data = pci40a[CNTL0];
        pci40a[CNTL0] = data | AUTO_ACK | CLR_AUTO;
        mfgr = 0xff & ipdac[ID_PROM + MFGR];
        rl32eWaitDouble(0.000004); 
        if (pci40a[CNTL2] & AUTO_INT_SET) {
            pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);
            sprintf(msg, "No IP module at PCI-40A slot %c, base %03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }
        pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);

        model = 0xff & ipdac[ID_PROM + MODEL_NUM];

        if (mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-DAC at PCI-40A slot %c, base %03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        driverId = 0xff & ipdac[ID_PROM + DRIVER_ID];

        for (i = 0; i < nChannels; i++) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;

            // get offset corrections from ID PROM
            oError[i] = (int_T)(int8_T)(ipdac[ID_PROM + DAC1_OFFSET + chan]);

            // get gain corrections from ID PROM
            gError[i] = (int_T)(int8_T)(ipdac[ID_PROM + DAC1_GAIN + chan]);

            // compute and store the chan address
            IWork[CHAN_I_IND + i] = (uint_T) &ipdac[dacIndex[chan]];
        }
        break;

    case SBS_FLEX104A:
        isaBase = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        carrierSlot  = mxGetPr(CARRIER_SLOT_ARG)[0];
        csrReg = CSR(isaBase);
        accReg = ACCESS(isaBase);
        dataReg = DATA(isaBase);
        slotCode = SLOT(carrierSlot);

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
        mfgr = 0xff & rl32eInpW(dataReg);

        // read Model Number from ID PROM
        rl32eOutpW(accReg, IDSPACE | slotCode | MODEL_NUM);
        while (--timeout > 0 && (rl32eInpW(csrReg) & IPWAIT));
        model = 0xff & rl32eInpW(dataReg);

        // check that we're got an IP-DAC
        if (timeout <= 0 || mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-DAC at Flex/104A slot %c base 0x%03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)isaBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        // read Driver ID (low byte) from ID PROM 
        rl32eOutpW(accReg, IDSPACE | slotCode | DRIVER_ID);
        while (rl32eInpW(csrReg) & IPWAIT);
        driverId = 0xff & rl32eInpW(dataReg);

        for (i = 0; i < nChannels; i++) {
            chan = mxGetPr(CHANNEL_ARG)[i] - 1;

            // get offset correction from ID PROM
            rl32eOutpW(accReg, IDSPACE | slotCode | (DAC1_OFFSET + chan) );
            while (rl32eInpW(csrReg) & IPWAIT);
            oError[i] = (int_T)(int8_T)(rl32eInpW(dataReg));

            // get gain correction from ID PROM
            rl32eOutpW(accReg, IDSPACE | slotCode | (DAC1_GAIN + chan) );
            while (rl32eInpW(csrReg) & IPWAIT);
            gError[i] = (int_T)(int8_T)(rl32eInpW(dataReg));

            // compute access register value needed to address the chan
            IWork[CHAN_I_IND + i] = IOSPACE | slotCode | dacIndex[chan];
        }
        break;
                
    default:
        sprintf(msg, "Unsupported carrier type: %d", carrierType);
        ssSetErrorStatus(S, msg);
        return;
    }

    for (i = 0; i < nChannels; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        code = (int_T)(10.0 * mxGetPr(RANGE_ARG)[i]);
        size = MAX_COUNT + 1;

        switch (code) {
        case -25: 
            RWork[GAIN_R_IND + i] = size / 5.0;
            RWork[OFFSET_R_IND + i] = size / 2;
            if (driverId == 4) {
                RWork[GAIN_R_IND + i] += gError[i] / 10.0;
                RWork[OFFSET_R_IND + i] += gError[i] / 4.0 + oError[i] / 4.0;
            }
            break;
        case -50:
            RWork[GAIN_R_IND + i] = size / 10.0;
            RWork[OFFSET_R_IND + i] = size / 2;
            if (driverId == 0) {
                RWork[GAIN_R_IND + i] += gError[i] / 20.0;
                RWork[OFFSET_R_IND + i] += gError[i] / 4.0 + oError[i] / 4.0;
            }
            break;
        case -100:
            RWork[GAIN_R_IND + i] = size / 20.0;
            RWork[OFFSET_R_IND + i] = size / 2;
            if (driverId == 2) {
                RWork[GAIN_R_IND + i] += gError[i] / 40.0;
                RWork[OFFSET_R_IND + i] += gError[i] / 4.0 + oError[i] / 4.0;
            }
            break;
        case 50:
            RWork[GAIN_R_IND + i] = size / 5.0;
            RWork[OFFSET_R_IND + i] = 0.0;
            if (driverId == 1) {
                RWork[GAIN_R_IND + i] += gError[i] / 20.0;
                RWork[OFFSET_R_IND + i] += oError[i] / 4.0;
            }
           break;
        case 100:
            RWork[GAIN_R_IND + i] = size / 10.0;
            RWork[OFFSET_R_IND + i] = 0.0;
            if (driverId == 3) {
                RWork[GAIN_R_IND + i] += gError[i] / 40.0;
                RWork[OFFSET_R_IND + i] += oError[i] / 4.0;
            }
            break;
        }     
    }

    // set channel voltages to their initial values

    for (i = 0; i < nChannels; i++) {

        voltage = (real_T) mxGetPr(INIT_VALUE_ARG)[i];

        count = voltage * RWork[GAIN_R_IND + i] + RWork[OFFSET_R_IND + i]; 

        if (count > MAX_COUNT)
            count = MAX_COUNT;
        if (count < 0)
            count = 0;

        switch (carrierType) {
        case SBS_PCI40A: 
            *(uint16_T *)IWork[CHAN_I_IND + i] = count;
            break;       
        case SBS_FLEX104A: 
            rl32eOutpW(accReg, IWork[CHAN_I_IND + i]);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, count);
           break;         
        }
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T      *IWork       = ssGetIWork(S);
    real_T     *RWork       = ssGetRWork(S);
    int_T       nChannels   = mxGetN(CHANNEL_ARG);
    CarrierType carrierType = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];
    int_T       i, chan, count;
    int_T       isaBase, csrReg, accReg, dataReg;
    real_T      voltage;
    
    InputRealPtrsType uPtrs;

    switch (carrierType) {
    case SBS_PCI40A: 
        break;   
    case SBS_FLEX104A: 
        isaBase = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        csrReg = CSR(isaBase);
        accReg = ACCESS(isaBase);
        dataReg = DATA(isaBase);
        break;
    }

    for (i = 0; i < nChannels; i++) {

        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        voltage = *uPtrs[0];

        count = voltage * RWork[GAIN_R_IND + i] + RWork[OFFSET_R_IND + i]; 

        if (count > MAX_COUNT)
            count = MAX_COUNT;
        if (count < 0)
            count = 0;

        switch (carrierType) {

        case SBS_PCI40A: 
            *(uint16_T *)IWork[CHAN_I_IND + i] = count;
            break;   
            
        case SBS_FLEX104A: 
            rl32eOutpW(accReg, IWork[CHAN_I_IND + i]);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, count);
            break;           
        }
    }

#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    CarrierType  carrierType  = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];
    int_T       *IWork        = ssGetIWork(S);
    real_T      *RWork        = ssGetRWork(S);
    int_T        nChannels    = mxGetN(CHANNEL_ARG);
    real_T       voltage;
    int_T        i, reset, count;
    int_T        isaBase, csrReg, accReg, dataReg;

    switch (carrierType) {
    case SBS_PCI40A: 
        break;   
    case SBS_FLEX104A: 
        isaBase = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        csrReg = CSR(isaBase);
        accReg = ACCESS(isaBase);
        dataReg = DATA(isaBase);
        break;
    }

    // set all resettable channel voltages to their init values

    for (i = 0; i < nChannels; i++) {

        reset = (int_T) mxGetPr(RESET_ARG)[i];

        if (!reset)
            continue;

        voltage = (real_T) mxGetPr(INIT_VALUE_ARG)[i];

        count = voltage * RWork[GAIN_R_IND + i] + RWork[OFFSET_R_IND + i]; 

        if (count > MAX_COUNT)
            count = MAX_COUNT;
        if (count < 0)
            count = 0;

        switch (carrierType) {
        case SBS_PCI40A: 
            *(uint16_T *)IWork[CHAN_I_IND + i] = count;
            break;       
        case SBS_FLEX104A: 
            rl32eOutpW(accReg, IWork[CHAN_I_IND + i]);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, count);
            break;         
        }
    }
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
