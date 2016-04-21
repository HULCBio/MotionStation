function Y = sqrt(X)
%SQRT   Symbolic matrix element-wise square root.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 03:12:12 $

Y = maple('map','sqrt',X);
