function H = hadamard(n)
%HADAMARD Hadamard matrix.
%   HADAMARD(N) is a Hadamard matrix of order N, that is,
%   a matrix H with elements 1 or -1 such that H'*H = N*EYE(N).
%   An N-by-N Hadamard matrix with N > 2 exists only if REM(N,4)=0.
%   This function handles only the cases where N, N/12 or N/20
%   is a power of 2.

%   Author: N.J. Higham 11-14-91.  Revised by CBM, 6/24/92.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/05/01 20:41:35 $

%   Reference: S.W. Golomb and L.D. Baumert, The search for Hadamard
%   matrices, Amer. Math. Monthly, 70 (1963) pp. 12-17.

[f,e] = log2([n n/12 n/20]);
k = find(f==1/2 & e>0);
if min(size(n)) > 1 || isempty(k)
   error('MATLAB:hadamard:InvalidInput',...
         'n must be an integer and n, n/12 or n/20 must be a power of 2.');
end
e = e(k)-1;

if k == 1        % N = 1 * 2^e;
   H = 1;

elseif k == 2    % N = 12 * 2^e;
   H = [ones(1,12); ones(11,1) ...
        toeplitz([-1 -1 1 -1 -1 -1 1 1 1 -1 1],[-1 1 -1 1 1 1 -1 -1 -1 1 -1])];

elseif k == 3    % N = 20 * 2^e;
   H = [ones(1,20); ones(19,1)   ...
        hankel([-1 -1 1 1 -1 -1 -1 -1 1 -1 1 -1 1 1 1 1 -1 -1 1], ...
               [1 -1 -1 1 1 -1 -1 -1 -1 1 -1 1 -1 1 1 1 1 -1 -1])];
end

%  Kronecker product construction.
for i = 1:e
    H = [H  H
         H -H];
end
