function [x,lenX,nchans] = checkinputsigdim(x)
%CHECKINPUTSIGDIM   Validdate input and columnize it if it's a row vector.  
%  [X,LENX,NCHANS] = CHECKINPUTSIGDIM(x) verifies that the input is not a
%  string, and returns a column vector if it's a row vector.  It also
%  returns the size in LENX and NCHANS of the input vector or matrix.

% Copyright 1988-2003 The MathWorks, Inc.

lenX = 0;
nchans = 0;
if ischar(x),
    msg = 'Invalid data.  You must specify a vector or matrix of doubles.'; 
    error(generatemsgid('invalidData'), msg);
end

[lenX,nchans] = size(x);
xIsMatrix = ~any([lenX,nchans]==1);

if ~xIsMatrix, 
    x = x(:);  % Make it column.
    [lenX,nchans] = size(x);
end 

% [EOF]
