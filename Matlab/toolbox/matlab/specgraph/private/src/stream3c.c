/* Copyright 1984-2002 The MathWorks, Inc.  */

/*

  stream3c.c   2D and 3D streamline MEX file
  The calling syntax is:

      verts = stream3c( x,y,z,    u,v,w,  sx,sy,sz, step, maxvert)
      verts = stream3c( [],[],[], u,v,w,  sx,sy,sz, step, maxvert)
      verts = stream3c( x,y,[],   u,v,[], sx,sy,[], step, maxvert)
      verts = stream3c( [],[],[], u,v,[], sx,sy,[], step, maxvert)

*/

static char rcsid[] = "$Revision: 1.8 $";

#include <math.h>
#include <stdlib.h>
#include <memory.h>
#include "mex.h"
 

/* Input Arguments */


#define	X_IN	    prhs[0]
#define	Y_IN	    prhs[1]
#define	Z_IN	    prhs[2]
#define	U_IN	    prhs[3]
#define	V_IN	    prhs[4]
#define	W_IN	    prhs[5]
#define	SX_IN	    prhs[6]
#define	SY_IN	    prhs[7]
#define	SZ_IN	    prhs[8]
#define	STEP_IN	    prhs[9]
#define	MAXVERT_IN  prhs[10]

#ifndef NULL
#define NULL 0
#endif

/* Output Arguments */

#define	V_OUT plhs[0]


int vertLimit;
double *verts;
int allocIncrement=2000;

/************************* allocVertArray **************************/
/* 
 * This subroutine allocates memory for the vertex array
 */
void 
allocVertArray()
{
    vertLimit += allocIncrement;
    if (verts==NULL) 
      {
	  /* use malloc for the first time */
	  if ((verts = (double *) malloc(vertLimit * 3 * sizeof(double))) == NULL) 
	    {
		mexErrMsgTxt("not enough memory to store vertices\n");
	    }
      }
    else 
      {
	  double *oldVerts = verts;
	  /* use realloc from now on */
	  if ((verts = (double *) realloc(verts, vertLimit * 3 * sizeof(double))) == NULL) 
	    {
		if (oldVerts)
		  free(oldVerts);
		mexErrMsgTxt("not enough memory to store vertices\n");
	    }
      }
}
	
#define GETX2(X) xvec[(X)]
#define GETY2(Y) yvec[(Y)]

#define GETU2(X,Y) ugrid[(Y) + ydim*(X)]
#define GETV2(X,Y) vgrid[(Y) + ydim*(X)]
#define GETW2(X,Y) wgrid[(Y) + ydim*(X)]

/*
 * 2D streamline(u,v,sx,sy)
 */
int
traceStreamUV(double *ugrid, double *vgrid,
	      int xdim, int ydim, 
	      double sx, double sy,
	      double step, int maxVert)
{
    int numVerts = 0;
    double x = sx-1, y = sy-1;
    int ix, iy;
    double xfrac, yfrac, ui, vi;
    double a,b,c,d, imax;

    while(1)
      {
	  /* if outside of the volume, done */
          if (x<0 || x>xdim-1 ||
              y<0 || y>ydim-1 ||
	      numVerts>=maxVert)
	    break;
	  
	  ix = (int)x;
	  iy = (int)y;
	  if (ix==xdim-1) ix--;
	  if (iy==ydim-1) iy--;
	  xfrac = x-ix;
	  yfrac = y-iy;

	  /* weights for linear interpolation */
	  a=(1-xfrac)*(1-yfrac);
	  b=(  xfrac)*(1-yfrac);
	  c=(1-xfrac)*(  yfrac);
	  d=(  xfrac)*(  yfrac);
	  
	  /* allocate if necessary and build up output array */
	  if ( numVerts+1 >= vertLimit ) 
	    allocVertArray();
	  verts[2*numVerts + 0] = x+1;
	  verts[2*numVerts + 1] = y+1;

	  /* if already been here, done */
	  if (numVerts>=2)
	    if (verts[2*numVerts + 0] == verts[2*(numVerts-2) + 0] &&
		verts[2*numVerts + 1] == verts[2*(numVerts-2) + 1])
	      break;
	  
	  numVerts++;
	  
		       
	  /* interpolate the vector data */
	  ui = 
	    GETU2(ix,  iy  )*a + GETU2(ix+1,iy  )*b +
	    GETU2(ix,  iy+1)*c + GETU2(ix+1,iy+1)*d;
	  vi = 
	    GETV2(ix,  iy  )*a + GETV2(ix+1,iy  )*b +
	    GETV2(ix,  iy+1)*c + GETV2(ix+1,iy+1)*d;
	  
	  /* calculate step size, if 0, done */
	  if (fabs(ui)>fabs(vi)) imax=fabs(ui); else imax=fabs(vi);
	  if (imax==0) break;
	  
	  imax = step/imax;
	  
	  ui *= imax;
	  vi *= imax;

	  /* update the current position */
	  x += ui;
	  y += vi;
	  
      }
    
    return(numVerts);
}

/*
 * 2D streamline(x,y,u,v,sx,sy)
 */
int
traceStreamXYUV(double *xvec, double *yvec,
		double *ugrid, double *vgrid,
	       int xdim, int ydim, 
	       double sx, double sy,
	      double step, int maxVert)
{
    int numVerts = 0;
    double x = sx-1, y = sy-1;
    int ix, iy;
    double x0,x1,y0,y1,xi,yi,dx,dy;
    double xfrac, yfrac, ui, vi;
    double a,b,c,d, imax;

    while(1)
      {
          if (x<0 || x>xdim-1 ||
              y<0 || y>ydim-1 ||
	      numVerts>=maxVert)
	    break;
	  
	  ix = (int)x;
	  iy = (int)y;
	  if (ix==xdim-1) ix--;
	  if (iy==ydim-1) iy--;
	  xfrac = x-ix;
	  yfrac = y-iy;

	  a=(1-xfrac)*(1-yfrac);
	  b=(  xfrac)*(1-yfrac);
	  c=(1-xfrac)*(  yfrac);
	  d=(  xfrac)*(  yfrac);
	  
	  if ( numVerts+1 >= vertLimit ) 
	    allocVertArray();
	  
	  x0 = GETX2(ix); x1 = GETX2(ix+1);
	  y0 = GETY2(iy); y1 = GETY2(iy+1);
	  xi = x0*(1-xfrac) + x1*xfrac;
	  yi = y0*(1-yfrac) + y1*yfrac;
	  
	  verts[2*numVerts + 0] = xi;
	  verts[2*numVerts + 1] = yi;
	  if (numVerts>=2)
	    if (verts[2*numVerts + 0] == verts[2*(numVerts-2) + 0] &&
		verts[2*numVerts + 1] == verts[2*(numVerts-2) + 1])
	      break;
	  numVerts++;
	  
	  ui = 
	    GETU2(ix,  iy  )*a + GETU2(ix+1,iy  )*b +
	    GETU2(ix,  iy+1)*c + GETU2(ix+1,iy+1)*d;
	  vi = 
	    GETV2(ix,  iy  )*a + GETV2(ix+1,iy  )*b +
	    GETV2(ix,  iy+1)*c + GETV2(ix+1,iy+1)*d;
	  
	  dx = x1-x0;
	  dy = y1-y0;
	  if (dx) ui /= dx;
	  if (dy) vi /= dy;
	  
	  if (fabs(ui)>fabs(vi)) imax=fabs(ui); else imax=fabs(vi);
	  if (imax==0) break;
	  
	  imax = step/imax;
	  
	  ui *= imax;
	  vi *= imax;
	  
	  x += ui;
	  y += vi;
	  
      }
    
    return(numVerts);
}


#define GETX3(X) xvec[(X)]
#define GETY3(Y) yvec[(Y)]
#define GETZ3(Z) zvec[(Z)]

#define GETU3(X,Y,Z) ugrid[(Y) + ydim*(X) + xdim*ydim*(Z)]
#define GETV3(X,Y,Z) vgrid[(Y) + ydim*(X) + xdim*ydim*(Z)]
#define GETW3(X,Y,Z) wgrid[(Y) + ydim*(X) + xdim*ydim*(Z)]



/*
 * 3D streamline(u,v,w,sx,sy,sz)
 */
int
traceStreamUVW(double *ugrid, double *vgrid, double *wgrid, 
	       int xdim, int ydim, int zdim, 
	       double sx, double sy, double sz,
	       double step, int maxVert)
{
    int numVerts = 0;
    double x = sx-1, y = sy-1, z = sz-1;
    int ix, iy, iz;
    double xfrac, yfrac, zfrac, ui, vi, wi;
    double a,b,c,d,e,f,g,h, imax;

    while(1)
      {
          if (x<0 || x>xdim-1 ||
              y<0 || y>ydim-1 ||
	      z<0 || z>zdim-1 ||
	      numVerts>=maxVert)
	    break;
	  
	  ix = (int)x;
	  iy = (int)y;
	  iz = (int)z;
	  if (ix==xdim-1) ix--;
	  if (iy==ydim-1) iy--;
	  if (iz==zdim-1) iz--;
	  xfrac = x-ix;
	  yfrac = y-iy;
	  zfrac = z-iz;

	  a=(1-xfrac)*(1-yfrac)*(1-zfrac);
	  b=(  xfrac)*(1-yfrac)*(1-zfrac);
	  c=(1-xfrac)*(  yfrac)*(1-zfrac);
	  d=(  xfrac)*(  yfrac)*(1-zfrac);
	  e=(1-xfrac)*(1-yfrac)*(  zfrac);
	  f=(  xfrac)*(1-yfrac)*(  zfrac);
	  g=(1-xfrac)*(  yfrac)*(  zfrac);
	  h=(  xfrac)*(  yfrac)*(  zfrac);

	  
	  if ( numVerts+1 >= vertLimit ) 
	    allocVertArray();
	  verts[3*numVerts + 0] = x+1;
	  verts[3*numVerts + 1] = y+1;
	  verts[3*numVerts + 2] = z+1;
	  if (numVerts>=2)
	    if (verts[3*numVerts + 0] == verts[3*(numVerts-2) + 0] &&
		verts[3*numVerts + 1] == verts[3*(numVerts-2) + 1] &&
		verts[3*numVerts + 2] == verts[3*(numVerts-2) + 2])
	      break;
	  numVerts++;
	  
	  
	  ui = 
	    GETU3(ix,  iy,  iz  )*a + GETU3(ix+1,iy,  iz  )*b +
	    GETU3(ix,  iy+1,iz  )*c + GETU3(ix+1,iy+1,iz  )*d +
	    GETU3(ix,  iy,  iz+1)*e + GETU3(ix+1,iy,  iz+1)*f + 
	    GETU3(ix,  iy+1,iz+1)*g + GETU3(ix+1,iy+1,iz+1)*h;
	  vi = 
	    GETV3(ix,  iy,  iz  )*a + GETV3(ix+1,iy,  iz  )*b +
	    GETV3(ix,  iy+1,iz  )*c + GETV3(ix+1,iy+1,iz  )*d +
	    GETV3(ix,  iy,  iz+1)*e + GETV3(ix+1,iy,  iz+1)*f + 
	    GETV3(ix,  iy+1,iz+1)*g + GETV3(ix+1,iy+1,iz+1)*h;
	  wi = 
	    GETW3(ix,  iy,  iz  )*a + GETW3(ix+1,iy,  iz  )*b +
	    GETW3(ix,  iy+1,iz  )*c + GETW3(ix+1,iy+1,iz  )*d +
	    GETW3(ix,  iy,  iz+1)*e + GETW3(ix+1,iy,  iz+1)*f + 
	    GETW3(ix,  iy+1,iz+1)*g + GETW3(ix+1,iy+1,iz+1)*h;
	  
	  if (fabs(ui)>fabs(vi)) imax=fabs(ui); else imax=fabs(vi);
	  if (fabs(wi)>imax) imax=fabs(wi);
	  if (imax==0) break;
		   
	  imax = step/imax;

	  ui *= imax;
	  vi *= imax;
	  wi *= imax;

	  x += ui;
	  y += vi;
	  z += wi;
	  
	  
      }
    
    return(numVerts);
}


/*
 * 3D streamline(x,y,z,u,v,w,sx,sy,sz)
 */
int
traceStreamXYZUVW(double *xvec, double *yvec, double *zvec, 
		  double *ugrid, double *vgrid, double *wgrid, 
		  int xdim, int ydim, int zdim, 
		  double sx, double sy, double sz,
		  double step, int maxVert)
{
    int numVerts = 0;
    double x = sx-1, y = sy-1, z = sz-1;
    int ix, iy, iz;
    double xfrac, yfrac, zfrac, ui, vi, wi;
    double x0,x1,y0,y1,z0,z1,xi,yi,zi,dx,dy,dz;
    double a,b,c,d,e,f,g,h, imax;

    while(1)
      {
          if (x<0 || x>xdim-1 ||
              y<0 || y>ydim-1 ||
	      z<0 || z>zdim-1 ||
	      numVerts>=maxVert)
	    break;
	  
	  ix = (int)x;
	  iy = (int)y;
	  iz = (int)z;
	  if (ix==xdim-1) ix--;
	  if (iy==ydim-1) iy--;
	  if (iz==zdim-1) iz--;
	  xfrac = x-ix;
	  yfrac = y-iy;
	  zfrac = z-iz;

	  a=(1-xfrac)*(1-yfrac)*(1-zfrac);
	  b=(  xfrac)*(1-yfrac)*(1-zfrac);
	  c=(1-xfrac)*(  yfrac)*(1-zfrac);
	  d=(  xfrac)*(  yfrac)*(1-zfrac);
	  e=(1-xfrac)*(1-yfrac)*(  zfrac);
	  f=(  xfrac)*(1-yfrac)*(  zfrac);
	  g=(1-xfrac)*(  yfrac)*(  zfrac);
	  h=(  xfrac)*(  yfrac)*(  zfrac);
	  
	  
	  if ( numVerts+1 >= vertLimit ) 
	    allocVertArray();
	  
	  x0 = GETX3(ix); x1 = GETX3(ix+1);
	  y0 = GETY3(iy); y1 = GETY3(iy+1);
	  z0 = GETZ3(iz); z1 = GETZ3(iz+1);
	  xi = x0*(1-xfrac) + x1*xfrac;
	  yi = y0*(1-yfrac) + y1*yfrac;
	  zi = z0*(1-zfrac) + z1*zfrac;

	  verts[3*numVerts + 0] = xi;
	  verts[3*numVerts + 1] = yi;
	  verts[3*numVerts + 2] = zi;
	  if (numVerts>=2)
	    if (verts[3*numVerts + 0] == verts[3*(numVerts-2) + 0] &&
		verts[3*numVerts + 1] == verts[3*(numVerts-2) + 1] &&
		verts[3*numVerts + 2] == verts[3*(numVerts-2) + 2])
	      break;
	  numVerts++;
	  
	  
	  ui = 
	    GETU3(ix,  iy,  iz  )*a + GETU3(ix+1,iy,  iz  )*b +
	    GETU3(ix,  iy+1,iz  )*c + GETU3(ix+1,iy+1,iz  )*d +
	    GETU3(ix,  iy,  iz+1)*e + GETU3(ix+1,iy,  iz+1)*f + 
	    GETU3(ix,  iy+1,iz+1)*g + GETU3(ix+1,iy+1,iz+1)*h;
	  vi = 
	    GETV3(ix,  iy,  iz  )*a + GETV3(ix+1,iy,  iz  )*b +
	    GETV3(ix,  iy+1,iz  )*c + GETV3(ix+1,iy+1,iz  )*d +
	    GETV3(ix,  iy,  iz+1)*e + GETV3(ix+1,iy,  iz+1)*f + 
	    GETV3(ix,  iy+1,iz+1)*g + GETV3(ix+1,iy+1,iz+1)*h;
	  wi = 
	    GETW3(ix,  iy,  iz  )*a + GETW3(ix+1,iy,  iz  )*b +
	    GETW3(ix,  iy+1,iz  )*c + GETW3(ix+1,iy+1,iz  )*d +
	    GETW3(ix,  iy,  iz+1)*e + GETW3(ix+1,iy,  iz+1)*f + 
	    GETW3(ix,  iy+1,iz+1)*g + GETW3(ix+1,iy+1,iz+1)*h;
	  
	  dx = x1-x0;
	  dy = y1-y0;
	  dz = z1-z0;
	  if (dx) ui /= dx;
	  if (dy) vi /= dy;
	  if (dz) wi /= dz; 

	  if (fabs(ui)>fabs(vi)) imax=fabs(ui); else imax=fabs(vi);
	  if (fabs(wi)>imax) imax=fabs(wi);
	  if (imax==0) break;
	  
	  imax = step/imax;
	  
	  ui *= imax;
	  vi *= imax;
	  wi *= imax;

	  x += ui;
	  y += vi;
	  z += wi;
	  
	  
      }
    
    return(numVerts);
}


void mexFunction(
		 int		nlhs,
		 mxArray	*plhs[],
		 int		nrhs,
		 const mxArray	*prhs[]
		 )
{
    double    *x, *y, *z, *u, *v, *w, *sx, *sy, *sz, *step, *maxVert;
    int  xSize, ySize, zSize, ncols=0;
    double	*vOut;
    const int *dims;
    int numVerts;
    
    /* Check for proper number of arguments */
    
    if (nrhs != 11) 
      mexErrMsgTxt("stream3c requires 11 input arguments. verts = stream3c( x,y,z, u,v,w, sx,sy,sz, step, maxVert )");
    else if (nlhs > 2) 
      mexErrMsgTxt("stream3c requires 1 output argument. verts = stream3c( x,y,z, u,v,w, sx,sy,sz, step, maxVert  )");

    x = mxGetPr( X_IN );
    y = mxGetPr( Y_IN );
    z = mxGetPr( Z_IN );
    u = mxGetPr( U_IN );
    v = mxGetPr( V_IN );
    w = mxGetPr( W_IN );
    sx = mxGetPr( SX_IN );
    sy = mxGetPr( SY_IN );
    sz = mxGetPr( SZ_IN );
    step    = mxGetPr( STEP_IN    );
    maxVert = mxGetPr( MAXVERT_IN );
    
    dims = mxGetDimensions(U_IN);
    xSize = dims[1];
    ySize = dims[0];
    if (xSize <= 1 || ySize <= 1) 
      mexErrMsgTxt("stream3c requires that all three dimensions be greater than 1");

    vertLimit = numVerts = 0;
    verts = NULL;
    if (w)
      { /* 3D */
	  ncols = 3;
	  zSize = dims[2];
	  if (zSize <= 1) 
	    mexErrMsgTxt("stream3c requires that all three dimensions be greater than 1");
	  if (x)
	    numVerts = traceStreamXYZUVW(x,y,z,u,v,w,xSize, ySize, zSize, *sx, *sy, *sz, *step, (int)(*maxVert));
	  else
	    numVerts = traceStreamUVW   (      u,v,w,xSize, ySize, zSize, *sx, *sy, *sz, *step, (int)(*maxVert));
      }
    else
      { /* 2D */
	  ncols = 2;
	  if (x)
	    numVerts = traceStreamXYUV(x,y,u,v,xSize, ySize, *sx, *sy, *step, (int)(*maxVert));
	  else 
	    numVerts = traceStreamUV  (    u,v,xSize, ySize, *sx, *sy, *step, (int)(*maxVert));
	  
      }
    
    /* Create matrices for the return arguments */
    V_OUT = mxCreateDoubleMatrix( ncols, numVerts,   mxREAL );
    
    /* Assign pointers to the various parameters */
    vOut = mxGetPr( V_OUT );
    
    /* compy the results into the output parameters*/
    memcpy((char *)vOut, (char *)verts, numVerts*ncols*sizeof(double));

    if (verts)
      free(verts);
    
}


