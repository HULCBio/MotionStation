/* $Revision: 1.6.4.1 $ */
// adsbsip16adc.c - xPC Target, non-inlined S-function driver for the 
// IP-16ADC IP module by SBS GreenSpring Modular I/O
//
// Copyright 1996-2003 The MathWorks, Inc.

#define  S_FUNCTION_LEVEL  2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME   adsbsip16adc

#include "simstruc.h" 

#ifdef   MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include <math.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "time_xpcimport.h"
#include "ipcarrier.h"
#endif

#define NUMBER_OF_ARGS        (8)
#define CARRIER_SLOT_ARG      ssGetSFcnParam(S,0) // 1 for slot A, etc.
#define CHANNEL_ARG           ssGetSFcnParam(S,1) // nonempty vector of {1..16}  
#define RANGE_ARG             ssGetSFcnParam(S,2) // vector of {5,10,-5,-10}
#define SAMPLE_TIME_ARG       ssGetSFcnParam(S,3) // seconds
#define CARRIER_TYPE_ARG      ssGetSFcnParam(S,4) // CarrierType enum
#define CARRIER_ISA_BASE_ARG  ssGetSFcnParam(S,5) // if relevant
#define CARRIER_PCI_BUS_ARG   ssGetSFcnParam(S,6) // if relevant
#define CARRIER_PCI_SLOT_ARG  ssGetSFcnParam(S,7) // if relevant 

#define MFGR_VAL              (0xf0)    // value of Manufacturer ID for SBS
#define MODEL_VAL             (0x36)    // value of Model No for IP-16ADC
#define RESOLUTION            (65536.0) // 16-bit 
#define NUM_CHANS             (16)  

#define IP16ADC_CSR           (0x00)    // word offsets of registers
#define IP16ADC_DATA          (0x02)
#define IP16ADC_TRIGGER       (0x06)

#define SWRESET               (0x2000)  // IP16ADC_CSR bits
#define SDL                   (0x1000)
#define FREERUN               (0x0100)
#define BPUP                  (0x0040)
#define UNITY                 (0x0020)

#define MFGR                  (0x04)    // word offsets of ID PROM data
#define MODEL_NUM             (0x05)   
#define OFFSET_CAL            (0x10)   
#define GAIN_CAL              (0x18)   

#define FULLGAIN              (0)
#define HALFGAIN              (1)
#define UNIPOLAR              (0)
#define BIPOLAR               (1)

#define NUM_R_WORKS           (8)
#define OFFSET_R_IND          (0) 
#define GAIN_R_IND            (4)

#define NUM_I_WORKS           (2 + NUM_CHANS)
#define ISA_BASE_I_IND        (0)
#define SLOT_BASE_I_IND       (1)
#define CSR_I_IND             (2)

#define TIMEOUT               (1000)

static char_T msg[256];

static int16_T isaProm(int_T isaBase, int_T access)
{
#ifndef MATLAB_MEX_FILE
    int_T csrReg  = CSR(isaBase);
    int_T accReg  = ACCESS(isaBase);
    int_T dataReg = DATA(isaBase);
    int_T loByte;
    int_T hiByte;

    rl32eOutpW(accReg, access);
    while (rl32eInpW(csrReg) & IPWAIT);
    hiByte = rl32eInpW(dataReg) & 0xff;

    rl32eOutpW(accReg, access + 1);
    while (rl32eInpW(csrReg) & IPWAIT);
    loByte = rl32eInpW(dataReg) & 0xff;

    return loByte | hiByte << 8;
#endif
}

static int16_T pciProm(volatile uint16_T *ip16adc, int_T address)
{
#ifndef MATLAB_MEX_FILE
    int16_T hiByte = 0xff & ip16adc[address];
    int16_T loByte = 0xff & ip16adc[address + 1];

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
    ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0; i < mxGetN(CHANNEL_ARG); i++) {
        ssSetOutputPortWidth(S, i, 1);
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
    CarrierType carrierType  = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];
    int_T       unipolar[16] = {0x8, 0x10, 0x9, 0x11, 0xa, 0x12, 0xb, 0x13, 
                                0xc, 0x14, 0xd, 0x15, 0xe, 0x16, 0xf, 0x17};
    
    int_T       data, mfgr, model, pciBus, pciSlot;
    int_T       i, csr, chan, first, range, gain, polarity;
    int_T       isaBase, csrReg, accReg, dataReg;
    int_T       slotCode, slotBase, promBase;
    real_T      Range, Offset, Gain, oError[2][2], gError[2][2];

    PCIDeviceInfo pciInfo;
    uint16_T *carrierBase;

    volatile uint16_T *ip16adc, *pci40a;

    if (nChannels > NUM_CHANS) {
        sprintf(msg, "IP-16ADC blocks has more than %d channels", NUM_CHANS);
        ssSetErrorStatus(S, msg);
        return;
    }

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
        ip16adc = rl32eGetDevicePtr(carrierBase + carrierSlot * SLOT_OFS,
            SLOT_LEN, RT_PG_USERREADWRITE);

        IWork[SLOT_BASE_I_IND] = (int_T) ip16adc;

        // for the first read from the slot, check for IP bus time-out,
        // i.e check that there actually is an IP module present
        pci40a = rl32eGetDevicePtr(carrierBase, 0x700, RT_PG_USERREADWRITE);
        data = pci40a[CNTL0];
        pci40a[CNTL0] = data | AUTO_ACK | CLR_AUTO;
        mfgr = 0xff & ip16adc[ID_PROM + MFGR];
        rl32eWaitDouble(0.000004); 
        if (pci40a[CNTL2] & AUTO_INT_SET) {
            pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);
            sprintf(msg, "No IP-16DAC at PCI-40A slot %c, base %03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }
        pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);

        model = 0xff & ip16adc[ID_PROM + MODEL_NUM];

        if (mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-16DAC at PCI-40A slot %c, base %03x", 
                (char) (carrierSlot + 'A' - 1), (uint_T) carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }
        
        // read calibration offsets and gains from PROM
        oError[FULLGAIN][UNIPOLAR] = pciProm(ip16adc, ID_PROM + 0x10);
        oError[FULLGAIN][BIPOLAR]  = pciProm(ip16adc, ID_PROM + 0x12);
        oError[HALFGAIN][UNIPOLAR] = pciProm(ip16adc, ID_PROM + 0x14);
        oError[HALFGAIN][BIPOLAR]  = pciProm(ip16adc, ID_PROM + 0x16); 

        gError[FULLGAIN][UNIPOLAR] = pciProm(ip16adc, ID_PROM + 0x18);
        gError[FULLGAIN][BIPOLAR]  = pciProm(ip16adc, ID_PROM + 0x1a);
        gError[HALFGAIN][UNIPOLAR] = pciProm(ip16adc, ID_PROM + 0x1c);
        gError[HALFGAIN][BIPOLAR]  = pciProm(ip16adc, ID_PROM + 0x1e);

        break;

    case SBS_FLEX104A: 
        isaBase  = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        csrReg   = CSR(isaBase);
        accReg   = ACCESS(isaBase);
        dataReg  = DATA(isaBase);
        slotCode = SLOT(carrierSlot); 
        slotBase = IOSPACE | slotCode;
        promBase = IDSPACE | slotCode;

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

        if (timeout <= 0 || mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-16DAC at Flex/104A slot %c base 0x%03x", 
                (char) (carrierSlot + 'A' - 1), (uint_T) isaBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        IWork[ISA_BASE_I_IND] = isaBase;  
        IWork[SLOT_BASE_I_IND] = slotBase;  

        // read calibration offsets and gains from PROM
        oError[FULLGAIN][UNIPOLAR] = isaProm(isaBase, promBase + 0x10);
        oError[FULLGAIN][BIPOLAR]  = isaProm(isaBase, promBase + 0x12);
        oError[HALFGAIN][UNIPOLAR] = isaProm(isaBase, promBase + 0x14);
        oError[HALFGAIN][BIPOLAR]  = isaProm(isaBase, promBase + 0x16);

        gError[FULLGAIN][UNIPOLAR] = isaProm(isaBase, promBase + 0x18);
        gError[FULLGAIN][BIPOLAR]  = isaProm(isaBase, promBase + 0x1a);
        gError[HALFGAIN][UNIPOLAR] = isaProm(isaBase, promBase + 0x1c);
        gError[HALFGAIN][BIPOLAR]  = isaProm(isaBase, promBase + 0x1e);

        break;
    
    default:
        sprintf(msg, "Unsupported carrier type: %d", carrierType);
        ssSetErrorStatus(S, msg);
        return;
   }

    // for each channel, compute CSR value, offset, and gain

    for (i = 0; i < nChannels; i++) {
        chan     = mxGetPr(CHANNEL_ARG)[i] - 1;
        range    = mxGetPr(RANGE_ARG)[i];
        gain     = (abs(range) == 5) ? FULLGAIN : HALFGAIN;
        polarity = (range > 0) ? UNIPOLAR : BIPOLAR;
        Range    = (polarity == UNIPOLAR) ? range : 2 * abs(range);
        Offset   = oError[gain][polarity];
        Gain     = gError[gain][polarity];

        // channel select bits CHSL0, CHSL1, CHSL2, INSL0, INSL1
        csr = (polarity == UNIPOLAR) ? unipolar[chan] : 0x18 + chan;

        // select gain
        if (gain == FULLGAIN) 
            csr |= UNITY;

        // select input polarity
        if (polarity == BIPOLAR) 
            csr |= BPUP;

        // single conversion mode 
        csr |= FREERUN;

        // turn s/w reset off 
        csr |= SWRESET;

        // IWork[CSR_I_IND + i] holds CSR value for channel i + 1
        if (i > 0) 
            IWork[CSR_I_IND + i - 1] = csr;
        else
            IWork[CSR_I_IND + nChannels - 1] = csr;

        if (polarity == UNIPOLAR) {
            RWork[OFFSET_R_IND + i] = Offset / 4.0;
            RWork[GAIN_R_IND + i] = 
                (1.0 - Gain / (4.0 * RESOLUTION)) * Range / RESOLUTION;
        } else {
            RWork[OFFSET_R_IND + i] = Offset / 4.0 + RESOLUTION / 2.0;
            RWork[GAIN_R_IND + i] = 
                (1.0 - Gain / (2.0 * RESOLUTION)) * Range / RESOLUTION;
        }

        /*/////////////////////////////////////////////////
        printf("chan %d range %d %s %s\n", 
            chan, 
            range, 
            gain == FULLGAIN ? "FULLGAIN" : "HALFGAIN", 
            polarity == UNIPOLAR ? "UNIPOLAR" : "BIPOLAR");

        printf("Range %.1f Offset %.1f Gain %.1f\n", 
            Range, 
            Offset, 
            Gain);
        printf("csr %04x OFFSET %.1f GAIN %f\n", 
            csr, 
            RWork[OFFSET_R_IND + i], 
            RWork[GAIN_R_IND + i]);
        *//////////////////////////////////////////////////
    }

    // set up first channel
    first = IWork[CSR_I_IND + nChannels - 1];

    switch (carrierType) {
        case SBS_PCI40A:
            ip16adc[IP16ADC_CSR] = first;
            break;

        case SBS_FLEX104A: 
            rl32eOutpW(accReg, slotBase + IP16ADC_CSR);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, first);
            break;
    }

    // wait for first channel to settle
    rl32eWaitDouble(0.0000035);
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T      *IWork       = ssGetIWork(S);
    real_T     *RWork       = ssGetRWork(S);
    int_T       nChannels   = mxGetN(CHANNEL_ARG);
    CarrierType carrierType = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];
    int_T       slotBase, isaBase, csrReg, accReg, dataReg, timeout;
    uint16_T    csr;
    uint16_T    count[NUM_CHANS];
    real_T     *y;
    uint_T      i;

    volatile uint16_T *ip16adc;

    switch (carrierType) {

    case SBS_PCI40A: 
        ip16adc = (uint16_T *) IWork[SLOT_BASE_I_IND];

        for (i = 0; i < nChannels; i++) {
            // trigger conversion of current channel
            ip16adc[IP16ADC_TRIGGER] = 0xffff;

            // wait for SDL to go low - about .75 microseconds
            for (timeout = 0; timeout < 10; timeout++)
                if (~(csr = ip16adc[IP16ADC_CSR]) & SDL) 
                    break;

            if (timeout >= 10) {
                sprintf(msg, "IP-16ADC SDL stuck hi; csr = 0x%x\n", csr); 
                ssSetErrorStatus(S, msg);
                return;
            }
            

            // set up next channel
            ip16adc[IP16ADC_CSR] = (uint16_T) IWork[CSR_I_IND + i];

            // wait for SDL to go high - about 8 microseconds
            for (timeout = 0; timeout < 20; timeout++)
                if ((csr = ip16adc[IP16ADC_CSR]) & SDL) 
                    break;

            if (timeout >= 20) {
                sprintf(msg, "IP-16ADC SDL stuck lo; csr = 0x%x\n", csr); 
                ssSetErrorStatus(S, msg);
                return;
            }

            // read count
            count[i] = (uint16_T) ip16adc[IP16ADC_DATA];
        }
        break;

    case SBS_FLEX104A: 
        slotBase = IWork[SLOT_BASE_I_IND];
        isaBase  = IWork[ISA_BASE_I_IND];
        csrReg   = CSR(isaBase);
        accReg   = ACCESS(isaBase);
        dataReg  = DATA(isaBase);

        for (i = 0; i < nChannels; i++) {

            // trigger conversion of current channel
            rl32eOutpW(accReg, slotBase + IP16ADC_TRIGGER);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, 0xffff);

            // wait for SDL to go low - about .75 microseconds
            /****
            for (timeout = 0; timeout < 3; timeout++) {
                rl32eOutpW(accReg, slotBase + IP16ADC_CSR);
                while (rl32eInpW(csrReg) & IPWAIT);
                csr = rl32eInpW(dataReg);
                if (~csr & SDL) 
                    break;
            }
            if (timeout >= 3) {
                sprintf(msg, "IP-16ADC SDL stuck hi; csr = 0x%x\n", csr); 
                ssSetErrorStatus(S, msg);
                return;
            }
            ****/
            
            // set up next channel
            rl32eOutpW(accReg, slotBase + IP16ADC_CSR);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, IWork[CSR_I_IND + i]);

            // wait for SDL to go high - about 8 microseconds
            for (timeout = 0; timeout < 10; timeout++) {
                rl32eOutpW(accReg, slotBase + IP16ADC_CSR);
                while (rl32eInpW(csrReg) & IPWAIT);
                csr = rl32eInpW(dataReg);
                if (csr & SDL) 
                    break;
            }
            if (timeout >= 10) {
                printf("IP-16ADC error - is an external +/-15V connected?\n");
                sprintf(msg, "IP-16ADC SDL stuck lo; csr = 0x%x\n", csr); 
                ssSetErrorStatus(S, msg);
                return;
            }

            // read count
            rl32eOutpW(accReg, slotBase + IP16ADC_DATA);
            while (rl32eInpW(csrReg) & IPWAIT);
            count[i] = (uint16_T) rl32eInpW(dataReg);
        }
        break;
    }

    // convert counts to volts and output the signals
    for (i = 0; i < nChannels; i++) {
        y = ssGetOutputPortRealSignal(S, i);
        y[0] = (count[i] - RWork[OFFSET_R_IND + i]) * RWork[GAIN_R_IND + i];
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
