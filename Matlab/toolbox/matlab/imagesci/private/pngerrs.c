/* Copyright 1984-2001 The MathWorks, Inc.  */

/* $Revision: 1.1.6.1 $ */
#include "pngerrs.h"
#include "mex.h"

static const char *error_messages[NUM_ERROR_MESSAGES];
static bool initialized = false;

void InitErrorMessages(void)
{
    if (! initialized)
    {
        initialized = true;

        error_messages[FILENAME_NOT_A_STRING] = "Filename must be a string.";
        error_messages[OUT_OF_MEMORY]  = "Out of memory.";
        error_messages[INTERLACE_NOT_A_STRING] = "Interlace must be 'none' or "
            "'adam7'";
        error_messages[BAD_INTERLACE] = "Interlace must be 'none' or 'adam7'";
        error_messages[BAD_MAP] = "Invalid colormap.";
        error_messages[TOO_MANY_MAP_COLORS] = "Colormap has more than 256 colors.";
        error_messages[BAD_MAP_VALUE] = "Colormap has values out of range.";
        error_messages[BAD_GAMMA] = "Gamma must be a positive scalar.";
        error_messages[BAD_CHROMA_SIZE] = "Chromaticity must be an 8-element "
            "vector.";
        error_messages[BAD_CHROMA_VALUE] = "Chromaticity has values out of range.";
        error_messages[BAD_TRANSPARENCY] = "Invalid transparency.";
        error_messages[BAD_COLOR_TYPE] = "Invalid color type.";
        error_messages[BAD_TRANSPARENCY_VALUE] = "Transparency has values out of range.";
        error_messages[TRANSPARENCY_WITH_ALPHA] = "Cannot specify alpha channel "
            "simultaneously with transparency.";
        error_messages[BAD_XRES] = "X resolution must be a positive scalar.";
        error_messages[BAD_YRES] = "Y resolution must be a positive scalar.";
        error_messages[BAD_RESUNIT] = "Resolution unit must be 'unknown' or "
            "'meter'";
        error_messages[BAD_BKGD] = "Invalid background color.";
        error_messages[BAD_BKGD_VALUE] = "Invalid background color.";
        error_messages[BAD_TEXT] = "Invalid text chunks.";
        error_messages[BAD_TEXT_VALUE] = "Invalid text chunk.";
        error_messages[FILE_OPEN] = "Could not open file.";
        error_messages[PNG_LIB_INIT] = "Could not initialize libpng data "
            "structures.";
        error_messages[PNG_LIB_ERROR] = "Unknown failure writing file.";
        error_messages[PARTIAL_RES_PROPS] = "X resolution, Y resolution, and "
            "resolution unit must all be specified if any is.";
        error_messages[UNKNOWN_COLOR_TYPE] = "Unknown color type.";
        error_messages[BAD_BACKGROUND_COLOR] = "Invalid background color specification.";
        error_messages[BAD_BIT_DEPTH] = "Invalid bit depth specification.";
        error_messages[BIT_DEPTH_WITH_NONGRAY] =
            "Can't override bitdepth unless image is grayscale.";
        error_messages[BAD_SIGBITS] = "Invalid significant bits specification.";
        error_messages[SIGBITS_OUT_OF_RANGE] = "Significant bits contains out-of-range values.";
    }
}

void pngErrorReturn(ErrorFlag err_flag)
{
    mexErrMsgTxt(error_messages[err_flag]);
}
