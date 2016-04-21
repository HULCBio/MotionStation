%% Matrix Exponentials
% For background on the computation of matrix exponentials, see
% "Nineteen dubious ways to compute the exponential of a matrix,
% twenty-five years later," SIAM Review 45, 3-49, 2003.
%
% The Pseudospectra Gateway is also highly recommended.  The web site is:
%
% http://web.comlab.ox.ac.uk/projects/pseudospectra/
%
% Here are three of the 19 ways to compute the exponential of a matrix.

% Copyright 2004 The MathWorks, Inc.

%% Start with the matrix A.

A = [0 1 2; 0.5 0 1; 2 1 0]
Asave = A;

%% Scaling and squaring
% |expmdemo1| is an M-code implementation of the built-in algorithm used by 
% MATLAB for the matrix exponential. See Golub and Van Loan, Matrix
% Computations, 3rd edition, algorithm 11.3-1.  

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
for k = 1:s, E = E*E; end

E1 = E

%% Matrix exponential via Taylor series.
% |expmdemo2| uses the classic definition for the matrix exponential. As a
% practical numerical method, this is slow and inaccurate if |norm(A)| is
% too large.

A = Asave;

% Taylor series for exp(A)
E = zeros(size(A));
F = eye(size(A));
k = 1;
while norm(E+F-E,1) > 0
   E = E + F;
   F = A*F/k;
   k = k+1;
end

E2 = E

%% Matrix exponential via eigenvalues and eigenvectors.
% |expmdemo3| assumes that the matrix has a full set of eigenvectors. As a
% practical numerical method, the accuracy is determined by the condition
% of the eigenvector matrix.

A = Asave;

[V,D] = eig(A);
E = V * diag(exp(diag(D))) / V;

E3 = E

%% Compare the results.
% For this matrix, they all do equally well

E = expm(Asave);
err1 = E - E1
err2 = E - E2
err3 = E - E3

%% Taylor series fails.
% Here is a matrix where the terms in the Taylor series become very large
% before they go to zero.  Consequently, |expmdemo2| fails. 

A = [-147 72; -192 93];
E1 = expmdemo1(A)
E2 = expmdemo2(A)
E3 = expmdemo3(A)

%% Eigenvalues and vectors fails.
% Here is a matrix that does not have a full set of eigenvectors.
% Consequently, |expmdemo3| fails. 

A = [-1 1; 0 -1];
E1 = expmdemo1(A)
E2 = expmdemo2(A)
E3 = expmdemo3(A)
