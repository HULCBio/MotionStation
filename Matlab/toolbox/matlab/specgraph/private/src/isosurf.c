/* Copyright 1984-2002 The MathWorks, Inc.  */

/*

  isosurf.c   Edge-based isosurface MEX file
  The calling syntax is:

      [ v f c ] = isosurf( data, colors, val, noshare, verbose )

*/

static char rcsid[] = "$Revision: 1.10 $";

#include <math.h>
#include <stdlib.h>
#include <memory.h>
#include "mex.h"
 

/* Input Arguments */


#define	DATA_IN	    prhs[0]
#define	COLORS_IN   prhs[1]
#define	VAL_IN      prhs[2]
#define	NOSHARE_IN  prhs[3]
#define	VERBOSE_IN  prhs[4]

#ifndef NULL
#define NULL 0
#endif

/* Output Arguments */

#define	V_OUT plhs[0]
#define	F_OUT plhs[1]
#define	C_OUT plhs[2]


/* statics used for keeping track of memory allocation */
double *verts, *faces, *cols;
int doColors;
int vertLimit, faceLimit;
int allocIncrement=20000;


/******************** edge structs and globals *******************/

typedef struct {
  int    verts[2];
  int    rightEdges[3];
  int    leftEdges[3];
} EDGE_ENTRY;

EDGE_ENTRY  edge_table[12] =
{
  {  0, 1,   2,3,1,  5,8,4,  }, /* E0  */
  {  1, 3,   0,2,3,  7,9,5,  }, /* E1  */
  {  0, 2,   4,10,6, 3,1,0,  }, /* E2  */
  {  2, 3,   6,11,7, 1,0,2,  }, /* E3  */
  {  0, 4,   0,5,8,  10,6,2, }, /* E4  */
  {  1, 5,   1,7,9,  8,4,0,  }, /* E5  */
  {  2, 6,   2,4,10, 11,7,3, }, /* E6  */
  {  3, 7,   3,6,11, 9,5,1,  }, /* E7  */
  {  4, 5,   4,0,5,  9,11,10,}, /* E8  */
  {  5, 7,   5,1,7,  11,10,8,}, /* E9  */
  {  4, 6,   8,9,11, 6,2,4,  }, /* E10 */
  {  6, 7,   10,8,9, 7,3,6,  }, /* E11 */
};

typedef struct {
  int    valid;
  double val;
  int*   nextedges;
  double color;
} CUR_CELL_EDGES;

/* These two statics define the current cube*/
int numValidEdges;
CUR_CELL_EDGES curedges[12];

int XYDIM;
double DATA[8];
int  currentTriangle, currentVertex;


/************************* allocArrays **************************/
/* 
 * Thse subroutines are for allocating memory for the 
 * vertex and face arrays
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
	  if (doColors)
	    if ((cols = (double *) malloc(vertLimit     * sizeof(double))) == NULL) 
	      {
		mexErrMsgTxt("not enough memory to store colors\n");
	      }
      }
    else 
      {
	  /* use realloc from now on */
	  if ((verts = (double *) realloc(verts, vertLimit * 3 * sizeof(double))) == NULL) 
	    {
		mexErrMsgTxt("not enough memory to store vertices\n");
	    }
	   if (doColors)
	     if ((cols  = (double *) realloc(cols , vertLimit     * sizeof(double))) == NULL) 
	       {
		 mexErrMsgTxt("not enough memory to store colors\n");
	       }
      }
}

void 
allocFaceArray()
{
    faceLimit += allocIncrement;
    if (faces==NULL) 
      {
	  /* use malloc for the first time */
	  if ((faces = (double *) malloc(faceLimit * 3 * sizeof(double))) == NULL) 
	    {
		mexErrMsgTxt("not enough memory to store faces\n");
	    }
      }
    else 
      {
	  /* use realloc from now on */
	  if ((faces = (double *) realloc(faces, faceLimit * 3 * sizeof(double))) == NULL) 
	    {
		mexErrMsgTxt("not enough memory to store faces\n");
	    }
      }
}


/************************* createVertex **************************/
/* 
 * Make a new vertex if one with the same coordinates does not
 * exist.
 */
int 
createVertex( double vx, double vy, double vz, double c)
{
    if ( currentVertex > 0 )
      {
	  int i;
	  double   firstZ = verts[3*(currentVertex-1) + 2];
	  double currentZ = firstZ;
	  
	  /* 
	   * If z is greater than 2 units from the first Z stop looking
	   */
	  for( i = currentVertex; i > 0 && firstZ-currentZ <= 2.0; i-- )
	    if ( vz == ( currentZ = verts[3*(i-1) + 2] ) &&
		 vx ==              verts[3*(i-1) + 0]   &&
		 vy ==              verts[3*(i-1) + 1]      )
	      
	      return(i);
	  
      }	
    
    verts[3*currentVertex + 0] = vx;
    verts[3*currentVertex + 1] = vy;
    verts[3*currentVertex + 2] = vz;
    if (doColors) cols[currentVertex] = c;

    currentVertex++;
    return(currentVertex);
}


/************************* createTriangle **************************/
/* 
 * Make a triangle from vertex table indices
 */
void createTriangle( int index0, int index1, int index2 )
{
    faces[3*currentTriangle + 0] = index0;
    faces[3*currentTriangle + 1] = index1;
    faces[3*currentTriangle + 2] = index2;
    currentTriangle++;
}


/************************* getCoords **************************/
/*
 * For each edge generate the x,y,z coords
 */
void getCoords(int edge, double *vx, double *vy, double *vz)
{
    double val = curedges[edge].val;
    switch (edge) 
      {
	case 0:  *vx = val; *vy = 0;   *vz = 0;   break;
	case 1:  *vx = 1;   *vy = val; *vz = 0;   break;
	case 2:  *vx = 0;   *vy = val; *vz = 0;   break;
	case 3:  *vx = val; *vy = 1;   *vz = 0;   break;
	case 4:  *vx = 0;   *vy = 0;   *vz = val; break;
	case 5:  *vx = 1;   *vy = 0;   *vz = val; break;
	case 6:  *vx = 0;   *vy = 1;   *vz = val; break;
	case 7:  *vx = 1;   *vy = 1;   *vz = val; break;
	case 8:  *vx = val; *vy = 0;   *vz = 1;   break;
	case 9:  *vx = 1;   *vy = val; *vz = 1;   break;
	case 10: *vx = 0;   *vy = val; *vz = 1;   break;
	case 11: *vx = val; *vy = 1;   *vz = 1;   break;
	  
      }
}

/************************* findNextEdge **************************/
/*
 * Find the next valid edge
 */
int findNextEdge(int thisedge)
{
    int j, edge, nextedge = -1;
    
    for(j=2; j>=0; j--) 
      {
	  edge = curedges[thisedge].nextedges[j];
	  if (curedges[edge].valid)
	    {
		nextedge = edge;
		break;
	    }
      }
    
    return(nextedge);
}

#define MAKE_TRIANGLE                              \
  verts[3*currentVertex + 0] = x+vx0+1;            \
  verts[3*currentVertex + 1] = y+vy0+1;            \
  verts[3*currentVertex + 2] = z+vz0+1;            \
  if (doColors) cols[currentVertex] = c0;                        \
  currentVertex++;                                 \
  faces[3*currentTriangle + 0] = currentVertex;    \
  			                           \
  verts[3*currentVertex + 0] = x+vx1+1;            \
  verts[3*currentVertex + 1] = y+vy1+1;            \
  verts[3*currentVertex + 2] = z+vz1+1;            \
  if (doColors) cols[currentVertex] = c1;                        \
  currentVertex++;                                 \
  faces[3*currentTriangle + 1] = currentVertex;    \
 			                           \
  verts[3*currentVertex + 0] = x+vx2+1;            \
  verts[3*currentVertex + 1] = y+vy2+1;            \
  verts[3*currentVertex + 2] = z+vz2+1;            \
  if (doColors) cols[currentVertex] = c2;                        \
  currentVertex++;                                 \
  faces[3*currentTriangle + 2] = currentVertex;    \
				                   \
  currentTriangle++;

/************************* generatePolygons **************************/
/*
 * Cycle through all the valid edges, stitching together a polygon
 * and then tesselate it
 */
void generatePolygons(int x, int y, int z, int noshare)
{	
    int i,j;
    int nextedge, nedges, edges[12];
    int numEdgesProcessed=0;

    
    for(i=0; i<12 && numEdgesProcessed<numValidEdges ; i++)
      if (curedges[i].valid)
	{
	    numEdgesProcessed++;
	    edges[0]=i;
	    nedges=1;
	    while(1)
	      {
		  nextedge = findNextEdge(edges[nedges-1]);
		  if (nextedge==edges[0] || nextedge==-1 || nedges==12)
		    {
			for (j=0; j<nedges; j++)
			  curedges[edges[j]].valid=0; 
			
			if (nedges>=3)
			  {
			      /* tesselate the polygon and create vertices */
			      double vx0,vy0,vz0,c0;
			      double vx2,vy2,vz2,c2;
			      int index0,index1,index2;
			      
			      /* There will be at most 10 triangles created which means
				 there will be a maximum of 30 vertices created. This is
				 sloppy but it works.				      */
			      if ( currentVertex+30 >= vertLimit ) 
				allocVertArray();
			      if ( currentTriangle+10 >= faceLimit )
				allocFaceArray();
			      
			      if (!noshare)
				{
				    int flag=1;
				    double vx1,vy1,vz1,c1;
				    int upcounter = 2;
				    int downcounter = nedges-2;
				    getCoords(edges[0], &vx0, &vy0, &vz0);
				    getCoords(edges[1], &vx1, &vy1, &vz1);
				    getCoords(edges[nedges-1], &vx2, &vy2, &vz2);
				    c0 = curedges[edges[0]].color;
				    c1 = curedges[edges[1]].color;
				    c2 = curedges[edges[nedges-1]].color;
				    index0=createVertex(x+vx0+1, y+vy0+1, z+vz0+1,c0);
				    index1=createVertex(x+vx1+1, y+vy1+1, z+vz1+1,c1);
				    index2=createVertex(x+vx2+1, y+vy2+1, z+vz2+1,c2);
				    if (index0 != index1 && index1 != index2 && index2 != index0)
				      createTriangle(index0, index1, index2);
				    for (j=0; j<nedges-3; j++)
				      {
					  if (flag)
					    {
						flag = 0;
						index0 = index2;
						getCoords(edges[upcounter], &vx2, &vy2, &vz2);
						c2 = curedges[edges[upcounter++]].color;
						index2=createVertex(x+vx2+1, y+vy2+1, z+vz2+1, c2);
						if (index0 != index1 && index1 != index2 && index2 != index0)
						  createTriangle(index0, index1, index2);
					    }
					  else
					    {
						flag = 1;
						index1 = index2;
						getCoords(edges[downcounter], &vx2, &vy2, &vz2);
						c2 = curedges[edges[downcounter--]].color;
						index2=createVertex(x+vx2+1, y+vy2+1, z+vz2+1, c2);
						if (index0 != index1 && index1 != index2 && index2 != index0)
						  createTriangle(index0, index1, index2);
					    }
					  
				      }
				}
			      else
				{

				    int flag=1;
				    double vx1,vy1,vz1,c1;
				    int upcounter = 2;
				    int downcounter = nedges-2;
				    getCoords(edges[0], &vx0, &vy0, &vz0);
				    getCoords(edges[1], &vx1, &vy1, &vz1);
				    getCoords(edges[nedges-1], &vx2, &vy2, &vz2);
				    c0 = curedges[edges[0]].color;
				    c1 = curedges[edges[1]].color;
				    c2 = curedges[edges[nedges-1]].color;
				    MAKE_TRIANGLE;
				    
				    for (j=0; j<nedges-3; j++)
				      {
					  if (flag)
					    {
						flag = 0;
						vx0 = vx2; vy0 = vy2; vz0 = vz2; c0 = c2;
						getCoords(edges[upcounter], &vx2, &vy2, &vz2);
						c2 = curedges[edges[upcounter++]].color;
						MAKE_TRIANGLE;
					    }
					  else
					    {
						flag = 1;
						vx1 = vx2; vy1 = vy2; vz1 = vz2; c1 = c2;
						getCoords(edges[downcounter], &vx2, &vy2, &vz2);
						c2 = curedges[edges[downcounter--]].color;
						MAKE_TRIANGLE;
					    }
					  
				      }

				}
			  }
			break;
		    }
		  edges[nedges++]=nextedge;
	      }
	    
	}
}


/************************** calcEdgeValues *************************/
/*
 * Calculate where the surface intersects each edge
 */
int calcEdgeValues(double *data,int x,int y,int z,int xdim,int ydim,int zdim,double isovalue)
{
    register double *tmp;
    double val, d;
    int i, v0, v1, found, flag;
    
    tmp = data + (z*XYDIM) + (x*ydim) + y;
    
    DATA[0] = *(tmp);
    DATA[2] = *(tmp + 1);
    tmp += ydim;
    DATA[1] = *(tmp);
    DATA[3] = *(tmp + 1);
    tmp = tmp - ydim + XYDIM;
    DATA[4] = *(tmp);
    DATA[6] = *(tmp + 1);
    tmp += ydim;
    DATA[5] = *(tmp);
    DATA[7] = *(tmp + 1);
    
    
    found = 0;
    for(i=0; i<12; i++)
      {
	  v0 = edge_table[i].verts[0];
	  v1 = edge_table[i].verts[1];
	  d = DATA[v1]-DATA[v0];
	  if (d==0)
	    {
		curedges[i].val = -1.0;
		curedges[i].valid = 0;
	    }
	  else
	    {
		val = (isovalue-DATA[v0])/d;
		curedges[i].val = val;
		flag = (d<0);
		if (flag)
		  val = 1-val; 
		if (val>=0 && val<1)
		  {
		      curedges[i].nextedges = (flag ? edge_table[i].leftEdges : edge_table[i].rightEdges); 
		      curedges[i].valid = 1;
		      
		      found++;
		  }
		else
		  {
		      curedges[i].valid = 0;
		  }
	    }
      }
    
    numValidEdges=found;
    return(found>0);
}

/************************** calcEdgeColorValues *************************/
/*
 * Calculate the interpolated colors where the surface intersects each edge
 */
void calcEdgeColorValues(double *colors,int x,int y,int z,int xdim,int ydim,int zdim)
{
    register double *tmp;
    int i, v0, v1;
    
    tmp = colors + (z*XYDIM) + (x*ydim) + y;
    
    DATA[0] = *(tmp);
    DATA[2] = *(tmp + 1);
    tmp += ydim;
    DATA[1] = *(tmp);
    DATA[3] = *(tmp + 1);
    tmp = tmp - ydim + XYDIM;
    DATA[4] = *(tmp);
    DATA[6] = *(tmp + 1);
    tmp += ydim;
    DATA[5] = *(tmp);
    DATA[7] = *(tmp + 1);

    for(i=0; i<12; i++)
      if (curedges[i].valid)
	{
	  v0 = edge_table[i].verts[0];
	  v1 = edge_table[i].verts[1];
	  curedges[i].color = DATA[v0]+curedges[i].val*(DATA[v1]-DATA[v0]);
	}
}


/**************************** isoSurface ****************************/
/* 
 * Process every voxel in the volume
 */
int isoSurface(double *data, double *colors, int xSize, int ySize, int zSize, double isovalue, int noshare, int verbose)
{

  register int x,y,z;
  
  XYDIM = xSize*ySize;
  
  for (z=0;z<zSize-1;z++)
    {
        if (verbose) 
	  printf("."); 
	for (x=0;x<xSize-1;x++) 
	  for (y=0;y<ySize-1;y++)
	    if (calcEdgeValues(data,x,y,z,xSize,ySize,zSize,isovalue))
	      {
		if (doColors) calcEdgeColorValues(colors,x,y,z,xSize,ySize,zSize);
		generatePolygons(x,y,z, noshare);
	      }
    }
  
  if (verbose) 
    printf("\n"); 
  return 0;
}



/**************************************************************************/
/**************************************************************************/


void mexFunction(
		 int		nlhs,
		 mxArray	*plhs[],
		 int		nrhs,
		 const mxArray	*prhs[]
		 )
{
    double    *data, *colors, *val, *noshare, *verbose;
    const int *dims;
    int	   ndims;
    int  xSize, ySize, zSize;
    double	*vOut, *fOut, *cOut;
    
    
    /* Check for proper number of arguments */
    
    if (nrhs != 5) 
      mexErrMsgTxt("isosurf requires 4 input arguments. [v f c] = isosurf( data, isoValue, colors, noshare, verbose )");
    else if (nlhs > 3) 
      mexErrMsgTxt("isosurf requires 2 output argument. [v f c] = isosurf( data, isoValue, colors, noshare, verbose )");

    /* Check the dimensions of data It must be 3 */
    ndims = mxGetNumberOfDimensions(DATA_IN);
    if (ndims != 3) 
      mexErrMsgTxt("isosurf requires 3 dimensional data");
    
    /* Check the dimensions of data are greater than one */
    dims = mxGetDimensions(DATA_IN);
    xSize = dims[1];
    ySize = dims[0];
    zSize = dims[2];
    if (xSize <= 1 || ySize <= 1 || zSize <= 1) 
      mexErrMsgTxt("isosurf requires that all three dimensions be greater than 1");
    
    data = mxGetPr( DATA_IN );
    colors = mxGetPr( COLORS_IN );
    val  = mxGetPr( VAL_IN  );
    noshare = mxGetPr( NOSHARE_IN );
    verbose = mxGetPr( VERBOSE_IN );
    
    doColors = !!colors;
    
    if (*verbose) 
      {
	  int i;
	  printf("ISOSURFACE: Computing triangles and vertices...\n");	
	  for (i=1;i<zSize;i++) printf(" ");
	  printf("V-done\n");
      }

    currentTriangle = currentVertex = 0;
    verts = faces = cols = NULL;
    vertLimit = faceLimit = 0;
    isoSurface(data, colors, xSize, ySize, zSize, *val, (int)(*noshare), (int)(*verbose));
    if (*verbose) 
      printf("ISOSURFACE: number of vertices=%d   number of triangles=%d\n", 
	     currentVertex, currentTriangle); 
    
    /* Create matrices for the return arguments */
    V_OUT = mxCreateDoubleMatrix( 3, currentVertex,   mxREAL );
    F_OUT = mxCreateDoubleMatrix( 3, currentTriangle, mxREAL );
    if (doColors)
      C_OUT = mxCreateDoubleMatrix( 1, currentVertex, mxREAL );
    else
      C_OUT = mxCreateDoubleMatrix( 0, 0, mxREAL );
    
    
    /* Assign pointers to the various parameters */
    vOut = mxGetPr( V_OUT );
    fOut = mxGetPr( F_OUT );
    cOut = mxGetPr( C_OUT );
    
    /* copy the results into the output parameters*/
    memcpy((char *)vOut, (char *)verts, currentVertex  *3*sizeof(double));
    memcpy((char *)fOut, (char *)faces, currentTriangle*3*sizeof(double));
    if (doColors)
      memcpy((char *)cOut, (char *)cols,  currentVertex    *sizeof(double));
    
    if (verts)
      free(verts);
    if (faces)
      free(faces);
    if (cols)
      free(cols);
}


