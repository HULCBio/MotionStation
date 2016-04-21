function r = geornd(p,varargin)
%GEORND Random arrays from the geometric distribution.
%   R = GEORND(P) returns an array of random numbers chosen from the
%   geometric distribution with probability parameter P.  The size of R is
%   the size of P.
%
%   R = GEORND(P,M,N,...) or R = GEORND(P,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also GEOCDF, GEOINV, GEOPDF, GEOSTAT, RANDOM.

%   GEORND uses the inversion method.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.3 $  $Date: 2004/01/24 09:33:59 $

if nargin < 1
    error('stats:geornd:TooFewInputs','Requires at least one input argument.');
end

[err, sizeOut] = statsizechk(1,p,varargin{:});
if err > 0
    error('stats:geornd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
p(p <= 0 | p > 1) = NaN;

% log(1-u) and log(1-p) "really" should both be negative, and
% the abs() here keeps the correct sign for their ratio when
% roundoff makes one of them exactly zero.
r = ceil(abs(log(rand(sizeOut)) ./ log(1 - p)) - 1); % == geoinv(u,p)

% Force a zero when p==1, instead of -1.
r(r < 0) = 0;
