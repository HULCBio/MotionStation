function s = spiral(n)
%SPIRAL SPIRAL(n) is an n-by-n matrix with elements ranging
%   from 1 to n^2 in a rectangular spiral pattern.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:34:37 $

% Start in the center.
s = zeros(n,n);
i = ceil(n/2);
j = ceil(n/2);
s(i,j) = 1;
if n==1, return, end

% Wind outward from the center.  Use fixed i and increasing j,
% then fixed j and increasing i, then fixed i and decreasing j,
% then fixed j and decreasing i.  Then repeat.
k = 1;  % Numbering.
d = 1;  % Increasing or decreasing.
for p = 1:n
   q = 1:min(p,n-1);  % Note that q is a vector.
   j = j+d*q;
   k = k+q;
   s(i,j) = k;
   if (p==n), return, end
   j = j(p);
   k = k(p);
   i = i+d*q';
   k = k+q';
   s(i,j) = k;
   i = i(p);
   k = k(p);
   d = -d;
end
