/*
 * CQ - MEX-file for variance minimization color quantization.
 *
 * [MAP,X] = CQ(RGB,N) finds a colormap, MAP, and optionally an index matrix, 
 * X, that approximates the truecolor image RGB.  RGB must be an M-by-N-by-3
 * uint8 array.  N must be a scalar double between 0 and 65536.  The
 * number of colors in the resulting colormap will be less than or equal
 * to N.  X is be uint8 if SIZE(MAP,1) is less than or equal to 256;
 * otherwise X is uint16.
 *
 */ 


/*
 * Revision 1.1 of this file is exactly as downloaded from Xiaolin Wu's 
 * web page on January 18, 2000:
 *
 *    http://www.csd.uwo.ca/~wu/index.html
 *    http://www.csd.uwo.ca/~wu/cq.c
 *
 * $Revision: 1.3.4.1 $
 *
 */

/**********************************************************************
            C Implementation of Wu's Color Quantizer (v. 2)
            (see Graphics Gems vol. II, pp. 126-133)

Author: Xiaolin Wu
        Dept. of Computer Science
        Univ. of Western Ontario
        London, Ontario N6A 5B7
        wu@csd.uwo.ca

Algorithm: Greedy orthogonal bipartition of RGB space for variance
           minimization aided by inclusion-exclusion tricks.
           For speed no nearest neighbor search is done. Slightly
           better performance can be expected by more sophisticated
           but more expensive versions.

The author thanks Tom Lane at Tom_Lane@G.GP.CS.CMU.EDU for much of
additional documentation and a cure to a previous bug.

Free to distribute, comments and suggestions are appreciated.
**********************************************************************/ 

static char rcsid[] = "$Id: cq.c,v 1.3.4.1 2003/08/01 18:10:21 batserve Exp $";

#include <math.h>
#include "mex.h"

#define MAXCOLORS  65536

#define RED       2
#define GREEN     1
#define BLUE      0

#define BOX_SIZE  33

struct box {
    int r0;                      /* min value, exclusive */
    int r1;                      /* max value, inclusive */
    int g0;  
    int g1;  
    int b0;  
    int b1;
    int vol;
};

/* Histogram is in elements 1..HISTSIZE along each axis,
 * element 0 is for base or marginal value
 * NB: these must start out 0!
 */

float           m2[BOX_SIZE][BOX_SIZE][BOX_SIZE];
long int        wt[BOX_SIZE][BOX_SIZE][BOX_SIZE];
long int        mr[BOX_SIZE][BOX_SIZE][BOX_SIZE];
long int        mg[BOX_SIZE][BOX_SIZE][BOX_SIZE];
long int        mb[BOX_SIZE][BOX_SIZE][BOX_SIZE];

void InitBoxes(void)
{
    int j;
    int m;
    int n;
    
    for (j = 0; j < BOX_SIZE; j++)
    {
        for (m = 0; m < BOX_SIZE; m++)
        {
            for (n = 0; n < BOX_SIZE; n++)
            {
                m2[j][m][n] = 0.0;
                wt[j][m][n] = 0;
                mr[j][m][n] = 0;
                mg[j][m][n] = 0;
                mb[j][m][n] = 0;
            }
        }
    }
}

/* build 3-D color histogram of counts, r/g/b, c^2 */
void
Hist3d(uint8_T *Ir, uint8_T *Ig, uint8_T *Ib, int num_pixels,
       long int *vwt, long int *vmr, long int *vmg, long int *vmb, float *m2,
       uint16_T *Qadd)
{
    int ind;
    int r;
    int g;
    int b;
    int inr;
    int ing;
    int inb;
    int table[256];
    long int i;
                
    for(i=0; i<256; ++i) 
    {
        table[i]=i*i;
    }
    
    for(i=0; i<num_pixels; ++i)
    {
        r = Ir[i]; 
        g = Ig[i]; 
        b = Ib[i];
        inr=(r>>3)+1; 
        ing=(g>>3)+1; 
        inb=(b>>3)+1; 
        Qadd[i]=ind=(inr<<10)+(inr<<6)+inr+(ing<<5)+ing+inb;
        /* [inr][ing][inb] */
        ++vwt[ind];
        vmr[ind] += r;
        vmg[ind] += g;
        vmb[ind] += b;
        m2[ind] += (float)(table[r]+table[g]+table[b]);
    }

}

/* At conclusion of the histogram step, we can interpret
 *   wt[r][g][b] = sum over voxel of P(c)
 *   mr[r][g][b] = sum over voxel of r*P(c)  ,  similarly for mg, mb
 *   m2[r][g][b] = sum over voxel of c^2*P(c)
 * Actually each of these should be divided by 'NumPixels' to give the usual
 * interpretation of P() as ranging from 0 to 1, but we needn't do that here.
 */

/* We now convert histogram into moments so that we can rapidly calculate
 * the sums of the above quantities over any desired box.
 */

/* compute cumulative moments. */
void
M3d(long int *vwt, long int *vmr, long int *vmg, long int *vmb, float *m2) 
{
    uint16_T ind1;
    uint16_T ind2;
    uint8_T i;
    uint8_T r;
    uint8_T g;
    uint8_T b;
    long int line;
    long int line_r;
    long int line_g;
    long int line_b;
    long int area[BOX_SIZE];
    long int area_r[BOX_SIZE];
    long int area_g[BOX_SIZE];
    long int area_b[BOX_SIZE];
    float line2;
    float area2[BOX_SIZE];

    for(r=1; r<BOX_SIZE; ++r)
    {
        for(i=0; i<BOX_SIZE; ++i) 
        {
            area2[i] = 0.0;
            area[i] = 0;
            area_r[i] = 0;
            area_g[i] = 0;
            area_b[i] = 0;
        }
        
        for(g=1; g<=32; ++g)
        {
            line2 = 0.0;
            line = 0;
            line_r = 0;
            line_g = 0;
            line_b = 0;
            for(b=1; b<=32; ++b)
            {
                ind1 = (r<<10) + (r<<6) + r + (g<<5) + g + b; /* [r][g][b] */
                line += vwt[ind1];
                line_r += vmr[ind1]; 
                line_g += vmg[ind1]; 
                line_b += vmb[ind1];
                line2 += m2[ind1];
                area[b] += line;
                area_r[b] += line_r;
                area_g[b] += line_g;
                area_b[b] += line_b;
                area2[b] += line2;
                ind2 = ind1 - 1089; /* [r-1][g][b] */
                vwt[ind1] = vwt[ind2] + area[b];
                vmr[ind1] = vmr[ind2] + area_r[b];
                vmg[ind1] = vmg[ind2] + area_g[b];
                vmb[ind1] = vmb[ind2] + area_b[b];
                m2[ind1] = m2[ind2] + area2[b];
            }
        }
    }
}

/* Compute sum over a box of any given statistic */
long int Vol(struct box *cube, long int mmt[BOX_SIZE][BOX_SIZE][BOX_SIZE]) 
{
    return( mmt[cube->r1][cube->g1][cube->b1] 
            -mmt[cube->r1][cube->g1][cube->b0]
            -mmt[cube->r1][cube->g0][cube->b1]
            +mmt[cube->r1][cube->g0][cube->b0]
            -mmt[cube->r0][cube->g1][cube->b1]
            +mmt[cube->r0][cube->g1][cube->b0]
            +mmt[cube->r0][cube->g0][cube->b1]
            -mmt[cube->r0][cube->g0][cube->b0] );
}

/* The next two routines allow a slightly more efficient calculation
 * of Vol() for a proposed subbox of a given box.  The sum of Top()
 * and Bottom() is the Vol() of a subbox split in the given direction
 * and with the specified new upper bound.
 */

/* Compute part of Vol(cube, mmt) that doesn't depend on r1, g1, or b1 */
/* (depending on dir) */
long int Bottom(struct box *cube, uint8_T dir, 
                long int mmt[BOX_SIZE][BOX_SIZE][BOX_SIZE])
{
    switch(dir)
    {
    case RED:
        return( -mmt[cube->r0][cube->g1][cube->b1]
                +mmt[cube->r0][cube->g1][cube->b0]
                +mmt[cube->r0][cube->g0][cube->b1]
                -mmt[cube->r0][cube->g0][cube->b0] );
        break;
    case GREEN:
        return( -mmt[cube->r1][cube->g0][cube->b1]
                +mmt[cube->r1][cube->g0][cube->b0]
                +mmt[cube->r0][cube->g0][cube->b1]
                -mmt[cube->r0][cube->g0][cube->b0] );
        break;
    case BLUE:
        return( -mmt[cube->r1][cube->g1][cube->b0]
                +mmt[cube->r1][cube->g0][cube->b0]
                +mmt[cube->r0][cube->g1][cube->b0]
                -mmt[cube->r0][cube->g0][cube->b0] );
        break;
    default:
        mexErrMsgIdAndTxt("Images:cq:internalBadDirValue",
                          "%s","Internal error: unrecognized value for dir.");
    }
}

/* Compute remainder of Vol(cube, mmt), substituting pos for */
/* r1, g1, or b1 (depending on dir) */
long int Top(struct box *cube, uint8_T dir, int pos, 
             long int mmt[BOX_SIZE][BOX_SIZE][BOX_SIZE])
{
    switch(dir)
    {
    case RED:
        return( mmt[pos][cube->g1][cube->b1] 
                -mmt[pos][cube->g1][cube->b0]
                -mmt[pos][cube->g0][cube->b1]
                +mmt[pos][cube->g0][cube->b0] );
        break;
    case GREEN:
        return( mmt[cube->r1][pos][cube->b1] 
                -mmt[cube->r1][pos][cube->b0]
                -mmt[cube->r0][pos][cube->b1]
                +mmt[cube->r0][pos][cube->b0] );
        break;
    case BLUE:
        return( mmt[cube->r1][cube->g1][pos]
                -mmt[cube->r1][cube->g0][pos]
                -mmt[cube->r0][cube->g1][pos]
                   +mmt[cube->r0][cube->g0][pos] );
        break;
    default:
        mexErrMsgIdAndTxt("Images:cq:internalBadDirValue",
                          "%s","Internal error: unrecognized value for dir.");
    }
}

/* Compute the weighted variance of a box */
/* NB: as with the raw statistics, this is really the variance * NumPixels */
float Var(struct box *cube)
{
    float dr;
    float dg;
    float db;
    float xx;
    float result;

    dr = (float) Vol(cube, mr); 
    dg = (float) Vol(cube, mg); 
    db = (float) Vol(cube, mb);
    xx = m2[cube->r1][cube->g1][cube->b1] 
        -m2[cube->r1][cube->g1][cube->b0]
        -m2[cube->r1][cube->g0][cube->b1]
        +m2[cube->r1][cube->g0][cube->b0]
        -m2[cube->r0][cube->g1][cube->b1]
        +m2[cube->r0][cube->g1][cube->b0]
        +m2[cube->r0][cube->g0][cube->b1]
        -m2[cube->r0][cube->g0][cube->b0];

    result = xx - (dr*dr+dg*dg+db*db)/(float)Vol(cube,wt);
    return (float) fabs((float) result);
}

/* We want to minimize the sum of the variances of two subboxes.
 * The sum(c^2) terms can be ignored since their sum over both subboxes
 * is the same (the sum for the whole box) no matter where we split.
 * The remaining terms have a minus sign in the variance formula,
 * so we drop the minus sign and MAXIMIZE the sum of the two terms.
 */


float Maximize(struct box *cube, uint8_T dir, int first, int last, int *cut,
               long int whole_r, long int whole_g, long int whole_b, 
               long int whole_w)
{
    long int half_r;
    long int half_g;
    long int half_b;
    long int half_w;
    long int base_r;
    long int base_g;
    long int base_b;
    long int base_w;
    int i;
    float temp;
    float max;

    base_r = Bottom(cube, dir, mr);
    base_g = Bottom(cube, dir, mg);
    base_b = Bottom(cube, dir, mb);
    base_w = Bottom(cube, dir, wt);
    max = 0.0;
    *cut = -1;
    for(i=first; i<last; ++i)
    {
        half_r = base_r + Top(cube, dir, i, mr);
        half_g = base_g + Top(cube, dir, i, mg);
        half_b = base_b + Top(cube, dir, i, mb);
        half_w = base_w + Top(cube, dir, i, wt);
        /* now half_x is sum over lower half of box, if split at i */
        if (half_w == 0) 
        {      
            /* subbox could be empty of pixels! */
            /* never split into an empty box */
            continue;             
        } 
        else
        {
            temp = ((float)half_r*half_r + (float)half_g*half_g +
                    (float)half_b*half_b)/half_w;
        }

        half_r = whole_r - half_r;
        half_g = whole_g - half_g;
        half_b = whole_b - half_b;
        half_w = whole_w - half_w;
        if (half_w == 0) 
        {      
            /* subbox could be empty of pixels! */
            /* never split into an empty box */
            continue;             
        } 
        else
        {
            temp += ((float)half_r*half_r + (float)half_g*half_g +
                     (float)half_b*half_b)/half_w;
        }

        if (temp > max) 
        {
            max=temp; 
            *cut=i;
        }
    }

    return(max);
}

int
Cut(struct box *set1, struct box *set2)
{
    uint8_T dir;
    int cutr;
    int cutg;
    int cutb;
    float maxr;
    float maxg;
    float maxb;
    long int whole_r;
    long int whole_g;
    long int whole_b;
    long int whole_w;

    whole_r = Vol(set1, mr);
    whole_g = Vol(set1, mg);
    whole_b = Vol(set1, mb);
    whole_w = Vol(set1, wt);

    maxr = Maximize(set1, RED, set1->r0+1, set1->r1, &cutr,
                    whole_r, whole_g, whole_b, whole_w);
    maxg = Maximize(set1, GREEN, set1->g0+1, set1->g1, &cutg,
                    whole_r, whole_g, whole_b, whole_w);
    maxb = Maximize(set1, BLUE, set1->b0+1, set1->b1, &cutb,
                    whole_r, whole_g, whole_b, whole_w);

    if( (maxr>=maxg)&&(maxr>=maxb) ) 
    {
        dir = RED;
        if (cutr < 0) 
        {
            return 0; /* can't split the box */
        }
    }
    else
    {
        if( (maxg>=maxr)&&(maxg>=maxb) ) {
            dir = GREEN;
        }
        else
        {
            dir = BLUE; 
        }
    }

    set2->r1 = set1->r1;
    set2->g1 = set1->g1;
    set2->b1 = set1->b1;

    switch (dir)
    {
    case RED:
        set2->r0 = set1->r1 = cutr;
        set2->g0 = set1->g0;
        set2->b0 = set1->b0;
        break;
    case GREEN:
        set2->g0 = set1->g1 = cutg;
        set2->r0 = set1->r0;
        set2->b0 = set1->b0;
        break;
    case BLUE:
        set2->b0 = set1->b1 = cutb;
        set2->r0 = set1->r0;
        set2->g0 = set1->g0;
        break;
    default:
        mexErrMsgIdAndTxt("Images:cq:internalBadDirValue",
                          "%s","Internal error: unrecognized value for dir.");
    }

    set1->vol=(set1->r1-set1->r0)*(set1->g1-set1->g0)*(set1->b1-set1->b0);
    set2->vol=(set2->r1-set2->r0)*(set2->g1-set2->g0)*(set2->b1-set2->b0);

    return 1;
}


Mark(struct box *cube, int label, uint8_T *tag)
{
    int r;
    int g;
    int b;

    for(r=cube->r0+1; r<=cube->r1; ++r)
    {
        for(g=cube->g0+1; g<=cube->g1; ++g)
        {
            for(b=cube->b0+1; b<=cube->b1; ++b)
            {
                tag[(r<<10) + (r<<6) + r + (g<<5) + g + b] = label;
            }
        }
    }
}

    


int
quantize_color(uint8_T *Ir, uint8_T *Ig, uint8_T *Ib, int num_pixels, 
               uint8_T *lut_r, uint8_T *lut_g, uint8_T *lut_b, int num_colors, 
               uint16_T *Qadd, bool compute_output_image)
{
    struct box *cube;
    uint8_T *tag;
    int next;
    long int i;
    long int weight;
    int k;
    float *vv;
    float temp;

    cube = (struct box *) mxCalloc(MAXCOLORS, sizeof(*cube));
    vv = (float *) mxCalloc(MAXCOLORS, sizeof(*vv));

    InitBoxes();

    Hist3d(Ir, Ig, Ib, num_pixels, (long int *) &wt, (long int *) &mr, 
           (long int *) &mg, (long int *) &mb, (float *) &m2, Qadd);

    M3d((long int *) &wt, (long int *) &mr, (long int *) &mg, 
        (long int *) &mb, (float *) &m2);

    cube[0].r0 = cube[0].g0 = cube[0].b0 = 0;
    cube[0].r1 = cube[0].g1 = cube[0].b1 = 32;
    next = 0;
    for(i=1; i<num_colors; ++i)
    {
        if (Cut(&cube[next], &cube[i])) 
        {
            /* volume test ensures we won't try to cut one-cell box */
            vv[next] = (cube[next].vol>1) ? Var(&cube[next]) : 0.0F;
            vv[i] = (cube[i].vol>1) ? Var(&cube[i]) : 0.0F;
        } 
        else 
        {
            vv[next] = 0.0;   /* don't try to split this box again */
            i--;              /* didn't create box i */
        }
        next = 0; 
        temp = vv[0];
        for(k=1; k<=i; ++k) 
        {
            if (vv[k] > temp) {
                temp = vv[k]; next = k;
            } 
        }
        if (temp <= 0.0) 
        {
            num_colors = i+1;
            /* Only got num_colors boxes */
            break;
        }
    }

    tag = (uint8_T *) mxMalloc(BOX_SIZE*BOX_SIZE*BOX_SIZE * sizeof(*tag));

    for(k=0; k<num_colors; ++k)
    {
        Mark(&cube[k], k, tag);
        weight = Vol(&cube[k], wt);
        if (weight) 
        {
            lut_r[k] = (uint8_T) (Vol(&cube[k], mr) / weight);
            lut_g[k] = (uint8_T) (Vol(&cube[k], mg) / weight);
            lut_b[k] = (uint8_T) (Vol(&cube[k], mb) / weight);
        }
        else
        {
            /* bogus box */
            lut_r[k] = lut_g[k] = lut_b[k] = 0;               
        }
    }

    if (compute_output_image)
    {
        for (i=0; i<num_pixels; ++i) 
        { 
            Qadd[i] = tag[Qadd[i]]; 
        }
    }

    mxFree(tag);
    mxFree(vv);
    mxFree(cube);

    return(num_colors);
}

int
check_inputs(int nrhs, const mxArray *prhs[])
{
    const int *size;
    int num_colors;

    if (nrhs != 2)
    {
        mexErrMsgIdAndTxt("Images:cq:twoInputsRequired",
                          "%s","2 input arguments required.");
    }
    
    if (! mxIsUint8(prhs[0]))
    {
        mexErrMsgIdAndTxt("Images:cq:firstInputMustBeUint8",
                          "%s","First input must be a uint8 array.");
    }
    
    if (mxGetNumberOfDimensions(prhs[0]) != 3)
    {
        mexErrMsgIdAndTxt("Images:cq:firstInputMustBe3DUint8",
                          "%s","First input must be a 3-D uint8 array.");
    }
    
    size = mxGetDimensions(prhs[0]);
    if (size[2] != 3)
    {
        mexErrMsgIdAndTxt("Images:cq:firstInputMustBeMbyNby3",
                          "%s","First input must be M-by-N-by-3.");
    }
    
    if (! mxIsDouble(prhs[1]) ||
        (mxGetNumberOfDimensions(prhs[1]) != 2) ||
        (mxGetM(prhs[1]) != 1) ||
        (mxGetN(prhs[1]) != 1))
    {
        mexErrMsgIdAndTxt("Images:cq:secondArgMustBeDoubleScalar",
                          "%s","Second argument must be a double scalar.");
    }

    num_colors = (int) mxGetScalar(prhs[1]);
    if (num_colors < 0)
    {
        mexErrMsgIdAndTxt("Images:cq:numColorsMustBeNonNegative",
                          "%s","NUM_COLORS cannot be negative.");
    }
    if (num_colors > MAXCOLORS)
    {
        mexErrMsgIdAndTxt("Images:cq:tooManyColors",
                          "%s","Too many colors specified.");
    }
    
    return(num_colors);
}

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const int *size;
    int num_pixels;
    uint8_T *image_bytes_red;
    uint8_T *image_bytes_green;
    uint8_T *image_bytes_blue;
    uint8_T *lut_red;
    uint8_T *lut_green;
    uint8_T *lut_blue;
    mxArray *out_image;
    mxArray *out_image_8;
    uint16_T *out_pr;
    uint8_T *out_pr_8;
    int num_colors;
    uint8_T *map_bytes;
    uint8_T *map_red;
    uint8_T *map_green;
    uint8_T *map_blue;
    int k;
    bool compute_output_image;

    num_colors = check_inputs(nrhs, prhs);

    lut_red = (uint8_T *) mxMalloc(num_colors * sizeof(*lut_red));
    lut_green = (uint8_T *) mxMalloc(num_colors * sizeof(*lut_green));
    lut_blue = (uint8_T *) mxMalloc(num_colors * sizeof(*lut_blue));

    size = mxGetDimensions(prhs[0]);
    num_pixels = size[0] * size[1];
    image_bytes_red = (uint8_T *) mxGetData(prhs[0]);
    image_bytes_green = image_bytes_red + num_pixels;
    image_bytes_blue = image_bytes_red + 2*num_pixels;

    out_image = mxCreateNumericMatrix(size[0], size[1], mxUINT16_CLASS, 
                                      mxREAL);
    out_pr = (uint16_T *) mxGetData(out_image);

    compute_output_image = (nlhs > 1);

    num_colors = quantize_color(image_bytes_red, image_bytes_green,
                                image_bytes_blue, num_pixels,
                                lut_red, lut_green, lut_blue, num_colors,
                                out_pr, compute_output_image);

    plhs[0] = mxCreateNumericMatrix(num_colors, 3, mxUINT8_CLASS, mxREAL);
    map_bytes = (uint8_T *) mxGetData(plhs[0]);
    map_red = map_bytes;
    map_green = map_bytes + num_colors;
    map_blue = map_bytes + 2*num_colors;
    for (k = 0; k < num_colors; k++)
    {
        map_red[k] = lut_red[k];
        map_green[k] = lut_green[k];
        map_blue[k] = lut_blue[k];
    }
    
    mxFree(lut_red);
    mxFree(lut_green);
    mxFree(lut_blue);

    if (nlhs > 1)
    {
        if (num_colors > 256)
        {
            plhs[1] = out_image;
        }
        else
        {
            out_image_8 = mxCreateNumericMatrix(size[0], size[1],
                                                mxUINT8_CLASS, mxREAL);
            out_pr_8 = (uint8_T *) mxGetData(out_image_8);
            for (k = 0; k < size[0]*size[1]; k++)
            {
                out_pr_8[k] = (uint8_T) out_pr[k];
            }
            
            mxDestroyArray(out_image);
            
            plhs[1] = out_image_8;
        }
    }
    else
    {
        mxDestroyArray(out_image);
    }
}

    

        
    
                                
    
