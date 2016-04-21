function [ndim, prob, chisquare] = barttest(x,alpha);
%BARTTEST Bartlett's test for dimensionality of the data in X.
%   [NDIM, PROB, CHISQUARE] = BARTTEST(X,ALPHA) requires a data matrix X and
%   a significance probability, ALPHA. It returns the number of dimensions
%   necessary to explain the nonrandom variation in X. The hypothesis is that 
%   the number of dimensions is equal to the number of the largest unequal 
%   eigenvalues of the covariance matrix of X.
%   CHISQUARE is a vector of statistics for testing this hypothesis 
%   sequentially for one, two, three, etc. dimensions.
%   PROB is the vector of significance probabilities that correspond to each
%   element of CHISQUARE.

%   Reference: J. Edward Jackson, "A User's Guide to Principal Components",
%   John Wiley & Sons, Inc. 1991 pp. 33-34.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.2.2 $  $Date: 2003/11/18 03:12:30 $

if nargin == 1
  alpha = 0.05;
end

[r, c] = size(alpha);
if ~isscalar(alpha) || ~isnumeric(alpha) || alpha<=0 || alpha>=1
   error('stats:barttest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

[nu,n] = size(x);
if n<=1 || nu<=1
   error('stats:barttest:NotEnoughData',...
         'X must have more than one row and column.');
end

% Compute latent = svd(cov(x)), but more efficient
latent = sort((svd(x - repmat(mean(x,1),nu,1)) .^ 2) / (nu-1));

% Let N be the number of rows in x.  nu should be N-1 (the
% degrees of freedom) according to Jackson, although Krzanowski,
% "Principles of Multivariate Analysis," Oxford, 1988, describes
% using N or N-(2p+11)/6.
nu = nu-1;

k = (0:n-2)';
lnlatent = flipud(cumsum(log(latent)));

pk = n - k;

logsum = log(flipud((latent(1)+cumsum(latent(2:n)))./flipud(pk)));
chisquare = (pk.*logsum - lnlatent(1:n-1))*nu;
df = (pk-1).*(pk+2)/2;
prob = 1-chi2cdf(chisquare,df);
dim  = min(find(prob>alpha));
if isempty(dim)
   ndim = n;
   return;
end
if dim == 1
   ndim = NaN;
   disp('The heuristics behind Bartlett''s Test are being violated for this data.'); 
else
   ndim = dim - 1;
end

