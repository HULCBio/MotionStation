/*
 * @(#)copy_row_as_col_br_dz_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:19 2004
 *
 *		built from:	copy_row_as_col_br_dz_rt.c
 */

#ifndef copy_row_as_col_br_dz_rt_h
#define copy_row_as_col_br_dz_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_CopyRowAsColBR_DZ(
    creal_T          *y,
    const real_T     *x,
    const int_T       nCols,
    const int_T       nRows,
    const int_T       rowIdx
    );

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* copy_row_as_col_br_dz_rt_h */