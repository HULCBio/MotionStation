function varargin = readavi(varargin)
%READAVI read frames from AVI file
%   MOVIEDATA = readavi(FILENAME,INDEX) reads from the AVI file FILENAME.  If
%   INDEX is 0, all frames in the movie are read. Otherwise, only frame number
%   INDEX is read.  READAVI returns a MATLAB structure MOVIEDATA with 
%   fields cdata and colormap.  cdata contains frame data that must be rotated 
%   and reshaped.  colormap contains the colormap if the frame is an Indexed 
%   image.  colormap must also be massaged into the correct size.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:59 $
%#mex

error(sprintf('Missing MEX-file %s.',mfilename));

