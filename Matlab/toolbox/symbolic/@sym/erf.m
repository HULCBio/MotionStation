function Y = erf(X)
%ERF    Symbolic error function.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 03:10:18 $

Y = maple('map','erf',X);
