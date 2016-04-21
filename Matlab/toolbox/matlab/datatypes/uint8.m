%UINT8 Convert to unsigned 8-bit integer.
%   I = UINT8(X) converts the elements of the array X into unsigned 8-bit
%   integers. X can be any numeric object, such as a DOUBLE. The values
%   of a UINT8 range from 0 to 255, or INTMIN('uint8') to INTMAX('uint8').
%   Values outside this range saturate on overflow, namely they are mapped
%   to 0 or 255 if they are outside the range. If X is already an unsigned
%   8-bit integer array, then UINT8 has no effect. DOUBLE and SINGLE values
%   are rounded to the nearest UINT8 value on conversion.
%
%   Some arithmetic operations are defined for UINT8 on interaction with
%   other UINT8 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   UINT8 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is UINT8.
%   UINT8 arrays saturate on overflow in arithmetic.
%
%   You can define or overload your own methods for the UINT8 class (as you
%   can for any object) by placing the appropriately named method in an
%   @uint8 directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large UINT8 arrays is: 
%
%      I = zeros(1000,1000,'uint8')
%
%   which creates a 1000x1000 element UINT8 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'uint8')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT16, UINT32, UINT64,
%   INT8, INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.


%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.4 $  $Date: 2004/04/10 23:25:40 $
%   Built-in function.
