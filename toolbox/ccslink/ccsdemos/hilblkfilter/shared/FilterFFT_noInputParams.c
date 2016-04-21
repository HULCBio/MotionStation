/* $Revision: 1.1.6.1 $ */
/*  C functions for C5510 
 *  Self-paced CCS Link Workshop  Ex1          */

#include <math.h>
#include <string.h>
#include "FftFuncSubs.h"
#include "FilterFFT_data.h"

/* Function declarations  */
void genInputSignal(short sineFreq);
void filter(void);
void computeSpectrum(void);
extern void DSP_fir_gen(const short *restrict x, const short *restrict h, 
    short *restrict r, int nh, int nr);

/* * * * * * * * * * * * */
/*        M A I N        */
/* * * * * * * * * * * * */
void main(void)
{
  genInputSignal(100);
  
  filter();
  
  computeSpectrum();

}


/* * * * * * * * * * * * *
 *    genInputSignal     *
 * * * * * * * * * * * * */
void genInputSignal(short sineFreq)
{
    int i;
     
    /**********************************************************************
     * Allowable frequencies are 100Hz and 200Hz.  
     * 100Hz is the pre-initialized default.
     **********************************************************************/
     
    if(sineFreq==200) {
        //memcpy(Sine,Sine200,256);
        for(i=0; i<256; i++) {
        	Sine[i] = Sine200[i];
    	}
    }
    /*************************************************************
     * Zero-pad  (required by fir_gen routine).
     * The 66th element of FilterInput is meant to be "time 0",
     * and the first 65 elements are for the transition region of
     * the filter.
     *************************************************************/
    
    for(i=0; i<65; i++) {
        FilterInput[i] = 0;
    }
    
    /*  Add Noise and Sinusoid signals */
    
    for(i=65; i<(256+65); i++) {
        FilterInput[i] = Noise[i-65] + Sine[i-65];
    }
    
}

/* * * * * * * * * * * * */
/*    filter             */
/* * * * * * * * * * * * */
void filter (void)
{
    DSP_fir_gen(FilterInput, filterCoeffs, FilterOutput, 65, 256);
}

/* * * * * * * * * * * * */
/*    computeSpectrum    */
/* * * * * * * * * * * * */
void computeSpectrum(void)
{

    int i;
    
    /**********************************************************************
     * Remove initial filter delay of half the filter order
     * MATLAB:  truncSignal = filterOutput( 33 : end );
     **********************************************************************/

    for(i = 0; i < (256-32); i++)   {
        FftBuffer[i] = FilterOutput[i+32];
    }

    /**************************************************************
     * Pad resulting signal to length 1024 for smooth 
     * freq-domain curve
     * MATLAB: paddedSignal = 
     *      [ truncSignal; zeros(1024-length(truncSignal), 1) ];
     **************************************************************/
    
    for(i = (256-32); i < 1024; i++)   {
        FftBuffer[i] = (short)0;
    }
    
    /**************************************************************
     * Compute fft
     * MATLAB: fftSignal = fft(paddedSignal);
     **************************************************************/
     DspblksFft_FftFuncSubs(FftBuffer, FftOutput);

    
    /**************************************************************
     * Compute abs(x)^2 = xr^2 + xi^2 
     **************************************************************/
    
    for(i = 0; i < 512; i++)   {
         MagSqrResult[i] = (short)(  
         ( (long)( (long)(FftOutput[i].re) * (long)(FftOutput[i].re) ) +
           (long)( (long)(FftOutput[i].im) * (long)(FftOutput[i].im) )  )
         >> 3 );
    }

}
