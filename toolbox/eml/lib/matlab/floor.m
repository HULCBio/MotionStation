function y = floor(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/floor.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:13 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''floor'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	y = eml_floor(x);
else
	xr = real(x);
	xi = imag(x);
	xr = eml_floor(xr);
	xi = eml_floor(xi);
	y  = complex(xr, xi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
