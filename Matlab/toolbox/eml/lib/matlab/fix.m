function y = fix(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/fix.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:12 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''fix'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = vector_fix(x);
else
	xr = real(x);
	xi = imag(x);
	xr = vector_fix(xr);
	xi = vector_fix(xi);
	y  = complex(xr, xi);
end

function y = vector_fix(x)

	% Declare y
	y = ones(size(x),class(x));

	for i = 1 : length(x(:))
		y(i) = scalar_fix(x(i));
	end;

function y = scalar_fix(x)

	if x > 0
		y = eml_floor(x);
	else
		y = eml_ceil(x);
	end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
