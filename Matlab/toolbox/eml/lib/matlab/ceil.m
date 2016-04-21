function y = ceil(x)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Should be able to handle int*, uint* (but not complex(int*,uint*))
%    Errors out on all integer values.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/ceil.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:04 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''ceil'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_ceil(x);
else
	xr = real(x);
	xi = imag(x);
	xr = eml_ceil(xr);
	xi = eml_ceil(xi);
	y  = complex(xr, xi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
