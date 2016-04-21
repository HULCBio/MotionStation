//////////////////////////////////////////////////////////////////////////////
// boundaries.cpp
//
// This file contains core boundary tracing routines used by bwboundaries.m
// and bwtraceboundary.m
//
// $Revision: 1.1.6.2 $  $Date: 2003/01/26 05:57:45 $
// Copyright 1993-2003 The MathWorks, Inc.
//////////////////////////////////////////////////////////////////////////////
#include <math.h>
#include "boundaries.h"

static char rcsid[] = "$Id: boundaries.cpp,v 1.1.6.2 2003/01/26 05:57:45 batserve Exp $";

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
Boundaries::Boundaries()
{
    //Initialize member variables
    fNumCols        = INVALID;
    fNumRows        = INVALID;
    fConn           = INVALID;
    fStartMarker    = INVALID;
    fBoundaryMarker = INVALID;
    fNextSearchDir  = INVALID;
    fOffsets[0]     = INVALID;
    fVOffsets[0]    = INVALID;

    fScratchLength = INITIAL_SCRATCH_LENGTH;

    //Initialize scratch space in which to record the boundary pixels
    fScratch = (int *)mxCalloc(fScratchLength, sizeof(int));
    //let Matlab know that we are handling this block of memory
    mexMakeMemoryPersistent(fScratch);
};

//////////////////////////////////////////////////////////////////////////////
// Note:  If the class is initialized statically, the destructor will be 
// called on matlab exit or when matlab's "clear" function is used
//////////////////////////////////////////////////////////////////////////////
Boundaries::~Boundaries()
{
    if(fScratch)
        mxFree(fScratch);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
mxArray *Boundaries::findBoundaries(double *labelMatrix)
{
    mxAssert( (fNumCols != INVALID),
              ERR_STRING("Boundaries::fNumCols","findBoundaries()"));

    mxAssert( (fNumRows != INVALID),
              ERR_STRING("Boundaries::fNumRows","FindBoundaries()"));

    mxAssert( (fConn != INVALID),
              ERR_STRING("Boundaries::fConn","findBoundaries()"));

    double *pLabelMatrix = padBuffer(labelMatrix);
    int     numElements  = fNumRows*fNumCols;
    double  numRegions   = 0.0;

    for (int i=0; i<numElements; i++)
    {
        if (pLabelMatrix[i] > numRegions)
        {
            numRegions = pLabelMatrix[i];
        }
    }

    mxArray *B = NULL;
    if(numRegions > 0.0)
    {
        int ndims = 2; int dims[2] = {(int)numRegions, 1};
        B = mxCreateCellArray(ndims, dims);
    }
    else
    {
        int ndims = 2; int dims[2] = {0, 0}; //Return empty cell array
        B = mxCreateCellArray(ndims, dims);
        return(B);
    }

    //prepare lookup tables used for tracing boundaries
    //This method only supports double input
    initTraceLUTs(mxDOUBLE_CLASS);
    setNextSearchDirection();

    int idx;
    int which;
    for (int c=1; c < fNumCols-1; c++)
    {
        for(int r=1; r < fNumRows-1; r++)
        {
            idx = fNumRows*c + r;
            which = (int)pLabelMatrix[idx]-1;
            
            if (pLabelMatrix[idx] > 0 && pLabelMatrix[idx-1] == 0 &&
                mxGetCell(B, which) == NULL )
            {
                //We've found the start of the next boundary
                mxArray *boundary = traceBoundary(pLabelMatrix, idx);
                mxSetCell(B, which, boundary);
            }            
        }
    }

    //Release the temporary image
    mxFree(pLabelMatrix);

    return(B);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
mxArray *Boundaries::traceBoundary(uint8_T  *bwImage, 
                                   int       startRow,
                                   int       startCol,
                                   int       firstStep,
                                   tdir_T    dir,
                                   int       maxNumPoints)
{
    mxAssert( (fNumCols != INVALID),
              ERR_STRING("Boundaries::fNumCols","traceBoundary()"));

    mxAssert( (fNumRows != INVALID),
              ERR_STRING("Boundaries::fNumRows","traceBoundary()"));

    mxAssert( (fConn != INVALID),
              ERR_STRING("Boundaries::fConn","traceBoundary()"));

    mxArray *boundary = NULL;

    uint8_T *pBWImage = padBuffer(bwImage);

    //Convert the starting point to linear index; 
    //take into account the initial zero padding
    int idx = startCol*fNumRows + startRow;

    //prepare lookup tables used for tracing boundaries
    initTraceLUTs(mxLOGICAL_CLASS, dir);

    //Check that the starting point is on a boundary
    if(isBoundaryPixel(pBWImage,idx))
    {
        //Find the next pixel in the chain thus establishing 
        //a valid first step;  the step specified by the user
        //could have led into the object
        setNextSearchDirection(pBWImage, idx, firstStep, dir);
        boundary = traceBoundary(pBWImage, idx, maxNumPoints);
    }
    else
    {
        boundary = mxCreateDoubleMatrix(0,0,mxREAL); //fail
    }

    //Release the temporary image
    mxFree(pBWImage);
    
    return(boundary);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
bool Boundaries::isBoundaryPixel(uint8_T *bwImage, int idx)
{
    mxAssert( fVOffsets[0] != INVALID, "fVOffsets[] must be calculated");

    bool isBoundaryPix = false;

    //First, make sure that it's not a background pixel, otherwise it's
    //an automatic failure
    if(bwImage[idx])
    {
        //Make sure that the pixel is not in the interior of the object
        int numVOffsets = (fConn == 4) ? 8 : 4;
        for (int i=0; i<numVOffsets; i++)
        {
            if(!bwImage[idx+fVOffsets[i]])
            {
                //If there was at least one background pixel abuting
                //pixel under test, then we do have a boundary pixel.
                isBoundaryPix = true;
                break;
            }
        }
    }
    
    return(isBoundaryPix);
}

//////////////////////////////////////////////////////////////////////////////
// Given an initial boundary pixel and an initial 'best guess' search
// direction, this method verifies that the best guess is valid and if it
// is not, then it finds the proper direction.
//
// NOTE: setNextSearchDirection method assumes that idx points to a valid
//       boundary pixel. It's the user's responsibility to make sure that
//       this is the case
//
//       The default input values are used by findBoundaries() method:
//       they are:  *bwImage = NULL, idx = 0, firstStep = 0, dir = clockwise
//////////////////////////////////////////////////////////////////////////////
void Boundaries::setNextSearchDirection(uint8_T  *bwImage, int idx, 
                                        int firstStep, tdir_T dir)
{
    mxAssert( (fConn != INVALID),
              ERR_STRING("Boundaries::fConn","setNextSearchDirection()"));
    mxAssert( fOffsets[0] != INVALID, "fOffsets[] must be calculated");

    if(bwImage == NULL) //Called from findBoundaries()
    {
        //next search direction depends on trace direction and connectivity
        fNextSearchDir = (dir == clockwise) ? 1 : ((fConn == 8) ? 7 : 3);
    }
    else //Make sure that the user specified valid starting direction
    {
        fNextSearchDir = 0; //initialize
        for (int clockIdx=firstStep; clockIdx<firstStep+fConn; clockIdx++)
        {
            //Convert clockwise idx to counterclockwise index so that
            //we don't have to write two "for" loops
            int tmp = 2*firstStep - clockIdx; //linear index which might be <0
            int counterIdx = (tmp > 0) ? tmp :fConn+tmp; //convert to positive

            //Set current index depending on the tracing direction
            int currentCircIdx = (dir == clockwise) ? clockIdx : counterIdx;
            currentCircIdx %= fConn; //convert linear index to circular index
            
            int offset = idx + fOffsets[currentCircIdx];
            
            if(isBoundaryPixel(bwImage, offset))
            {
                //If we took one step back, is there a background pixel,
                //as there should be?  If there isn't then we can't make
                //this direction to be our first step because the algorithm
                //would fail.
                int previousPixelIdx = (dir == clockwise) ?
                    currentCircIdx-1 : currentCircIdx+1;
                if(previousPixelIdx < 0) previousPixelIdx+=fConn;

                if(!bwImage[idx + fOffsets[previousPixelIdx]])
                {
                    //Found a proper border pixel; let's use this direction
                    fNextSearchDir = currentCircIdx;
                    break;
                }
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////////
//initTraceLUTs initilizes the lookup tables and other initial values used by
//the traceBoundaries template method.
//////////////////////////////////////////////////////////////////////////////
void Boundaries::initTraceLUTs(mxClassID classID,
                               tdir_T    dir)
{
    mxAssert( (fNumRows != INVALID),
              ERR_STRING("Boundaries::fNumRows","initTraceLUTs()"));

    mxAssert( (fConn != INVALID),
              ERR_STRING("Boundaries::fConn","initTraceLUTs()"));


    switch(classID)
    {
      case(mxLOGICAL_CLASS):
        fStartMarker = START_UINT8;
        fBoundaryMarker = BOUNDARY_UINT8;
        break;
      case(mxDOUBLE_CLASS):
        fStartMarker = START_DOUBLE;
        fBoundaryMarker = BOUNDARY_DOUBLE;
        break;
      default:
        //Should never get here
        mexErrMsgIdAndTxt("Images:boundaries:unsuppDataType", "%s",
                          "Unsupported data type.");
        break;
    }

    //Compute the linear indexing offsets to take us from a pixel to its
    //neighbors.  
    int  M = fNumRows;
    if(fConn == 8)
    {
        //Order is: [N, NE, E, SE, S, SW, W, NW];
        fOffsets[0]=-1;fOffsets[1]= M-1;fOffsets[2]=  M;fOffsets[3]= M+1;
        fOffsets[4]= 1;fOffsets[5]=-M+1;fOffsets[6]= -M;fOffsets[7]=-M-1;

        //Offsets used for testing if the pixel belongs to a boundary;
        //see isBoundaryPixel()
        fVOffsets[0]=-1;fVOffsets[1]=M;fVOffsets[2]=1;fVOffsets[3]=-M;        
    }
    else
    {
        //Order is [N, E, S, W]
        fOffsets[0]=-1;fOffsets[1]=M;fOffsets[2]=1;fOffsets[3]=-M;

        //Offsets used for testing if the pixel belongs to a boundary
        fVOffsets[0]=-1;fVOffsets[1]= M-1;fVOffsets[2]=  M;fVOffsets[3]= M+1;
        fVOffsets[4]= 1;fVOffsets[5]=-M+1;fVOffsets[6]= -M;fVOffsets[7]=-M-1;
    }
        
    static int  ndl8c[8] = {1,2,3,4,5,6,7,0};
    static int  nsdl8c[8] = {7,7,1,1,3,3,5,5};

    static int  ndl4c[4] = {1,2,3,0};
    static int nsdl4c[4] = {3,0,1,2};

    static int  ndl8cc[8] = {7,0,1,2,3,4,5,6};
    static int nsdl8cc[8] = {1,3,3,5,5,7,7,1};

    static int  ndl4cc[4] = {3,0,1,2};
    static int nsdl4cc[4] = {1,2,3,0};

    //fNextDirectionLut is a lookup table.  Given that we just looked at
    //neighbor in a given direction, which neighbor do we look at next?

    //fNextSearchDirectionLut is another lookup table.  
    //Given the direction from pixel k to pixel k+1, what is the direction 
    //to start with when examining the neighborhood of pixel k+1?

    if(dir == clockwise)
    {
        fNextDirectionLut = (fConn == 8) ? ndl8c :  ndl4c;
        fNextSearchDirectionLut = (fConn == 8) ? nsdl8c : nsdl4c;
    }
    else //counterclockwise
    {
        fNextDirectionLut = (fConn == 8) ? ndl8cc :  ndl4cc;
        fNextSearchDirectionLut = (fConn == 8) ? nsdl8cc : nsdl4cc;
    }    
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Boundaries::setNumCols(int numCols)
{
    //Assume that padding will occur
    fNumCols = numCols+2;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Boundaries::setNumRows(int numRows)
{
    //Assume that padding will occur
    fNumRows = numRows+2;
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void Boundaries::setConnectivity(int conn)
{
    mxAssert(conn == 4 || conn == 8, "boundaries.cpp: Connectivity must be "
             "equal either 4 or 8\n");

    fConn = conn;
}
