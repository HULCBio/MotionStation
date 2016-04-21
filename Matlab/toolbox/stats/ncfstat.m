function [m,v]= ncfstat(nu1,nu2,delta)
%NCFSTAT Mean and variance for the noncentral F distribution.
%   [M,V] = NCFSTAT(NU1,NU2,DELTA) returns the mean and variance
%   of the noncentral F pdf with NU1 and NU2 degrees of freedom and
%   noncentrality parameter, DELTA.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 73-74.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.1 $  $Date: 2003/11/01 04:27:20 $

if nargin < 2, 
    error('stats:ncfstat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode, nu1, nu2, delta] = distchck(3,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfstat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize the mean and variance to zero.
m = zeros(size(delta)); v = m;

% Return NaN for mean and variance if NU2 is less than 2.
k = find(nu2 <= 2);
m(k) = NaN;
v(k) = NaN;

% Return NaN for variance if NU2 is less than or equal to 4.
v(nu2 <= 4) = NaN;

k = find(nu2 > 2);
if any(k)
   m(k) = nu2(k).*(nu1(k) + delta(k))./(nu1(k).*(nu2(k) - 2));
end

k = find(nu2 > 4);
if any(k)
   n1pd = nu1(k) + delta(k);
   n2m2 = nu2(k) - 2;
   n2dn1 = (nu2(k)./nu1(k)).^2;
   v(k) = 2*n2dn1.*(n1pd.^2 + (n1pd + delta(k)).*n2m2)./((nu2(k) - 4).*n2m2.^2);
end
