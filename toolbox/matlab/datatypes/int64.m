%INT64 Convert to signed 64-bit integer.
%   I = INT64(X) converts the elements of array X into signed 64-bit
%   integers. X can be any numeric object (such as a DOUBLE). DOUBLE
%   and SINGLE values are rounded to the nearest INT64 value on 
%   conversion. If X is already a signed 64-bit integer array, then
%   INT64 has no effect. 
%
%   The values of an INT64 range from -9,223,372,036,854,775,808 to
%   9,223,372,036,854,775,807, (that is, from INTMIN('int64') to 
%   INTMAX('int64')). Values outside this range are mapped to INTMIN('int64') 
%   or INTMAX('int64').
%
%   NOTE: The range of values that can be passed to INT64 from the command
%   prompt or from an M-file function without loss of precision is -2^53 to
%   2^53, inclusive. When reading values from a MAT-file, INT64 correctly
%   represents the full range -2^63 to (2^63)-1.
%
%   The INT64 class is primarily meant to be used to store integer values.
%   Hence most operations that manipulate arrays without changing their
%   elements are defined (examples are RESHAPE, SIZE, the relational
%   operators, logical operators, subscripted assignment and subscripted
%   reference).  No math operations are defined for the INT64.
%
%   You can define your own methods for the INT64 CLASS (as you can for any
%   object) by placing the appropriately named method in an @int64
%   directory within a directory on your path.
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large INT64 arrays is: 
%
%      I = zeros(100,100,'int64')
%
%   which creates a 100x100 element INT64 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   UINT64, INT8, INT16, INT32, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.2.4.4 $  $Date: 2004/04/16 22:05:18 $
%   Built-in function.
