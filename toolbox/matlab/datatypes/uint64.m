%UINT64 Convert to unsigned 64-bit integer.
%   I = UINT64(X) converts the elements of the array X into unsigned
%   64-bit integers. X can be any numeric object, such as a DOUBLE. 
%   DOUBLE and SINGLE values are rounded to the nearest UINT64 value 
%   on conversion. If X is already an unsigned 64-bit integer array, 
%   then UINT64 has no effect. 
%
%   The values of a UINT64 range from 0 to 18,446,744,073,709,551,615, 
%   (that is, from INTMIN('uint64') to INTMAX('uint64')). Values outside 
%   this range are mapped to INTMIN('uint64') or INTMAX('uint64').
%
%   NOTE: The range of values that can be passed to UINT64 from the command
%   prompt or from an M-file function without loss of precision is 0 to
%   2^53, inclusive. When reading values from a MAT-file, UINT64 correctly
%   represents the full range 0 to (2^64)-1.
%
%   The UINT64 class is primarily meant to be used to store integer
%   values.  Hence most operations that manipulate arrays without changing
%   their elements are defined (examples are RESHAPE, SIZE, the relational
%   operators, logical operators, subscripted assignment and subscripted
%   reference).  No math operations are defined for the UINT64.
%
%   You can define your own methods for the UINT64 class (as you can for any
%   object) by placing the appropriately named method in an @uint64
%   directory within a directory on your path.    
%   Type HELP DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large UINT64 arrays is: 
%
%      I = zeros(100,100,'uint64')
%
%   which creates a 100x100 element UINT64 array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   See also DOUBLE, SINGLE, DATATYPES, ISINTEGER, UINT8, UINT16, UINT32,
%   INT8, INT16, INT32, INT64, INTMIN, INTMAX, EYE, ONES, ZEROS.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.2.4.4 $  $Date: 2004/04/16 22:05:19 $
%   Built-in function.
