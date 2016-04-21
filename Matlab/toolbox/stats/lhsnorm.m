function [X,z] = lhsnorm(mu,sigma,n,dosmooth)
%LHSNORM Generate a latin hypercube sample with a normal distribution
%   X=LHSNORM(MU,SIGMA,N) generates a latin hypercube sample X of size
%   N from the multivariate normal distribution with mean vector M
%   and covariance matrix SIGMA.  X is similar to a random sample from
%   the multivariate normal distribution, but the marginal distribution
%   of each column is adjusted so that its its sample marginal
%   distribution is close to its theoretical normal distribution.
%
%   X=LHSNORM(MU,SIGMA,N,'ONOFF') controls the amount of smoothing in the
%   sample.  If 'ONOFF' is 'off', each column has points equally spaced
%   on the probability scale.  In other words, each column is a permutation
%   of the values G(.5/N), G(1.5/N), ..., G(1-.5/N) where G is the inverse
%   normal cumulative distribution for that column's marginal distribution.
%   If 'ONOFF' is 'on' (the default), each column has points uniformly
%   distributed on the probability scale.  For example, in place of
%   0.5/N we use a value having a uniform distribution on the                  
%   interval (0/N,1/N).            
%
%   See also LHSDESIGN, MVNRND.

%   Reference:  Stein, M. (1987), "Large sample properties of simulations
%   using latin hypercube sampling," Technometrics, V. 29, No. 2, p. 143.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.2 $  $Date: 2004/01/24 09:34:18 $

% Generate a random sample with a specified distribution and
% correlation structure -- in this case multivariate normal
z = mvnrnd(mu,sigma,n);

% Find the ranks of each column
p = length(mu);
x = zeros(size(z),class(z));
for i=1:p
   x(:,i) = rank(z(:,i));
end

% Get gridded or smoothed-out values on the unit interval
if (nargin<4) || isequal(dosmooth,'on')
   x = x - rand(size(x));
else
   x = x - 0.5;
end
x = x / n;

% Transform each column back to the desired marginal distribution,
% maintaining the ranks (and therefore rank correlations) from the
% original random sample
for i=1:p
   x(:,i) = norminv(x(:,i),mu(i), sqrt(sigma(i,i)));
end
X = x;

% -----------------------
function r=rank(x)

% Similar to tiedrank, but no adjustment for ties here
[sx, rowidx] = sort(x);
r(rowidx) = 1:length(x);
r = r(:);
