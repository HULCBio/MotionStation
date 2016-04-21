function [X, junk] = readfits(filename)
%READFITS Read image data from a FITS file.
%   A = READFITS(FILENAME) reads the unscaled data from the primary HDU
%   of a FITS file.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:45 $

X = fitsread(filename, 'raw');
junk = [];
