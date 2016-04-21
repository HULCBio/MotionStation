%INT16 Convert to signed 16-bit integer.
%   I = INT16(X) converts the elements of the array X into signed 16-bit
%   integers. X can be any numeric object, such as a DOUBLE. The values
%   of an INT16 range from -32768 to 32767, or INTMIN('int16') to
%   INTMAX('int16'). Values outside this range saturate on overflow, namely
%   they are mapped to -32768 or 32767 if they are outside the range. If X
%   is already a signed 16-bit integer array, then INT16 has no effect.
%   DOUBLE and SINGLE values are rounded to the nearest INT16 value on
%   conversion.
%
%   Some arithmetic operations are defined for INT16 on interaction with
%   other INT16 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   INT16 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is INT16.
%   INT16 arrays saturate on overflow in arithmetic.
%
%   You can define or overload your own methods for the INT16 class (as you
%   can for any object) by placing the appropriately named method in an
%   @int16 directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large INT16 arrays is: 
%
%      I = zeros(1000,1000,'int16')
%
%   which creates a 1000x1000 element INT16 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'int16')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   UINT64, INT8, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/10 23:25:21 $
%   Built-in function.
