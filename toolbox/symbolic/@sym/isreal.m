function r = isreal(x)

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 03:11:54 $

r = isequal(x,conj(x));
