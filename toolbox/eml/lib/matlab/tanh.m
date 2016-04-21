function y = tanh(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/tanh.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:44 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''tanh'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_tanh(x);
else
	% Adapted from utComplexScalarTanh in src\util\libm\cmath1.cpp

	% tanh(z) = sinh(z)/cosh(z) -> Inf/Inf for large z.
	% Use tanh(x+i*y) = (tanh(x)+i*tan(y))/(1+i*tanh(x)*tan(y))
	xr  = real(x);
	xi  = imag(x);
	c1r = eml_tanh(xr);
	c1i = eml_tan(xi);
	c2r = ones(1,class(xr));
	c2i = eml_tanh(xr) .* eml_tan(xi);
	c1  = complex(c1r, c1i);
	c2  = complex(c2r, c2i);
	y   = c1 ./ c2;
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
