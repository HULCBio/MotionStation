function y = ncx2pdf(x,v,delta)
%NCX2PDF Noncentral chi-square probability density function (pdf).
%   Y = NCX2PDF(X,V,DELTA) Returns the noncentral chi-square pdf with V 
%   degrees of freedom and noncentrality parameter, DELTA, at the values 
%   in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     
%
%   Some texts refer to this distribution as the generalized Rayleigh,
%   Rayleigh-Rice, or Rice distribution.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 50-52.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.4.4 $  $Date: 2004/01/16 20:09:54 $

if nargin <  3, 
    error('stats:ncx2pdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x v delta] = distchck(3,x,v,delta);

if errorcode > 0
    error('stats:ncx2pdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
if isa(x,'single')
   y = zeros(size(x),'single');
   s = sqrt(eps('single'));
else
   y=zeros(size(x));
   s = sqrt(eps);
end

y(x <= 0) = 0;  
y(delta < 0) = NaN; % can't have negative non-centrality parameter.
k = find((x > 0) & (delta >=0));
k1 = k;
delta = delta(k);
hdelta = delta/2;
v = v(k);
x = x(k);
x1 = x;  % make a copy to be used when reversing direction.
v1 = v;

% When non-centrality parameter is very large, the initial values of the
% poisson numbers used in the approximation are very small, smaller than
% epsilon. This would cause premature convergence. To avoid that, we start
% from counter=hdelta, which is the peak of the poisson numbers, and go in
% both directions.
peakloc = max(0,ceil((-(v+2) + sqrt((v-2).^2 + 4*delta.*x))/4));
counter = peakloc;

% Sum the series.
P = poisspdf(counter,hdelta);
C = chi2pdf(x,v+2*counter);
P0 = P;
C0 = C;
while(true)           % loop upward
   % Conceptually do the following, but do it more efficiently by using
   % a recursive formula to update the pdf values in each iteration:
   %   yplus = poisspdf(counter,hdelta).*chi2pdf(x,v+2*counter);
   yplus = P .* C;
   
   % Update result unless we have gone too far into the tail
   notnan = ~isnan(yplus);
   y(k(notnan)) = y(k(notnan)) + yplus(notnan);
   
   % Find indices requiring further iteration
   j = find(notnan & (yplus > s*(y(k)+s)));
   if isempty(j), break; end
   x = x(j);
   v = v(j);
   hdelta = hdelta(j);
   counter = counter(j)+1;
   k = k(j);
   P = P(j) .* hdelta ./ counter;
   C = C(j) .* x ./ (v+2*counter-2);
end

% Now start iterating down from the peak, unless the peak is at the bottom
counter = peakloc - 1;
j = find(counter>=0);
if isempty(j), return; end

x = x1(j);
v = v1(j);
delta = delta(j);
hdelta = delta/2;
k = k1(j);
counter = counter(j);

P = P0;
C = C0;
while any(counter >= 0)
   P = P(j) .* (counter+1) ./ hdelta;
   C = C(j) .* (v+2*counter) ./ x;
   yplus = P .* C;
   
   notnan = ~isnan(yplus);
   y(k(notnan)) = y(k(notnan)) + yplus(notnan);
   
   j = find(notnan & (yplus > s*(y(k)+s)) & (counter > 0));
   if isempty(j), break; end
   x = x(j);
   v = v(j);
   hdelta = hdelta(j);
   counter = counter(j)-1;
   k = k(j);
end

