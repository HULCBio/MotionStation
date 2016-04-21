function y = mrdivide(x1, x2)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) At present full matrix division is not supported.  The
% denominator must be a scalar.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/mrdivide.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:29 $

eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x1), 'error', ['Function ''mrdivide'' is not defined for values of class ''' class(x1) '''.']);
eml_assert(isfloat(x2), 'error', ['Function ''mrdivide'' is not defined for values of class ''' class(x2) '''.']);

eml_assert(length(x2(:)) == 1,...
          ['Matrix division is not fully supported. The denominator ' ...
           'must be a scalar.']);

y = x1 ./ x2;

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
