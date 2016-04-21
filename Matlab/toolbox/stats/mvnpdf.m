function y = mvnpdf(X, Mu, Sigma)
%MVNPDF Multivariate normal probability density function (pdf).
%   Y = MVNPDF(X) returns the n-by-1 vector Y, containing the probability
%   density of the multivariate normal distribution with zero mean and
%   identity covariance matrix, evaluated at each row of the n-by-d matrix
%   X. Rows of X correspond to observations and columns correspond to
%   variables or coordinates.
%
%   Y = MVNPDF(X,MU) returns the density of the multivariate normal
%   distribution with mean MU and identity covariance matrix, evaluated
%   at each row of X.  MU is a 1-by-d vector, or an n-by-d matrix, in which
%   case the density is evaluated for each row of X with the corresponding
%   row of MU.  MU can also be a scalar value, which MVNPDF replicates to
%   match the size of X.
%
%   Y = MVNPDF(X,MU,SIGMA) returns the density of the multivariate normal
%   distribution with mean MU and covariance SIGMA, evaluated at each row
%   of X.  SIGMA is a d-by-d matrix, or an d-by-d-by-n array, in which case
%   the density is evaluated for each row of X with the corresponding page
%   of SIGMA, i.e., MVNPDF computes Y(I) using X(I,:) and SIGMA(:,:,I).
%   Pass in the empty matrix for MU to use its default value when you want
%   to only specify SIGMA.
%
%   If X is a 1-by-d vector, MVNPDF replicates it to match the leading
%   dimension of MU or the trailing dimension of SIGMA.
%
%   Example:
%
%      mu = [1 -1];
%      Sigma = [.9 .4; .4 .3];
%      X = mvnrnd(mu, Sigma, 10);
%      p = mvnpdf(X, mu, Sigma);
%
%   See also MVNRND, NORMPDF.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/01/16 20:09:41 $

if nargin < 1 | isempty(X)
    error('stats:mvnpdf:InputSizeMismatch','Requires the input argument X.');
elseif ndims(X) > 2
    error('stats:mvnpdf:InvalidData','X must be a matrix.');
end

% Get size of data.  Column vectors provisionally interpreted as multiple scalar data.
[n,d] = size(X);

% Assume zero mean, data are already centered
if nargin < 2 | isempty(Mu)
    X0 = X;

% Get scalar mean, and use it to center data
elseif prod(size(Mu)) == 1
    X0 = X - Mu;

% Get vector mean, and use it to center data
elseif ndims(Mu) == 2
    [n2,d2] = size(Mu);
    if d2 ~= d % has to have same number of coords as X
        error('stats:mvnpdf:InputSizeMismatch',...
              'X and MU must have the same number of columns.');
    elseif n2 == n % lengths match
        X0 = X - Mu;
    elseif n2 == 1 % mean is a single row, rep it out to match data
        X0 = X - repmat(Mu,n,1);
    elseif n == 1 % data is a single row, rep it out to match mean
        n = n2;
        X0 = repmat(X,n2,1) - Mu;
    else % sizes don't match
        error('stats:mvnpdf:InputSizeMismatch',...
              'X or MU must be a row vector, or X and MU must have the same number of rows.');
    end
    
else
    error('stats:mvnpdf:BadMu','MU must be a matrix.');
end

% Assume identity covariance, data are already standardized
if nargin < 3 | isempty(Sigma)
    % Special case: if Sigma isn't supplied, then interpret X
    % and Mu as row vectors if they were both column vectors
    if d == 1 & prod(size(X)) > 1
        X0 = X0';
        [n,d] = size(X0);
    end
    xRinv = X0;
    sqrtInvDetSigma = 1;
    
% Single covariance matrix
elseif ndims(Sigma) == 2
    % Special case: if Sigma is supplied, then use it to try to interpret
    % X and Mu as row vectors if they were both column vectors.
    if (d == 1 & prod(size(X)) > 1) & size(Sigma,1) == n
        X0 = X0';
        [n,d] = size(X0);
    end
    
    % Make sure Sigma is the right size
    if size(Sigma,1) ~= d | size(Sigma,2) ~= d
        error('stats:mvnpdf:BadSigma',...
              'SIGMA must be a square matrix with size equal to the number of columns in X.');
    else
        % Make sure Sigma is a valid covariance matrix
        [spd,R] = isspd(Sigma);
        if spd
            % Create array of standardized data, vector of inverse det
            xRinv = X0 / R;
            sqrtInvDetSigma = 1 / prod(diag(R));
        else
            error('stats:mvnpdf:BadSigma',...
                  'SIGMA must be symmetric and positive definite.');
        end
    end
    
% Multiple covariance matrices
elseif ndims(Sigma) == 3
    % Special case: if Sigma is supplied, then use it to try to interpret
    % X and Mu as row vectors if they were both column vectors.
    if (d == 1 & prod(size(X)) > 1) & size(Sigma,1) == n
        X0 = X0';
        [n,d] = size(X0);
    end
    
    % Data and mean are a single row, rep them out to match covariance
    if n == 1 % already know size(Sigma,3) > 1
        n = size(Sigma,3);
        X0 = repmat(X0,n,1); % rep centered data out to match cov
    end

    % Make sure Sigma is the right size
    if size(Sigma,1) ~= d | size(Sigma,2) ~= d
        error('stats:mvnpdf:InputSizeMismatch',...
              'Each page of SIGMA must be a square matrix with size equal to the number of columns in X.');
    elseif size(Sigma,3) ~= n
        error('stats:mvnpdf:InputSizeMismatch',...
              'SIGMA must have one page for each row of X.');
    else
        
        % Create array of standardized data, vector of inverse det
        xRinv = zeros(n,d);
        sqrtInvDetSigma = zeros(n,1);
        for i = 1:n
            % Make sure Sigma is a valid covariance matrix
            [spd,R] = isspd(Sigma(:,:,i));
            if spd
                xRinv(i,:) = X0(i,:) / R;
                sqrtInvDetSigma(i) = 1 / prod(diag(R));
            else
                error('stats:mvnpdf:BadSigma',...
                      'SIGMA must be symmetric and positive definite.');
            end
        end
    end
   
elseif ndims(Sigma) > 3
    error('stats:mvnpdf:BadSigma',...
          'SIGMA must be a matrix or a 3 dimensional array.');
end

% Exponents in pdf are the inner products of the standardized data
quadform = sum(xRinv.^2, 2);
y = sqrt((2*pi)^(-d)) * sqrtInvDetSigma .* exp(-0.5*quadform);


function [t,R] = isspd(Sigma)
%ISPDS Test if a matrix is positive definite symmetric
% T = ISPDS(SIGMA) returns a logical indicating whether the matrix SIGMA is
% square, symmetric, and positive definite, i.e., it is a valid full rank
% covariance matrix.
%
% [T,R] = ISPDS(SIGMA) returns the cholesky factor of SIGMA in R.  If SIGMA
% is not square symmetric, ISPDS returns [] in R.

% Test for square, symmetric
[n,m] = size(Sigma);
if (n == m) & all(all(abs(Sigma - Sigma') < 10*eps(max(abs(diag(Sigma))))))
    % Test for positive definiteness
    [R,p] = chol(Sigma);
    if p == 0
        t = true;
    else
        t = false;
    end
else
    R = [];
    t = false;
end