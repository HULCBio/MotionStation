function z = times(x,y)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/times.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:45 $

% Error check nargin
eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''times'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isfloat(y), 'error', ['Function ''times'' is not defined for values of class ''' class(y) '''.']);

if ~isscalar(x) && ~isscalar(y)
   eml_assert(all(size(x) == size(y)), 'error', 'Matrix dimensions must agree.');
end

if isreal(x) && isreal(y)
    z = eml_times(x,y);
else
   xr = real(x);
   xi = imag(x);
   
   yr = real(y);
   yi = imag(y);
   
   zr = eml_times(xr,yr) - eml_times(xi,yi);
   zi = eml_times(xr,yi) + eml_times(xi,yr);
   z = complex(zr,zi);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
