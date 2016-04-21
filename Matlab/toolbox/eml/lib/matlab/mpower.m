function y = mpower(x1, x2)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Matrix power is not supported. At present, both the base and the
% exponent must be scalar values.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/mpower.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:28 $

eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x1), 'error', ['Function ''mpower'' is not defined for values of class ''' class(x1) '''.']);
eml_assert(isfloat(x2), 'error', ['Function ''mpower'' is not defined for values of class ''' class(x2) '''.']);
eml_assert(length(x1(:)) == 1 && length(x2(:)) == 1, ...
           'Matrix exponentiation is not supported.');

y = x1 .^ x2;

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
