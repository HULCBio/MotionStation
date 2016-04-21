/* $Revision: 1.1.6.1 $ */
#ifndef PNGMEX_H
#define PNGMEX_H

#include "mex.h"
#include "pngutils.h"
#include "pngerrs.h"

void InfoPNG(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void ReadPNG(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void WritePNG(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

#endif /* PNGMEX_H */
