function eigmovie(A)
%EIGMOVIE Symmetric eigenvalue movie.
%   EIGMOVIE(A) shows a "movie" that depicts the computation of
%   the eigenvalues of a symmetric matrix.
%   EIGMOVIE, by itself, uses A = pascal(6)/2.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.10.4.3 $  $Date: 2004/04/10 23:24:34 $

commandwindow

Old_Format=get(0,'Format');
if nargin < 1
   A = pascal(6)/2;
end

n = length(A);
A = (A + A')/2;
more off
clc
format short
home
disp('Symmetrized input matrix')
A
disp('Pause. Press any key to continue.'), pause
I = eye(size(A));

for k = 2:n-1
   home
   disp(['Householder similarity transformation ' int2str(k-1)]) 
   u = A(:,k-1);
   u(1:k-1) = zeros(k-1,1);
   u = u/norm(u);
   if u(k) < 0, u = -u; end
   u(k) = u(k) + 1;
   beta = -u(k);  % -(norm(u)^2)/2
   v = A*u/beta;
   gamma = v'*u/(2*beta);
   v = v + gamma*u;
   A  =  A + u*v' + v*u';
   j = (k+1):n;  z = zeros(n-k,1);
   A(j,k-1) = z;  A(k-1,j) = z';
   A
   disp('Pause. Press any key to continue.'), pause
end
home

clc
it = 0;
while n > 0
   home
   disp(['Symmetric tridiagonal QR iteration ' int2str(it) '   '])
   d = diag(A); e = diag(A,-1);
   A = diag(d) + diag(e,-1) + diag(e,1)
   if n > 1, k = n-1:n; else k = 1:2; end
   S = A(k,k);
   disp('Lower 2-by-2 = ')
   disp(' ')
   format long e
   disp(S)
   format short
   disp('Pause. Press any key to continue.'), pause
   if n == 1, break, end
   if abs(S(2,1)) < eps*(abs(S(1,1)) + abs(S(2,2)))
      A(n,n-1) = 0;  A(n-1,n) = 0;
      n = n-1;
   else
      shift = eig(S);
      if abs(shift(1)-A(n,n)) < abs(shift(2)-A(n,n))
         shift = shift(1); 
      else 
          shift = shift(2); 
      end
      [Q,R] = qr(A-shift*I);
      A = R*Q+shift*I;
   end
   it = it + 1;
end
disp('Done.')

%  Restore Format
set(0,'Format',Old_Format)