/*
 * Header file DSPCICFILTER_RT.H
 *
 * Runtime library C function prototypes for CIC Filter algorithms
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2003/07/10 19:49:48 $
 *
 * FCN NAMING CONVENTIONS
 * ----------------------
 *
 *   MWDSP_CIC[Dec|Int][Zer|Lat][iioo]
 *
 *   MWDSP: MathWorks DSP Runtime Library function (standard prefix)
 *
 *   Dec: "Decimator"
 *   Int: "Integrator"
 *
 *   Zer: "Zero latency" (Hogenauer) filter structure
 *   Lat: "Non-zero latency" (e.g. Xilinx CIC core) filter structure
 *
 *    ii = 08:  Input data types signed  8-bit integers
 *    ii = 16:  Input data types signed 16-bit integers
 *    ii = 32:  Input data types signed 32-bit integers
 *
 *    oo = 08: Output data types signed  8-bit integers
 *    oo = 16: Output data types signed 16-bit integers
 *    oo = 32: Output data types signed 32-bit integers
 *
 *   [NOTE that all state data types are always signed 32-bit integers]
 *
 *
 * COMMON FCN FEATURES
 * -------------------
 *
 *   o All functions are "frame-based" only.  The I/O frame size MUST be a
 *     multiple of R, the resampling (i.e. interpolation or decimation) factor.
 *
 *   o Real-only (complex I/O supported by treating samples as separate real
 *              channels when calling - i.e. pretend twice as many real samples)
 *
 *   o Multi-channel support
 *
 *   o State array values are updated inside each fcn call for client caller
 *
 *   o All arrays are assumed to be contiguous linear memory
 *     (column-major for pointer address read/write operations).
 *
 *   o Caller must use pre-allocated arrays
 *
 *   o NO memory management is performed in these functions.
 *     All memory must be pre-allocated by caller before call
 *     Array memory validity and bounds are not checked
 *     (i.e. all memory is assumed to be valid, and managed by caller).
 *
 *
 * DETAILS REGARDING "STATES" ARRAY
 * --------------------------------
 *
 * The memory for the "states" array is contiguous and every channel grouping is
 * concatenated.  That is, the memory is arranged as:
 *
 *
 *   [Chan1_States Chan2_States etc.]
 *
 *
 * where each channel is a linear and CIRCBUFF combination as follows...
 *
 *
 *   CIC Decimator filters:
 *
 *     Each channel grouping of the "states" array is formed as
 *
 *     - 1 (of size N samples) linear buffer (for the N integrator stages)
 *     - N (of size M samples) CIRCBUFFs (for the N comb stages)
 *
 *
 *   CIC Interpolator filters:
 *
 *     Each channel grouping of the "states" array is formed as
 *
 *     - N (of size M samples) CIRCBUFFs (for the N comb stages)
 *     - 1 (of size N samples) linear buffer (for the N integrator stages)
 *
 *
 *   NOTE: CIRCBUFFs require a little extra overhead for use,
 *         see DSPCIRCBUFF_RT.H for more details on CIRCBUFFs.
 *
 *
 * DETAILS REGARDING "stgInpWLs" ARRAY
 * -----------------------------------
 *
 * The stgInpWLs array points to the simulated 2*N word lengths at the 
 * INPUT of each of the 2*N stages in the CIC Filter (N integrator stages +
 * N comb stages).  Note also that these input word length values match the
 * internal (accumulated wrap-around) sum word length values for each stage.
 *
 * These word lengths must be between 2 and 32 for these run time library fcns.
 *
 *
 * DETAILS REGARDING "stgShifts" ARRAY
 * -----------------------------------
 *
 * The stgShifts array explicitly sets the ANSI-C integer right shift value
 * for each of the 2*N stages within the CIC Filter algorithm (N integrator
 * stages + N comb stages).  The right shift value is for the adjustment of
 * the accumulated wrap-around sum type (internal to each stage) to the
 * stage output type (before the input to the next stage).  This mimics the
 * MSB extraction/selection (LSB truncation) that happens in FPGA/ASIC hardware
 * using available operators (">>") in the ANSI-C language.
 *
 * These shift values must be precomputed by the client.  This is an optimization
 * to reduce the run time for each function.  To compute the right shift value for
 * a stage, do the following:
 *
 *   - If the stage output word length is greater than the input/sum word length,
 *     then the shift value for that stage output should be set to
 *
 *         SHIFT_VALUE = 0
 *
 *   - If the stage output word length is less than the input/sum word length,
 *     then the shift value for that stage output should be set to
 *
 *         SHIFT_VALUE = (INPUT_WORDLENGTH - OUTPUT_WORDLENGTH)
 *
 * IMPORTANT NOTE: The vales pointed to by the stgShifts array must be
 *                 non-negative integers between 0 and 31 (inclusive).
 *                 Otherwise, unexpected (and silent / platform-dependent)
 *                 numerical errors may occur on the resulting signed
 *                 twos-complement fixed-point data values computed by
 *                 the CIC Filter algorithm.
 */

#ifndef _DSPCICFILTER_RT_
#define _DSPCICFILTER_RT_

#include "dsp_rt.h"

#ifdef DSPCICFILTER_EXPORTS
#define DSPCICFILTER_EXPORT EXPORT_FCN
#else
#define DSPCICFILTER_EXPORT MWDSP_IDECL
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Zero Latency Decimator */
DSPCICFILTER_EXPORT void MWDSP_CICDecZer0808(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer0816(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer0832(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer1608(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer1616(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer1632(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);


DSPCICFILTER_EXPORT void MWDSP_CICDecZer3208(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer3216(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecZer3232(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);


/* Non-Zero Latency Decimator */
DSPCICFILTER_EXPORT void MWDSP_CICDecLat0808(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat0816(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat0832(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat1608(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat1616(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat1632(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat3208(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat3216(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICDecLat3232(
    int            R, /* Decimation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    const int32_T *stgShifts, /* 2N effectve right shifts for stage OUTPUTS   */
                              /* (non-negative for conversion between stages) */

    int            phase,     /* Downsample output sample phase, */
                              /* must be between 0 and (R-1).    */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);


/* Zero Latency Interpolator */
DSPCICFILTER_EXPORT void MWDSP_CICIntZer0808(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer0816(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer0832(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer1608(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer1616(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer1632(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer3208(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer3216(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntZer3232(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);


/* Non-Zero Latency Interpolator */
DSPCICFILTER_EXPORT void MWDSP_CICIntLat0808(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat0816(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat0832(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int8_T  *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat1608(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat1616(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat1632(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int16_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat3208(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int8_T        *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat3216(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int16_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

DSPCICFILTER_EXPORT void MWDSP_CICIntLat3232(
    int            R, /* Interpolation factor */
    int            N, /* Number of (comb or integrator) stages */

    int            nChans,    /* Number of (real) I/O channels     */
    int            nFrames,   /* TOTAL number of (length R) frames */

    const int32_T *inp,       /* Input array  */
    int32_T       *out,       /* Output array */
    int32_T       *states,    /* States array */

    int            statesPerChanSize,
                              /* Precomputed per-channel in terms of number */
                              /* of real 32-bit integer (int32_T) samples   */
                              /* (taking into account extra overhead for    */
                              /*  CIRCBUFF comb states implementation...)   */

    const int32_T *stgInpWLs, /* 2N simulated word lengths for stage INPUTS */
                              /* (between 2 and 32 for each stage           */

    int32_T        finalOutShiftVal, /* right shift value to use to convert */
                                     /* final stage WL to output port WL    */

    int            phase,     /* Upsample output sample phase, */
                              /* must be between 0 and (R-1).  */

    int            ioStride   /* Real input/output channel stride. */
                              /* Use "1" for real-only data or for */
                              /* non-interleaved complex data. Use */
                              /* "2" for complex interleaved data. */
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspcicfilter/cic_dec_lat_0808_rt.c"
#include "dspcicfilter/cic_dec_lat_0816_rt.c"
#include "dspcicfilter/cic_dec_lat_0832_rt.c"
#include "dspcicfilter/cic_dec_lat_1608_rt.c"
#include "dspcicfilter/cic_dec_lat_1616_rt.c"
#include "dspcicfilter/cic_dec_lat_1632_rt.c"
#include "dspcicfilter/cic_dec_lat_3208_rt.c"
#include "dspcicfilter/cic_dec_lat_3216_rt.c"
#include "dspcicfilter/cic_dec_lat_3232_rt.c"
#include "dspcicfilter/cic_dec_zer_0808_rt.c"
#include "dspcicfilter/cic_dec_zer_0816_rt.c"
#include "dspcicfilter/cic_dec_zer_0832_rt.c"
#include "dspcicfilter/cic_dec_zer_1608_rt.c"
#include "dspcicfilter/cic_dec_zer_1616_rt.c"
#include "dspcicfilter/cic_dec_zer_1632_rt.c"
#include "dspcicfilter/cic_dec_zer_3208_rt.c"
#include "dspcicfilter/cic_dec_zer_3216_rt.c"
#include "dspcicfilter/cic_dec_zer_3232_rt.c"
#include "dspcicfilter/cic_int_lat_0808_rt.c"
#include "dspcicfilter/cic_int_lat_0816_rt.c"
#include "dspcicfilter/cic_int_lat_0832_rt.c"
#include "dspcicfilter/cic_int_lat_1608_rt.c"
#include "dspcicfilter/cic_int_lat_1616_rt.c"
#include "dspcicfilter/cic_int_lat_1632_rt.c"
#include "dspcicfilter/cic_int_lat_3208_rt.c"
#include "dspcicfilter/cic_int_lat_3216_rt.c"
#include "dspcicfilter/cic_int_lat_3232_rt.c"
#include "dspcicfilter/cic_int_zer_0808_rt.c"
#include "dspcicfilter/cic_int_zer_0816_rt.c"
#include "dspcicfilter/cic_int_zer_0832_rt.c"
#include "dspcicfilter/cic_int_zer_1608_rt.c"
#include "dspcicfilter/cic_int_zer_1616_rt.c"
#include "dspcicfilter/cic_int_zer_1632_rt.c"
#include "dspcicfilter/cic_int_zer_3208_rt.c"
#include "dspcicfilter/cic_int_zer_3216_rt.c"
#include "dspcicfilter/cic_int_zer_3232_rt.c"
#endif /* MWDSP_INLINE_DSPRTLIB */

#ifdef __cplusplus
} // close brace for extern C from above
#endif

#endif /* _DSPCICFILTER_RT_ */

/* [EOF] */
