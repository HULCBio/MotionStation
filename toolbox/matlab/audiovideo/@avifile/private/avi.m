function varargout = avi(varargin)
%AVI write AVI file
%   ID = AVI('open',FILENAME) initializes the interface to the AVIFILE routines
%   		    and returns ID, a unique integer ID corresponding to the open file
%   		    FILENAME.  The MATLAB M-file AIVFILE should be used to call this routine.
%   
%   AVI('addframe',FRAME,BITMAPINFO,FRAMENUM,FPS,QUALITY,ID, STREAMNAME) adds FRAME 
%   		    number FRAMENUM to the stream in the AVI file represented by ID.  The 
%   		    BITMAPINFO is the bitmapheader structure of the AVIFILE object.  
%   		    The FPS (frames per second) and QUALITY parameters are required by the
%   		    AVIFILE routines. STREAMNAME is a string describing the video stream.
%                   The MATLAB M-file AVIFILE/ADDFRAME should be used to call this routine.
%   
%   AVI('close',ID) finishes writing the AVI file represented by ID.  This will 
%   		    close the stream and file handles. This routine should be called by
%   		    the MATLAB M-file AVIFILE/CLOSE.
%

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:49 $

error(sprintf('Missing MEX-file %s.',mfilename));

   
