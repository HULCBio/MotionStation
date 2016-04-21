function y = tpdf(x,v)
% TPDF  Probability density function (pdf) for Student's T distribution
%   Y = TPDF(X,V) returns the pdf of Student's T distribution with
%   V degrees of freedom, at the values in X.
%   
%   The size of Y is the common size of X and V. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   References:
%      [1]  E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, New York, 1970, Section 10.3, pages 144-146.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.3 $  $Date: 2004/01/24 09:37:02 $

if nargin < 2, 
    error('stats:tpdf:TooFewInputs','Requires two input arguments.'); 
end

[errorcode x v] = distchck(2,x,v);

if errorcode > 0
    error('stats:tpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero, or NaN for invalid d.f.
if isa(x,'single')
    y = zeros(size(x),'single');
else
    y = zeros(size(x));
end
y(v <= 0) = NaN;

% Use gammaln function to avoid overflows.
k = find(v > 0);
if any(k)
    term = exp(gammaln((v(k) + 1) / 2) - gammaln(v(k)/2));
    y(k) = term ./ (sqrt(v(k)*pi) .* (1 + (x(k) .^ 2) ./ v(k)) .^ ((v(k) + 1)/2));
end
