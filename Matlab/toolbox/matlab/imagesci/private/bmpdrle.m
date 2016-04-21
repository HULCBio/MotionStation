function out = bmpdrle(in,width,height,method)
%BMPDRLE Decompress RLE-compressed data from a BMP file.
%   OUT = BMPDRLE(IN,WIDTH,HEIGHT,METHOD) decodes the
%   RLE-compressed byte-stream from a BMP file.  IN is a uint8
%   vector.  WIDTH and HEIGHT are the expected dimensions of the
%   image; they are obtained by reading the BMP header
%   information.  METHOD can be either 'rle4' or 'rle8' for 4-bit
%   or 8-bit RLE compression.  OUT is a uint8 array containing
%   the decompressed image data.
%
%   Reference:  Murray and vanRyper, Encyclopedia of Graphics
%   File Formats, 2nd ed, O'Reilly, 1996.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:43 $
%#mex

error('MATLAB:bmpdrle:missingMEX', 'Missing MEX-file BMPDRLE');
