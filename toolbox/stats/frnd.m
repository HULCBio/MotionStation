function r = frnd(v1,v2,varargin);
%FRND Random arrays from the F distribution.
%   R = FRND(V1,V2) returns an array of random numbers chosen from the F
%   distribution with parameters V1 and V2.  The size of R is the common
%   size of V1 and V2 if both are arrays.  If either parameter is a scalar,
%   the size of R is the size of the other parameter.
%
%   R = FRND(V1,V2,M,N,...) or R = FRND(V1,V2,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also FCDF, FINV, FPDF, FSTAT, NCFRND, RANDOM.

%   FRND generates values using the definition of an F random variable, as
%   the ratio of chi-square random variables.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.3 $  $Date: 2004/01/24 09:33:48 $

if nargin < 2
    error('stats:frnd:TooFewInputs','Requires at least two input arguments.'); 
end

[err, sizeOut, numelOut] = statsizechk(2,v1,v2,varargin{:});
if err > 0
    error('stats:frnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
v1(v1 <= 0) = NaN;
v2(v2 <= 0) = NaN;

r = (randg(v1./2, sizeOut) ./ v1) ./ (randg(v2./2, sizeOut) ./ v2);
