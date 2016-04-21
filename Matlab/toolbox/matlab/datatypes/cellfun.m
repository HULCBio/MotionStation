%CELLFUN Functions on cell array contents.
%   D = CELLFUN(FUN, C) where FUN is one of 
%
%   	'isreal'    -- true for real cell element
%   	'isempty'   -- true for empty cell element
%   	'islogical' -- true for logical cell element
%   	'length'    -- length of cell element
%   	'ndims'     -- number of dimensions of cell element
%   	'prodofsize'-- number of elements in cell element
%
%   and C is the cell array, returns the results of
%   applying the specified function to each element
%   of the cell array. D is a double array the same
%   size as C containing the results of applying FUN on
%   the corresponding cell elements of C.
%
%   D = CELLFUN('size', C, K) returns the size along
%   the K-th dimension of each element of C.
%
%   D = CELLFUN('isclass', C, CLASSNAME) returns true 
%   for a cell element if the class of the element 
%   matches the CLASSNAME string. Unlike the ISA function,
%   'isclass' of a subclass of CLASSNAME returns false.
%
%   Note: When C contains objects, CELLFUN does not call any
%   overloaded versions of FUN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $