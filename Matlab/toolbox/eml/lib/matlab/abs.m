function y = abs(x)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Only supports single/double.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/abs.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $Date: 2004/04/01 16:07:02 $
%
% Comments:
% "real" version should be rewritten to call fabs directly

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''abs'' is not defined for values of class ''' class(x) '''.']);

if(size(x,1) == 0 || size(x,2) == 0)
    y = x;
    return;
end

y = zeros(size(x),class(x));
    
for i = 1 : length(x(:))
  if(isreal(x))
    y(i) = eml_fabs(x(i));
  else
	% Adapted from utCqabs in src\util\libm\cmath1.cpp
	xr = real(x(i));
	xi = imag(x(i));
    if eml_fabs(xr) > eml_fabs(xi)
      t = xi/xr;
      y(i) = eml_fabs(xr) * sqrt(1 + t*t);
    elseif xi ~= 0
      t = xr/xi;
      y(i) = eml_fabs(xi) * sqrt(1 + t*t);
    else
      y(i) = 0;
    end
  end
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
