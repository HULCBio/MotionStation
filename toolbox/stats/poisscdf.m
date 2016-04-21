function p = poisscdf(x,lambda)
%POISSCDF Poisson cumulative distribution function.
%   P = POISSCDF(X,LAMBDA) computes the Poisson cumulative
%   distribution function with parameter LAMBDA at the values in X.
%
%   The size of P is the common size of X and LAMBDA. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.22.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.2.2 $  $Date: 2004/01/16 20:09:59 $
 
if nargin < 2, 
    error('stats:poisscdf:TooFewInputs','Requires two input arguments.'); 
end

scalarlambda = (prod(size(lambda)) == 1);

[errorcode x lambda] = distchck(2,x,lambda);

if errorcode > 0
    error('stats:poisscdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if ~isfloat(x)
   x = double(x);
   p = zeros(size(x));
else
   p = zeros(size(x),class(x));
end
xx = floor(x);

% Return NaN if Lambda is not positive.
p(lambda < 0) = NaN;

% Compute P when X is positive.
k = find(xx >= 0 & lambda >= 0);
val = max(xx(:));

if scalarlambda
  tmp = cumsum(poisspdf(0:val,lambda(1)));            
  p(k) = tmp(xx(k) + 1);
else
  compare = repmat((0:val)',1,length(k));
  bigx = xx(k);
  bigx = bigx(:);
  bigx = bigx(:,ones(1,val+1))';
  biglambda = lambda(k);
  biglambda = biglambda(:);
  biglambda = biglambda(:,ones(1,val+1))';
  index = (bigx >= compare);
  indicator = zeros(size(compare));
  indicator(index) = poisspdf(compare(index),biglambda(index));
  p(k) = sum(indicator,1);
end 

% Make sure that round-off errors never make P greater than 1.
p(p>1) = 1;
