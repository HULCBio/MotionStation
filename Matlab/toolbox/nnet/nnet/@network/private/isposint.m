function f=isposint(v)
%ISPOSINT True for positive integer values.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

f = 1;
if ~isa(v,'double') | any(size(v) ~= [1 1]) | ...
  ~isreal(v) | v<0 | round(v) ~= v
  f = 0;
end
