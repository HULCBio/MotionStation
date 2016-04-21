function b = isfinite(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isfinite.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:18 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''isfinite'' is not defined for values of class ''' class(x) '''.']);

b = ~isinf(x) & ~isnan(x);

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
