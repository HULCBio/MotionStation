function y = round(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/round.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:38 $
% Comments:
% Scalar rounding needs a proper rewrite.

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''round'' is not defined for values of class ''' class(x) '''.']);

if (isempty(x)),
     y = x;
     return;
end;

if(isreal(x))
	y = vector_round(x);
else
	xr = real(x);
	xi = imag(x);
	xr = vector_round(xr);
	xi = vector_round(xi);
	y  = complex(xr, xi);
end


function y = vector_round(x)

	% Declare y
	y = ones(size(x),class(x));

	for i = 1 : length(x(:))
		y(i) = scalar_round(x(i));
	end

function y = scalar_round(x)

	xFix  = fix(x);
	xFrac = abs(x - xFix);
	if xFrac >= 0.5
		if x > 0
			y = ceil(x);
		else
			y = floor(x);
		end
	else
		if x > 0
			y = floor(x);
		else
			y = ceil(x);
		end
	end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
