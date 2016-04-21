function Y = exp(X)
%EXP    Symbolic matrix element-wise exponentiation.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 03:08:00 $

Y = maple('map','exp',X);
