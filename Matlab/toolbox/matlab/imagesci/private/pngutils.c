/* Copyright 1984-2001 The MathWorks, Inc.  */

/* $Revision: 1.1.6.1 $ */
#include "pngerrs.h"
#include "pngutils.h"
#include "mex.h"

/*
 * Check the byte-order of the CPU.
 * Code adapted from _Encyclopedia of Graphics File Formats_,
 * 2nd edition, pp. 114-115.
 */
int CheckByteOrder(void)
{
    int16_T w = 0x0001;
    int8_T *b = (int8_T *) &w;
    return(b[0] ? LSB_FIRST : MSB_FIRST);
}

MexInfoType *InitMexInfo()
{
    MexInfoType *mexInfo;
    
    mexInfo = mxCalloc(1, sizeof(*mexInfo));
    mexInfo->filename = NULL;
    mexInfo->fp = NULL;
    mexInfo->png_ptr = NULL;
    mexInfo->info_ptr = NULL;
    mexInfo->palette = NULL;
    mexInfo->trans = NULL;
    mexInfo->row = NULL;
    mexInfo->rows = NULL;
    mexInfo->text_ptr = NULL;
    mexInfo->num_text = 0;
    
    return(mexInfo);
}

#define FREE_IF_NOT_NULL(ptr) {if ((ptr) != NULL) mxFree((void *) (ptr));}
void DestroyMexInfo(MexInfoType *mexInfo)
{
    int k;

    FREE_IF_NOT_NULL(mexInfo->filename);
    FREE_IF_NOT_NULL(mexInfo->palette);
    FREE_IF_NOT_NULL(mexInfo->trans);
    FREE_IF_NOT_NULL(mexInfo->row);
    FREE_IF_NOT_NULL(mexInfo->rows);

    if (mexInfo->text_ptr != NULL)
    {
        for (k = 0; k < mexInfo->num_text; k++)
        {
            FREE_IF_NOT_NULL((mexInfo->text_ptr)[k].key);
            FREE_IF_NOT_NULL((mexInfo->text_ptr)[k].text);
        }
        mxFree((void *) mexInfo->text_ptr);
    }
    
    if (mexInfo->fp != NULL)
    {
        fclose(mexInfo->fp);
    }
    
    mxFree((void *) mexInfo);
}

void WarningHandler(png_structp png_ptr, png_const_charp message)
{
    mexWarnMsgTxt(message);
}

ErrorFlag GetFilename(const mxArray *filename_array, char **filename)
{
    int length;
    
    if (!mxIsChar(filename_array) || (mxGetM(filename_array) != 1))
    {
        return(FILENAME_NOT_A_STRING);
    }

    length = mxGetNumberOfElements(filename_array) * sizeof(mxChar) + 1;
    *filename = (char *) mxCalloc(length, sizeof(*filename));
    if (*filename == NULL)
    {
        return(OUT_OF_MEMORY);
    }
    
    mxGetString(filename_array, *filename, length);

    return(SUCCESS);
}

#define BUFFER_LENGTH 10
ErrorFlag GetBackgroundColor(const mxArray *bg_array, 
                             png_color_16p background,
                             int color_type,
                             int bit_depth,
                             bool *bg_is_none)
{
    double *pr;
    double tmp;
    int k;
    char buffer[BUFFER_LENGTH];

    *bg_is_none = false;

    if (mxIsChar(bg_array))
    {
        mxGetString(bg_array, buffer, BUFFER_LENGTH);
        if (strcmp(buffer, "none") == 0)
        {
            *bg_is_none = true;
            return(SUCCESS);
        }
        else
        {
            return(BAD_BACKGROUND_COLOR);
        }
    }
    

    if (!mxIsDouble(bg_array))
    {
        return(BAD_BACKGROUND_COLOR);
    }

    if (color_type == PNG_COLOR_TYPE_PALETTE)
    {
        if (mxGetNumberOfElements(bg_array) == 1)
        {
            tmp = mxGetScalar(bg_array);
            if ((tmp < 1) || (tmp > 256) || ((int) tmp != tmp))
            {
                return(BAD_BACKGROUND_COLOR);
            }
            /*
             * Switch from one-based to zero-based.
             */
            background->index = (png_byte) (tmp - 1);
        }
        else if (mxGetNumberOfElements(bg_array) == 3)
        {
            /*
             * RGB-style background color is allowed for reading.
             */
            pr = mxGetPr(bg_array);
            for (k = 0; k < 2; k++)
            {
                if ((pr[k] < 0.0) || (pr[k] > 1.0))
                {
                    return(BAD_BACKGROUND_COLOR);
                }
            }
            background->red = (png_uint_16) (pr[0] * MAX_PIXEL_VALUE(bit_depth) + 0.5);
            background->green = (png_uint_16) (pr[1] * MAX_PIXEL_VALUE(bit_depth) + 0.5);
            background->blue = (png_uint_16) (pr[2] * MAX_PIXEL_VALUE(bit_depth) + 0.5);
        }
        else
        {
            return(BAD_BACKGROUND_COLOR);
        }
    }
    else if ((color_type == PNG_COLOR_TYPE_GRAY) ||
             (color_type == PNG_COLOR_TYPE_GRAY_ALPHA))
    {
        if (mxGetNumberOfElements(bg_array) != 1)
        {
            return(BAD_BACKGROUND_COLOR);
        }
        tmp = mxGetScalar(bg_array);
        if ((tmp < 0.0) || (tmp > 1.0))
        {
            return(BAD_BACKGROUND_COLOR);
        }
        background->gray = (png_uint_16) (tmp * MAX_PIXEL_VALUE(bit_depth) + 0.5);
    }
    else
    {
        if (mxGetNumberOfElements(bg_array) != 3)
        {
            return(BAD_BACKGROUND_COLOR);
        }
        pr = mxGetPr(bg_array);
        for (k = 0; k < 2; k++)
        {
            if ((pr[k] < 0.0) || (pr[k] > 1.0))
            {
                return(BAD_BACKGROUND_COLOR);
            }
        }
        background->red = (png_uint_16) (pr[0] * MAX_PIXEL_VALUE(bit_depth) + 0.5);
        background->green = (png_uint_16) (pr[1] * MAX_PIXEL_VALUE(bit_depth) + 0.5);
        background->blue = (png_uint_16) (pr[2] * MAX_PIXEL_VALUE(bit_depth) + 0.5);
    }
    return(SUCCESS);
}
