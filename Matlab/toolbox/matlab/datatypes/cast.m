function b = cast(a,className)
%CAST  Cast a variable to a different data type or class.
%   B = CAST(A,NEWCLASS) casts A to class NEWCLASS. A must be convertible to
%   class NEWCLASS. NEWCLASS must be the name of one of the builtin data types.
%
%   Example:
%      a = int8(5);
%      b = cast(a,'uint8');
%
%   See also CLASS.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/11/14 20:06:39 $
%   Built-in function.
