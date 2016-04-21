function [X,E,s] = polyeig(varargin)
%POLYEIG Polynomial eigenvalue problem.
%   [X,E] = POLYEIG(A0,A1,..,Ap) solves the polynomial eigenvalue problem
%   of degree p:
%      (A0 + lambda*A1 + ... + lambda^p*Ap)*x = 0.
%   The input is p+1 square matrices, A0, A1, ..., Ap, all of the same
%   order, n.  The output is an n-by-n*p matrix, X, whose columns
%   are the eigenvectors, and a vector of length n*p, E, whose
%   elements are the eigenvalues.
%      for j = 1:n*p
%         lambda = E(j)
%         x = X(:,j)
%         (A0 + lambda*A1 + ... + lambda^p*Ap)*x is approximately 0.
%      end
%
%   E = POLYEIG(A0,A1,..,Ap) is a vector of length n*p whose
%   elements are the eigenvalues of the polynomial eigenvalue problem.
%
%   Special cases:
%      p = 0, polyeig(A), the standard eigenvalue problem, eig(A).
%      p = 1, polyeig(A,B), the generalized eigenvalue problem, eig(A,-B).
%      n = 1, polyeig(a0,a1,..,ap), for scalars a0, ..., ap, 
%      is the standard polynomial problem, roots([ap .. a1 a0])
%
%   If both A0 and Ap are singular the problem is potentially ill-posed.
%   Theoretically, the solutions might not exist or might not be unique.
%   Computationally, the computed solutions may be inaccurate.
%   If one, but not both, of A0 and Ap is singular, the problem is well
%   posed, but some of the eigenvalues may be zero or "infinite".
%
%   [X,E,S] = POLYEIG(A0,A1,..,AP) also returns a P*N length vector of
%   condition numbers for the eigenvalues.
%   At least one of A0 and AP must be nonsingular.
%   Large condition numbers imply that the problem is near one with
%   multiple eigenvalues.
%
%   See also EIG, COND, CONDEIG.

%   Nicholas J. Higham and Francoise Tisseur
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.12.4.3 $  $Date: 2004/01/24 09:22:16 $
 
%   Build two n*p-by-n*p matrices:
%      A = [A0   0   0   0]   B = [-A1 -A2 -A3 -A4]
%          [ 0   I   0   0]       [  I   0   0   0]
%          [ 0   0   I   0]       [  0   I   0   0]
%          [ 0   0   0   I]       [  0   0   I   0]

n = length(varargin{1});
p = nargin-1;
if (nargout > 2) && (p < 2)
    error('MATLAB:polyeig:tooFewInputs', ...
        'Must provide at least two matrices.')
end

A = eye(n*p);
A(1:n,1:n) = varargin{1};
if p == 0
    B = eye(n);
    p = 1;
else
    B = diag(ones(n*(p-1),1),-n);
    j = 1:n;
    for k = 1:p
        B(1:n,j) = - varargin{k+1};
        j = j+n;
    end
end

% Use the QZ algorithm on the big matrix pair (A,B).
if nargout > 1
    [X,E] = eig(A,B);
    E = diag(E);
else
    X = eig(A,B);
    return
end

if p == 1
    return
end

% For each eigenvalue, extract the eigenvector from whichever portion
% of the big eigenvector matrix X gives the smallest normalized residual.
V = zeros(n,p);
% Division by zero possible for zero eigenvalues, so turn off warnings.
warns = warning('query','all'); warning('off','MATLAB:divideByZero');
for j = 1:p*n
    V(:) = X(:,j);
    R = varargin{p+1};
    if ~isinf(E(j))
        for k = p:-1:1
            R = varargin{k} + E(j)*R;
        end
    end
    R = R*V;
    res = sum(abs(R))./ sum(abs(V));  % Normalized residuals.
    [ignore,ind] = min(res);
    X(1:n,j) = V(:,ind)/norm(V(:,ind));  % Eigenvector with unit 2-norm.
end
X = X(1:n,:);
warning(warns)

if (nargout > 2)
    % Construct matrix Y whose rows are conjugates of left eigenvectors.
    rcond_p = rcond(varargin{p+1});
    rcond_0 = rcond(varargin{1});
    if max(rcond_p,rcond_0) <= eps
        error('MATLAB:polyeig:nonSingularCoeffMatrix', ...
            ['Either the leading or the trailing coefficient matrix must be' ...
                ' nonsingular.'])
    end
    if rcond_p >= rcond_0
        V = varargin{p+1}; E1 = E;
    else
        V = varargin{1}; E1 = 1./E;
    end
    Y = X;
    for i=1:p-1
        Y = [Y; Y(end-n+1:end,:)*diag(E1)];
    end
    B = zeros(p*n,n); B(end-n+1:end,1:n) = eye(n);
    Y = Y\B/V;
    for i = 1:n*p, Y(i,:) = Y(i,:)/norm(Y(i,:)); end % Normalize left eigenvectors.
    
    % Reconstruct alpha-beta representation of eigenvalues: E(i) = a(i)/b(i).
    a = E;
    b = ones(size(a));
    k = isinf(a); a(k) = 1; b(k) = 0;
    
    nu = zeros(p+1,1);
    for i = 1:p+1, nu(i) = norm(varargin{i},'fro'); end
    s = zeros(n*p,1);
    
    % Compute condition numbers.
    for j = 1:p*n
        ab = (a(j).^(0:p-1)).*(b(j).^(p-1:-1:0));
        Da = ab(1)*varargin{2};
        Db = p*ab(1)*varargin{1};
        for k = 2:p
            Da = Da + k*ab(k)*varargin{k+1};
            Db = Db + (p-k+1)*ab(k)*varargin{k};
        end
        nab = norm( (a(j).^(0:p)) .* (b(j).^(p:-1:0)) .* nu' );
        s(j) = nab / abs( Y(j,:) * (conj(b(j))*Da-conj(a(j))*Db) * X(:,j) );
    end
    
end
