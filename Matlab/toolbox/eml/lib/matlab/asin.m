function y = asin(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/asin.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:00 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''asin'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_asin(x);
else
	% v = sqrt(1+x)
	% u = sqrt(1-x)
	% y = atan(real(x)/real(u*v)) + i*asinh(imag(u'*v))
	v  = sqrt(1 + x);
	u  = sqrt(1 - x);
	yr = eml_atan(real(x) ./ real(u .* v));
	yi = asinh(imag(conj(u) .* v));
	y  = complex(yr, yi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
