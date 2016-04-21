function y = cos(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/cos.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:05 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''cos'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_cos(x);
else
	% Declare y
	base = ones(size(x),class(x));
	y = complex(base, base);

	for i = 1 : length(x(:))
		y(i) = scalar_ccos(x(i));
	end
end

% Adapted from utComplexScalarCos in src\util\libm\cmath1.cpp
function y = scalar_ccos(x)

	xr = real(x);
	xi = imag(x);
	if xi ~= 0
		yr =  eml_cos(xr) * eml_cosh(xi);
		yi = -eml_sin(xr) * eml_sinh(xi);
	else
		yr = eml_cos(xr);
		yi = zeros(size(xi),class(xi));
	end
	y = complex(yr, yi);

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
