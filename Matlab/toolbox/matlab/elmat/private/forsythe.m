function A = forsythe(n, alpha, lambda)
%FORSYTHE Forsythe matrix (perturbed Jordan block).
%   A = GALLERY('FORSYTHE',N,ALPHA,LAMBDA) is the N-by-N matrix 
%   equal to the Jordan block with eigenvalue LAMBDA with the 
%   exception that A(N,1) = ALPHA. ALPHA defaults to SQRT(EPS) and 
%   LAMBDA to 0.
%
%   The characteristic polynomial of A is given by
%      det(A-t*I) = (LAMBDA-t)^N - ALPHA*(-1)^N.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:42:14 $

if nargin < 2, alpha = sqrt(eps); end
if nargin < 3, lambda = 0; end

A = jordbloc(n, lambda);
A(n,1) = alpha;
