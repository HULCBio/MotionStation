// encquanserq8.c - xPC Target, non-inlined S-function driver for the 
// encoder section of the Quanser Q8 Data Acquisition System

// Copyright 2003 The MathWorks, Inc.

// The Q8 has eight encoder channels numbered 0-7.

// These channels are implemented by four chips ENC01, ENC23, ENC45, ENC67, 
// each of which contains an even and an odd channel. So ENC01 implements
// channels 0 and 1, ENC23 implements 2 and 3, etc. In the following code  
// the chips are numbered 0-3 and the channels on a chip are referrred to
// to as unit 0 and unit 1.

// There are two encoder control registers: A and B, each consisting of four
// bytes, one per channel. Register A controls the odd channels and register B
// the even channels. The low order byte of register A controls channel 0, etc.
// Two of the bits in each control byte are used to select which internal 
// control register in the chip is being accessed: RLD, CMR, IOR, or IDR. 
// See the #defines for more information about these registers.

// In the same way a pair of encoder data registers named A and B are used to
// read the 24-bit counts. Only one byte of data per channel can be retrieved 
// per read, so that three consecutive reads are needed to assemble the count
// for any given channel. These reads return the low, mid, and high order bytes, 
// depending on the Byte Pointer (BP) register for the channel. The BP registers
// are internal to the encoder chips and not directly accessible, but can be
// reset using the corresponding RLD registers.


#define S_FUNCTION_LEVEL   2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME    encquanserq8

#include <stddef.h> 
#include <stdlib.h> 

#include "simstruc.h" 

#ifdef  MATLAB_MEX_FILE
#include "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#include "time_xpcimport.h"
#include "util_xpcimport.h"

#endif

#define NUM_ARGS              11
#define CHANNEL_ARG           ssGetSFcnParam(S,0)  // vector of [1:8] 
#define INITIAL_COUNT_ARG     ssGetSFcnParam(S,1)  // vector of int 
#define PRESCALE_ARG          ssGetSFcnParam(S,2)  // vector of [0:255]
#define QUADRATURE_ARG        ssGetSFcnParam(S,3)  // vector of [0,1,2,4]
#define MODE_ARG              ssGetSFcnParam(S,4)  // vector of [0:3]
#define SYNCHRONOUS_INDEX_ARG ssGetSFcnParam(S,5)  // vector of [0:1]
#define INDEX_POLARITY_ARG    ssGetSFcnParam(S,6)  // vector of [0:1]
#define PRESERVE_COUNTS_ARG   ssGetSFcnParam(S,7)  // vector of [0:1]
#define SAMPLE_TIME_ARG       ssGetSFcnParam(S,8)  // int
#define PCI_BUS_ARG           ssGetSFcnParam(S,9)  // int
#define PCI_SLOT_ARG          ssGetSFcnParam(S,10) // int

#define NUM_I_WORKS           (3)
#define BASE_I_IND            (0)
#define RLDA_I_IND            (1)
#define RLDB_I_IND            (2)
#define NUM_R_WORKS           (0) 

#define MAX_CHAN              (8)

#define VENDOR_ID             (uint16_T)(0x11E3)   
#define DEVICE_ID             (uint16_T)(0x0010)   
#define SUBVENDOR_ID          (uint16_T)(0x5155)   
#define SUBDEVICE_ID          (uint16_T)(0x0200)   
#define PCI_BYTES             (0x0400)   

#define BIT(n)                (1 << n)

// 32-bit-register offsets
#define CONTROL_REGISTER      (0x08 / 4)   // R/W
#define STATUS_REGISTER       (0x0c / 4)   // R
#define ENCODER_DATA_A        (0x30 / 4)   // R/W
#define ENCODER_DATA_B        (0x34 / 4)   // R/W
#define ENCODER_CONTROL_A     (0x38 / 4)   // R/W
#define ENCODER_CONTROL_B     (0x3c / 4)   // R/W

// Encoder Control Registers

#define THIS_PARITY           (0 * BIT(7)) // register A operates on even channels only, register B on odd channels only
#define EVEN_AND_ODD          (1 * BIT(7)) // operate on even and odd channels

#define RLD_SELECT            (0 * BIT(5)) // select RLD 
#define CMR_SELECT            (1 * BIT(5)) // select CMR
#define IOR_SELECT            (2 * BIT(5)) // select IOR 
#define IDR_SELECT            (3 * BIT(5)) // select IDR 

// RLD - Reset and Load Signal Decoders Register

#define RLD_NO_TRANSFERS      (0 * BIT(3)) // do not perform any transfers
#define RLD_SET_CNTR          (1 * BIT(3)) // preload reg (PR) -> count (CNTR)
#define RLD_GET_CNTR          (2 * BIT(3)) // CNTR -> output latch (OL)
#define RLD_SET_PSC           (3 * BIT(3)) // PR LSB -> filter prescaler (PSC)

#define RLD_NO_RESETS         (0 * BIT(1)) // do not reset flags or counter
#define RLD_RESET_CNTR        (1 * BIT(1)) // reset counter (CNTR) to zero
#define RLD_RESET_FLAGS       (2 * BIT(1)) // reset borrow (BT), carry (CT), compare (CPT), sign (S) flags
#define RLD_RESET_E           (3 * BIT(1)) // reset error flag (E)

#define RLD_RESET_BP          (1 * BIT(0)) // reset byte pointer (BP)

// CMR - Counter Mode Register

#define CMR_NONQUADRATURE     (0 * BIT(3)) // count & direction inputs
#define CMR_QUADRATURE_1X     (1 * BIT(3)) // quadrature 1X mode
#define CMR_QUADRATURE_2X     (2 * BIT(3)) // quadrature 2X mode
#define CMR_QUADRATURE_4X     (3 * BIT(3)) // quadrature 4X mode

#define CMR_NORMAL            (0 * BIT(1)) // normal (wraps at under/overflow)
#define CMR_RANGE             (1 * BIT(1)) // range limit: counts stops at 0 or PR and resumes when direction reverses
#define CMR_NONRECYCLE        (2 * BIT(1)) // non-recycle: stops at under/overflow, restarts at CNTR reset/load
#define CMR_MODULO            (3 * BIT(1)) // modulo-N (where N is the value in PR)

#define CMR_BINARY            (0 * BIT(0)) // binary count mode
#define CMR_BCD               (1 * BIT(0)) // BCD count mode

// IOR - Input/Output Control Register

#define IOR_CARRY_BORROW      (0 * BIT(3)) // FLG1 is CARRY, FLG2 is BORROW
#define IOR_COMPARE_BORROW    (1 * BIT(3)) // FLG1 is COMPARE, FLG2 is BORROW
#define IOR_CARRY_UPDOWN      (2 * BIT(3)) // FLG1 is CARRY/BORROW, FLG2 is UP/DOWN
#define IOR_INDEX_ERROR       (3 * BIT(3)) // FLG1 is IDX, FLG2 is E

#define IOR_RCNTR_RESET       (0 * BIT(2)) // RCNTR/ABG pin is Reset CNTR
#define IOR_RCNTR_GATE        (1 * BIT(2)) // RCNTR/ABG pin is A & B Enable

#define IOR_LCNTR_LOAD        (0 * BIT(1)) // LCNTR/LOL pin loads CNTR
#define IOR_LCNTR_LATCH       (1 * BIT(1)) // LCNTR/LOL pin latches CNTR to OL

#define IOR_DISABLE_AB        (0 * BIT(0)) // disable A and B inputs
#define IOR_ENABLE_AB         (1 * BIT(0)) // enable A and B inputs

// IDR - Index Control Register
//
#define IDR_LCNTR_INDEX       (0 * BIT(2)) // LCNTR/LOL pin is indexed
#define IDR_RCNTR_INDEX       (1 * BIT(2)) // RCNTR/ABG pin is indexed << don't use IDR_RCNTR_INDEX with Q8 >>
//
#define IDR_NEG_INDEX         (0 * BIT(1)) // negative index polarity
#define IDR_POS_INDEX         (1 * BIT(1)) // positive index polarity
//
#define IDR_ASYNCHRONOUS      (0 * BIT(0)) // disable index
#define IDR_SYNCHRONOUS       (1 * BIT(0)) // enable index


#define ENCODER_MASK (0x000000ff)          // encoder-related Control Register bits

#define PACK(x) (0x1010101 * ((x) & 0xff)) // packs 4 copies of byte x into an int_32

#define BYTE(x,n) ((x) >> 8*(n) & 0xff)    // return the n-th order byte of the int_32 x

typedef volatile void         *ptr_T;
typedef volatile int32_T      *reg32_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i, numOutputPorts;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumInputPorts(S, 0);

    numOutputPorts = mxGetN(CHANNEL_ARG);

    ssSetNumOutputPorts(S, numOutputPorts);
    for (i = 0; i < numOutputPorts; i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMPLE_TIME_ARG)[0] == -1.0) {
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
	uint_T *IWork   = ssGetIWork(S);
    int_T   pciSlot = mxGetPr(PCI_SLOT_ARG)[0];
    int_T   pciBus  = mxGetPr(PCI_BUS_ARG)[0];
    int_T   nChans  = mxGetN(CHANNEL_ARG);
	int_T   used[4] = {0,0,0,0};
	int_T   prescale[2] = {0,0};
	int_T   preload[3][2] = {{0,0},{0,0},{0,0}};

    int_T   i, chan, unit, chip, shift, value, control; 
	int_T   cmrQuad, cmrMode, rldSetCntr, idrSynchronous, idrPolarity;
	int_T   rld[2], cmr[2], idr[2], ior[2], rldInit[2];
    ptr_T   bar;
    reg32_T base;

    PCIDeviceInfo pciInfo;

    if (pciSlot < 0) {
        if (rl32eGetPCIInfo(VENDOR_ID, DEVICE_ID, &pciInfo)) {
            sprintf(msg, "No Quanser Q8 found");
            ssSetErrorStatus(S, msg);
            return;
        }
     
    } else if (rl32eGetPCIInfoAtSlot(VENDOR_ID, DEVICE_ID, 
        pciSlot + pciBus * 256, &pciInfo)) {
        sprintf(msg, "No Quanser Q8 at bus %d slot %d", pciBus, pciSlot);
        ssSetErrorStatus(S, msg);
        return;
    }

    bar = (ptr_T) pciInfo.BaseAddress[0];

    base = (reg32_T) rl32eGetDevicePtr(bar, PCI_BYTES, RT_PG_USERREADWRITE);

    IWork[BASE_I_IND] = (int_T) base;

    control = base[CONTROL_REGISTER] & ~ENCODER_MASK;

    cmr[0] = cmr[1] = PACK(THIS_PARITY | CMR_SELECT);

	rld[0] = rld[1] = PACK(THIS_PARITY | RLD_SELECT | RLD_RESET_BP);

	ior[0] = ior[1] = PACK(THIS_PARITY | IOR_SELECT | IOR_RCNTR_RESET | IOR_INDEX_ERROR);

	idr[0] = idr[1] = PACK(THIS_PARITY | IDR_SELECT | IDR_LCNTR_INDEX);

    rldInit[0] = rldInit[1] = 0;

	for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
		chan %= MAX_CHAN;

        unit = chan % 2;
        chip = chan / 2;

		shift = chip * 8;

		switch ((int_T)mxGetPr(QUADRATURE_ARG)[i]) {
			case 0:  cmrQuad = CMR_NONQUADRATURE; break;
			case 1:  cmrQuad = CMR_QUADRATURE_1X; break;
			case 2:  cmrQuad = CMR_QUADRATURE_2X; break;
			case 4:  cmrQuad = CMR_QUADRATURE_4X; break;
			default: cmrQuad = CMR_QUADRATURE_1X;
		}

		switch ((int_T)mxGetPr(MODE_ARG)[i]) {
			case 0:  cmrMode = CMR_NORMAL;     break;
			case 1:  cmrMode = CMR_RANGE;      break;
			case 2:  cmrMode = CMR_NONRECYCLE; break;
			case 3:  cmrMode = CMR_MODULO;     break;
			default: cmrMode = CMR_NORMAL;
		}

		switch ((int_T)mxGetPr(INDEX_POLARITY_ARG)[i]) {
			case 0:  idrPolarity = IDR_NEG_INDEX; break;
			case 1:  idrPolarity = IDR_POS_INDEX; break;
			default: idrPolarity = IDR_NEG_INDEX;
		}

		switch ((int_T)mxGetPr(SYNCHRONOUS_INDEX_ARG)[i]) {
			case 0:  idrSynchronous = IDR_ASYNCHRONOUS; break;
			case 1:  idrSynchronous = IDR_SYNCHRONOUS;  break;
			default: idrSynchronous = IDR_ASYNCHRONOUS;
		}

		switch ((int_T)mxGetPr(PRESERVE_COUNTS_ARG)[i]) {
			case 0:  rldSetCntr = RLD_SET_CNTR; break;
			case 1:  rldSetCntr = 0;            break;
			default: rldSetCntr = 0;
		}

		// construct the prescale values for the filter clock
		value = mxGetPr(PRESCALE_ARG)[i];
		prescale[unit] |= BYTE(value, 0) << shift;

		// construct the preload values to initialize the counts
		value = mxGetPr(INITIAL_COUNT_ARG)[i];
		preload[0][unit] |= BYTE(value, 0) << shift;
		preload[1][unit] |= BYTE(value, 1) << shift;
		preload[2][unit] |= BYTE(value, 2) << shift;

		// assemble the I/LD enable bits for the control register
		control |= BIT(chan);

		// record the units (even, odd, or both) used by each chip
		used[chip] |= BIT(unit);

        // assemble the CMR register commands
        cmr[unit] |= (cmrQuad | cmrMode | CMR_BINARY) << shift;

		// assemble the IOR register commands
		ior[unit] |= (IOR_LCNTR_LATCH | IOR_ENABLE_AB) << shift; 
		
		// assemble the IDR register commands
		idr[unit] |= (idrPolarity | idrSynchronous) << shift;

		// assemble the RLD commands to initialize the counts (or not)	
		rldInit[unit] |= rldSetCntr << shift; 

	} // for i < nChans


    // set quadrature, mode, binary count for all encoders
    base[ENCODER_CONTROL_A] = cmr[0];
    base[ENCODER_CONTROL_B] = cmr[1];

    // note that rld[unit] always includes a RESET_BP

    // reset BT, CT, CPT, S and E flags for all encoders
    base[ENCODER_CONTROL_A] = rld[0] | PACK(  RLD_RESET_FLAGS | RLD_RESET_E);
    base[ENCODER_CONTROL_B] = rld[1] | PACK(  RLD_RESET_FLAGS | RLD_RESET_E);

    // set the filter clock frequency prescale values for all encoders
	base[ENCODER_DATA_A] = prescale[0]; 
	base[ENCODER_DATA_B] = prescale[1];
    //base[ENCODER_DATA_A] = 0; 
    //base[ENCODER_DATA_B] = 0; 
    //base[ENCODER_DATA_A] = 0; 
    //base[ENCODER_DATA_B] = 0; 
    base[ENCODER_CONTROL_A] = rld[0] | PACK( RLD_SET_PSC );
    base[ENCODER_CONTROL_B] = rld[1] | PACK( RLD_SET_PSC );

    // set the preload registers to the requested initial counts 
    base[ENCODER_DATA_A] = preload[0][0]; 
	base[ENCODER_DATA_B] = preload[0][1];
    base[ENCODER_DATA_A] = preload[1][0]; 
	base[ENCODER_DATA_B] = preload[1][1];
    base[ENCODER_DATA_A] = preload[2][0]; 
	base[ENCODER_DATA_B] = preload[2][1];
    base[ENCODER_CONTROL_A] = rld[0] | rldInit[0];
    base[ENCODER_CONTROL_B] = rld[1] | rldInit[1];
 
	// enable A and B for channels being used
	base[ENCODER_CONTROL_A] = ior[0];
	base[ENCODER_CONTROL_B] = ior[1];

	// set index polarity and synchronicity
	base[ENCODER_CONTROL_A] = idr[0];
	base[ENCODER_CONTROL_B] = idr[1];

    // Enable I/LD inputs for the channels being used
    base[CONTROL_REGISTER] = control;

	// construct and save the RLD commands for use by mdlOutputs
	for (chip = 0; chip < 4; chip++) {
		shift = chip * 8;
		switch (used[chip]) {
			case 1 : rld[0] |= (THIS_PARITY  | RLD_GET_CNTR) << shift; break;
			case 2 : rld[1] |= (THIS_PARITY  | RLD_GET_CNTR) << shift; break;
			case 3 : rld[0] |= (EVEN_AND_ODD | RLD_GET_CNTR) << shift; break;
		}
	}

	IWork[RLDA_I_IND] = rld[0];
	IWork[RLDB_I_IND] = rld[1];
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

    int_T  *IWork  = ssGetIWork(S);
    reg32_T base   = (reg32_T) IWork[BASE_I_IND];
    int_T   rldA   = IWork[RLDA_I_IND];
    int_T   rldB   = IWork[RLDB_I_IND];
    int_T   nChans = mxGetN(CHANNEL_ARG);

	int_T  i, chan, unit, chip, count, data[3][2];
    real_T *y;

	if (rldA & PACK(EVEN_AND_ODD)) {
		base[ENCODER_CONTROL_A] = rldA;
		data[0][0] = base[ENCODER_DATA_A];
		data[0][1] = base[ENCODER_DATA_B];
		data[1][0] = base[ENCODER_DATA_A];
		data[1][1] = base[ENCODER_DATA_B];
		data[2][0] = base[ENCODER_DATA_A];
		data[2][1] = base[ENCODER_DATA_B];

	} else if (rldA & PACK(RLD_GET_CNTR)) {
		base[ENCODER_CONTROL_A] = rldA;
		data[0][0] = base[ENCODER_DATA_A];
		data[1][0] = base[ENCODER_DATA_A];
		data[2][0] = base[ENCODER_DATA_A];

	} else if (rldB & PACK(RLD_GET_CNTR)) {
		base[ENCODER_CONTROL_B] = rldB;
		data[0][1] = base[ENCODER_DATA_B];
		data[1][1] = base[ENCODER_DATA_B];
		data[2][1] = base[ENCODER_DATA_B];
    
    } else { // can't happen
        printf("Q8 encoder error %x %x\n", rldA, rldB);
    }

	for (i = 0; i < nChans; i++) {
		chan = mxGetPr(CHANNEL_ARG)[i] - 1;
		chan %= MAX_CHAN;
		unit = chan % 2;
        chip = chan / 2;

		count  = BYTE(data[2][unit], chip) << 16;
		count += BYTE(data[1][unit], chip) << 8;
		count += BYTE(data[0][unit], chip);

        y = ssGetOutputPortRealSignal(S, i);
        y[0] = count;
	}
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#endif
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
