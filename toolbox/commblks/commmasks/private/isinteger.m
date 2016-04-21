function isInt = isinteger(Vec)
%ISINTEGER Check elements of a vector or matrix to be integer-valued.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/01/09 17:36:27 $

isInt = all( Vec(:) == floor(Vec(:)) );

return;

% [EOF]
