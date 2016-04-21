function y = sqrt(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/sqrt.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/14 23:58:41 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''sqrt'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_sqrt(x);
else
	% Declare y
	base = ones(size(x),class(x));
	y = complex(base, base);

	for i = 1 : length(x(:))
		y(i) = scalar_csqrt(x(i));
	end
end

function y = scalar_csqrt(x)

	% Adapted from utComplexScalarSqrt in src\util\libm\cmath1.cpp
	xr = real(x);
	xi = imag(x);
	yr = zeros(size(xr),class(xr));
	yi = zeros(size(xi),class(xi));
	s = eml_sqrt(0.5 .* (abs(x) + abs(xr)));
	if xr >= 0
		yr = s;
	end
	s  = copy_sign(s, xi);
	if xr <= 0.0
		yi = s;
	end;
	if xr <  0.0
		yr = 0.5 * (xi ./ yi);
	end;
	if xr >  0.0
		yi = 0.5 * (xi ./ yr);
	end;
	y = complex(yr, yi);

function y = copy_sign(x1, x2)

	y = sign_positive_zero(x2) .* abs(x1);

function y = sign_positive_zero(x)

	if x == 0
		y = ones(1,class(x));
	else
		y = sign(x);
	end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
