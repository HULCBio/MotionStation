function y = sinh(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/sinh.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:40 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''sinh'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_sinh(x);
else
	% Adapted from utComplexScalarSinh in src\util\libm\cmath1.cpp
	xr = real(x);
	xi = imag(x);
	yr = eml_sinh(xr) .* eml_cos(xi);
	yi = eml_cosh(xr) .* eml_sin(xi);
	y = complex(yr, yi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
