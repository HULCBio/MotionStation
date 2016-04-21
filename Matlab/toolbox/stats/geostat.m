function [m,v] = geostat(p)
%GEOSTAT Mean and variance of the geometric distribution.
%   [M,V] = GEOSTAT(P) returns the mean and variance of the geometric
%   distribution with probability parameter P.  M and V are the size of the
%   input argument.
%
%   See also GEOCDF, GEOINV, GEOPDF, GEORND.

%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, 1046pp., sec. 26.1.24.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.4.1 $  $Date: 2003/11/01 04:26:20 $

if nargin < 1
    error('stats:geostat:TooFewInputs','Requires one input argument.');
end

% Return NaN for out of range parameters.
p(p <= 0 | 1 < p) = NaN;

m = (1 - p) ./ p;
v = m ./ p;
