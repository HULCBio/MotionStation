function y = sin(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/sin.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/14 23:58:39 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''sin'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_sin(x);
else
	% Declare y
	base = ones(size(x),class(x));
	y = complex(base, base);

	for i = 1 : length(x(:))
		y(i) = scalar_csin(x(i));
	end
end

% Adapted from utComplexScalarSin in src\util\libm\cmath1.cpp
function y = scalar_csin(x)

	xr = real(x);
	xi = imag(x);
	if xi ~= 0
		yr = eml_sin(xr) .* eml_cosh(xi);
		yi = eml_cos(xr) .* eml_sinh(xi);
	else
		yr = eml_sin(xr);
		yi = zeros(size(xi), class(xi));
	end
	y = complex(yr, yi);

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
