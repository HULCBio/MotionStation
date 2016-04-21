function xmin = realmin(varargin)
%REALMIN Smallest positive floating point number.
%   x = realmin is the smallest positive normalized double precision floating
%   point number on this computer.  Anything smaller underflows or is an IEEE
%   "denormal".
%
%   REALMIN('double') is the same as REALMIN with no arguments.
%
%   REALMIN('single') is the smallest positive normalized single precision
%   floating point number on this computer.
%
%   See also EPS, REALMAX, INTMIN.

%   C. Moler, 7-26-91, 6-10-92.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.2 $  $Date: 2004/01/24 09:21:47 $

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
        error('MATLAB:realmin:invalidClassName','Invalid class name.')
    end
  else
    error('MATLAB:realmin:inputMustBeString', ...
          'Input must be a string class name.')
  end
else % nargin > 1
  error('MATLAB:realmin:tooManyInputs', 'Too many inputs.');
end

if dbl
  minexp = -1022;
else
  minexp = -126;
end

% pow2(f,e) is f*2^e, computed by adding e to the exponent of f.
  % When pow2 is implemented on singles, change this, making minexp single:
if dbl
  xmin = pow2(1,minexp);
else
  xmin = single(pow2(1,minexp));
end
