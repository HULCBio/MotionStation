function y = nctpdf(x,v,delta)
%NCTPDF Noncentral T probability density function (pdf).
%   Y = NCTPDF(X,V,DELTA) Returns the noncentral T pdf with V degrees 
%   of freedom and noncentrality parameter, DELTA, at the values in X. 
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     

%   Reference:
%      [1]  Johnson, Norman, and Kotz, Samuel, "Distributions in
%      Statistics: Continuous Univariate Distributions-2", Wiley
%      1970 pp. 204-205 equation 8.
%      [2]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 pp. 147-148.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.17.2.4 $  $Date: 2004/01/24 09:34:42 $


if nargin < 1, 
    error('stats:nctpdf:TooFewInputs','Requires at least one input argument.');
end

[errorcode, x, v, delta] = distchck(3,x,v,delta);

if errorcode > 0
    error('stats:nctpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% if some delta==0, call tcdf for those entries, call nctcdf for other entries.
f = (delta == 0);
if any(f(:))
   y = zeros(size(delta));
   y(f) = tpdf(x(f),v(f));
   f1 = ~f;
   if any(f1(:))
      y(f1) = nctpdf(x(f1),v(f1),delta(f1));
   end
   return
end

%   Initialize Y to zero.
if isa(x,'single')
   y = zeros(size(x),'single');
   qeps = eps('single')^(3/4);
else
   y = zeros(size(x));
   qeps = eps^(3/4);
end

k = find(v > 0);
if any(k)
   nu = v(k);
   d = delta(k);
   t = x(k);
   lnu = log(nu+t.^2);
   lnu1 = gammaln((nu+1)/2);
   lnu2 = gammaln((nu+2)/2);
   term = exp(-0.5.*(log(pi)+log(nu)) -(d.^2)/2  + lnu1 - gammaln(nu/2) ...
      + ((nu+1)/2).*(log(nu)-lnu));

   infsum = zeros(size(k));
   tsq = t.^2;
   ratio = tsq .* (d.^2) ./ (nu + tsq);

   % Set up for infinite sum by computing first two terms.
   j = 0;
   t0 = 1;
   t1 = t .* d .* sqrt(2) .* exp(lnu2 - lnu1) ./ sqrt(nu + tsq);
   infsum = infsum + (t0 + t1);

   % Sum the series by computing term j from term j-2
   while 1
      t0 = t0 .* ratio .* (nu+j+1) / ((j+1) * (j+2));
      infsum = infsum + t0;
      if all(abs(t0 ./infsum) < qeps), break; end
      j = j + 1;
      t1 = t1 .* ratio .* (nu+j+1) / ((j+1) * (j+2));
      infsum = infsum + t1;
      if all(abs(t1 ./infsum) < qeps), break; end
      j = j + 1;
   end
   y(k) = term .* infsum;
end

y(v <= 0) = NaN;
