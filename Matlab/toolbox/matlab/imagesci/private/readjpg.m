function [A,junk] = readjpg(filename)
%READJPG Read image data from a JPEG file.
%   A = READJPG(FILENAME) reads image data from a JPEG file.
%   A is a uint8 array that is 2-D for grayscale and 2-D for RGB
%   images. 
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:48 $

[depth, msg] = jpeg_depth(filename);

if (isempty(depth))
    error('MATLAB:readjpg:unknownJPEGBitDepth', '%s', msg);
end

if (depth <= 8)
  
    A = rjpg8c(filename);
    
elseif (depth <= 12)
  
    A = rjpg12c(filename);
    
elseif (depth <= 16)
  
    A = rjpg16c(filename);
    
else
  
    error('MATLAB:readjpg:unsupportedJPEGBitDepth', ...
          'JPEG files with %d bits are not supported.', depth)
    
end

junk = [];
