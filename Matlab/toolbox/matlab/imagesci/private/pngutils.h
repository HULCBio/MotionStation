/* $Revision: 1.1.6.1 $ */
#ifndef PNGUTILS_H
#define PNGUTILS_H

#include <stdio.h>
#include "png.h"
#include "pngerrs.h"
#include "mex.h"

#define MAX_PIXEL_VALUE(bit_depth) ((1 << (bit_depth)) - 1)

#define LSB_FIRST 0
#define MSB_FIRST 1
int CheckByteOrder(void);

/*
 * This structure contains the pointers to dynamically allocated functions
 * or file pointers that need to be cleaned up.  We're making a structure
 * to contain this information because it needs to be passed to the error
 * handler.
 */
typedef struct mex_info
{
    char *filename;
    FILE *fp;
    png_structp png_ptr;
    png_infop info_ptr;
    png_colorp palette;
    png_bytep trans;
    png_bytep row;
    png_bytep *rows;
    png_textp text_ptr;
    int num_text;
}
MexInfoType;

MexInfoType *InitMexInfo(void);
void DestroyMexInfo(MexInfoType *mexInfo);
extern void WarningHandler(png_structp png_ptr, png_const_charp message);
ErrorFlag GetFilename(const mxArray *filename_array, char **filename);
ErrorFlag GetBackgroundColor(const mxArray *bg_array, 
                             png_color_16p background,
                             int color_type,
                             int bit_depth,
                             bool *bg_is_none);

#endif /* PNGUTILS_H */

