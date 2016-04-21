function bool = isvector(var)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isvector.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:24 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');

bool = size(var,1) == 1 || size(var,2) == 1;
