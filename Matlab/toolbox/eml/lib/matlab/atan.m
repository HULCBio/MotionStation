function y = atan(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/atan.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:02 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''atan'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_atan(x);
else
	% y = -i*double_atanh(i*x);
	xr = real(x);
	xi = imag(x);
	c1 = complex(-xi, xr);
	t  = atanh(c1);
	yr = imag(t);
	yi = -real(t);
	y  = complex(yr, yi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
