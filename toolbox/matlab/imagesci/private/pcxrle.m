function pcxrle(filename,data)
%PCXRLE Run-length encode a byte stream for a PCX file.
%   PCXRLE(FILENAME,DATA) run-length encodes the bytes in the
%   uint8 array DATA and appends the result to the file
%   specified by the string FILENAME.
%
%   See also IMWRITE, IMREAD, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:41 $
%#mex

error('MATLAB:pcxrle:missingMEX', 'Missing MEX-file PCXRLE');
