/* Copyright 1993-2003 The MathWorks, Inc. */

/* $Revision: 5.16.4.1 $  $Date*/

static char rcsid[] = "$Id: ditherc.c,v 5.16.4.1 2003/01/26 05:59:20 batserve Exp $";

/*
 *
 *	ditherc.c
 *
 *	DITHERC.MEX		Error Propagation Image Dithering 
 *
 *	IM = DITHER( RGB, MAP, Qm, Qe ) will dither the RGB 
 *	image against the colormap MAP to create the dithered indexed image
 *	IM.  Qm specifies the number of quantization bits to use along each 
 *	color axis of the inverse color map.  Qe specifies the number of
 *	quantization bits to use for color space error calculations.
 *
 *      Qm must be at least 1 and no greater than 10.
 *      Qe must be at least 1 and no greater than 31.
 *
 *      This function requires temporary memory storage proportional to
 *      c1*2^(3*Qm) + c2*2^(Qe+1) + c3*prod(size(R)).  c1, c2 and c3 are
 *      architecture dependant.  Memory usage is typically around 256Kb for
 *      a 100x100 image using the default parameters.
 *
 *	Joseph M. Winograd 7-93
 *
 *	References: 
 *	  R. W. Floyd and L. Steinberg, "An Adaptive Algorithm for
 *	    Spatial Gray Scale," International Symposium Digest of Technical
 *	    Papers, Society for Information Displays, 36.  1975.
 *        Spencer W. Thomas, "Efficient Inverse Color Map Computation",
 *          Graphics Gems II, (ed. James Arvo), Academic Press: Boston.
 *          1991. (includes source code)
 *
 */

#include <string.h> 
#include "mex.h"
#include "invcmap.h"
 
#define clamp(x,l,h)    ((x)<(l)?(l):(x)>(h)?(h):(x))
#define maxx(x,y)	((x)>(y)?(x):(y))
#define elem2d(x,y)     ((x)+(y)*dim2x)                 

#define RGB		(0)	/* Parameter list/array indexing constants. */
#define MAP		(1)
#define QM		(2)	/* Quantization levels in map. */
#define QE		(3)	/* Quantization levels in error calculation. */

/*****************************************************************************/

/*
 *	Floyd-Steinberg Error Propogation Dithering
 */

void fsdither( uint8_T *r, uint8_T *g, uint8_T *b, 
               int32_T *mapq, int32_T k, int32_T *inverse_colormap, 
               uint16_T *dithered_image, int32_T m, int32_T n, 
               int32_T qm, int32_T qe, int32_T *tab1, int32_T *tab3, 
               int32_T *tab5, int32_T *tab7)
{
    real64_T scale;
    register int32_T x, y, z, Rval, Gval, Bval;
    int32_T pixel_value;
    int32_T dim2x = k, elevels, mask, bitshift0,
	bitshift1, bitshift2, Roffset, Goffset,
	Boffset;
    int32_T *rq;
    int32_T *gq;
    int32_T *bq;
    int32_T *rq_next;
    int32_T *gq_next;
    int32_T *bq_next;
    int32_T offset;
    
    /*
     * Make z volatile to force it out of a register.  Makes sure
     * that multiplication by 255 is rounded correctly on extended
     * precision machines (MAC, PC, HP300).
     */
    volatile real64_T zr,zg,zb;

    /* Handle special case of no dithering possible. */

    if (qe < qm) {
	elevels = (1 << qm) - 1;	/* Really mlevels-1 */
        scale = (real64_T) elevels / 255.0;
	for (z = 0; z < m*n; z++) {
            zr = (real64_T) r[z] * scale + 0.5;
            zg = (real64_T) g[z] * scale + 0.5;
            zb = (real64_T) b[z] * scale + 0.5;
	    dithered_image[z] = (uint16_T) (inverse_colormap[
		(((int32_T) zr) << (qm+qm)) +
		(((int32_T) zg) << qm) +
                ((int32_T) zb) ]); 
	}
	return;
    }

    /* Set up for dither. */

    elevels = (1 << qe);
    bitshift0 = qe - qm;
    bitshift1 = qm - bitshift0;
    bitshift2 = qm + bitshift1;
    mask = ~((1 << bitshift0) - 1);
    Roffset = elem2d(0,0);
    Goffset = elem2d(0,1);
    Boffset = elem2d(0,2);

    /* Calculate fast math table values. */

    y = elevels / 32;
    for (x = -elevels; x < 0; x++) {
        tab1[x+elevels] = -((y-x) / 16);
        tab3[x+elevels] = -((y-3*x) / 16);
        tab5[x+elevels] = -((y-5*x) / 16);
        tab7[x+elevels] = -((y-7*x) / 16);
    }
    for (x = 0; x < elevels; x++) {
        tab1[x+elevels] = ((y+x) / 16);
        tab3[x+elevels] = ((y+3*x) / 16);
        tab5[x+elevels] = ((y+5*x) / 16);
        tab7[x+elevels] = ((y+7*x) / 16);
    }
 
 
    for (x = 0; x < 3*k; x++) {
        mapq[x] -= elevels;
    }

    rq = (int32_T *) mxCalloc(m, sizeof(*rq));
    gq = (int32_T *) mxCalloc(m, sizeof(*gq));
    bq = (int32_T *) mxCalloc(m, sizeof(*bq));
    rq_next = (int32_T *) mxCalloc(m, sizeof(*rq_next));
    gq_next = (int32_T *) mxCalloc(m, sizeof(*gq_next));
    bq_next = (int32_T *) mxCalloc(m, sizeof(*bq_next));

    scale = (elevels - 1.0) / 255.0;
    
    if (n > 0)
    {
        /* 
         * Initialize rq_next, gq_next, bq_next to the first column 
         * of pixels. 
         */
        for (y = 0; y < m; y++)
        {
            rq_next[y] = (int32_T) (r[y] * scale + 0.5);
            gq_next[y] = (int32_T) (g[y] * scale + 0.5);
            bq_next[y] = (int32_T) (b[y] * scale + 0.5);
        }
    }

    for (x = z = 0; x < n; x++) {

        /*
         * Copy rq_next, gq_next, and bq_next into rq, gq, and bq.
         */
        memcpy(rq, rq_next, m*sizeof(*rq));
        memcpy(gq, gq_next, m*sizeof(*gq));
        memcpy(bq, bq_next, m*sizeof(*bq));

        if (x < (n-1))
        {
            /* 
             * Initialize rq_next, gq_next, bq_next to the x+1 column 
             * of pixels. 
             */
            for (y = 0, offset = (x+1)*m; y < m; y++, offset++)
            {
                rq_next[y] = (int32_T) (r[offset] * scale + 0.5);
                gq_next[y] = (int32_T) (g[offset] * scale + 0.5);
                bq_next[y] = (int32_T) (b[offset] * scale + 0.5);
            }
        }
 
        for (y = 0; y < m; y++, z++) {
 
            /* Place this pixel. */
 
            pixel_value = inverse_colormap[
		 (((rq[y]=clamp(rq[y],0,elevels-1)) & mask)<<bitshift2) +
                 (((gq[y]=clamp(gq[y],0,elevels-1)) & mask)<<bitshift1) +
		 ((bq[y]=clamp(bq[y],0,elevels-1))>>bitshift0) ];
	    dithered_image[z] = (uint16_T) pixel_value;
 
            /* Calculate errors. */
 
            Rval = rq[y] -= mapq[pixel_value + Roffset];
            Gval = gq[y] -= mapq[pixel_value + Goffset];
            Bval = bq[y] -= mapq[pixel_value + Boffset];
 
 
            /* Apply error to next pixel. */
 
            if (y != m-1) {
            	rq[y+1] += tab7[Rval];
            	gq[y+1] += tab7[Gval];
            	bq[y+1] += tab7[Bval];
            }
 
            /* Apply error to right pixel. */
 
            if (x != n-1) {
            	rq_next[y] += tab5[Rval];
            	gq_next[y] += tab5[Gval];
            	bq_next[y] += tab5[Bval];
 
            	/* Apply error to upper right pixel. */
 
            	if (y) {
        	    rq_next[y-1] += tab3[Rval];
        	    gq_next[y-1] += tab3[Gval];
        	    bq_next[y-1] += tab3[Bval];
            	}
 
            	/* Apply error to lower right pixel. */
 
            	if (y != m-1) {
            	    rq_next[y+1] += tab1[Rval];
            	    gq_next[y+1] += tab1[Gval];
            	    bq_next[y+1] += tab1[Bval];
                }
	    }
        }
    }

    mxFree(bq_next);
    mxFree(gq_next);
    mxFree(rq_next);
    mxFree(bq);
    mxFree(gq);
    mxFree(rq);
}
 
 
/*
 *      Gateway routine.
 */

void ValidateInputs(int nlhs,
                    mxArray *plhs[],
                    int nrhs,
                    const mxArray *prhs[],
                    int32_T *qm,
                    int32_T *qe)
{
    int32_T p;
    int32_T q;
    int32_T i;
    real64_T *map;
    const int *size;
                
    if (nrhs != 4) 
    {
	mexErrMsgIdAndTxt("Images:ditherc:expectedSixInputArgs",
			  "ditherc expects six input arguments");
    }

    if (!mxIsUint8(prhs[RGB]))
    {
        mexErrMsgIdAndTxt("Images:ditherc:imageExpectedUINT8",
                          "Input image must be uint8.");
    }
    size = mxGetDimensions(prhs[RGB]);
    if (mxGetNumberOfDimensions(prhs[RGB]) > 3)
    {
	mexErrMsgIdAndTxt("Images:ditherc:inputImageTooManyDimensions",
                          "Input image has too many dimensions.");
    }
    if ( (mxGetNumberOfDimensions(prhs[RGB]) == 3) &&
         (size[2] != 3) )
    {
	mexErrMsgIdAndTxt("Images:ditherc:inputImageInvalidDimensions",
                          "Invalid dimensions for input image.");
    }
    if (mxIsComplex(prhs[RGB]))
    {
	mexErrMsgIdAndTxt("Images:ditherc:inputImageMustBeReal",
                          "Input image must be real.");
    }
    
    p = mxGetM(prhs[MAP]);
    q = mxGetN(prhs[MAP]);
    if (p < 2)
    {
	mexErrMsgIdAndTxt("Images:ditherc:colormapExpectedAtLeast2Entries",
                          "Colormap must have at least two entries.");
    }
    if (p > 65536)
    {
	mexErrMsgIdAndTxt("Images:ditherc:colormapTooManyEntries",
                          "Colormap must not have more than 65536 entries.");
    }
    if (q != 3)
    {
	mexErrMsgIdAndTxt("Images:ditherc:colormapMustBeMby3",
                          "Colormap must be an M-by-3 matrix.");
    }
    if (!mxIsDouble(prhs[MAP]) || mxIsComplex(prhs[MAP]))
    {
	mexErrMsgIdAndTxt("Images:ditherc:colormapMustBeReal",
                          "Colormap must be real.");
    }
    
    if (!mxIsDouble(prhs[QM]) || (mxGetNumberOfElements(prhs[QM]) != 1) ||
        mxIsComplex(prhs[QM]))
    {
	mexErrMsgIdAndTxt("Images:ditherc:qmMustBeRealDoubleScalar",
                          "Qm must be a real double scalar.");
    }
    
    if (!mxIsDouble(prhs[QE]) || (mxGetNumberOfElements(prhs[QE]) != 1) ||
        mxIsComplex(prhs[QE]))
    {
	mexErrMsgIdAndTxt("Images:ditherc:qeMustBeRealDoubleScalar",
                          "Qe must be a real double scalar.");
    }
    
    *qm = (int32_T) mxGetScalar(prhs[QM]);
    *qe = (int32_T) mxGetScalar(prhs[QE]);

    if (*qm < 1)
    {
	mexErrMsgIdAndTxt("Images:ditherc:qmMustBeAtLeastOne",
                          "Qm must be at least 1.");
    }
    if (*qm > ((sizeof(int32_T) * 8) / 3))
    {
	mexErrMsgIdAndTxt("Images:ditherc:qmMustBeLessThanTen",
                          "Qm must be no greater than 10.");
    }
    
    if (*qe < 1)
    {
	mexErrMsgIdAndTxt("Images:ditherc:qeMustBeAtLeastOne",
                          "Qe must be at least 1.");
    }
    if (*qe > (sizeof(int32_T) * 8 - 1))
    {
	mexErrMsgIdAndTxt("Images:ditherc:qeMustBeNotGreaterThan31",
                          "Qe must be no greater than 31.");
    }

    map = mxGetPr(prhs[MAP]);
    for (i = 0; i < p*q; i++)
    {
        if ((map[i] < 0.0) || (map[i] > 1.0))
        {
            mexErrMsgIdAndTxt("Images:ditherc:colormapOutOfRangeVals",
                              "Colormap contains out-of-range values.");
        }
    }
    
    /* hey, if we made it all the way here, everything's ok */
}
    
 
void mexFunction(
	int nlhs,
	mxArray *plhs[],
	int nrhs,
	const mxArray *prhs[])
{
    /* Declare input variable data. */

    uint8_T     *r, *g, *b;
    real64_T	*map;
    int32_T	qm, qe;
    int32_T     out_size[2];
    const int   *in_size;
        
    /* Declare output variable data. */

    mxArray     *result;
    uint16_T   *dithered_image;

    /* Declare working storage data. */

    uint32_T *scratchpad;
    int32_T *inverse_colormap;
    int32_T m, n, k, x, elevels, mlevels;
    int32_T *mapq, *tab1, *tab3, *tab5, *tab7;
    int32_T i;
    uint8_T *pu8;
    uint16_T *pu16;
    /*
     * Make z volatile to force it out of a register.  Makes sure
     * that multiplication by 255 is rounded correctly on extended
     * precision machines (MAC, PC, HP300).
     */
    volatile real64_T z;

    /* Check input arguments. */
    ValidateInputs(nlhs, plhs, nrhs, prhs, &qm, &qe);

    elevels = 1 << maxx(qm, qe);
    mlevels = 1 << qm;

    in_size = mxGetDimensions(prhs[RGB]);
    m = in_size[0];
    n = in_size[1];

    map = mxGetPr(prhs[MAP]);
    k = mxGetM(prhs[MAP]);

    /* create output array */
    out_size[0] = m;
    out_size[1] = n;
    if (k <= 256)
    {
        result = mxCreateNumericArray(2, out_size, mxUINT8_CLASS, mxREAL);
    }
    else
    {
        result = mxCreateNumericArray(2, out_size, mxUINT16_CLASS, mxREAL);
    }

    if (mxIsEmpty(result))
    {
        /* nothing to do */
        plhs[0] = result;
        return;
    }

    r = (uint8_T *) mxGetData(prhs[RGB]);
    if (mxGetNumberOfDimensions(prhs[RGB]) == 2)
    {
        g = r;
        b = r;
    }
    else
    {
        g = r + m*n;
        b = g + m*n;
    }

    /* Allocate working memory. */
    dithered_image = mxCalloc(mxGetNumberOfElements(result), 
                              sizeof(*dithered_image));
    inverse_colormap = mxCalloc( mlevels*mlevels*mlevels, 
                                 sizeof(*inverse_colormap) );
    mapq = mxCalloc( k*3, sizeof( *mapq ) );
    tab1 = mxCalloc( elevels*2, sizeof( *tab1 ) );
    tab3 = mxCalloc( elevels*2, sizeof( *tab3 ) );
    tab5 = mxCalloc( elevels*2, sizeof( *tab5 ) );
    tab7 = mxCalloc( elevels*2, sizeof( *tab7 ) );

    for (x = 0; x < 3*k; x++) {
        z = map[x] * (elevels-1) + 0.5;
        mapq[x] = (int32_T) z;

    }
 
    /* Call algorithms. */

    scratchpad = mxCalloc( mlevels*mlevels*mlevels, sizeof(*scratchpad) );
    inv_cmap_2( k, mapq, qm, maxx(qm,qe), scratchpad, inverse_colormap );
    mxFree(scratchpad);

    fsdither( r, g, b, mapq, k, inverse_colormap, dithered_image, 
		m, n, qm, qe, tab1, tab3, tab5, tab7 );

    if (k <= 256)
    {
        /* uint8 zero-based output */
        pu8 = (uint8_T *) mxGetData(result);
        for (i = 0; i < m*n; i++)
        {
            *pu8++ = (uint8_T) dithered_image[i];
        }
    }
    else
    {
        /* uint16 zero-based output */
        pu16 = (uint16_T *) mxGetData(result);
        for (i = 0; i < m*n; i++)
        {
            *pu16++ = (uint16_T) dithered_image[i];
        }
    }
    
    plhs[0] = result;
    
    /* Free working memory */
    mxFree(tab7);
    mxFree(tab5);
    mxFree(tab3);
    mxFree(tab1);
    mxFree(inverse_colormap);
    mxFree(dithered_image);
    mxFree(mapq);

} /* mexFunction() */
