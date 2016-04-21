/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * WPNG.C
 *
 * This module implements the png('write',...) syntax of png.mex.
 *
 * Syntax:
 * png('write',data,map,filename,colortype,bitdepth,sigbits,alpha, ...
 *             interlace,transparency,background,gamma, ...
 *             chromaticities,xres,yres,resunit,text)
 *
 *
 * data          uint8 or uint16 array, M-by-N or M-by-N-by-3
 *
 * map           MATLAB-style colormap, P-by-3, double; may be
 *               [] if there's no colormap
 *
 * filename      string
 *
 * colortype     PNG colortype: 0, 2, 3, 4, or 6
 *
 * bitdepth      Requested bitdepth: 1, 2, 4, 8, or 16 (the valid set
 *               depends on the colortype)
 *
 * sigbits       - For indexed images: 3-element vector in the range
 *                 [1,bitdepth]
 *               - For grayscale images, no alpha: scalar in the range
 *                 [1,bitdepth]
 *               - For grayscale images, alpha: 2-element vector in the
 *                 range [1,bitdepth]
 *               - For truecolor images, no alpha : 3-element vector in the 
 *                 range [1,bitdepth]
 *               - For truecolor images, alpha: 4-element vector in the
 *                 range [1,bitdepth]
 *               - []
 *
 * alpha         Alpha channel, M-by-N, same class as data; may be []
 *
 * interlace     'none' or 'adam7'
 *
 * transparency  - For indexed images (colortype = 3): Q-element vector
 *                 in the range [0,1]; Q <= P
 *               - For grayscale images (colortype = 0 or 4): scalar
 *                 in the range [0,1]
 *               - For truecolor images (colortype = 2 or 6): 3-element
 *                 vector in the range [0,1]
 *               - []
 *               - cannot specify transparency and alpha at the same time
 *
 * background    - For indexed images: integer in the range [1, P]
 *               - For grayscale images: scalar in the range [0, 1]
 *               - For truecolor images: 3-element vector in the range [0, 1]
 *               - []
 *
 * gamma         - nonnegative scalar or []
 *
 * chromaticities 8-element vector ([wx wy rx ry gx gy bx by]) in the 
 *                   range [0,1], or []
 *
 * xres          scalar indicating pixels/unit, or []
 *
 * yres          scalar indicating pixels/unit, or []
 *
 * resunit       'unknown', 'meter', or []
 *
 * textchunks    Q-by-2 cell array containing text chunks.  The first
 *               column contains the keywords; the second column contains
 *               the value strings.  Keyword strings may contain only 
 *               the decimal character codes 32-126 and 161-255.  Value
 *               strings may also contain the linefeed character (decimal 10).
 *               Keywords must be at least one character and less than
 *               80 characters long.
 */

#include <stdio.h>
#include "png.h"
#include "pngmex.h"
#include "mex.h"

static char rcsid[] = "$Revision: 1.1.6.1 $";

#define IM_IN                (prhs[1])
#define MAP_IN               (prhs[2])
#define FILENAME_IN          (prhs[3])
#define COLORTYPE_IN         (prhs[4])
#define BITDEPTH_IN          (prhs[5])
#define SIGBITS_IN           (prhs[6])
#define ALPHA_IN             (prhs[7])
#define INTERLACE_IN         (prhs[8])
#define TRANSPARENCY_IN      (prhs[9])
#define BACKGROUND_IN        (prhs[10])
#define GAMMA_IN             (prhs[11])
#define CHROMATICITY_IN      (prhs[12])
#define XRES_IN              (prhs[13])
#define YRES_IN              (prhs[14])
#define RESUNIT_IN           (prhs[15])
#define TEXT_IN              (prhs[16])

#define NUM_INPUTS           (17)

/*
 * Text items longer than this will be stored as zTXt chunks rather
 * than tEXt chunks.
 */
#define TEXT_COMPRESSION_THRESHOLD   (1000)

#define STRING_BUFFER_LENGTH (64)

#define ERRCHECK(fcn) {err_flag = fcn; if (err_flag != SUCCESS) goto CLEANUP;}

#define MMAX(a,b) ((a) < (b) ? (b) : (a))

ErrorFlag GetBitDepth(const mxArray *bitdepth_array, int *bit_depth)
{
    if (!mxIsDouble(bitdepth_array) ||
        (mxGetNumberOfElements(bitdepth_array) != 1))
    {
        return(BAD_BIT_DEPTH);
    }

    *bit_depth = (int) mxGetScalar(bitdepth_array);

    return(SUCCESS);
}

ErrorFlag GetColorType(const mxArray *colortype_array, int *color_type)
{
    if (!mxIsDouble(colortype_array) ||
        (mxGetNumberOfElements(colortype_array) != 1))
    {
        return(BAD_COLOR_TYPE);
    }

    *color_type = (int) mxGetScalar(colortype_array);

    return(SUCCESS);
}

ErrorFlag GetInterlaceType(const mxArray *interlace_array, int *interlace)
{
    char buffer[STRING_BUFFER_LENGTH];

    if (mxIsEmpty(interlace_array))
    {
        *interlace = PNG_INTERLACE_NONE;
        return(SUCCESS);
    }
    
    if (!mxIsChar(interlace_array) || (mxGetM(interlace_array) != 1))
    {
        return(INTERLACE_NOT_A_STRING);
    }

    mxGetString(interlace_array, buffer, STRING_BUFFER_LENGTH);
    if (strcmp(buffer, "none") == 0)
    {
        *interlace = PNG_INTERLACE_NONE;
    }
    else if (strcmp(buffer, "adam7") == 0)
    {
        *interlace = PNG_INTERLACE_ADAM7;
    }
    else
    {
        return(BAD_INTERLACE);
    }
    
    return(SUCCESS);
}

ErrorFlag GetPalette(const mxArray *map_array, MexInfoType *mexInfo, int *num_palette)
{
    double *pr;
    int k;

    *num_palette = mxGetM(map_array);

    if (!mxIsDouble(map_array) || (mxGetN(map_array) != 3) ||
        (*num_palette == 0))
    {
        return(BAD_MAP);
    }

    if (*num_palette > 256)
    {
        return(TOO_MANY_MAP_COLORS);
    }
    
    mexInfo->palette = (png_color *) mxCalloc(*num_palette, sizeof(png_color));
    if (mexInfo->palette == NULL)
    {
        return(OUT_OF_MEMORY);
    }
    
    pr = mxGetPr(map_array);
    for (k = 0; k < *num_palette * 3; k++)
    {
        if ((pr[k] < 0.0) || (pr[k] > 1.0))
        {
            return(BAD_MAP_VALUE);
        }
    }

    for (k = 0; k < *num_palette; k++)
    {
        mexInfo->palette[k].red = (png_byte) (255.0 * *pr++ + 0.5);
    }
    for (k = 0; k < *num_palette; k++)
    {
        mexInfo->palette[k].green = (png_byte) (255.0 * *pr++ + 0.5);
    }
    for (k = 0; k < *num_palette; k++)
    {
        mexInfo->palette[k].blue = (png_byte) (255.0 * *pr++ + 0.5);
    }

    return(SUCCESS);
}

ErrorFlag GetGamma(const mxArray *gamma_array, double *gamma)
{
    if (!mxIsDouble(gamma_array) || (mxGetNumberOfElements(gamma_array) != 1))
    {
        return(BAD_GAMMA);
    }
    
    *gamma = mxGetScalar(gamma_array);
    if (*gamma < 0.0)
    {
        return(BAD_GAMMA);
    }

    return(SUCCESS);
}

ErrorFlag GetChromaticity(const mxArray *chrom_array, double *wx, double *wy,
                    double *rx, double *ry, double *gx, double *gy,
                    double *bx, double *by)
{
    double *pr;
    int k;
    
    if (!mxIsDouble(chrom_array) || (mxGetNumberOfElements(chrom_array) != 8))
    {
        return(BAD_CHROMA_SIZE);
    }
    
    pr = mxGetPr(chrom_array);
    for (k = 0; k < 8; k++)
    {
        if ((pr[k] < 0.0) || (pr[k] > 1.0))
        {
            return(BAD_CHROMA_VALUE);
        }
    }
            
    *wx = pr[0];
    *wy = pr[1];
    *rx = pr[2];
    *ry = pr[3];
    *gx = pr[4];
    *gy = pr[5];
    *bx = pr[6];
    *by = pr[7];

    return(SUCCESS);
}

ErrorFlag GetSigBits(const mxArray *sigbits_array, int color_type,
                     int bit_depth, png_color_8 *sig_bits)
{
    int k;
    int num_elements;
    double *pr;
    png_byte val;
    
    num_elements = mxGetNumberOfElements(sigbits_array);
    if (!mxIsDouble(sigbits_array) || (num_elements == 0))
    {
        return(BAD_SIGBITS);
    }

    pr = mxGetPr(sigbits_array);
    for (k = 0; k < num_elements; k++)
    {
        val = (png_byte) pr[k];
        if ((val < 1) || (val > bit_depth))
        {
            return(SIGBITS_OUT_OF_RANGE);
        }
    }
    
    switch (color_type)
    {
    case PNG_COLOR_TYPE_GRAY:
        if (num_elements != 1)
        {
            return(BAD_SIGBITS);
        }
        sig_bits->gray = (png_byte) pr[0];
        break;
        
    case PNG_COLOR_TYPE_RGB:
        if (num_elements != 3)
        {
            return(BAD_SIGBITS);
        }
        sig_bits->red = (png_byte) pr[0];
        sig_bits->green = (png_byte) pr[1];
        sig_bits->blue = (png_byte) pr[2];
        break;
        
    case PNG_COLOR_TYPE_PALETTE:
        if (num_elements != 3)
        {
            return(BAD_SIGBITS);
        }
        sig_bits->red = (png_byte) pr[0];
        sig_bits->green = (png_byte) pr[1];
        sig_bits->blue = (png_byte) pr[2];
        break;

    case PNG_COLOR_TYPE_GRAY_ALPHA:
        if (num_elements != 2)
        {
            return(BAD_SIGBITS);
        }
        sig_bits->gray = (png_byte) pr[0];
        sig_bits->alpha = (png_byte) pr[1];
        break;

    case PNG_COLOR_TYPE_RGB_ALPHA:
        if (num_elements != 4)
        {
            return(BAD_SIGBITS);
        }
        sig_bits->red = (png_byte) pr[0];
        sig_bits->green = (png_byte) pr[1];
        sig_bits->blue = (png_byte) pr[2];
        sig_bits->alpha = (png_byte) pr[3];
        break;
    }

    return(SUCCESS);
}

ErrorFlag GetTransparency(const mxArray *transparency_array, int color_type, 
                          png_bytep *trans, int *num_trans, 
                          png_color_16 *trans_values)
{
    double *pr;
    int k;

    *trans = NULL;

    if (!mxIsDouble(transparency_array))
    {
        return(BAD_TRANSPARENCY);
    }

    *num_trans = mxGetNumberOfElements(transparency_array);
    pr = mxGetPr(transparency_array);
    for (k = 0; k < *num_trans; k++)
    {
        if ((pr[k] < 0.0) || (pr[k] > 1.0))
        {
            return(BAD_TRANSPARENCY_VALUE);
        }
    }

    if (color_type == PNG_COLOR_TYPE_PALETTE)
    {
        *trans = (png_bytep) mxCalloc(*num_trans, sizeof(png_byte));
        if (*trans == NULL)
        {
            return(OUT_OF_MEMORY);
        }
        pr = mxGetPr(transparency_array);
        for (k = 0; k < *num_trans; k++)
        {
            (*trans)[k] = (png_byte) (255.0 * pr[k] + 0.5);
        }
    }
    
    else if (color_type == PNG_COLOR_TYPE_GRAY)
    {
        if (*num_trans != 1)
        {
            return(BAD_TRANSPARENCY);
        }
        trans_values->gray = (png_uint_16) (65535.0 * pr[0] + 0.5);
    }
    
    else if (color_type == PNG_COLOR_TYPE_RGB)
    {
        if (*num_trans != 3)
        {
            return(BAD_TRANSPARENCY);
        }
        trans_values->red = (png_uint_16) (65535.0 * pr[0] + 0.5);
        trans_values->green = (png_uint_16) (65535.0 * pr[1] + 0.5);
        trans_values->blue = (png_uint_16) (65535.0 * pr[2] + 0.5);
    }
    
    else
    {
        return(TRANSPARENCY_WITH_ALPHA);
    }
    
    return(SUCCESS);
}

ErrorFlag GetResProps(const mxArray *xres_array, const mxArray *yres_array,
                const mxArray *resunit_array, png_uint_32 *res_x, png_uint_32 *res_y,
                int *unit_type)
{
    char buffer[STRING_BUFFER_LENGTH];

    if (!mxIsDouble(xres_array) || (mxGetNumberOfElements(xres_array) != 1))
    {
        return(BAD_XRES);
    }
    if (!mxIsDouble(yres_array) || (mxGetNumberOfElements(yres_array) != 1))
    {
        return(BAD_YRES);
    }
    if (!mxIsChar(resunit_array) || (mxGetM(resunit_array) != 1))
    {
        return(BAD_RESUNIT);
    }
    
    *res_x = (png_uint_32) mxGetScalar(xres_array);
    *res_y = (png_uint_32) mxGetScalar(yres_array);
    
    mxGetString(resunit_array, buffer, STRING_BUFFER_LENGTH);
    if (strcmp(buffer, "unknown") == 0)
    {
        *unit_type = PNG_RESOLUTION_UNKNOWN;
    }
    else if (strcmp(buffer, "meter") == 0)
    {
        *unit_type = PNG_RESOLUTION_METER;
    }
    else
    {
        return(BAD_RESUNIT);
    }
    
    return(SUCCESS);
}

ErrorFlag GetTextChunks(const mxArray *text_array, MexInfoType *mexInfo)
{
    mxArray *array;
    int N;
    int length;
    int k;

    mexInfo->num_text = mxGetM(text_array);
    N = mxGetN(text_array);
    
    if (!mxIsCell(text_array) || (mxGetN(text_array) != 2))
    {
        return(BAD_TEXT);
    }
    
    /*
     * Check cell contents
     */
    for (k = 0; k < mexInfo->num_text * 2; k++)
    {
        array = mxGetCell(text_array, k);
        if (!mxIsChar(array) || (mxGetM(array) != 1))
        {
            return(BAD_TEXT_VALUE);
        }
    }

    mexInfo->text_ptr = (png_textp) mxCalloc(mexInfo->num_text, sizeof(png_text));
    for (k = 0; k < mexInfo->num_text; k++)
    {
        /*
         * Get keyword
         */
        array = mxGetCell(text_array, k);
        length = mxGetNumberOfElements(array) * mxGetElementSize(array) + 1;
        mexInfo->text_ptr[k].key = (png_charp) mxCalloc(length, 
                                               sizeof(*(mexInfo->text_ptr[k].key)));
        mxGetString(array, mexInfo->text_ptr[k].key, length);

        /*
         * Get value string
         */
        array = mxGetCell(text_array, k + mexInfo->num_text);
        length = mxGetNumberOfElements(array) * mxGetElementSize(array) + 1;
        mexInfo->text_ptr[k].text = (png_charp) mxCalloc(length, 
                                                sizeof(*(mexInfo->text_ptr[k].text)));
        
        mxGetString(array, mexInfo->text_ptr[k].text, length);

        if (length > TEXT_COMPRESSION_THRESHOLD)
        {
            mexInfo->text_ptr[k].compression = PNG_TEXT_COMPRESSION_zTXt;
        }
        else
        {
            mexInfo->text_ptr[k].compression = PNG_TEXT_COMPRESSION_NONE;
        }
    }

    return(SUCCESS);
}

void FillRow16(const mxArray *image_array, void *alpha_in, int m, uint16_T *row)
{
    int ndims;
    const int *size;
    uint16_T *p;
    int k;
    int nplanes;
    int plane_stride;
    int col;
    int j;
    uint16_T *alpha;
    
    ndims = mxGetNumberOfDimensions(image_array);
    size = mxGetDimensions(image_array);
    p = (uint16_T *) mxGetData(image_array);
    if (ndims == 2)
    {
        nplanes = 1;
    }
    else
    {
        nplanes = size[2];
    }
    plane_stride = size[0] * size[1];

    p += m;
    if (alpha_in != NULL)
    {
        alpha = (uint16_T *) alpha_in;
        alpha += m;
    }
    else
    {
        alpha = NULL;
    }
    k = 0;
    for (col = 0; col < size[1]; col++)
    {
        for (j = 0; j < nplanes; j++)
        {
            row[k++] = p[j*plane_stride + col*size[0]];
        }
        if (alpha != NULL)
        {
            row[k++] = alpha[col*size[0]];
        }
    }
}

void FillRow8(const mxArray *image_array, void *alpha_in, int m, uint8_T *row)
{
    int ndims;
    const int *size;
    uint8_T *p;
    int k;
    int nplanes;
    int plane_stride;
    int col;
    int j;
    uint8_T *alpha;
    
    ndims = mxGetNumberOfDimensions(image_array);
    size = mxGetDimensions(image_array);
    p = (uint8_T *) mxGetData(image_array);
    if (ndims == 2)
    {
        nplanes = 1;
    }
    else
    {
        nplanes = size[2];
    }
    plane_stride = size[0] * size[1];

    p += m;
    if (alpha_in != NULL)
    {
        alpha = (uint8_T *) alpha_in;
        alpha += m;
    }
    else
    {
        alpha = NULL;
    }
    k = 0;
    for (col = 0; col < size[1]; col++)
    {
        for (j = 0; j < nplanes; j++)
        {
            row[k++] = p[j*plane_stride + col*size[0]];
        }
        if (alpha != NULL)
        {
            row[k++] = alpha[col*size[0]];
        }
    }
}

static void WriteErrorHandler(png_structp png_ptr, png_const_charp message)
{
    MexInfoType *mexInfo = (MexInfoType *) (png_ptr->error_ptr);

    png_destroy_write_struct(&(mexInfo->png_ptr), &(mexInfo->info_ptr));
    DestroyMexInfo(mexInfo);
    mexErrMsgTxt(message);
}

void WritePNG(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    png_uint_32 width;
    png_uint_32 height;
    int bit_depth;
    int color_type;
    int num_palette;
    int num_trans;
    int interlace_type;
    int num_res_props_set;
    int num_bytes;
    int number_of_passes;
    double white_x;
    double white_y;
    double red_x;
    double red_y;
    double green_x;
    double green_y;
    double blue_x;
    double blue_y;
    double gamma;
    png_uint_32 res_x;
    png_uint_32 res_y;
    int unit_type;
    png_color_16 trans_values;
    png_color_16 background;
    png_color_8 sig_bits;
    int k;
    png_uint_32 m;
    ErrorFlag err_flag = SUCCESS;
    MexInfoType *mexInfo;
    bool bg_is_none;
    const int *size;
    void *alphaPtr;
    png_time ptime;
    
    InitErrorMessages();
    mexInfo = InitMexInfo();
    
    if (nrhs < NUM_INPUTS)
    {
        mexErrMsgTxt("Too few inputs.");
    }
    else if (nrhs > NUM_INPUTS)
    {
        mexErrMsgTxt("Too many inputs.");
    }

    ERRCHECK(GetBitDepth(BITDEPTH_IN, &bit_depth));
    ERRCHECK(GetColorType(COLORTYPE_IN, &color_type));
    size = mxGetDimensions(IM_IN);
    width = size[1];
    height = size[0];
    alphaPtr = mxGetData(ALPHA_IN);

    /*
     * Make a buffer for a row
     */
    switch (color_type)
    {
    case PNG_COLOR_TYPE_GRAY:
    case PNG_COLOR_TYPE_PALETTE:
        num_bytes = width * MMAX(bit_depth,8) / 8;
        break;

    case PNG_COLOR_TYPE_GRAY_ALPHA:
        num_bytes = width * MMAX(bit_depth,8) * 2 / 8;
        break;

    case PNG_COLOR_TYPE_RGB:
        num_bytes = width * MMAX(bit_depth,8) * 3 / 8;
        break;

    case PNG_COLOR_TYPE_RGB_ALPHA:
        num_bytes = width * MMAX(bit_depth,8) * 4 / 8;
        break;

    default:
        err_flag = UNKNOWN_COLOR_TYPE;
        goto CLEANUP;
    }
    mexInfo->row = (png_bytep) mxCalloc(num_bytes, sizeof(png_byte));

    ERRCHECK(GetFilename(FILENAME_IN, &(mexInfo->filename)));

    mexInfo->fp = fopen(mexInfo->filename, "wb");
    if (mexInfo->fp == NULL)
    {
        err_flag = FILE_OPEN;
        goto CLEANUP;
    }

    mexInfo->png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, mexInfo, 
                                      WriteErrorHandler, WarningHandler);
    if (mexInfo->png_ptr == NULL)
    {
        err_flag = PNG_LIB_INIT;
        goto CLEANUP;
    }

    mexInfo->info_ptr = png_create_info_struct(mexInfo->png_ptr);
    if (mexInfo->info_ptr == NULL)
    {
        err_flag = PNG_LIB_INIT;
        goto CLEANUP;
    }

    png_init_io(mexInfo->png_ptr, mexInfo->fp);

    ERRCHECK(GetInterlaceType(INTERLACE_IN, &interlace_type));
    
    png_set_IHDR(mexInfo->png_ptr, mexInfo->info_ptr, width, height, bit_depth,
                 color_type, interlace_type, PNG_COMPRESSION_TYPE_DEFAULT,
                 PNG_FILTER_TYPE_DEFAULT);

    if (!mxIsEmpty(SIGBITS_IN))
    {
        ERRCHECK(GetSigBits(SIGBITS_IN, color_type, bit_depth, &sig_bits));
        png_set_sBIT(mexInfo->png_ptr, mexInfo->info_ptr, &sig_bits);
    }
    
    if ((color_type == PNG_COLOR_TYPE_PALETTE) ||
        ((color_type | PNG_COLOR_MASK_ALPHA == PNG_COLOR_TYPE_RGB_ALPHA) &&
         (!mxIsEmpty(MAP_IN))))
    {
        ERRCHECK(GetPalette(MAP_IN, mexInfo, &num_palette));
        png_set_PLTE(mexInfo->png_ptr, mexInfo->info_ptr, mexInfo->palette, 
                     num_palette);
    }
    
    if (!mxIsEmpty(GAMMA_IN))
    {
        ERRCHECK(GetGamma(GAMMA_IN, &gamma));
        png_set_gAMA(mexInfo->png_ptr, mexInfo->info_ptr, gamma);
    }
    
    if (!mxIsEmpty(CHROMATICITY_IN))
    {
        ERRCHECK(GetChromaticity(CHROMATICITY_IN, &white_x, &white_y,
                              &red_x, &red_y, &green_x, &green_y,
                                 &blue_x, &blue_y));

        if (mxIsEmpty(GAMMA_IN))
        {
            mexWarnMsgTxt("If you set the chromaticities, you should also set "
                          "gamma.");
        }
        png_set_cHRM(mexInfo->png_ptr, mexInfo->info_ptr, white_x, white_y, red_x, red_y,
                     green_x, green_y, blue_x, blue_y);
    }

    if (!mxIsEmpty(TRANSPARENCY_IN))
    {
        ERRCHECK(GetTransparency(TRANSPARENCY_IN, color_type, &(mexInfo->trans), 
                &num_trans, &trans_values));
        if (color_type == PNG_COLOR_TYPE_PALETTE)
        {
            png_set_tRNS(mexInfo->png_ptr, mexInfo->info_ptr, mexInfo->trans, 
                         num_trans, NULL);
        }
        else
        {
            png_set_tRNS(mexInfo->png_ptr, mexInfo->info_ptr, NULL, 
                         num_trans, &trans_values);
        }
    }
    
    num_res_props_set = (!mxIsEmpty(XRES_IN)) + (!mxIsEmpty(YRES_IN)) +
        (!mxIsEmpty(RESUNIT_IN));
    if (num_res_props_set == 0)
    {
        /* nothing to do */
    }
    else if (num_res_props_set == 3)
    {
        ERRCHECK(GetResProps(XRES_IN, YRES_IN, RESUNIT_IN, &res_x, &res_y, 
                             &unit_type));
        png_set_pHYs(mexInfo->png_ptr, mexInfo->info_ptr, res_x, res_y, unit_type);
    }
    else
    {
        err_flag = PARTIAL_RES_PROPS;
        goto CLEANUP;
    }

    if (!mxIsEmpty(BACKGROUND_IN))
    {
        ERRCHECK(GetBackgroundColor(BACKGROUND_IN, &background, color_type,
                bit_depth, &bg_is_none));
        png_set_bKGD(mexInfo->png_ptr, mexInfo->info_ptr, &background);
    }
    
    if (!mxIsEmpty(TEXT_IN))
    {
        ERRCHECK(GetTextChunks(TEXT_IN, mexInfo));
        png_set_text(mexInfo->png_ptr, mexInfo->info_ptr, mexInfo->text_ptr, 
                mexInfo->num_text);
    }

    png_convert_from_time_t(&ptime, time(NULL));
    png_set_tIME(mexInfo->png_ptr, mexInfo->info_ptr, &ptime);
    
    /*
     * Write out header information
     */
    png_write_info(mexInfo->png_ptr, mexInfo->info_ptr);

    if ((bit_depth == 16) && (CheckByteOrder() == LSB_FIRST))
    {
        /*
         * PNG library returns 16-bit values as big-endian by default,
         * and we're on a little-endian machine.  Tell libpng to swap
         * bytes.
         */
        png_set_swap(mexInfo->png_ptr);
    }
    
    if (bit_depth < 8)
    {
        png_set_packing(mexInfo->png_ptr);
    }

    /*
     * Write out image data
     */
    number_of_passes = png_set_interlace_handling(mexInfo->png_ptr);
    for (k = 0; k < number_of_passes; k++)
    {
        for (m = 0; m < height; m++)
        {
            if (bit_depth == 16)
            {
                FillRow16(IM_IN, alphaPtr, m, (uint16_T *) mexInfo->row);
            }
            else
            {
                FillRow8(IM_IN, alphaPtr, m, (uint8_T *) mexInfo->row);
            }
            png_write_rows(mexInfo->png_ptr, &(mexInfo->row), 1);
        }
    }

    png_write_end(mexInfo->png_ptr, mexInfo->info_ptr);
    

CLEANUP:

    png_destroy_write_struct(&(mexInfo->png_ptr), &(mexInfo->info_ptr));
    DestroyMexInfo(mexInfo);
    if (err_flag != SUCCESS)
    {
        pngErrorReturn(err_flag);
    }
}
