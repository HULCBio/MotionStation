/* $Revision: 1.3 $ */
/* 
  adsbsiphiadc.c - xPC Target, non-inlined S-function driver for the 
  IP-HiADC IP module by SBS GreenSpring Modular I/O

  Copyright 1996-2002 The MathWorks, Inc.
*/

#define  S_FUNCTION_LEVEL  2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME   adsbsiphiadc

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

#define NUMBER_OF_ARGS        8
#define CARRIER_SLOT_ARG      ssGetSFcnParam(S,0) // 1 for slot A, etc.
#define CHANNEL_ARG           ssGetSFcnParam(S,1) // nonempty vector of 1:16  
#define RANGE_ARG             ssGetSFcnParam(S,2) // 1, 2: bipolar 5V, 10V
#define SAMPLE_TIME_ARG       ssGetSFcnParam(S,3) // seconds
#define CARRIER_TYPE_ARG      ssGetSFcnParam(S,4) // CarrierType enum
#define CARRIER_ISA_BASE_ARG  ssGetSFcnParam(S,5) // if relevant
#define CARRIER_PCI_BUS_ARG   ssGetSFcnParam(S,6) // if relevant
#define CARRIER_PCI_SLOT_ARG  ssGetSFcnParam(S,7) // if relevant 

#define MFGR_VAL              (0xf0) // value of Manufacturer ID for SBS
#define MODEL_VAL             (0x93) // value of Model No for IP-HiADC
#define RESOLUTION            (4096) // 12-bit 
#define NUM_CHANS             (16)   // number of IP-HiADC channels
#define NUM_GROUPS            (4)    // number of channel groups

#define RDH1                  (0x00) // register word offsets
#define RDT1                  (0x10)
#define SCSR                  (0x20)
#define CR                    (0x21)
#define EEC                   (0x2a)
#define EED                   (0x2b)

#define EEPROM_5V             (0x64) // EEPROM data word offsets 
#define EEPROM_10V            (0x24)


#define MODEL_NUM             (0x05) // ID PROM data word offsets
#define MFGR                  (0x04)

#define NUM_R_WORKS             (32)
#define OFFSET_R_IND             (0) // offsets for each chan
#define GAIN_R_IND              (16) // gains for each chan, current range

#define NUM_I_WORKS             (18)
#define ACCESS_I_IND             (0) // Flex/104A access register data
                                     // (or PCI-40A channel addresses)
#define STROBE_I_IND            (16) // strobe value
#define HIADC_I_IND             (17) // base address of IP slot (PCI carriers)

static char_T msg[256];

void readEPROM1(int_T csrReg, int_T accReg, int_T dataReg, 
                   int_T slotCode, uint16_T *dest, int_T address)
{
#ifndef MATLAB_MEX_FILE
    uint32_T data, mask;
    uint16_T reg;


    // select EEPROM
    rl32eOutpW(accReg, slotCode | EEC);
    rl32eOutpW(dataReg, 1);
    while (rl32eInpW(csrReg) & IPWAIT);

    data = 0x0600 | (address & 0xff);

    // write out address bits
    for (mask = 0x0400; mask; mask >>= 1) {
        rl32eOutpW(accReg, slotCode | EED);
        while (rl32eInpW(csrReg) & IPWAIT);
        rl32eOutpW(dataReg, (mask & data) ? 1 : 0);
    }

    // read word
    for (mask = 0, data = 0; mask < 16; mask++) {
        rl32eOutpW(accReg, slotCode | EED);
        while (rl32eInpW(csrReg) & IPWAIT);
        reg = rl32eInpW(dataReg);

        data = (data << 1) + (reg & 1);
    }

    // deselect EEPROM
    rl32eOutpW(accReg, slotCode | EEC);
    while (rl32eInpW(csrReg) & IPWAIT);
    rl32eOutpW(dataReg, 0);

    *dest = data;
#endif
}

void readEPROM2(volatile uint16_T *hiadc, uint16_T *dest, int_T address)
{
#ifndef MATLAB_MEX_FILE
    uint32_T data;
    uint32_T mask;
    uint16_T reg;

    hiadc[EEC] = 1; // select EEPROM

    data = 0x0600 | (address & 0xff);

    for (mask = 0x0400; mask; mask >>= 1) // write out all address bits
        hiadc[EED] = (mask & data) ? 1 : 0;

    for (mask = 0, data = 0; mask < 16; mask++) {
        reg = hiadc[EED];
        data = (data << 1) + (reg & 0x0001);
    }

    hiadc[EEC] = 0; // deselect EEPROM
    *dest = data;
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
    int_T         timeout      = 1000;
    uint_T       *IWork        = (uint_T *) ssGetIWork(S);
    real_T       *RWork        = ssGetRWork(S);
    int_T         nChannels    = mxGetN(CHANNEL_ARG);
    int_T         range        = mxGetPr(RANGE_ARG)[0];
    int_T         carrierSlot  = mxGetPr(CARRIER_SLOT_ARG)[0];
    CarrierType   carrierType  = (CarrierType)mxGetPr(CARRIER_TYPE_ARG)[0];
    uint16_T      *carrierBase, *physical, data, mfgr, model, strobe, calData; 
    int_T         chan[NUM_CHANS], group[NUM_CHANS], last[NUM_GROUPS]; 
    int_T         i, j, pciSlot, pciBus, isaBase;
    int_T         csrReg, accReg, dataReg, slotCode; 
    real_T        gain, voltage;
    PCIDeviceInfo pciInfo;
    union { float fval; int ival; unsigned short int word[2]; } x;

    volatile uint16_T *hiadc, *pci40a;
    
    // For convenience internally we number the groups 0..NUM_GROUPS-1 and 
    // the channels 0..NUM_CHANS-1. group[i] is the group chan[i] belongs to.
    for (i = 0; i < nChannels; i++) {
        chan[i] = mxGetPr(CHANNEL_ARG)[i] - 1;
        group[i] = chan[i] % NUM_GROUPS;
    }

    // Construct the strobe data to be written to the SCSR register.
    strobe = 0;
    for (i = 0; i < nChannels; i++) {
        strobe |= (1 << group[i]);
    }
    IWork[STROBE_I_IND] = strobe;

    // For each group, set last[g] to the last i in the sequence of indices
    // 1, 2, ..., nChannels-1, 0 for which chan(i) is in group g, or to -1 
    // if no such i exists. 
    for (i = 0; i < NUM_GROUPS; i++) {
        last[i] = -1;
    }
    last[group[0]] = 0;
    for (i = nChannels - 1; i > 0; i--) {
        if (last[group[i]] < 0)
            last[group[i]] = i;
    }

    // For each i compute the appropriate RDT or RDH register address offset
    // we need to access to start the conversion for chan[i+1]. This is a 
    // word offset which will be used with the hiadc pointer (PCI-40A) or  
    // written to the access register (Flex/104A).
    for (i = 0; i < nChannels; i++) {
        j = (i+1) % nChannels;
        if (j == last[group[j]]) {
            IWork[ACCESS_I_IND + i] = RDT1 + chan[j];
        }else{
            IWork[ACCESS_I_IND + i] = RDH1 + chan[j];
        }
    }

    // range-dependent variables
    if (range == 1) { // -5V to 5V
        calData = EEPROM_5V;
        gain = 10.0 / RESOLUTION;

    } else { // -10V to 10V    
        calData = EEPROM_10V;
        gain = 20.0 / RESOLUTION;
    }
   
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

        // set hiadc = slot base address
        carrierBase = (uint16_T *)pciInfo.BaseAddress[2];
        physical = carrierBase + carrierSlot * SLOT_OFS;
        hiadc = rl32eGetDevicePtr(physical, SLOT_LEN, RT_PG_USERREADWRITE);

        IWork[HIADC_I_IND] = (int_T) hiadc;

        // for the first read from the slot, check for IP bus time-out,
        // i.e check that there acuually is an IP module present
        pci40a = rl32eGetDevicePtr(carrierBase, 0x700, RT_PG_USERREADWRITE);
        data = pci40a[CNTL0];
        pci40a[CNTL0] = data | AUTO_ACK | CLR_AUTO;
        mfgr = hiadc[ID_PROM + MFGR];
        rl32eWaitDouble(0.000004); 
        if (pci40a[CNTL2] & AUTO_INT_SET) {
            pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);
            sprintf(msg, "No IP module at PCI-40A slot %c, base %03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }
        pci40a[CNTL0] = data & ~(AUTO_ACK | CLR_AUTO);

        model = hiadc[ID_PROM + MODEL_NUM];

        // check that we're got an actual IP-HiADC
        if (mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-HiADC at PCI-40A slot %c, base %03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)carrierBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        // s/w reset and ADC reset
        hiadc[SCSR] = 0x30; 

        // select the correct range
        if (range == 1) {
            hiadc[CR] = 0x0004; // -5V to 5V
        } else {   
            hiadc[CR] = 0x0006; // -10V to 10V 
        }

        // compute offsets and gains
        for (i = 0; i < 16; i++) {
            readEPROM2(hiadc, &x.word[1], calData++);      
            readEPROM2(hiadc, &x.word[0], calData++);  
            RWork[OFFSET_R_IND + i] = x.fval;

            readEPROM2(hiadc, &x.word[1], calData++);   
            readEPROM2(hiadc, &x.word[0], calData++);   
            RWork[GAIN_R_IND + i] = x.fval * gain;
        }
        break;

    case SBS_FLEX104A:
        isaBase = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        csrReg = CSR(isaBase);
        accReg = ACCESS(isaBase);
        dataReg = DATA(isaBase);
        slotCode = SLOT(carrierSlot);


        // IP reset - takes about 250ms
        rl32eOutpW(csrReg, TMRST | IPRST);
        rl32eWaitDouble(0.300); 
        while (--timeout > 0 && (rl32eInpW(csrReg) & IPWAIT));
        if (timeout <= 0 || ~rl32eInpW(csrReg) & RSTSTAT) {
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

        // check that we're got an actual IP-HiADC
        if (timeout <= 0 || mfgr != MFGR_VAL || model != MODEL_VAL) {
            sprintf(msg, "No IP-HiADC at Flex/104A slot %c base 0x%03x", 
                (char)(carrierSlot + 'A' - 1), (uint_T)isaBase);
            ssSetErrorStatus(S, msg);
            return;
        }

        // compute access register value needed to address the channel
        for (i = 0; i < nChannels; i++) {
            IWork[ACCESS_I_IND + i] |= slotCode; 
        }

        // s/w reset and ADC reset
        rl32eOutpW(accReg, slotCode | SCSR);
        while (rl32eInpW(csrReg) & IPWAIT);
        rl32eOutpW(dataReg, 0x30);

        // select the correct range, sign extension
        if (range == 1) { // -5V to 5V
            rl32eOutpW(accReg, slotCode | CR);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, 0x0004);
       } else { // -10V to 10V
            rl32eOutpW(accReg, slotCode | CR);
            while (rl32eInpW(csrReg) & IPWAIT);
            rl32eOutpW(dataReg, 0x0006);
        }

        // compute offsets and gains
        for (i = 0; i < 16; i++) {
            readEPROM1(csrReg,accReg,dataReg,slotCode,&x.word[1],calData++);      
            readEPROM1(csrReg,accReg,dataReg,slotCode,&x.word[0],calData++);  
            RWork[OFFSET_R_IND + i] = x.fval;

            readEPROM1(csrReg,accReg,dataReg,slotCode,&x.word[1],calData++);   
            readEPROM1(csrReg,accReg,dataReg,slotCode,&x.word[0],calData++);   
            RWork[GAIN_R_IND + i] = x.fval * gain;
        }
        break;

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
    int_T      *IWork       = ssGetIWork(S);
    real_T     *RWork       = ssGetRWork(S);
    int_T       nChannels   = mxGetN(CHANNEL_ARG);
    CarrierType carrierType = (CarrierType) mxGetPr(CARRIER_TYPE_ARG)[0];
    uint16_T    strobe      = IWork[STROBE_I_IND];
    int16_T     count[NUM_CHANS];
    int_T       i, first, isaBase, carrierSlot; 
    int_T       csrReg, accReg, dataReg, slotCode;
    real_T     *y;

    volatile uint16_T *hiadc = (uint16_T *) IWork[HIADC_I_IND];
 
    if (nChannels < 1)
        return;

    first = RDH1 + mxGetPr(CHANNEL_ARG)[0] - 1;

    switch (carrierType) {

    case SBS_PCI40A: 
        hiadc[first] = 0xffff;
        hiadc[SCSR] = strobe;
        rl32eWaitDouble(0.000001); // might have to increase

        for (i = 0; i < nChannels; i++) {
            count[i] = hiadc[ IWork[ACCESS_I_IND + i] ]; 
        }
        break;   
        
    case SBS_FLEX104A: 
        isaBase = mxGetPr(CARRIER_ISA_BASE_ARG)[0];
        carrierSlot  = mxGetPr(CARRIER_SLOT_ARG)[0];
        csrReg = CSR(isaBase);
        accReg = ACCESS(isaBase);
        dataReg = DATA(isaBase);
        slotCode = SLOT(carrierSlot);

        // select first channel
        rl32eOutpW(accReg, slotCode | first);
        while (rl32eInpW(csrReg) & IPWAIT);
        rl32eOutpW(dataReg, 0xffff);

        // write strobe bits to SCSR
        rl32eOutpW(accReg, slotCode | SCSR);
        while (rl32eInpW(csrReg) & IPWAIT);
        rl32eOutpW(dataReg, strobe);

        rl32eWaitDouble(0.000001); 

        // read the count array
        for (i = 0; i < nChannels; i++) {
            rl32eOutpW(accReg, slotCode | IWork[ACCESS_I_IND + i]);
            while (rl32eInpW(csrReg) & IPWAIT);
            count[i] = rl32eInpW(dataReg);
        }
        break;
    }

    for (i = 0; i < nChannels; i++) {
        y = ssGetOutputPortRealSignal(S, i);
        y[0] = ((double)count[i] + RWork[OFFSET_R_IND + i]) * 
            RWork[GAIN_R_IND + i];
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




