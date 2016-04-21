%INT8 Convert to signed 8-bit integer.
%   I = INT8(X) converts the elements of the array X into signed 8-bit
%   integers. X can be any numeric object, such as a DOUBLE. The values
%   of an INT8 range from -128 to 127, or INTMIN('int8') to INTMAX('int8').
%   Values outside this range saturate on overflow, namely they are mapped
%   to -128 or 127 if they are outside the range. If X is already a signed
%   8-bit integer array, then INT8 has no effect. DOUBLE and SINGLE values
%   are rounded to the nearest INT8 value on conversion.
%
%   Some arithmetic operations are defined for INT8 on interaction with
%   other INT8 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   INT8 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is INT8.
%   INT8 arrays saturate on overflow in arithmetic.
%
%   You can define or overload your own methods for the INT8 class (as you
%   can for any object) by placing the appropriately named method in an
%   @int8 directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large INT8 arrays is: 
%
%      I = zeros(1000,1000,'int8')
%
%   which creates a 1000x1000 element INT8 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'int8')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   UINT64, INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/10 23:25:24 $
%   Built-in function.
