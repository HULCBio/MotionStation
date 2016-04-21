/* $Revision: 1.3 $ */
/* 
  dasbsip16dac.c - xPC Target, non-inlined S-function driver for the 
  IP-16DAC IP module by SBS GreenSpring Modular I/O

  with initial value and reset parameters

  Copyright 1996-2002 The MathWorks, Inc.
*/

#define  S_FUNCTION_LEVEL  2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME   dasbsip16dac

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

#define NUMBER_OF_ARGS        (10)
#define CARRIER_SLOT_ARG      ssGetSFcnParam(S,0) // 1 for slot A, etc.
#define CHANNEL_ARG           ssGetSFcnParam(S,1) // subset of {1,2,3}
#define RANGE_ARG             ssGetSFcnParam(S,2) // vector of -5,-10,5,10 
#define RESET_ARG             ssGetSFcnParam(S,3) // vector of boolean
#define INIT_VALUE_ARG        ssGetSFcnParam(S,4) // vector of double
#define SAMPLE_TIME_ARG       ssGetSFcnParam(S,5) // seconds
#define CARRIER_TYPE_ARG      ssGetSFcnParam(S,6) // CarrierType enum
#define CARRIER_ISA_BASE_ARG  ssGetSFcnParam(S,7) // if relevant
#define CARRIER_PCI_BUS_ARG   ssGetSFcnParam(S,8) // if relevant
#define CARRIER_PCI_SLOT_ARG  ssGetSFcnParam(S,9) // if relevant 

#define MFGR_VAL              (0xf0)  // SBS Manufacturer ID
#define MODEL_VAL             (0x25)  // IP-16DAC Model No 
#define RESOLUTION            (65536) // 16 bit
#define MAX_COUNT             (65535) // max count
#define NUM_CHANS             (3)     // number of channels

#define MODEL_NUM             (0x05)  // ID PROM word offsets
#define MFGR                  (0x04)

#define NUM_R_WORKS           (NUM_CHANS * 2)
#define OFFSET_R_IND          (0)
#define GAIN_R_IND            (NUM_CHANS)

#define NUM_I_WORKS           (1)
#define CHAN_I_IND            (0)   // access reg data for chan 0 (Flex/104A)
                                    // address of chan 0 (PCI-40A)

static char_T msg[256];

static int16_T isaProm(int_T isaBase, int_T access)
{
#ifndef MATLAB_MEX_FILE
    int_T csrReg  = CSR(isaBase);
    int_T accReg  = ACCESS(isaBase);
    int_T dataReg = DATA(isaBase);
    int16_T loByte;
    int16_T hiByte;

    rl32eOutpW(accReg, access);
    while (rl32eInpW(csrReg) & IPWAIT);
    hiByte = 0xff & rl32eInpW(dataReg);

    rl32eOutpW(accReg, access + 1);
    while (rl32eInpW(csrReg) & IPWAIT);
    loByte = 0xff & rl32eInpW(dataReg);

    return loByte | hiByte << 8;
#endif
}

static int16_T pciProm(volatile uint16_T *ip16dac, int_T address)
{
#ifndef MATLAB_MEX_FILE
    int16_T hiByte = 0xff & ip16dac[address];
    int16_T loByte = 0xff & ip16dac[address + 1];

    return loByte | hiByte << 8;
#endif
}

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
    int_T       timeout     = 1000;
    int_T      *IWork       = ssGetIWork(S);
    real_T     *RWork       = ssGetRWork(S);
    int_T       nChannels   = mxGetN(CHANNEL_ARG);
    uint_T      carrierSlot = mxGetPr(CARRIER_SLOT_ARG)[0];
    CarrierType carrierType = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];

    int_T       i, data, chan, range, count, mfgr, model, pciSlot, pciBus;
    int_T       isaBase, csrReg, accReg, dataReg, slotCode, slotBase, promBase;
    int_T       oError[NUM_CHANS], gError[NUM_CHANS];
    real_T      voltage;

    PCIDeviceInfo pciInfo;
    uint16_T *carrierBase;

    volatile uint16_T *ip16dac, *pci40a;

    switch (carrierType) {

    case SBS_PCI40A: 
        pciSlot = mxGetPr(CARRIER_PCI_SLOT_ARG)[0];
        pciBus  = mxGetPr(CARRIER_PCI_BUS_ARG)[0];
        
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
        ip16dac = rl32eGetDevicePtr(carrierBase + carrierSlot * SLOT_OFS,
            SLOT_LEN, RT_PG_USERREADWRITE);

        IWork[CHAN_I_IND] = (int_T) ip16dac;

        // for the first read from the slot, check for IP bus time-out,
        // i.e check that there acuually is an IP module present
        pci40a = rl32eGetDevicePtr(carrierBase, 0x700, RT_PG_USERREADWRITE);
        data = pci40a[CNTL0];
        pci40a[CNTL0] = data | AUTO_ACK | CLR_AUTO;
        mfgr = 0xff & ip16dac[ID_PROM + MFGR];
        rl32eWaitDouble(0.000004); 
        if (pci40a[CNTL2] & AUTO_INT_SET) {
            pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);
            sprintf(msg, "No IP-16DAC at PCI-40A slot %c, base %03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }
        pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);

        model = 0xff & ip16dac[ID_PROM + MODEL_NUM];

        if (mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-16DAC at PCI-40A slot %c, base %03x", 
                (char) (carrierSlot + 'A' - 1), (uint_T) carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        // read offset and gain errors from PROM
        oError[0] = pciProm(ip16dac, ID_PROM + 0x0c);
        oError[1] = pciProm(ip16dac, ID_PROM + 0x0e);
        oError[2] = pciProm(ip16dac, ID_PROM + 0x10);
        gError[0] = pciProm(ip16dac, ID_PROM + 0x12);
        gError[1] = pciProm(ip16dac, ID_PROM + 0x14);
        gError[2] = pciProm(ip16dac, ID_PROM + 0x16);

        break;
        
    case SBS_FLEX104A: 
        isaBase  = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        csrReg   = CSR(isaBase);
        accReg   = ACCESS(isaBase);
        dataReg  = DATA(isaBase);
        slotCode = SLOT(carrierSlot); 
        slotBase = IOSPACE | slotCode;
        promBase = IDSPACE | slotCode;

        IWork[CHAN_I_IND] = slotBase;  

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

        if (timeout <= 0 || mfgr != MFGR_VAL || model != MODEL_VAL) 
        {
            sprintf(msg, "No IP-16DAC at Flex/104A slot %c base 0x%03x", 
                (char) (carrierSlot + 'A' - 1), (uint_T) isaBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        // read offset and gain errors from PROM
        oError[0] = isaProm(isaBase, promBase + 0x0c);
        oError[1] = isaProm(isaBase, promBase + 0x0e);
        oError[2] = isaProm(isaBase, promBase + 0x10);
        gError[0] = isaProm(isaBase, promBase + 0x12);
        gError[1] = isaProm(isaBase, promBase + 0x14);
        gError[2] = isaProm(isaBase, promBase + 0x16);

        break;
        
    default:
            sprintf(msg, "Unsupported carrier type: %d", carrierType);
            ssSetErrorStatus(S, msg);
            return;
    }

    for (i = 0; i < nChannels; i++) {
        chan  = mxGetPr(CHANNEL_ARG)[i] - 1;
        range = mxGetPr(RANGE_ARG)[i];

        switch (range) {
        case -5:
            RWork[OFFSET_R_IND + i] = RESOLUTION / 2.0 - oError[chan] / 4.0;
            RWork[GAIN_R_IND + i]   = RESOLUTION / 10.0;
            RWork[GAIN_R_IND + i]  *= 1.0 + gError[chan] / (2.0 * RESOLUTION);
            break;
        case 5:
            RWork[OFFSET_R_IND + i] = -oError[chan] / 4.0;
            RWork[GAIN_R_IND + i]   = RESOLUTION / 5.0;
            RWork[GAIN_R_IND + i]  *= 1.0 + gError[chan] / (2.0 * RESOLUTION);
           break;
        case 10:
            RWork[OFFSET_R_IND + i] = -oError[chan] / 4.0;
            RWork[GAIN_R_IND + i]   = RESOLUTION / 10.0;
            RWork[GAIN_R_IND + i]  *= 1.0 + gError[chan] / (2.0 * RESOLUTION);
            break;
        case -10:
            RWork[OFFSET_R_IND + i] = RESOLUTION / 2.0 - oError[chan]/4;
            RWork[GAIN_R_IND + i]   = RESOLUTION / 20.0;
            RWork[GAIN_R_IND + i]  *= 1.0 + gError[chan] / (2.0 * RESOLUTION);
            break;
        }     
    }

    // set channel voltages to their initial values

    for (i = 0; i < nChannels; i++) {
        chan    = mxGetPr(CHANNEL_ARG)[i] - 1;
        voltage = (real_T) mxGetPr(INIT_VALUE_ARG)[i];
        count   = voltage * RWork[GAIN_R_IND + i] + RWork[OFFSET_R_IND + i]; 

        if (count > MAX_COUNT)
            count = MAX_COUNT;
        if (count < 0)
            count = 0;

        switch (carrierType) {
            case SBS_PCI40A: 
                ip16dac[chan] = count;
                break;  
            case SBS_FLEX104A: {
                rl32eOutpW(accReg, slotBase + chan);
                while (rl32eInpW(csrReg) & IPWAIT);
                rl32eOutpW(dataReg, count);
               break;         
            }
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

    int_T       i, count, chan, slotBase, isaBase, csrReg, accReg, dataReg;
    real_T      voltage;
    
    InputRealPtrsType uPtrs;

    volatile uint16_T *ip16dac;

    switch (carrierType) {
        case SBS_PCI40A: 
            ip16dac = (uint16_T *) IWork[CHAN_I_IND];
            break;   
        case SBS_FLEX104A: 
            isaBase  = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
            csrReg   = CSR(isaBase);
            accReg   = ACCESS(isaBase);
            dataReg  = DATA(isaBase);
            slotBase = IWork[CHAN_I_IND];
            break;
    }

    for (i = 0; i < nChannels; i++) {

        uPtrs = ssGetInputPortRealSignalPtrs(S, i);
        voltage = *uPtrs[0];

        chan  = mxGetPr(CHANNEL_ARG)[i] - 1;
        count = voltage * RWork[GAIN_R_IND + i] + RWork[OFFSET_R_IND + i]; 

        if (count > MAX_COUNT)
            count = MAX_COUNT;
        if (count < 0)
            count = 0;

        switch (carrierType) {
            case SBS_PCI40A: 
                ip16dac[chan] = count;
                break;   
            case SBS_FLEX104A: 
                rl32eOutpW(accReg, slotBase + chan);
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
    int_T        i, chan, reset, count;
    int_T        slotBase, isaBase, csrReg, accReg, dataReg;
    
    volatile uint16_T *ip16dac;

    switch (carrierType) {
        case SBS_PCI40A: 
            ip16dac = (uint16_T *)IWork[CHAN_I_IND];
            break;   
        case SBS_FLEX104A: 
            isaBase  = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
            csrReg   = CSR(isaBase);
            accReg   = ACCESS(isaBase);
            dataReg  = DATA(isaBase);
            slotBase = IWork[CHAN_I_IND];
            break;
    }

    // set all resettable channel voltages to their init values

    for (i = 0; i < nChannels; i++) {

        reset = (int_T) mxGetPr(RESET_ARG)[i];

        if (!reset)
            continue;

        chan    = mxGetPr(CHANNEL_ARG)[i] - 1;
        voltage = (real_T) mxGetPr(INIT_VALUE_ARG)[i];
        count   = voltage * RWork[GAIN_R_IND + i] + RWork[OFFSET_R_IND + i]; 

        if (count < 0)
            count = 0;
        if (count > MAX_COUNT)
            count = MAX_COUNT;

        switch (carrierType) {
            case SBS_PCI40A: 
                ip16dac[chan] = count;
                break;   
            case SBS_FLEX104A: 
                rl32eOutpW(accReg, slotBase + chan);
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
