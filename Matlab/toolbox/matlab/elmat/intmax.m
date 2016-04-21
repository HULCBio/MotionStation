function imax = intmax(varargin)
%INTMAX Largest positive integer value.
%   X = INTMAX is the largest positive value representable in an int32.
%   Any value that is larger than INTMAX will saturate to INTMAX when
%   cast to int32.
%
%   INTMAX('int32') is the same as INTMAX with no arguments.
%
%   INTMAX(CLASSNAME) is the largest positive value in the integer class
%   CLASSNAME. Valid values of CLASSNAME are 'int8', 'uint8', 'int16',
%   'uint16', 'int32', 'uint32', 'int64' and 'uint64'.
%
%   See also INTMIN, REALMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $  $Date: 2004/03/17 20:05:03 $

if (nargin == 0)
  imax = int32(2147483647);
elseif (nargin == 1)
  classname = varargin{1};
  if ischar(classname)
    switch (classname)
      case 'int8'
        imax = int8(127);
      case 'uint8'
        imax = uint8(255);
      case 'int16'
        imax = int16(32767);
      case 'uint16'
        imax = uint16(65535);
      case 'int32'
        imax = int32(2147483647);
      case 'uint32'
        imax = uint32(4294967295);
      case 'int64'
        % Turn off the overflow warning because the constant value below
        % is interpreted as the closest double value, namely 2^63.
        % This is out of range and warns of overflow upon conversion to int64.
        s = warning('query','MATLAB:intConvertOverflow');
        warning('off','MATLAB:intConvertOverflow');
        imax = int64(9223372036854775807);
        warning(s);
      case 'uint64'
        % Turn off the overflow warning because the constant value below
        % is interpreted as the closest double value, namely 2^64.
        % This is out of range and warns of overflow upon conversion to uint64.
        s = warning('query','MATLAB:intConvertOverflow');
        warning('off','MATLAB:intConvertOverflow');
        imax = uint64(18446744073709551615);
        warning(s);
      otherwise
        error('MATLAB:intmax:invalidClassName','Invalid class name.')
    end
  else
    error('MATLAB:intmax:inputMustBeString', ...
          'Input must be a string, the name of an integer class.')
  end
else % nargin > 1
  error('MATLAB:intmax:tooManyInputs', 'Too many inputs.');
end
