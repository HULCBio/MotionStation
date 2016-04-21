function X = mldivide(A, B)
%MLDIVIDE Symbolic matrix left division.
%   MLDIVIDE(A,B) overloads symbolic A \ B.
%   X = A\B solves the symbolic linear equations A*X = B.
%   Warning messages are produced if X does not exist or is not unique.  
%   Rectangular matrices A are allowed, but the equations must be
%   consistent; a least squares solution is not computed.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/04/16 22:22:54 $

A = sym(A);
B = sym(B);

if all(size(A) == 1)
   % Division by a scalar
   X = ldivide(A,B);

elseif ndims(A) > 2 | ndims(B) > 2
   error('symbolic:sym:mldivide:errmsg1','Input arguments must be 2-D.')

elseif size(A,1) ~= size(B,1)
   error('symbolic:sym:mldivide:errmsg2','First dimensions must agree.')

else
   % Matrix divided by matrix

   X = maple('linsolve',char(A),char(B),'''_rank''');

   % Solution does not exist.
   if isempty(X)
      warning('symbolic:sym:mldivide:warnmsg1','System is inconsistent. Solution does not exist.')
      X = Inf;
      X = sym(X(ones(size(A,2),size(B,2))));
      maple('_rank := ''_rank'';');
      return
   end;

   % Check rank and clear _rank in Maple workspace.
   if str2double(maple('_rank')) < min(size(A))
      warning('symbolic:sym:mldivide:warnmsg2','System is rank deficient. Solution is not unique.')
   end
   maple('_rank := ''_rank'';');

   % Set any free parameters, _t[k][j], to zero.
   t = findstr(X,'_t[');
   s = findstr(X,']');
   for k = fliplr(t)
      r = s(s > k);
      X(k:r(2)) = '0';
   end
   X = maple('',sym(X));
end
