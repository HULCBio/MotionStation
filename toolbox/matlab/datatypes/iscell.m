function t = iscell(a)
%ISCELL True for cell array.
%   ISCELL(C) returns 1 if C is a cell array and 0 otherwise.
%
%   See also CELL, PAREN, ISSTRUCT, ISNUMERIC, ISOBJECT, ISLOGICAL.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 03:21:16 $

t = isa(a,'cell');
