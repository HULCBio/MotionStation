function [phat, pci] = betafit(x,alpha)
%BETAFIT Parameter estimates and confidence intervals for beta distributed data.
%   BETAFIT(X) Returns the maximum likelihood estimates of the  
%   parameters of the beta distribution given the data in the vector, X.  
%
%   [PHAT, PCI] = BETAFIT(X,ALPHA) gives MLEs and 100(1-ALPHA) 
%   percent confidence intervals given the data. By default, the
%   optional parameter ALPHA = 0.05 corresponding to 95% confidence intervals.
%
%   This function requires all X values to be greater than 0 and
%   less than 1.  You can restrict the fit to valid values by typing
%
%        BETAFIT(X(X>0 & X<1))
%
%   If values are equal to 0 or 1 up to a precision of 1e-6, you
%   can round the X values away from 0 and 1 by typing
%
%        BETAFIT(MAX(1e-6, MIN(1-1e-6,X)))
%
%   See also BETACDF, BETAINV, BETAPDF, BETARND, BETASTAT, MLE. 

%   Reference:
%      [1]  Hahn, Gerald J., & Shapiro, Samuel, S.
%      "Statistical Models in Engineering", Wiley Classics Library
%      John Wiley & Sons, New York. 1994 p. 95.

%   Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 2.15.2.1 $  $Date: 2003/11/01 04:25:02 $

if nargin < 2 
    alpha = 0.05;
end
p_int = [alpha/2; 1-alpha/2];

if min(size(x)) > 1
  error('stats:betafit:VectorRequired','The first input must be a vector.');
end
x = x(~isnan(x));

if ((min(x) <= 0) | (max(x) >= 1))
  error('stats:betafit:BadData',...
        'All values must be larger than 0 and smaller than 1.');
end

n = length(x);

if (min(x) == max(x))
   error('stats:betafit:BadData',...
         'Cannot fit a beta distribution if all values are the same.');
end

% Initial Estimates.
tmp1 = prod((1-x) .^ (1/n));
tmp2 = prod(x .^ (1/n));
tmp3 = (1 - tmp1 - tmp2);
ahat = 0.5*(1-tmp1) / tmp3;
bhat = 0.5*(1-tmp2) / tmp3;

pstart = [ahat bhat];
ld = sum(log(x));
l1d = sum(log(1-x));
phat = fminsearch('betalik1',pstart,optimset('display','none'),ld,l1d,n);


if nargout == 2
  [logL,info]=betalike(phat,x);
  sigma = sqrt(diag(info));
  pci = norminv([p_int p_int],[phat; phat],[sigma';sigma']);
end
