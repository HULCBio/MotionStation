function r = chi2rnd(v,varargin);
%CHI2RND Random arrays from chi-square distribution.
%   R = CHI2RND(V) returns an array of random numbers chosen from the
%   chi-square distribution with V degrees of freedom.  The size of R is
%   the size of V.
%
%   R = CHI2RND(V,M,N,...) or R = CHI2RND(V,[M,N,...]) returns an
%   M-by-N-by-... array. 
%
%   See also CHI2CDF, CHI2INV, CHI2PDF, CHI2STAT, NCX2RND, RANDOM.

%   CHI2RND generates values using the definition of the chi-square
%   distribution, as a special case of the gamma distribution.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.3 $  $Date: 2004/01/24 09:33:12 $

if nargin < 1
    error('stats:chi2rnd:TooFewInputs','Requires at least one input argument.');
end

[err, sizeOut] = statsizechk(1,v,varargin{:});
if err > 0
    error('stats:chi2rnd:InputSizeMismatch','Size information is inconsistent.');
end

% Generate gamma random values, and scale them.
r = 2.*randg(v./2, sizeOut);
