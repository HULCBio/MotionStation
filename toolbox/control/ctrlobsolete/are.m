function X = are(A,B,C)
%ARE  Algebraic Riccati Equation solution.
%
%    X = ARE(A, B, C) returns the stablizing solution (if it
%    exists) to the continuous-time Riccati equation:
%
%           A'*X + X*A - X*B*X + C = 0
%
%    assuming B is symmetric and nonnegative definite and C is
%    symmetric.
%
%    See also  RIC, CARE, DARE.

%       M. Wette, ECE Dept., Univ. of California 5-11-87
%       Revised 6-16-87 MW
%               3-16-88 MW
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:35:10 $

%  -- check for correct input problem --
[nr,nc] = size(A); n = nr;
if (nr ~= nc), error('Nonsquare A matrix'); end;
[nr,nc] = size(B);
if (nr~=n | nc~=n), error('Incorrectly dimensioned B matrix'); end;
[nr,nc] = size(C);
if (nr~=n | nc~=n), error('Incorrectly dimensioned C matrix'); end;

% Following is much faster than before
[q,t] = schur([A -B; -C -A']);
[q,t] = rsf2csf(q,t);

tol = 10.0*eps*max(abs(diag(t)));   % ad hoc tolerance
ns = 0;
%
%  Prepare an array called index to send message to ordering routine 
%  giving location of eigenvalues with respect to the imaginary axis.
%  -1  denotes open left-half-plane
%   1  denotes open right-half-plane
%   0  denotes within tol of imaginary axis
%
index = [];  
for i = 1:2*n,
    if (real(t(i,i)) < -tol),
        index = [ index -1 ];
    ns = ns + 1;
    elseif (real(t(i,i)) > tol),
    index = [ index 1 ];
    else,
    index = [ index 0 ];
    end;
end;
if (ns ~= n), error('No solution: (A,B) may be uncontrollable or no solution exists'); end;
[q,t] = schord(q,t,index);
X = real(q(n+1:n+n,1:n)/q(1:n,1:n));

