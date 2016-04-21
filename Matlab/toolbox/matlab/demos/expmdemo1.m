function E = expmdemo1(A)
%EXPMDEMO1  Matrix exponential via Pade approximation.
%   E = EXPMDEMO1(A) is an M-file implementation of the built-in
%   algorithm used by MATLAB for the matrix exponential.
%   See Golub and Van Loan, Matrix Computations, Algorithm 11.3-1.
%
%   See also EXPM, EXPMDEMO2, EXPMDEMO3.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:24:38 $

% Scale A by power of 2 so that its norm is < 1/2 .
[f,e] = log2(norm(A,'inf'));
s = max(0,e+1);
A = A/2^s;

% Pade approximation for exp(A)
X = A; 
c = 1/2;
E = eye(size(A)) + c*A;
D = eye(size(A)) - c*A;
q = 6;
p = 1;
for k = 2:q
   c = c * (q-k+1) / (k*(2*q-k+1));
   X = A*X;
   cX = c*X;
   E = E + cX;
   if p
     D = D + cX;
   else
     D = D - cX;
   end
   p = ~p;
end
E = D\E;

% Undo scaling by repeated squaring
for k=1:s, E = E*E; end

