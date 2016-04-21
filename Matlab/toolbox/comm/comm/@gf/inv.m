function z = inv(A)
%INV  Inverse of GF matrix.
%   INV(X) is the inverse of the square matrix X.
%   An error message is printed if X is singular.
%
%   See also LU, LSOLVE, USOLVE.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:15:02 $ 

if size(A.x,1)~=size(A.x,2)
   error('Matrix must be square.')
else
   z = A;
   z.x = uint16(zeros(size(A.x)));
   [L,U,P] = lu(A);
   for i = 1:size(A.x,2)
      temp = lsolve(L,gf(double(P.x)*((1:size(A.x,2))'==i),A.m,A.prim_poly));
      temp = usolve(U,temp);      
      z.x(:,i) = temp.x;
   end
end   
