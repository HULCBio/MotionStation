function bool = isscalar(var)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isscalar.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:23 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');

bool = length(var) == 1;
