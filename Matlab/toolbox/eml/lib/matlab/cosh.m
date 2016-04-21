function y = cosh(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/cosh.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:06 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''cosh'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_cosh(x);
else
	% Adapted from utComplexScalarCosh in src\util\libm\cmath1.cpp
	xr = real(x);
	xi = imag(x);
	yr = eml_cosh(xr) .* eml_cos(xi);
	yi = eml_sinh(xr) .* eml_sin(xi);
	y  = complex(yr, yi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

%Example of how to write @double functions from Mehran
%if(isreal(x))
%	RTN=0;
%	eml_ignore('RTN=1;y = builtin(''cosh'',x);');
%	if RTN, return; end
%	y = eml_cosh(x);
%else
%	% Adapted from utComplexScalarCosh in src\util\libm\cmath1.cpp
%	xr = real(x);
%	xi = imag(x);
%	yr = cosh(xr) .* cos(xi);
%	yi = sinh(xr) .* sin(xi);
%	y  = complex(yr, yi);
%end
%eml_ignore(eml_assert(...
%	isequal(y,builtin('cosh',x))));	