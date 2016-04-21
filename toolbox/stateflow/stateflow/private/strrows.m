%STRROWS  Form a string matrix (MEX file)
%         M = STRROWS( S1, S2, S3, ... ) returns a string matrix where each
%         row is a string argument passed. The column size is the length of
%         the largest string arguments. Other strings are padded with 0 to
%         make the matrix valid. There are no theoretical limits to the number
%         of arguments. Each argument in itself may be a string (row-wise)
%         matrix.

%
%  Written by E.Mehran Mestchian
%  Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:00:50 $

