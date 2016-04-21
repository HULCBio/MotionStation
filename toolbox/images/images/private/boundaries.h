//////////////////////////////////////////////////////////////////////////////
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $
//////////////////////////////////////////////////////////////////////////////

#ifndef BOUNDARIES_H
#define BOUNDARIES_H

#include <string.h>
#include "mex.h"
#include "iptutil_cpp.h"

//Values used for marking the starting and boundary pixels.
#define START_DOUBLE     -2
#define BOUNDARY_DOUBLE  -3

#define START_UINT8       2
#define BOUNDARY_UINT8    3

#define INITIAL_SCRATCH_LENGTH 200

#define INVALID -10

typedef enum
{
    counterclockwise = 0,
    clockwise = 1
} tdir_T;

class Boundaries
{
  private:   

    //Member variables
    //////////////////
    int fNumCols;
    int fNumRows;
    int fConn;

    //Variables used by the tracing algorithm
    int  fOffsets[8];
    int  fVOffsets[8];
    int *fNextDirectionLut;
    int *fNextSearchDirectionLut;
    int  fNextSearchDir;
    int  fScratchLength;
    int *fScratch;
    int  fStartMarker;
    int  fBoundaryMarker;

    //Methods
    /////////
    void initTraceLUTs(mxClassID classID,
                       tdir_T    dir       = clockwise);

    //The defaults for this method are used by findBoundaries()
    void setNextSearchDirection(uint8_T *bwImage    = NULL, 
                                int      idx        = 0,
                                int      firstStep  = 0,
                                tdir_T   dir        = clockwise);

    bool isBoundaryPixel(uint8_T *bwImage, int idx);
    
    //Templetized Methods
    /////////////////////

    //////////////////////////////////////////////////////////////////////////
    //Adds a border of zeros to the input image so that we will not have 
    //to worry about going out of bounds while tracing objects 
    //////////////////////////////////////////////////////////////////////////
    template<typename _T>
        _T *padBuffer(_T *buff)
        {
            _T *paddedBuf = (_T *)mxCalloc(fNumRows*fNumCols, sizeof(_T));
            for(int i=0; i < fNumCols-2; i++)
            {
                memcpy(&paddedBuf[(i+1)*fNumRows+1], &buff[i*(fNumRows-2)],
                       (fNumRows-2)*sizeof(_T));
            }

            return(paddedBuf);
        }

    //////////////////////////////////////////////////////////////////////////
    //This method traces a single contour.  It takes a label matrix, linear
    //index to the initial border pixel belonging to the object that's 
    //going to be traced, and it needs to be pre-configured by invoking 
    //initializeTracer routine. It returns mxArray containing X-Y coordinates 
    //of border pixels.  
    //////////////////////////////////////////////////////////////////////////
    template<typename _T>
        mxArray *traceBoundary(_T *bwImage, int idx, int maxNumPixels=-1)
        {
            mxAssert( (fConn != -1),
                      ERR_STRING("Boundaries::fConn","traceBoundary()"));

            mxAssert( (fStartMarker != -1),
                      ERR_STRING("Boundaries::fStartMarker",
                                 "traceBoundary()"));

            mxAssert( (fBoundaryMarker != -1),
                      ERR_STRING("Boundaries::fBoundaryMarker",
                                 "traceBoundary()"));
            

            //Initialize loop variables
            fScratch[0]           = idx;
            bwImage[idx]          = fStartMarker;
            bool done             = false;
            int  numPixels        = 1;
            int  currentPixel     = idx;
            int  nextSearchDir    = fNextSearchDir;
            int  initDepartureDir = -1;
            
            while(!done)
            {
                // Find the next boundary pixel.
                int  direction      = nextSearchDir;
                bool foundNextPixel = false;

                for(int k=0; k < fConn; k++)
                {
                    //Try to locate the next pixel in the chain
                    int neighbor = currentPixel + fOffsets[direction];
                    
                    if(bwImage[neighbor])
                    {
                        //Found the next boundary pixel.
                        if(bwImage[currentPixel] == fStartMarker &&
                           initDepartureDir == -1)
                        {
                            //We are making the initial departure from the
                            //starting pixel.
                            initDepartureDir = direction;
                        }
                        else if(bwImage[currentPixel] == fStartMarker &&
                                initDepartureDir == direction)
                        {
                            //We are about to retrace our path.
                            //That means we're done.
                            done = true;
                            foundNextPixel = true;
                            break;
                        }
                        
                        //Take the next step along the boundary.
                        nextSearchDir = 
                            fNextSearchDirectionLut[direction];
                        foundNextPixel = true;
                        
                        if(fScratchLength <= numPixels)
                        {
                            // Double the scratch space.
                            fScratchLength *= 2;
                            fScratch = (int *)mxRealloc(fScratch,
                                                        fScratchLength*
                                                        sizeof(int));
                            //let Matlab know that we are handling this memory
                            mexMakeMemoryPersistent(fScratch);
                        }
                        
                        //First use numPixels as an index into scratch array,
                        //then increment it
                        fScratch[numPixels] = neighbor;
                        numPixels++;

                        //note to self: numPixels at this point will
                        //be at least 2;
                        if(numPixels == maxNumPixels)
                        {
                            done = true;
                            break;
                        }
                        
                        if(bwImage[neighbor] != fStartMarker)
                        {
                            bwImage[neighbor] = fBoundaryMarker;
                        }
                        
                        currentPixel = neighbor;
                        break;
                    }
                    
                    direction = fNextDirectionLut[direction];
                }
                
                if (!foundNextPixel)
                {
                    //If there is no next neighbor, the region must 
                    //just have a single pixel.
                    numPixels = 2;
                    fScratch[1] = fScratch[0];
                    done = true;
                }
            }

            mxArray *boundary = mxCreateDoubleMatrix(numPixels,2,mxREAL);
            //Stuff the array with proper data
            double *dataPtr = (double *)mxGetData(boundary);
            
            //Convert linear indices to row-column coordinates and
            //save them in the output mxArray. Remove the effect of zero
            //padding.
            for(int k=0; k < numPixels; k++)
            {           
                //The casts remove the bias introduced by the padding
                dataPtr[k] = (int)(fScratch[k])%fNumRows; //rows
                dataPtr[numPixels+k] = 
                    (int)((float)fScratch[k]/fNumRows); //cols
            }
            
            return boundary;
        }    
    
  public:
    
    Boundaries();
    virtual ~Boundaries();
    
    mxArray *findBoundaries(double *labelMatrix);
    mxArray *traceBoundary(uint8_T *bwImage, int startRow, 
                           int startCol, int firstStep, 
                           tdir_T dir, int maxNumPoints);
    
    //Accessor methods
    //////////////////
    void setNumCols(int numCols);
    void setNumRows(int numRows);
    void setConnectivity(int conn);
};

#endif
