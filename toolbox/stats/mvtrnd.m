function r = mvtrnd(c,df,cases);
%MVTRND Random matrices from the multivariate t distribution.
%   R = MVTRND(C,DF,CASES) returns a matrix of random numbers from
%   the multivariate t distribution.  C is a correlation matrix and
%   DF is the degrees of freedom.  CASES is the number of rows in R.
%
%   Each row of R is generated as a multivariate normal random vector
%   with mean 0 and covariance C, divided by a scaled chi-square
%   random variate with DF degrees of freedom.  C is a symmetric
%   non-negative definite matrix.  Typically C is a correlation
%   matrix; if its diagonal elements are not 1, it is scaled to
%   correlation form.  CASES is the number of rows in R.
%
%   See also MVNRND.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/11/01 04:27:07 $

if (nargin < 3)
   error('stats:mvtrnd:TooFewInputs','MVTRND requires three arguments.');
end

[m n] = size(c);
if (m ~= n)
   error('stats:mvtrnd:BadCorrelation',...
         'The correlation matrix C must be square');
end

df = df(:);
if (length(df)~=1 & length(df)~=cases)
   error('stats:mvtrnd:InputSizeMismatch',...
         'DF must be a scalar or a vector with CASES elements.');
end

% Make sure C is a correlation matrix, then get Cholesky factor
s = diag(c);
if (any(s~=1))
   c = c ./ sqrt(s * s');
end
[T,p] = chol(c);
if (p ~= 0)
   error('stats:mvtrnd:BadCorrelation',...
         'C must be a positive definite matrix.');
end

% Generate normal and sqrt(normalized chi-square), then divide
r = randn(cases, n) * T;
x = sqrt(gamrnd(df./2, 2, cases, 1) ./ df);
r = r ./ x(:,ones(n,1));
