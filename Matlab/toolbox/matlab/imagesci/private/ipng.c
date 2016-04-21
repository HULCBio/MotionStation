/* Copyright 1984-2001 The MathWorks, Inc.  */

/*
 * IPNG.c
 *
 * This module implements the png('info',...) syntax of png.mex.
 *
 * Syntax:
 * info = png('info',filename)
 *
 * info is a structure.  The fields of info are listed in the variable 
 * fieldnames in the function InfoPNG() below.
 *
 */

#include <stdio.h>
#include "png.h"
#include "pngmex.h"
#include "mex.h"

static char rcsid[] = "$Revision: 1.1.6.1 $";

#define NUM_INPUTS           (2)
#define FILENAME_IN          (prhs[1])
#define INFO_OUT             (plhs[0])

#define ERRCHECK(fcn) {err_flag = fcn; if (err_flag != SUCCESS) goto CLEANUP;}

#define SCALAR_DOUBLE_ARRAY(value) (mxCreateDoubleScalar(value))

/*
 * The following function is copied from png_convert_to_rfc1123() in
 * pngwrite.c in libpng.  We're using our own renamed copy because libpng's
 * version has a bug, in that day "31" is printed as day "0".
 * -sle, April 1998
 */

/* Convert the supplied time into an RFC 1123 string suitable for use in
 * a "Creation Time" or other text-based time string.
 */
png_charp
mw_png_convert_to_rfc1123(png_structp png_ptr, png_timep ptime)
{
   static PNG_CONST char short_months[12][4] =
	{"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

   if (png_ptr->time_buffer == NULL)
   {
      png_ptr->time_buffer = (png_charp)png_malloc(png_ptr, (png_uint_32)(29*
         sizeof(char)));
   }

#ifdef USE_FAR_KEYWORD
   {
      char near_time_buf[29];
      sprintf(near_time_buf, "%d %s %d %02d:%02d:%02d +0000",
               (ptime->day - 1) % 31 + 1, short_months[(ptime->month - 1) %12],
               ptime->year, ptime->hour % 24, ptime->minute % 60,
               ptime->second % 61);
      png_memcpy(png_ptr->time_buffer, near_time_buf,
      29*sizeof(char));
   }
#else
   sprintf(png_ptr->time_buffer, "%d %s %d %02d:%02d:%02d +0000",
               (ptime->day - 1) % 31 + 1, short_months[(ptime->month - 1) %12],
               ptime->year, ptime->hour % 24, ptime->minute % 60,
               ptime->second % 61);
#endif
   return ((png_charp)png_ptr->time_buffer);
}

static void InfoErrorHandler(png_structp png_ptr, png_const_charp message)
{
    MexInfoType *mexInfo = (MexInfoType *) (png_ptr->error_ptr);

    png_destroy_read_struct(&(mexInfo->png_ptr), &(mexInfo->info_ptr), NULL);
    DestroyMexInfo(mexInfo);
    mexErrMsgTxt(message);
}

void InfoPNG(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    png_uint_32 width;
    png_uint_32 height;
    int bit_depth;
    int color_type;
    int interlace_type;
    ErrorFlag err_flag = SUCCESS;
    MexInfoType *mexInfo;
    png_bytep row;
    int num_passes;
    int pass;
    png_uint_32 y;
    mxArray *tmpArray;
    double gamma;
    int renderingIntent;
    png_color_8p sig_bit;
    double *pr;
    png_colorp palette;
    int num_palette = 0;
    png_uint_16p hist;
    double white_x, white_y;
    double red_x, red_y;
    double green_x, green_y;
    double blue_x, blue_y;
    png_textp text_ptr;
    int *otherTextIndices = NULL;
    int numOtherTextChunks = 0;
    int k;
    int num_trans;
    png_bytep trans;
    png_color_16p trans_values;
    png_timep mod_time;
    png_charp time_buffer;
    png_color_16p background;
    png_uint_32 offset_x;
    png_uint_32 offset_y;
    int offset_unit;
    png_uint_32 res_x;
    png_uint_32 res_y;
    int res_unit;
    int num_text;
    
    const char *fieldnames[] = {
        "Filename",
        "FileModDate",
        "FileSize",
        "Format",
        "FormatVersion",
        "Width",
        "Height",
        "BitDepth",
        "ColorType",
        "FormatSignature",
        "Colormap",
        "Histogram",
        "InterlaceType",
        "Transparency",
        "SimpleTransparencyData",
        "BackgroundColor",
        "RenderingIntent",
        "Chromaticities",
        "Gamma",
        "XResolution",
        "YResolution",
        "ResolutionUnit",
        "XOffset",
        "YOffset",
        "OffsetUnit",
        "SignificantBits",
        "ImageModTime",
        "Title",
        "Author",
        "Description",
        "Copyright",
        "CreationTime",
        "Software",
        "Disclaimer",
        "Warning",
        "Source",
        "Comment",
        "OtherText"
    };
    
    int numFields = sizeof(fieldnames) / sizeof(*fieldnames);

    double sig[] = {137.0, 80.0, 78.0, 71.0, 13.0, 10.0, 26.0, 10.0};
    
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

    ERRCHECK(GetFilename(FILENAME_IN,&(mexInfo->filename)));

    mexInfo->fp = fopen(mexInfo->filename, "rb");
    if (mexInfo->fp == NULL)
    {
        err_flag = FILE_OPEN;
        goto CLEANUP;
    }

    mexInfo->png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, 
                                              mexInfo, 
                                              InfoErrorHandler, 
                                              WarningHandler);
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

    png_read_info(mexInfo->png_ptr, mexInfo->info_ptr);

    png_get_IHDR(mexInfo->png_ptr, mexInfo->info_ptr, &width, &height, &bit_depth,
                 &color_type, &interlace_type, NULL, NULL);

    row = mxCalloc(png_get_rowbytes(mexInfo->png_ptr, mexInfo->info_ptr), sizeof(*row));
    num_passes = png_set_interlace_handling(mexInfo->png_ptr);
    for (pass = 0; pass < num_passes; pass++)
    {
        for (y = 0; y < height; y++)
        {
            png_read_rows(mexInfo->png_ptr, &row, NULL, 1);
        }
    }

    png_read_end(mexInfo->png_ptr, mexInfo->info_ptr);

    INFO_OUT = mxCreateStructMatrix(1, 1, numFields, fieldnames);

    mxSetField(INFO_OUT, 0, "Filename", mxCreateString(mexInfo->filename));
    mxSetField(INFO_OUT, 0, "Format", mxCreateString("png"));
    mxSetField(INFO_OUT, 0, "Width", SCALAR_DOUBLE_ARRAY(width));
    mxSetField(INFO_OUT, 0, "Height", SCALAR_DOUBLE_ARRAY(height));
    if ((color_type == PNG_COLOR_TYPE_RGB) ||
        (color_type == PNG_COLOR_TYPE_RGB_ALPHA))
    {
        mxSetField(INFO_OUT, 0, "BitDepth", SCALAR_DOUBLE_ARRAY(bit_depth * 3));
    }
    else
    {
        mxSetField(INFO_OUT, 0, "BitDepth", SCALAR_DOUBLE_ARRAY(bit_depth));
    }

    if ((color_type == PNG_COLOR_TYPE_GRAY) ||
        (color_type == PNG_COLOR_TYPE_GRAY_ALPHA))
    {
        mxSetField(INFO_OUT, 0, "ColorType", mxCreateString("grayscale"));
    }
    else if (color_type == PNG_COLOR_TYPE_PALETTE)
    {
        mxSetField(INFO_OUT, 0, "ColorType", mxCreateString("indexed"));
    }
    else if ((color_type == PNG_COLOR_TYPE_RGB) ||
             (color_type == PNG_COLOR_TYPE_RGB_ALPHA))
    {
        mxSetField(INFO_OUT, 0, "ColorType", mxCreateString("truecolor"));
    }
    else
    {
        mxSetField(INFO_OUT, 0, "ColorType", mxCreateString("unknown"));
    }

    tmpArray = mxCreateDoubleMatrix(1, 8, mxREAL);
    pr = mxGetPr(tmpArray);
    for (k = 0; k < 8; k++)
    {
        pr[k] = sig[k];
    }
    mxSetField(INFO_OUT, 0, "FormatSignature", tmpArray);
    
    if (interlace_type == PNG_INTERLACE_NONE)
    {
        mxSetField(INFO_OUT, 0, "InterlaceType", mxCreateString("none"));
    }
    else if (interlace_type == PNG_INTERLACE_ADAM7)
    {
        mxSetField(INFO_OUT, 0, "InterlaceType", mxCreateString("adam7"));
    }
    else
    {
        mxSetField(INFO_OUT, 0, "InterlaceType", mxCreateString("unknown"));
    }

    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_gAMA))
    {
        png_get_gAMA(mexInfo->png_ptr, mexInfo->info_ptr, &gamma);
        mxSetField(INFO_OUT, 0, "Gamma", SCALAR_DOUBLE_ARRAY(gamma));
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_sRGB))
    {
        png_get_sRGB(mexInfo->png_ptr, mexInfo->info_ptr, &renderingIntent);
        switch (renderingIntent)
        {
        case PNG_sRGB_INTENT_SATURATION:
            mxSetField(INFO_OUT, 0, "RenderingIntent", 
                       mxCreateString("saturation"));
            break;
            
        case PNG_sRGB_INTENT_PERCEPTUAL:
            mxSetField(INFO_OUT, 0, "RenderingIntent", 
                       mxCreateString("perceptual"));
            break;
            
        case PNG_sRGB_INTENT_ABSOLUTE:
            mxSetField(INFO_OUT, 0, "RenderingIntent", 
                       mxCreateString("absolute"));
            break;
            
        case PNG_sRGB_INTENT_RELATIVE:
            mxSetField(INFO_OUT, 0, "RenderingIntent", 
                       mxCreateString("relative"));
            break;
            
        default:
            mxSetField(INFO_OUT, 0, "RenderingIntent",
                       mxCreateString("unknown"));
        }
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_sBIT))
    {
        png_get_sBIT(mexInfo->png_ptr, mexInfo->info_ptr, &sig_bit);
        switch (color_type)
        {
        case PNG_COLOR_TYPE_GRAY:
            mxSetField(INFO_OUT, 0, "SignificantBits",
                       SCALAR_DOUBLE_ARRAY(sig_bit->gray));
            break;
            
        case PNG_COLOR_TYPE_RGB:
            tmpArray = mxCreateDoubleMatrix(1, 3, mxREAL);
            pr = mxGetPr(tmpArray);
            pr[0] = (double) sig_bit->red;
            pr[1] = (double) sig_bit->green;
            pr[2] = (double) sig_bit->blue;
            mxSetField(INFO_OUT, 0, "SignificantBits", tmpArray);
            break;
            
        case PNG_COLOR_TYPE_PALETTE:
            tmpArray = mxCreateDoubleMatrix(1, 3, mxREAL);
            pr = mxGetPr(tmpArray);
            pr[0] = (double) sig_bit->red;
            pr[1] = (double) sig_bit->green;
            pr[2] = (double) sig_bit->blue;
            mxSetField(INFO_OUT, 0, "SignificantBits", tmpArray);
            break;

        case PNG_COLOR_TYPE_GRAY_ALPHA:
            tmpArray = mxCreateDoubleMatrix(1, 2, mxREAL);
            pr = mxGetPr(tmpArray);
            pr[0] = (double) sig_bit->gray;
            pr[1] = (double) sig_bit->alpha;
            mxSetField(INFO_OUT, 0, "SignificantBits", tmpArray);
            break;

        case PNG_COLOR_TYPE_RGB_ALPHA:
            tmpArray = mxCreateDoubleMatrix(1, 4, mxREAL);
            pr = mxGetPr(tmpArray);
            pr[0] = (double) sig_bit->red;
            pr[1] = (double) sig_bit->green;
            pr[2] = (double) sig_bit->blue;
            pr[3] = (double) sig_bit->alpha;
            mxSetField(INFO_OUT, 0, "SignificantBits", tmpArray);
            break;
            
        }
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_PLTE))
    {
        png_get_PLTE(mexInfo->png_ptr, mexInfo->info_ptr, &palette,
                     &num_palette);
        tmpArray = mxCreateDoubleMatrix(num_palette, 3, mxREAL);
        pr = mxGetPr(tmpArray);
        for (k = 0; k < num_palette; k++)
        {
            pr[k] = (double) palette[k].red / 255.0;
            pr[k+num_palette] = (double) palette[k].green / 255.0;
            pr[k+2*num_palette] = (double) palette[k].blue / 255.0;
        }
        mxSetField(INFO_OUT, 0, "Colormap", tmpArray);
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_hIST))
    {
        png_get_hIST(mexInfo->png_ptr, mexInfo->info_ptr, &hist);
        tmpArray = mxCreateDoubleMatrix(num_palette, 1, mxREAL);
        pr = mxGetPr(tmpArray);
        for (k = 0; k < num_palette; k++)
        {
            pr[k] = (double) hist[k];
        }
        mxSetField(INFO_OUT, 0, "Histogram", tmpArray);
    }
    
    if ((color_type == PNG_COLOR_TYPE_GRAY_ALPHA) ||
        (color_type == PNG_COLOR_TYPE_RGB_ALPHA))
    {
        mxSetField(INFO_OUT, 0, "Transparency", mxCreateString("alpha"));
    }
    else if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_tRNS))
    {
        mxSetField(INFO_OUT, 0, "Transparency", mxCreateString("simple"));
        png_get_tRNS(mexInfo->png_ptr, mexInfo->info_ptr, &trans,
                     &num_trans, &trans_values);
        if (color_type == PNG_COLOR_TYPE_PALETTE)
        {
            tmpArray = mxCreateDoubleMatrix(num_trans, 1, mxREAL);
            pr = mxGetPr(tmpArray);
            for (k = 0; k < num_trans; k++)
            {
                pr[k] = (double) trans[k] / 255.0;
            }
        }
        else if (color_type == PNG_COLOR_TYPE_GRAY)
        {
            tmpArray = mxCreateDoubleScalar(
		(double) trans_values->gray / MAX_PIXEL_VALUE(bit_depth));
        }
        else
        {
            tmpArray = mxCreateDoubleMatrix(1, 3, mxREAL);
            pr = mxGetPr(tmpArray);
            pr[0] = (double) trans_values->red / MAX_PIXEL_VALUE(bit_depth);
            pr[1] = (double) trans_values->green / MAX_PIXEL_VALUE(bit_depth);
            pr[2] = (double) trans_values->blue / MAX_PIXEL_VALUE(bit_depth);
        }
        mxSetField(INFO_OUT, 0, "SimpleTransparencyData", tmpArray);
    }
    else
    {
        mxSetField(INFO_OUT, 0, "Transparency", mxCreateString("none"));
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_tIME))
    {
        png_get_tIME(mexInfo->png_ptr, mexInfo->info_ptr, &mod_time);

        time_buffer = mw_png_convert_to_rfc1123(mexInfo->png_ptr, mod_time);
        mxSetField(INFO_OUT, 0, "ImageModTime", mxCreateString(time_buffer));
        /*
         * png_destroy_read_struct() doesn't free time_buffer, although
         * png_destroy_write_struct() does.  Weird.  We have to free
         * it ourselves here to avoid leaks later.
         */
        png_free(mexInfo->png_ptr, time_buffer);
        mexInfo->png_ptr->time_buffer = NULL;
    }

    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_cHRM))
    {
        png_get_cHRM(mexInfo->png_ptr, mexInfo->info_ptr, &white_x, &white_y,
                     &red_x, &red_y, &green_x, &green_y, &blue_x, &blue_y);
        tmpArray = mxCreateDoubleMatrix(1, 8, mxREAL);
        pr = mxGetPr(tmpArray);
        pr[0] = white_x;
        pr[1] = white_y;
        pr[2] = red_x;
        pr[3] = red_y;
        pr[4] = green_x;
        pr[5] = green_y;
        pr[6] = blue_x;
        pr[7] = blue_y;
        mxSetField(INFO_OUT, 0, "Chromaticities", tmpArray);
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_bKGD))
    {
        png_get_bKGD(mexInfo->png_ptr, mexInfo->info_ptr, &background);
        if (color_type == PNG_COLOR_TYPE_PALETTE)
        {
            /*
             * Pass 1-based index back to MATLAB
             */
            mxSetField(INFO_OUT, 0, "BackgroundColor", 
                       SCALAR_DOUBLE_ARRAY(background->index + 1));
        }
        else if ((color_type == PNG_COLOR_TYPE_GRAY) ||
                 (color_type == PNG_COLOR_TYPE_GRAY_ALPHA))
        {
            mxSetField(INFO_OUT, 0, "BackgroundColor",
                       SCALAR_DOUBLE_ARRAY((double) background->gray /
                                           MAX_PIXEL_VALUE(bit_depth)));
        }
        else
        {
            tmpArray = mxCreateDoubleMatrix(1, 3, mxREAL);
            pr = mxGetPr(tmpArray);
            pr[0] = (double) background->red / MAX_PIXEL_VALUE(bit_depth);
            pr[1] = (double) background->green / MAX_PIXEL_VALUE(bit_depth);
            pr[2] = (double) background->blue / MAX_PIXEL_VALUE(bit_depth);
            mxSetField(INFO_OUT, 0, "BackgroundColor", tmpArray);
        }
    }

    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_oFFs))
    {
        png_get_oFFs(mexInfo->png_ptr, mexInfo->info_ptr, &offset_x,
                     &offset_y, &offset_unit);
        mxSetField(INFO_OUT, 0, "XOffset", SCALAR_DOUBLE_ARRAY(offset_x));
        mxSetField(INFO_OUT, 0, "YOffset", SCALAR_DOUBLE_ARRAY(offset_y));
        if (offset_unit == PNG_OFFSET_PIXEL)
        {
            mxSetField(INFO_OUT, 0, "OffsetUnit", mxCreateString("pixel"));
        }
        else if (offset_unit == PNG_OFFSET_MICROMETER)
        {
            mxSetField(INFO_OUT, 0, "OffsetUnit",mxCreateString("micrometer"));
        }
        else
        {
            mxSetField(INFO_OUT, 0, "OffsetUnit", mxCreateString("unknown"));
        }
    }
    
    if (png_get_valid(mexInfo->png_ptr, mexInfo->info_ptr, PNG_INFO_pHYs))
    {
        png_get_pHYs(mexInfo->png_ptr, mexInfo->info_ptr, &res_x,
                     &res_y, &res_unit);
        mxSetField(INFO_OUT, 0, "XResolution", SCALAR_DOUBLE_ARRAY(res_x));
        mxSetField(INFO_OUT, 0, "YResolution", SCALAR_DOUBLE_ARRAY(res_y));
        if (res_unit == PNG_RESOLUTION_METER)
        {
            mxSetField(INFO_OUT, 0, "ResolutionUnit", mxCreateString("meter"));
        }
        else
        {
            mxSetField(INFO_OUT, 0, "ResolutionUnit", mxCreateString("unknown"));
        }
    }

    /*
     * Getting num_text as a return argument in addition to an output argument
     * looks like it is necessary because of a bug in libpng.  -sle
     */
    num_text = png_get_text(mexInfo->png_ptr, mexInfo->info_ptr, &text_ptr, &num_text);
    if (num_text > 0)
    {
        /*
         * Create a vector in which to store the indices of text chunks that
         * do not belong to the standard set, e.g., Author, Creator, etc.
         */
        otherTextIndices = (int *) mxCalloc(num_text, sizeof(*otherTextIndices));
    }
    
    for (k = 0; k < num_text; k++)
    {
        if (strcmp(text_ptr[k].key, "Author") == 0)
        {
            mxSetField(INFO_OUT, 0, "Author", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Title") == 0)
        {
            mxSetField(INFO_OUT, 0, "Title", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Description") == 0)
        {
            mxSetField(INFO_OUT, 0, "Description", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Copyright") == 0)
        {
            mxSetField(INFO_OUT, 0, "Copyright", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Creation Time") == 0)
        {
            mxSetField(INFO_OUT, 0, "CreationTime", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Software") == 0)
        {
            mxSetField(INFO_OUT, 0, "Software", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Disclaimer") == 0)
        {
            mxSetField(INFO_OUT, 0, "Disclaimer", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Warning") == 0)
        {
            mxSetField(INFO_OUT, 0, "Warning", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Source") == 0)
        {
            mxSetField(INFO_OUT, 0, "Source", 
                       mxCreateString(text_ptr[k].text));
        }
        else if (strcmp(text_ptr[k].key, "Comment") == 0)
        {
            mxSetField(INFO_OUT, 0, "Comment", 
                       mxCreateString(text_ptr[k].text));
        }
        else
        {
            otherTextIndices[numOtherTextChunks++] = k;
        }
    }
    
    if (numOtherTextChunks > 0)
    {
        tmpArray = mxCreateCellMatrix(numOtherTextChunks, 2);
        for (k = 0; k < numOtherTextChunks; k++)
        {
            mxSetCell(tmpArray, k, 
                      mxCreateString(text_ptr[otherTextIndices[k]].key));
            mxSetCell(tmpArray, k + numOtherTextChunks, 
                      mxCreateString(text_ptr[otherTextIndices[k]].text));
        }
        mxSetField(INFO_OUT, 0, "OtherText", tmpArray);
    }
    
CLEANUP:

    png_destroy_read_struct(&(mexInfo->png_ptr), &(mexInfo->info_ptr), NULL);
    DestroyMexInfo(mexInfo);
    if (otherTextIndices != NULL)
    {
        mxFree((void *) otherTextIndices);
    }
    if (err_flag != SUCCESS)
    {
        pngErrorReturn(err_flag);
    }
}
