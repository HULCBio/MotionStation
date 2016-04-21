function B = mpower(A,p)
%POWER  Symbolic matrix power.
%   POWER(A,p) overloads symbolic A^p.
%
%   Example;
%      A = [x y; alpha 2]
%      A^2 returns [x^2+alpha*y  x*y+2*y; alpha*x+2*alpha  alpha*y+4].

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/16 22:22:56 $

A = sym(A);
p = sym(p); 

if all(size(A) == 1) & all(size(p) == 1)
   % Both scalars
   B = maple(A,'^',p);

elseif all(size(p) == 1)
   % Scalar exponent
   if ~isempty(findsym(p)) | p ~= fix(double(p))
      error('symbolic:sym:mpower:errmsg1','Exponent must be a numeric integer.')
   end
   if size(A,1) ~= size(A,2)
      error('symbolic:sym:mpower:errmsg2','Matrix must be square.')
   end
   B = sym(eye(size(A))); 
   p = double(p);
   if p > 0
      for k = 1:p
         B = A*B;
      end
   else
      A = inv(A);
      for k = 1:abs(p)
         B = A*B;
      end
   end
      
elseif all(size(A) == 1)
   % Scalar base
   if size(p,1) ~= size(p,2)
      error('symbolic:sym:mpower:errmsg3','Matrix must be square.')
   end
   B = expm(log(A)*p);

else
   error('symbolic:sym:mpower:errmsg4','Either base or exponent must be a scalar.')
end 
