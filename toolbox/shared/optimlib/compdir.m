function [SD, dirType] = compdir(Z,H,gf,nvars,f);
% COMPDIR Computes a search direction in a subspace defined by Z.  [SD,
% dirType] = compdir(Z,H,gf,nvars,f) returns a search direction for the
% subproblem 0.5*Z'*H*Z + Z'*gf. Helper function for NLCONST. SD is Newton
% direction if possible. SD is a direction of negative curvature if the
% Cholesky factorization of Z'*H*Z fails. If the negative curvature
% direction isn't negative "enough", SD is the steepest descent direction.
% For singular Z'*H*Z, SD is the steepest descent direction even if small,
% or even zero, magnitude.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/20 23:20:26 $

% Define constant strings
Newton = 'Newton';                     % Z'*H*Z positive definite
NegCurv = 'negative curvature chol';   % Z'*H*Z indefinite
SteepDescent = 'steepest descent';     % Z'*H*Z (nearly) singular

dirType = [];
% Compute the projected Newton direction if possible
projH = Z'*H*Z;
[R, p] = chol(projH);
if ~p  % positive definite: use Newton direction
    %  SD=-Z*((Z'*H*Z)\(Z'*gf));
    SD = - Z*(R \ ( R'\(Z'*gf)));
    dirType = Newton;
else % not positive definite
    [L,sneg] = choltrap(projH);
    if ~isempty(sneg) & sneg'*projH*sneg < -sqrt(eps) % if negative enough
        SD = Z*sneg;
        dirType = NegCurv;
    else % Not positive definite, not negative definite "enough",
        % so use steepest descent direction
        stpDesc = - Z*(Z'*gf);
        % ||SD|| may be (close to) zero, but qpsub handles that case
        SD = stpDesc;
        dirType = SteepDescent;
    end %   
end % ~p  (positive definite)

% Make sure it is a descent direction
if gf'*SD > 0
    SD = -SD;
end

%-----------------------------------------------
function [L,sneg] = choltrap(A)
% CHOLTRAP Compute Cholesky factor or direction of negative curvature.
%     [L, SNEG] = CHOLTRAP(A) computes the Cholesky factor L, such that
%     L*L'= A, if it exists, or returns a direction of negative curvature
%     SNEG for matrix A when A is not positive definite. If A is positive
%     definite, SNEG will be []. 
%
%     If A is singular, it is possible that SNEG will not be a direction of
%     negative curvature (but will be nonempty). In particular, if A is
%     positive semi-definite, SNEG will be nonempty but not a direction of
%     negative curvature. If A is indefinite but singular, SNEG may or may
%     not be a direction of negative curvature.

sneg = [];
n = size(A,1);
L = eye(n);
tol = 0;    % Dividing by sqrt of small number isn't a problem 
for k=1:n-1
    if A(k,k) <= tol
        elem = zeros(length(A),1); 
        elem(k,1) = 1;
        sneg = L'\elem;
        return;
    else
        L(k,k) = sqrt(A(k,k));
        s = k+1:n;
        L(s,k) = A(s,k)/L(k,k);
        A(k+1:n,k+1:n) =  A(k+1:n,k+1:n)  - tril(L(k+1:n,k)*L(k+1:n,k)');   
    end
end
if A(n,n) <= tol
    elem = zeros(length(A),1); 
    elem(n,1) = 1;
    sneg = L'\elem;
else
    L(n,n) = sqrt(A(n,n));
end

