function imin = intmin(varargin)
%INTMIN Smallest integer value.
%   X = INTMIN is the smallest value representable in an int32.
%   Any value that is smaller than INTMIN will saturate to INTMIN when
%   cast to int32.
%
%   INTMIN('int32') is the same as INTMIN with no arguments.
%
%   INTMIN(CLASSNAME) is the smallest value in the integer class CLASSNAME.
%   Valid values of CLASSNAME are 'int8', 'uint8', 'int16', 'uint16',
%   'int32', 'uint32', 'int64' and 'uint64'.
%
%   See also INTMAX, REALMIN.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $  $Date: 2004/03/17 20:05:04 $

if (nargin == 0)
  imin = int32(-2147483648);
elseif (nargin == 1)
  classname = varargin{1};
  if ischar(classname)
    switch (classname)
      case 'int8'
        imin = int8(-128);
      case 'uint8'
        imin = uint8(0);
      case 'int16'
        imin = int16(-32768);
      case 'uint16'
        imin = uint16(0);
      case 'int32'
        imin = int32(-2147483648);
      case 'uint32'
        imin = uint32(0);
      case 'int64'
        imin = int64(-9223372036854775808);
      case 'uint64'
        imin = uint64(0);
      otherwise
        error('MATLAB:intmin:invalidClassName','Invalid class name.')
    end
  else
    error('MATLAB:intmin:inputMustBeString', ...
          'Input must be a string, the name of an integer class.')
  end
else % nargin > 1
  error('MATLAB:intmin:tooManyInputs', 'Too many inputs.');
end
