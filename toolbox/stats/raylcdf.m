function p = raylcdf(x,b)
%RAYLCDF  Rayleigh cumulative distribution function.
%   P = RAYLCDF(X,B) returns the Rayleigh cumulative distribution 
%   function with parameter B at the values in X.
%
%   The size of P is the common size of X and B. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 134-136.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.3 $  $Date: 2004/01/16 20:10:22 $

if nargin < 1
    error('stats:raylcdf:TooFewInputs',...
          'Requires at least one input argument.'); 
end
if nargin<2
    b = 1;
end

[errorcode x b] = distchck(2,x,b);

if errorcode > 0
    error('stats:raylcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single')
    p=zeros(size(x),'single');
else
    p=zeros(size(x));
end

% Return NaN if B is not positive.
k1 = find(b <= 0);
if any(k1) 
    tmp   = NaN;
    p(k1) = tmp(ones(size(k1)));
end

k=find(b > 0 & x >= 0);
if any(k),
   xk = x(k);
   bk = b(k);
    p(k) = 1 - exp(-xk .^ 2 ./ (2*bk .^ 2));
end
