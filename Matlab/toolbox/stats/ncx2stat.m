function [m,v]= ncx2stat(nu,delta)
%NCX2STAT Mean and variance for the noncentral chi-square distribution.
%   [M,V] = NCX2STAT(NU,DELTA) returns the mean and variance
%   of the noncentral chi-square pdf with NU degrees of freedom and
%   noncentrality parameter, DELTA.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 50-51.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.1 $  $Date: 2003/11/01 04:27:30 $

if nargin < 2, 
    error('stats:ncx2stat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode, nu, delta] = distchck(2,nu,delta);

if errorcode > 0
    error('stats:ncx2stat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize the mean and variance to NaN.
m = zeros(size(nu));
m(:) = NaN;
v = zeros(size(nu));
v(:) = NaN;

% Compute mean and variance for valid parameter values.
k = (nu > 0 & delta >= 0);
if any(k(:))
    m(k) = delta(k) + nu(k);
    v(k) = 2*(nu(k) + 2*(delta(k)));
end
