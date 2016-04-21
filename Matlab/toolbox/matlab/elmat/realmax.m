function rmax = realmax(varargin)
%REALMAX Largest positive floating point number.
%   x = realmax is the largest double precision floating point number
%   representable on this computer.  Anything larger overflows.
%
%   REALMAX('double') is the same as REALMAX with no arguments.
%
%   REALMAX('single') is the largest single precision floating point number
%   representable on this computer. Anything larger overflows to single(Inf).
%
%   See also EPS, REALMIN, INTMAX.

%   C. Moler, 7-26-91, 6-10-92, 8-27-93.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.2 $  $Date: 2004/01/24 09:21:46 $

if (nargin == 0)
  dbl = true;
elseif (nargin == 1)
  classname = varargin{1};
  if ischar(classname)
    switch (classname)
      case 'double'
        dbl = true;
      case 'single'
        dbl = false;
      otherwise
        error('MATLAB:realmax:invalidClassName','Invalid class name.')
    end
  else
    error('MATLAB:realmax:inputMustBeString', ...
          'Input must be a string class name.')
  end
else % nargin > 1
  error('MATLAB:realmax:tooManyInputs', 'Too many inputs.');
end

% 2-eps is the largest floating point number smaller than 2.
% When eps accepts a classname, change this to:
% f = 2 - eps(classname)
if dbl
  f = 2 - eps;
else
  f = 2 - single(2^-23);
end

if dbl
  maxexp = 1023;
else
  maxexp = 127;
end

% pow2(f,e) is f*2^e, computed by adding e to the exponent of f.
  % When pow2 is implemented on singles, change this:
if dbl
  rmax = pow2(f,maxexp);
else
  rmax = single(pow2(double(f),maxexp));
end
