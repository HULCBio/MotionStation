/* Prototypes for interface to the AudioPMC library.
 * audPMCHelper.h $Revision: 1.1.4.1 $  $Date: 2004/04/08 21:02:29 $
 * Copyright 2002 The MathWorks, Inc.
 */

// Define one and only one of these at a time.
// Make sure these agree with xpcHelpers.c in the pmc_audio directory or
// strange things will happen.
#undef BLINKER_TEST
#undef PRIME_TEST
#define MIXER

typedef struct dsp21k_info * PDSP21K;

typedef struct boardInfo {
    PDSP21K proc[2];
    int bus;
    int slot;
} boardInfo;

typedef struct host_desc
{
    int lower;
    int upper;
} host_desc;

typedef struct ardes {
	int length;
	unsigned char *array;
} arraydes;

#define NUM_AUDPMC_BOARDS 4

extern boardInfo AudPMCBoards[NUM_AUDPMC_BOARDS];

void * xpcOpenReadChannel( int channel, int procnum );
void * xpcOpenWriteChannel( int channel, int procnum );
void xpcSetAudioPMC( PDSP21K processor, int pnum, int freq, int framesize, int crystal );
PDSP21K ConstructProc( PCIDeviceInfo *, int );
int   dsp21k_dl_dxe_array( PDSP21K, arraydes * );
void  xpcSetAudioPMC( PDSP21K proc, int pnum, int freq, int framesize, int crystal );
int   dsp21k_start( PDSP21K );
void  dsp21k_dl_int( PDSP21K board, ULONG dsp_addr, int val);
int   dsp21k_ul_int( PDSP21K board, ULONG dsp_addr);
float dsp21k_ul_flt( PDSP21K board, ULONG dsp_addr );
ULONG dsp21k_get_addr( PDSP21K processor, const char * name);
