function [r,T] = mvnrnd(mu,sigma,cases,T);
%MVNRND Random vectors from the multivariate normal distribution.
%   R = MVNRND(MU,SIGMA) returns an n-by-d matrix R of random vectors
%   chosen from the multivariate normal distribution with mean vector MU,
%   and covariance matrix SIGMA.  MU is an n-by-d matrix, and MVNRND
%   generates each row of R using the corresponding row of MU.  SIGMA is a
%   d-by-d symmetric positive semi-definite matrix, or a d-by-d-by-n array.
%   If SIGMA is an array, MVNRND generates each row of R using the
%   corresponding page of SIGMA, i.e., MVNRND computes R(I,:) using MU(I,:)
%   and SIGMA(:,:,I).  If MU is a 1-by-d vector, MVNRND replicates it to
%   match the trailing dimension of SIGMA.
%
%   R = MVNRND(MU,SIGMA,CASES) returns a CASES-by-d matrix R of random
%   vectors chosen from the multivariate normal distribution with a common
%   1-by-d mean vector MU, and a common d-by-d covariance matrix SIGMA.

%   R = MVNRND(MU,SIGMA,CASES,T) supplies the Cholesky factor T of
%   SIGMA, so that SIGMA == T'*T.  No error checking is done on T.
%
%   [R,T] = MVNRND(...) returns the Cholesky factor T, so it can be
%   re-used to make later calls more efficient.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.4.2 $  $Date: 2004/03/09 16:16:47 $

if nargin < 2 | isempty(mu) | isempty(sigma)
    error('stats:mvnrnd:TooFewInputs',...
          'Requires the input arguments MU and SIGMA.');
elseif ndims(mu) > 2
    error('stats:mvnrnd:BadMu','MU must be a matrix.');
elseif ndims(sigma) > 3
    error('stats:mvnrnd:BadSigma',...
          'SIGMA must be a matrix or a 3-dimensional array.');
end

[n,d] = size(mu);

% Special case: if mu is a column vector, then use sigma to try
% to interpret it as a row vector.
if d == 1 & size(sigma,1) == n
    mu = mu';
    [n,d] = size(mu);
end

% Get size of data.
if nargin < 3 | isempty(cases)
    nocases = true; % cases not supplied
else
    nocases = false; % cases was supplied
    if n == cases
        % mu is ok
    elseif n == 1 % mu is a single row, make cases copies
        n = cases;
        mu = repmat(mu,n,1);
    else
        error('stats:mvnrnd:InputSizeMismatch',...
              'MU must be a row vector, or must have CASES rows.');
    end
end

% Single covariance matrix
if ndims(sigma) == 2
    % Make sure sigma is the right size
    if size(sigma,1) ~= d | size(sigma,2) ~= d
        error('stats:mvnrnd:InputSizeMismatch',...
              'SIGMA must be a square matrix with size equal to the number of columns in MU.');
    end
    
    % Factor sigma unless that has already been done, using a function
    % that will perform a Cholesky-like factorization as long as the
    % sigma matrix is positive semi-definite (can have perfect correlation).
    % Cholesky requires a positive definite matrix.  sigma == T'*T
    if nargin < 4
        [T p] = statchol(sigma);
        if p > 0
           error('stats:mvnrnd:BadSigma',...
                 'SIGMA must be a positive semi-definite matrix.');
        end
    end
    r = randn(n,size(T,1)) * T + mu;
    
% Multiple covariance matrices
elseif ndims(sigma) == 3
    % mu is a single row and cases not given, rep mu out to match sigma
    if n == 1 & nocases % already know size(sigma,3) > 1
        n = size(sigma,3);
        mu = repmat(mu,n,1);
    end
    
    % Make sure sigma is the right size
    if size(sigma,1) ~= d | size(sigma,2) ~= d
        error('stats:mvnrnd:InputSizeMismatch',...
              'Each page of SIGMA must be a square matrix with size equal to the number of columns in MU.');
    elseif size(sigma,3) ~= n
        error('stats:mvnrnd:InputSizeMismatch','SIGMA must have CASES pages.');
    end
    r = zeros(n,d);
    if nargin < 4
       if nargout > 1
          T = zeros(size(sigma));
       end
       for i = 1:n
           [R p] = statchol(sigma(:,:,i));
           if p > 0
              error('stats:mvnrnd:BadSigma',...
                    'SIGMA must be a positive semi-definite matrix.');
           end
           Rrows = size(R,1);
           r(i,:) = randn(1,Rrows) * R + mu(i,:);
           if nargout > 1
              T(1:Rrows,:,i) = R;
           end
       end
    else
       for i = 1:n
           r(i,:) = randn(1,d) * T(:,:,i) + mu(i,:);
       end
   end
end
