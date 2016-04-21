%INT32 Convert to signed 32-bit integer.
%   I = INT32(X) converts the elements of the array X into signed 32-bit
%   integers. X can be any numeric object, such as a DOUBLE. The values
%   of an INT32 range from -2,147,483,648 to 2,147,483,647, or
%   INTMIN('int32') to INTMAX('int32'). Values outside this range saturate
%   on overflow, namely they are mapped to -2,147,483,648 or 2,147,483,647
%   if they are outside the range. If X is already a signed 32-bit integer
%   array, then INT32 has no effect. DOUBLE and SINGLE values are rounded
%   to the nearest INT32 value on conversion.
%
%   Some arithmetic operations are defined for INT32 on interaction with
%   other INT32 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   INT32 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is INT32.
%   INT32 arrays saturate on overflow in arithmetic.
%
%   You can define or overload your own methods for the INT32 class (as you
%   can for any object) by placing the appropriately named method in an
%   @int32 directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large INT32 arrays is: 
%
%      I = zeros(1000,1000,'int32')
%
%   which creates a 1000x1000 element INT32 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'int32')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   UINT64, INT8, INT16, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/10 23:25:22 $
%   Built-in function.
