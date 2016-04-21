function s = num2mstr(n)
%NUM2MSTR Convert number to string in maximum precision.
%   S = NUM2MSTR(N) converts real numbers of input 
%   matrix N to string output vector S, in 
%   maximum precision.
%
%   See also NUM2STR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

[r,c] = size(n);
if ischar(n)
   s = n;

elseif max(r,c)==1
   s = sprintf('%25.18g',n);

elseif r>1
   s = [];
   for k=1:r
       s = [s sprintf('%25.18g',n(k,:)) ';'];
   end
   s = ['[' s ']'];

elseif c>1
   s = sprintf('%25.18g',n);
   s = ['[' s ']'];

else
   s = '';
end
