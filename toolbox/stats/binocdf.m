function y = binocdf(x,n,p)
%BINOCDF Binomial cumulative distribution function.
%   Y=BINOCDF(X,N,P) returns the binomial cumulative distribution
%   function with parameters N and P at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   The algorithm uses the cumulative sums of the binomial masses.

%   Reference:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.20.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.2.3 $  $Date: 2004/02/01 22:10:14 $

if nargin < 3, 
    error('stats:binocdf:TooFewInputs','Requires three input arguments.'); 
end 

scalarnp = (prod(size(n)) == 1 & prod(size(p)) == 1);

[errorcode x n p] = distchck(3,x,n,p);

if errorcode > 0
    error('stats:binocdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to 0.
if isa(x,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end

% Y = 1 if X >= N
k = find(x >= n);
y(k) = 1;


% assign 1 to p==0 indices.
k2 = (p == 0);
y(k2) = 1;

% assign 0 to p==1 indices
k3 = (p == 1);
y(k3) = x(k3)>=n(k3);

% Return NaN if any arguments are outside of their respective limits.
% this may overwrite k2 indices.
k1 = (n < 0 | p < 0 | p > 1 | round(n) ~= n | x < 0); 
y(k1) = NaN;

% Compute Y when 0 < X < N.
xx = floor(x);
if ~isfloat(xx)
   xx = double(xx);
end
k = find(xx >= 0 & xx < n & ~k1 & ~k2 & ~k3);
k = k(:);

% Accumulate the binomial masses up to the maximum value in X.
if any(k)
   val = max(xx(:));
   i = (0:val)';
   if scalarnp
      tmp = cumsum(binopdf(i,n(1),p(1)));
      y(k) = tmp(xx(k) + 1);
   else
      compare = i(:,ones(size(k)));
      index = xx(k);
      index = index(:);
      index = index(:,ones(size(i)))';
      nbig = n(k);
      nbig = nbig(:);
      nbig = nbig(:,ones(size(i)))';
      pbig = p(k);
      pbig = pbig(:);
      pbig = pbig(:,ones(size(i)))';
      y0 = binopdf(compare,nbig,pbig);
      indicator = find(compare > index);
      y0(indicator) = 0;
      y(k) = sum(y0,1);
   end
end

% Make sure that round-off errors never make P greater than 1.
k = find(y > 1);
y(k) = 1;


