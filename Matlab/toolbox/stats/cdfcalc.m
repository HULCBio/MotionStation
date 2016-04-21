function [yCDF,xCDF,n,emsg,eid] = cdfcalc(x,xname)
%CDFCALC Calculate an empirical cumulative distribution function.
%   [YCDF,XCDF] = CDFCALC(X) calculates an empirical cumulative
%   distribution function (CDF) of the observations in the data sample
%   vector X. X may be a row or column vector, and represents a random
%   sample of observations from some underlying distribution.  On
%   return XCDF is the set of X values at which the CDF increases.
%   At XCDF(i), the function increases from YCDF(i) to YCDF(i+1).
%
%   [YCDF,XCDF,N] = CDFCALC(X) also returns N, the sample size.
%
%   [YCDF,XCDF,N,EMSG,EID] = CDFCALC(X) also returns an error message and
%   error id if X is not a vector or if it contains no values other than NaN.
%
%   See also CDFPLOT.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.2 $  $Date: 2004/01/24 09:33:11 $

% Ensure the data is a VECTOR.
yCDF = [];
xCDF = [];
if (nargin < 2)
   if isempty(inputname(1))
      xname = 'X';
   else
      xname = inputname(1);
   end
end
n = 0;
if (min(size(x)) ~= 1)
    emsg = sprintf('Input sample %s must be a vector.', xname);
    eid = 'VectorRequired';
    return;
end

% Remove missing observations indicated by NaN's.
x = x(~isnan(x));
n = length(x);
if n == 0
   emsg = sprintf('Input sample %s has no valid data (all NaN''s).', ...
                  xname);
   eid = 'NotEnoughData';
   return;
end

% Sort observation data in ascending order.
x = sort(x(:));

%
% Compute cumulative sum such that the sample CDF is
% F(x) = (number of observations <= x) / (total number of observations).
% Note that the bin edges are padded with +/- infinity for auto-scaling of
% the x-axis.
%

% Get cumulative sums
yCDF = (1:n)' / n;

% Remove duplicates; only need final one with total count
notdup = ([diff(x(:)); 1] > 0);
xCDF = x(notdup);
yCDF = [0; yCDF(notdup)];
emsg = '';
eid = '';