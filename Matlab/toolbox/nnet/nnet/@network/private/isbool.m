function f=isbool(v,r,c)
%ISBOOL True for properly sized boolean matrices.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if islogical(v)
  f = all(size(v) == [r c]);
  return;
end

f = 1;

if ~isa(v,'double') | any(size(v) ~= [r c])
  f = 0;
elseif (prod(size(v)) > 0) & any((v ~= 0) & (v ~= 1))
  f = 0;
end
