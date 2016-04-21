function y = tan(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/tan.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:43 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''tan'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_tan(x);
else
	% Adapted from utComplexScalarTan in src\util\libm\cmath1.cpp

	% tan(z) = sin(z)/cos(z) -> i(Inf/Inf) for z with large |imag(z)|.
	% Use tan(x+i*y) = (tan(x)+i*tanh(y))/(1-i*tan(x)*tanh(y))

	xr  = real(x);
	xi  = imag(x);
	c1r = eml_tan(xr);
	c1i = eml_tanh(xi);
	c2r = ones(1,class(c1r));
	c2i = -(eml_tan(xr) .* eml_tanh(xi));
	c1  = complex(c1r, c1i);
	c2  = complex(c2r, c2i);
	y   = c1 ./ c2;
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
