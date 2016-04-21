function r = ncfrnd(nu1,nu2,delta,varargin)
%NCFRND Random arrays from the noncentral F distribution.
%   R = NCFRND(NU1,NU2,DELTA) returns an array of random numbers chosen
%   from the noncentral F distribution with parameters NU1, NU2, and DELTA.
%   The size of R is the common size of NU1, NU2, and DELTA if all are
%   arrays.  If any parameters are scalars, the size of R is the size of the
%   other parameter(s).
%
%   R = NCFRND(NU1,NU2,DELTA,M,N,...) or R = NCFRND(NU1,NU2,DELTA,[M,N,...])
%   returns an M-by-N-by-... array.
%
%   See also NCFCDF, NCFINV, NCFPDF, NCFSTAT, FRND, RANDOM.

%   NCFRND generates values using the definition of a noncentral F random
%   variable, as the ratio of a noncentral chi-square and a (central)
%   chi-square.

%   Reference:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.3 $  $Date: 2004/01/24 09:34:41 $

if nargin < 3
    error('stats:ncfrnd:TooFewInputs','Requires at least three input arguments.');
end

[err, sizeOut] = statsizechk(3,nu1,nu2,delta,varargin{:});
if err > 0
    error('stats:ncfrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
nu1(nu1 <= 0) = NaN;
nu2(nu2 <= 0) = NaN;
delta(delta < 0) = NaN;

r = (ncx2rnd(nu1,delta,sizeOut) ./ nu1) ./ (2.*randg(nu2./2,sizeOut) ./ nu2);
