/* Copyright 1984-98 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#ifndef PNGERRS_H
#define PNGERRS_H

/*
 * Errors
 */
typedef enum errors
{
    SUCCESS = 0,
    FILENAME_NOT_A_STRING,
    OUT_OF_MEMORY,
    INTERLACE_NOT_A_STRING,
    BAD_INTERLACE,
    BAD_MAP,
    TOO_MANY_MAP_COLORS,
    BAD_MAP_VALUE,
    BAD_GAMMA,
    BAD_CHROMA_SIZE,
    BAD_CHROMA_VALUE,
    BAD_TRANSPARENCY,
    BAD_COLOR_TYPE,
    BAD_TRANSPARENCY_VALUE,
    TRANSPARENCY_WITH_ALPHA,
    BAD_XRES,
    BAD_YRES,
    BAD_RESUNIT,
    BAD_BKGD,
    BAD_BKGD_VALUE,
    BAD_TEXT,
    BAD_TEXT_VALUE,
    FILE_OPEN,
    PNG_LIB_INIT,
    PNG_LIB_ERROR,
    PARTIAL_RES_PROPS,
    UNKNOWN_COLOR_TYPE,
    BAD_BACKGROUND_COLOR,
    BAD_BIT_DEPTH,
    BIT_DEPTH_WITH_NONGRAY,
    BAD_SIGBITS,
    SIGBITS_OUT_OF_RANGE,
    NUM_ERROR_MESSAGES  /* this one must stay last on the list */
}
ErrorFlag;

void pngErrorReturn(ErrorFlag err_flag);
void InitErrorMessages(void);

#endif /* PNGERRS_H */
