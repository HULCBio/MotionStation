function r = isrealcell(x,r)
%ISREALCELL True for a cell array with real elements.
%   ISREALCELL(X) returns true if X is a cell array with real
%   elements.  This is a recursive routine.
%
%   ISREALCELL(X,R) returns true if X is a cell array with real elements and
%   R is true.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:27:34 $

if nargin==1
  r = logical(1);
end
if isa(x,'cell')
  for k = 1:length(x)
    r = isrealcell(x{k},r);
  end
else
  r = r & isreal(x);
end
