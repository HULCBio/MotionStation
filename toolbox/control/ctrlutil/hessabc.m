function h = hessabc(a,b,c)
%HESSABC  Computes Hessenberg form of [0,C;B,A]
% 
%   See also HESS, GETZEROS, RLOCUS.

%   Author: P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 06:38:59 $

%   RE: When [0 c;b a] is symmetric, HESS may permute the row/first column.
%       E.g., [p,h] = hess([0 1 1;1 0 0;1 0 0])  -> 
%                                     p = permutation and p(1,1)~=0
%       Prevent this by breaking symmetry when b=c'.

if all(b(:)==c(:))
   % Destroy symmetry
   b = 2*b;
   c = c/2;
end

h = hess([0 c;b a]);
