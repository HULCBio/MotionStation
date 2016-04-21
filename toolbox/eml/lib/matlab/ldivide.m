function z = ldivide(x,y)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Does not use the accurate algorithm in the complex case.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/ldivide.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/03/21 22:08:12 $

% Error check nargin
eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''ldivide'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isfloat(y), 'error', ['Function ''ldivide'' is not defined for values of class ''' class(y) '''.']);

z = rdivide(y, x);

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
