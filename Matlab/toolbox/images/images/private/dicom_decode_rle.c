/*
 * Copyright 1993-2003 The MathWorks, Inc.
 * $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:32 $
 */

/*
 * DICOM_DECODE_RLE MEX-file
 *
 * Decode run-length encoded (RLE) byte-stream.
 *
 * PIXEL_CELLS = DICOM_DECODE_RLE(COMP_FRAGMENT, DECOMP_SEGMENT_SIZE)
 * decompresses the run-length encoded fragment COMP_FRAGMENT and returns
 * the decompressed PIXEL_CELLS.  DECOMP_SEGMENT_SIZE is the number of
 * elements in the decompressed fragment and is used to indicate when
 * decompression is completed.
 *
 */

#include "mex.h"

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[] )
{
    
/* An RLE compressed fragment is composed of an RLE header followed by 1
   or more byte segments.  The RLE header is a fixed-length table of
   offsets for the byte segments.  There are the same number of byte
   segments as the value of SamplesPerPixel.
   
   The value in "decomp_segment_sizes" should be
   
   (Height * Width * BitsAllocated) / 8 bytes
   
   The result of decompressing the fragment is a group of pixel cells.
   
   See PS 3.5-2000 Annex G and PS 3.3-1999 Sec. 7.6.3.1 for more details. 
*/
    
    int num_segments;
    UINT32_T segments[15];

    mxArray *pixel_cells;
    UINT8_T *pixel_cells_data;

    long int fragment_x, fragment_y;

    UINT8_T *tmp_data;
    UINT32_T *header_data;
    UINT8_T *frag_data;

    long int decompressed_bytes;
    long int decomp_segment_size;

    long int cursor_pos;
    INT8_T source_byte;

    double out_end;

    int p, q;

    /* 
     * Check arguments. 
     */

    if (nrhs != 2) { 
	mexErrMsgIdAndTxt("Images:dicom_decode_rle:twoInputArgsRequired",
                          "%s","Two input arguments required."); 
    } else if (nlhs > 1) {
	mexErrMsgIdAndTxt("Images:dicom_decode_rle:tooManyOutputs",
                          "%s","Too many output arguments."); 
    } 


    /* prhs[0]: Compressed fragment. */

    fragment_x = mxGetM(prhs[0]);
    fragment_y = mxGetN(prhs[0]);

    if ((!mxIsUint8(prhs[0])) || 
        (MIN(fragment_x, fragment_y) != 1)) {
        
        mexErrMsgIdAndTxt("Images:dicom_decode_rle:fragmentMustBeUint8Vector",
                          "%s","Compressed fragment must be a vector of UINT8.");

    }

    /* prhs[1]: Size of decompressed segment. */

    if ((mxGetNumberOfElements(prhs[1]) != 1) || 
        (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS)) {

        mexErrMsgIdAndTxt("Images:dicom_decode_rle:segmentMustBeRealScalar",
                          "%s","Decompressed segment size must be a real scalar.");

    }

    decomp_segment_size = (long int) (mxGetPr(prhs[1])[0]);


    /*
     * Read RLE Header 
     */
    
    /* The RLE header is 16 unsigned long words: the first is the number of
       segments, the remaining are byte offsets to the beginning of the
       segment data relative to the beginning of the RLE header.  Any
       unused entries in the table should be set to 0x0000.  
    */

    header_data = (UINT32_T *) mxGetData(prhs[0]);
    num_segments = (int) (header_data[0]);

    if (num_segments > 15) {

        mexErrMsgIdAndTxt("Images:dicom_decode_rle:rleFragmentHasTooManySegs",
                          "%s","RLE fragment contains more than 15 segments.");

    }

    /* Fill the offsets with the next 15 long values. */
    for (p=0; p < 15; p++) {

        segments[p] = header_data[p+1];

    }

    /* Keep track of the position (in bytes) in compressed fragment. */
    cursor_pos = 64;


    /*
     * Decompress the segments.
     */


    /* Create a container for the output data. */

    /* Size of output container should correspond to actual pixel cell
     * details:
     *  - Must be large enough to contain the whole pixel cell.
     *  - Number of elements in pixel_cells should be equal to total number
     *    of pixel cells.
     */

    pixel_cells = mxCreateNumericMatrix(1, (num_segments*decomp_segment_size),
                                        mxUINT8_CLASS, mxREAL);
    pixel_cells_data = (UINT8_T *) mxGetData(pixel_cells);

    frag_data = (UINT8_T *) mxGetData(prhs[0]);

    for (p=0; p < num_segments; p++) {

        /* Verify that there are num_segments encoded segments. */
        if (cursor_pos >= (fragment_x * fragment_y)) {
            
            mexErrMsgIdAndTxt("Images:dicom_decode_rle:"
                              "notEnoughCompressedData",
                              "%s","Not enough compressed data.");

        }

        /* Create an unpadded temporary buffer for the pixel cells. */
        tmp_data = (UINT8_T *) mxMalloc(sizeof(UINT8_T) * decomp_segment_size);

        decompressed_bytes = 0;

        /* Read the data from the fragment and decompress. */
        while (decompressed_bytes < decomp_segment_size) {

            /* Get the source byte. */
            source_byte = (INT8_T) frag_data[cursor_pos];
            cursor_pos++;

            if ((source_byte >= 0) && (source_byte <= 127)) {

                /* Output next (source_byte + 1) bytes literally. */

                out_end = decompressed_bytes + source_byte + 1;

                while (decompressed_bytes < out_end) {

                    tmp_data[decompressed_bytes++] = frag_data[cursor_pos++];

                }

            } else if ((source_byte >= -127) && (source_byte <= -1)) {

                /* Output the next byte (-source_byte + 1) times. */

                source_byte = -source_byte;

                out_end = decompressed_bytes + source_byte + 1;

                while (decompressed_bytes < out_end) {

                    tmp_data[decompressed_bytes++] = frag_data[cursor_pos];

                }
 
                /* Move to next source_byte. */
                cursor_pos++;

            } else if (source_byte == -128) {

                /* Do nothing. */

            }
            
        }

        /* Append the decompressed fragment to the pixel data. */

        decompressed_bytes = 0;  /* Reuse this counter. */

        for (q = p*decomp_segment_size; q < (p+1)*decomp_segment_size; q++)
        {

            pixel_cells_data[q] = tmp_data[decompressed_bytes++];

        }
        

        /* Clean up. */
        mxFree(tmp_data);
        tmp_data = 0;

    }

    plhs[0] = pixel_cells;

}
