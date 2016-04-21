function [U,S,V,flag] = svds(varargin)
%SVDS   Find a few singular values and vectors.
%   If A is M-by-N, SVDS(A,...) manipulates a few eigenvalues and vectors
%   returned by EIGS(B,...), where B = [SPARSE(M,M) A; A' SPARSE(N,N)],
%   to find a few singular values and vectors of A.  The positive
%   eigenvalues of the symmetric matrix B are the same as the singular
%   values of A.
%
%   S = SVDS(A) returns the 6 largest singular values of A.
%
%   S = SVDS(A,K) computes the K largest singular values of A.
%
%   S = SVDS(A,K,SIGMA) computes the K singular values closest to the 
%   scalar shift SIGMA.  For example, S = SVDS(A,K,0) computes the K
%   smallest singular values.
%
%   S = SVDS(A,K,'L') computes the K largest singular values (the default).
%
%   S = SVDS(A,K,SIGMA,OPTIONS) sets some parameters (see EIGS):
%
%   Field name       Parameter                               Default
%
%   OPTIONS.tol      Convergence tolerance:                    1e-10
%                    NORM(A*V-U*S,1) <= tol * NORM(A,1).
%   OPTIONS.maxit    Maximum number of iterations.               300
%   OPTIONS.disp     Number of values displayed each iteration.    0
%
%   [U,S,V] = SVDS(A,...) computes the singular vectors as well.
%   If A is M-by-N and K singular values are computed, then U is M-by-K
%   with orthonormal columns, S is K-by-K diagonal, and V is N-by-K with
%   orthonormal columns.
%
%   [U,S,V,FLAG] = SVDS(A,...) also returns a convergence flag.
%   If EIGS converged then NORM(A*V-U*S,1) <= TOL * NORM(A,1) and
%   FLAG is 0.  If EIGS did not converge, then FLAG is 1.
%
%   Note: SVDS is best used to find a few singular values of a large,
%   sparse matrix.  To find all the singular values of such a matrix,
%   SVD(FULL(A)) will usually perform better than SVDS(A,MIN(SIZE(A))).
%
%   Example:
%      load west0479
%      sf = svd(full(west0479))
%      sl = svds(west0479,10)
%      ss = svds(west0479,10,0)
%      s2 = svds(west0479,10,2)
%
%      sl will be a vector of the 10 largest singular values, ss will be a
%      vector of the 10 smallest singular values, and s2 will be a vector
%      of the 10 singular values of west0479 which are closest to 2.
%
%   See also SVD, EIGS.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.2 $  $Date: 2004/03/02 21:48:32 $

A = varargin{1};
[m,n] = size(A);
p = min(m,n);
q = max(m,n);

% B's positive eigenvalues are the singular values of A
% "top" of B's eigenvectors correspond to left singular values of A
% "bottom" of B's eigenvectors correspond to right singular vectors of A
B = [sparse(m,m) A; A' sparse(n,n)];

if nargin < 2
   k = min(p,6);
else
   k = varargin{2};
end
if nnz(A) == 0
   if nargout <= 1
      U = zeros(k,1);
   else
      U = eye(m,k);
      S = zeros(k,k);
      V = eye(n,k);
      flag = 0;
   end
   return
end
if nargin < 3
   bk = min(p,k);
   if isreal(A)
       bsigma = 'LA';
   else
       bsigma = 'LR';
   end
else
   sigma = varargin{3};
   if sigma == 0 % compute a few extra eigenvalues to be safe
      bk = 2 * min(p,k);
   else
      bk = k;
   end
   if strcmp(sigma,'L')
       if isreal(A)
           bsigma = 'LA';
       else
           bsigma = 'LR';
       end
   elseif isa(sigma,'double')
      bsigma = sigma;
      if ~isreal(bsigma)
          error('MATLAB:svds:ComplexSigma', 'Sigma must be real.');
      end
   else
      error('MATLAB:svds:InvalidArg3',...
            'Third argument must be a scalar or the string ''L''.')
   end   
end
if nargin < 4
   % norm(B*W-W*D,1) / norm(B,1) <= tol / sqrt(2)
   % => norm(A*V-U*S,1) / norm(A,1) <= tol
   boptions.tol = 1e-10 / sqrt(2);
   boptions.disp = 0;
else
   options = varargin{4};
   if isstruct(options)
      if isfield(options,'tol')
         boptions.tol = options.tol / sqrt(2);
      else
         boptions.tol = 1e-10 / sqrt(2);
      end
      if isfield(options,'maxit')
         boptions.maxit = options.maxit;
      end
      if isfield(options,'disp')
         boptions.disp = options.disp;
      else
         boptions.disp = 0;
      end
   else
      error('MATLAB:svds:Arg4NotOptionsStruct',...
            'Fourth argument must be a structure of options.')
   end   
end

[W,D,bflag] = eigs(B,bk,bsigma,boptions);

if ~isreal(D) || (isreal(A) && ~isreal(W))
   error('MATLAB:svds:ComplexValuesReturned',...
         ['eigs([0 A; A'' 0]) returned complex values -' ...
         ' singular values of A cannot be computed in this way.'])
end

% permute D and W so diagonal entries of D are sorted by proximity to sigma
d = diag(D);
if strcmp(bsigma,'LA') || strcmp(bsigma,'LR')
   nA = max(d);
   [dum,ind] = sort(nA-d);
else
   nA = normest(A);
   [dum,ind] = sort(abs(d-bsigma));
end
d = d(ind);
W = W(:,ind);

% Tolerance to determine the "small" singular values of A.
% If eigs did not converge, give extra leeway.
if bflag 
   dtol = q * nA * sqrt(eps);
   uvtol = m * sqrt(sqrt(eps));
else
   dtol = q * nA * eps;
   uvtol = m * sqrt(eps);
end

% Which (left singular) vectors are already orthogonal, with norm 1/sqrt(2)?
UU = W(1:m,:)' * W(1:m,:);
dUU = diag(UU);
VV = W(m+(1:n),:)' * W(m+(1:n),:);
dVV = diag(VV);
indpos = find((d > dtol) & (abs(dUU-0.5) <= uvtol) & (abs(dVV-0.5) <= uvtol));
indpos = indpos(1:min(end,k));
npos = length(indpos);
U = sqrt(2) * W(1:m,indpos);
s = d(indpos);
V = sqrt(2) * W(m+(1:n),indpos);

% There may be 2*(p-rank(A)) zero eigenvalues of B corresponding
% to the rank deficiency of A and up to q-p zero eigenvalues
% of B corresponding to the difference between m and n.

if npos < k
   indzero = find(abs(d) <= dtol);
   QWU = orth(W(1:m,indzero));
   QWV = orth(W(m+(1:n),indzero));
   nzero = min([size(QWU,2), size(QWV,2), k-npos]);
   U = [U QWU(:,1:nzero)];
   s = [s; abs(d(indzero(1:nzero)))];
   V = [V QWV(:,1:nzero)];
end

% sort the singular values in descending order (as in svd)
[s,ind] = sort(s);
s = s(end:-1:1);
if nargout <= 1
   U = s;
else
   U = U(:,ind(end:-1:1));
   S = diag(s);
   V = V(:,ind(end:-1:1));
   flag = norm(A*V-U*S,1) > sqrt(2) * boptions.tol * norm(A,1);
end


