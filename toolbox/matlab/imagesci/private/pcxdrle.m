function varargout = pcxdrle(varargin)
%PCXDRLE Decompress RLE-compressed data from a PCX file.
%   [X,IDX] = PCXDRLE(BUFFER,HEIGHT,WIDTH) decompresses the
%   RLE-compressed byte-stream contained in the uint8 vector
%   BUFFER.  X is a uint8 array containing the decompressed
%   result.  Note that the dimensions of X will be
%   WIDTH-by-HEIGHT.  This reflects the way pixel data is ordered
%   in a PCX file.  IDX is the index of the last BUFFER element
%   processed.  The reason that all of the elements of BUFFER
%   might not be processed is that BUFFER may contain colormap
%   data at the end.
%
%   Reference:  Murray and vanRyper, Encyclopedia of Graphics
%   File Formats, 2nd ed, O'Reilly, 1996.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:40 $
%#mex

error('MATLAB:pcxdrle:missingMEX', 'Missing MEX-file PCXDRLE');
