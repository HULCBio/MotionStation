function Y = uminus(X)
%UMINUS Symbolic negation.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 03:12:33 $


Y = X;
for k = 1:prod(size(X))
   Y(k).s = ['-(', X(k).s, ')'];
end
Y = maple('',Y);
