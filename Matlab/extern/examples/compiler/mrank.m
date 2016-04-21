function r = mrank(n)
%Doc example.  Chapter 5.

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.6.1 $

r = zeros(n,1);
for k = 1:n
   r(k) = rank(magic(k));
end
