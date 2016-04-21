function t = isstruct(a)
%ISSTRUCT True for structures.
%   ISSTRUCT(S) returns 1 if S is a structure and 0 otherwise.
%
%   See also STRUCT, ISFIELD, ISCELL, ISNUMERIC, ISOBJECT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/15 03:21:27 $

t = isa(a,'struct');

