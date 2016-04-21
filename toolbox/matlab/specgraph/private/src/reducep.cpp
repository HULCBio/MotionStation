/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
  This code is based on "QSlim Simplification Software"
  http://almond.srv.cs.cmu.edu/afs/cs/user/garland/www/quadrics/qslim.html
*/

static char rcsid[] = "$Revision: 1.8.4.3 $";

#include <math.h>
#include <stdlib.h>

#include "AdjModel.h"


#include "decimate.h"
#include "avars.h"

#include "mex.h"

#if defined(ARCH_GLNX86) || defined(ARCH_IBM_RS) || defined(ARCH_MAC)
#include <dlfcn.h>
#endif

void reduce_init(Model *M0, double *v, double *f, int nvin, int nfin, int verbose)
{
    int i;
    int initialVertCount;
    int initialEdgeCount;
    int initialFaceCount;
    
    //cerr << "Reading input ..." << endl;
    
    
    will_constrain_boundaries = true;
    boundary_constraint_weight = 1000;
    placement_policy = PLACE_ENDPOINTS;

    
    // create vertices
    Vec3 vec;
    for(i=0; i<nvin; i++)
      {    
	  vec[X] = v[i+0*nvin];
	  vec[Y] = v[i+1*nvin];
	  vec[Z] = v[i+2*nvin];
	  M0->in_Vertex(vec);
      }
    
    // create faces
    for(i=0; i<nfin; i++)
      M0->in_Face((int)(f[i+0*nfin]), (int)(f[i+1*nfin]), (int)(f[i+2*nfin]));
    
    M0->bounds.complete();
    
    initialVertCount = M0->vertCount();
    initialEdgeCount = M0->edgeCount();
    initialFaceCount = M0->faceCount();
    
    //cerr << "Cleaning up initial input ..." << endl;
    
    // Get rid of degenerate faces
    int fkill=0;
    for(i=0; i<M0->faceCount(); i++)
      if( !M0->face(i)->plane().isValid() )
	{
	  M0->killFace(M0->face(i));
	  //fkill++;
	}
    
    M0->removeDegeneracy(M0->allFaces());
    //
    // Get rid of unused vertices
    int vkill = 0;
    for(i=0; i<M0->vertCount(); i++)
      {
	  if( M0->vertex(i)->edgeUses().length() == 0 )
	    {
		M0->vertex(i)->kill();
		vkill++;
	    }
      }
    
    //cerr << "Input model summary:" << endl;
    //cerr << "    Vertices    : " << initialVertCount << "  -> " << M0->validVertCount-vkill << endl;
    //cerr << "    Edges       : " << initialEdgeCount << "  -> " << M0->validEdgeCount << endl;
    //cerr << "    Faces       : " << initialFaceCount << "  -> " << M0->validFaceCount-fkill << endl;
    if (verbose) 
      printf("REDUCEPATCH: Cleaned Input: Vertices=%d, Faces=%d\n",
	     M0->validVertCount-vkill,  M0->validFaceCount-fkill);	
}

void reduce_execute( Model *M0, int face_target, int verbose, double *vOut, double *fOut, int *nv, int *nf, int nvout, int nfout)
{
    int i, j;
    int uniqVerts = 0;
    int numOrigFaces,verboseIncrement;

    decimate_init(*M0, pair_selection_tolerance);

    numOrigFaces = M0->validFaceCount;
    verboseIncrement = (int) ceil((numOrigFaces-face_target)/50.0);
    
    if (verbose) 
      printf("REDUCEPATCH: Working");
    while( M0->validFaceCount > face_target 
	   && M0->validFaceCount > 0
	   /*&& decimate_min_error() < error_tolerance*/ )
      {
	if (verbose && (numOrigFaces-M0->validFaceCount)%verboseIncrement==0)
	  printf(".");
	decimate_contract(*M0);
      }    
    if (verbose) 
      printf("\n");
    
    for(i=0, j=0; i<M0->vertCount(); i++)
      {
	  if( M0->vertex(i)->isValid() )
	    {
		M0->vertex(i)->tempID = ++uniqVerts;
		const Vertex& v = *M0->vertex(i);
		vOut[j + 0*nvout] = v[X];
		vOut[j + 1*nvout] = v[Y];
		vOut[j + 2*nvout] = v[Z];
		j++;
	    }
	  else
	    M0->vertex(i)->tempID = -1;
	  
      }
    
    *nv = j;
    
    //cerr << "Output model summary:" << endl;
    //cerr << "    Vertices    : " << j << endl;

     if (verbose) 
       printf("REDUCEPATCH: Done: Vertices=%d, ",j);
     
     for(i=0, j=0; i<M0->faceCount(); i++)
      {
	if( M0->face(i)->isValid() )
	{
	    Face *f = M0->face(i);
	    Vertex *v0 = (Vertex *)f->vertex(0);
	    Vertex *v1 = (Vertex *)f->vertex(1);
	    Vertex *v2 = (Vertex *)f->vertex(2);

	    
	    fOut[j + 0*nfout] = v0->tempID;
	    fOut[j + 1*nfout] = v1->tempID;
	    fOut[j + 2*nfout] = v2->tempID;
	    j++;
	}
    }

    *nf = j;

    //cerr << "    Faces       : " << j << endl;
    
     if (verbose) 
       printf("Faces=%d\n",j);
     
    decimate_cleanup();
}


void
reduce( int target, double *v, double *f, int nvin, int nfin, int verbose, int nvout, int nfout, double *vOut, double *fOut, int *nv, int *nf)
{
    Model M0;

    reduce_init(&M0, v, f, nvin, nfin, verbose);
    reduce_execute(&M0, target, verbose, vOut, fOut, nv, nf, nvout, nfout);
}



/* Input Arguments */


#define	V_IN	 prhs[0]
#define	F_IN     prhs[1]
#define	T_IN	 prhs[2]
#define	VERBOSE_IN	 prhs[3]


/* Output Arguments */

#define	V_OUT plhs[0]
#define	F_OUT plhs[1]

void mexFunction(
		 int		nlhs,
		 mxArray	*plhs[],
		 int		nrhs,
		 const mxArray	*prhs[]
		 )
{
    double   *v, *f;
    double   *vOut, *fOut;
    int	   ndims, nv, nf, nvin, nfin, target, verbose, nvout, nfout;
  
    /* Check for proper number of arguments */    
    if (nrhs != 4) 
      mexErrMsgTxt("reducep requires 4 input arguments. [v f] = reducep(v, f, targetFaces, verbose)");
    else if (nlhs != 2) 
      mexErrMsgTxt("reducep requires 2 output argument. [v f] = reducep(v, f, targetFaces, verbose)");
    
    
    /* Check the dimensions of data It must be 2 */
    
    ndims = mxGetNumberOfDimensions(V_IN);
    if (ndims != 2) 
      mexErrMsgTxt("reducep requires 2 dimensional data");
    ndims = mxGetNumberOfDimensions(F_IN);
    if (ndims != 2) 
      mexErrMsgTxt("reducep requires 2 dimensional data");

    v = mxGetPr( V_IN );
    f = mxGetPr( F_IN );
    target = (int)(*(mxGetPr( T_IN )));
    verbose = (int)(*(mxGetPr( VERBOSE_IN )));
    
    nvin = mxGetM( V_IN );
    nfin = mxGetM( F_IN );
    
    
    nfout = target;
    nvout = min(nvin, 3*nfout);
    /* Create matrices for the return arguments */
    V_OUT = mxCreateDoubleMatrix( nvout, 3, mxREAL );
    F_OUT = mxCreateDoubleMatrix( nfout, 3, mxREAL );
    
    /* Assign pointers to the various parameters */
    vOut = mxGetPr( V_OUT );
    fOut = mxGetPr( F_OUT );
    
    reduce(target, v, f, nvin, nfin, verbose, nvout, nfout, vOut, fOut, &nv, &nf);
    
    memcpy( vOut+nv*1, vOut+nvout*1, nv*sizeof(double) );
    memcpy( vOut+nv*2, vOut+nvout*2, nv*sizeof(double) );
    mxSetM( V_OUT, nv);

    memcpy( fOut+nf*1, fOut+nfout*1, nf*sizeof(double) );
    memcpy( fOut+nf*2, fOut+nfout*2, nf*sizeof(double) );
    mxSetM( F_OUT, nf);
}


