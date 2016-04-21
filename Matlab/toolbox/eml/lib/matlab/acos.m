function y = acos(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/acos.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/03/21 22:07:42 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''acos'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_acos(x);
else
	% v = sqrt(1+x)
	% u = sqrt(1-x)
	% y = 2*atan(real(u)/real(v)) + i*asinh(imag(v'*u))
	v  = sqrt(1 + x);
	u  = sqrt(1 - x);
	yr = 2 * eml_atan(real(u) ./ real(v));
	yi = asinh(imag(conj(v) .* u));
	y  = complex(yr, yi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
