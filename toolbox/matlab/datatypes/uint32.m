%UINT32 Convert to unsigned 32-bit integer.
%   I = UINT32(X) converts the elements of the array X into unsigned 32-bit
%   integers. X can be any numeric object, such as a DOUBLE. The values
%   of a UINT32 range from 0 to 4,294,967,295, or INTMIN('uint32') to
%   INTMAX('uint32'). Values outside this range saturate on overflow, namely
%   they are mapped to 0 or 4,294,967,295 if they are outside the range. If X
%   is already an unsigned 32-bit integer array, then UINT32 has no effect.
%   DOUBLE and SINGLE values are rounded to the nearest UINT32 value on
%   conversion.
%
%   Some arithmetic operations are defined for UINT32 on interaction with
%   other UINT32 arrays. For example, +, -, .*, ./, .\ and .^.
%   If at least one operand is scalar, *, /, \ and ^ are also defined.
%   UINT32 arrays may also interact with scalar DOUBLE variables, including
%   constants, and the result of the operation is UINT32.
%   UINT32 arrays saturate on overflow in arithmetic.
%
%   You can define or overload your own methods for the UINT32 class (as you
%   can for any object) by placing the appropriately named method in an
%   @uint32 directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large UINT32 arrays is: 
%
%      I = zeros(1000,1000,'uint32')
%
%   which creates a 1000x1000 element UINT32 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = 17 * ones(5,6,'uint32')
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT64, INT8,
%   INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/10 23:25:38 $
%   Built-in function.
