function r = random(name,varargin)
%RANDOM Generate random arrays from a named distribution.
%   The appropriate syntax depends on the number of parameters in the
%   distribution you are using:
%
%   R = RANDOM(NAME,A) returns an array of random numbers from the named
%   distribution that requires a single parameter array A.
%   R = RANDOM(NAME,A,B) returns an array of random numbers from the named
%   distribution that requires two parameter arrays A and B.
%   R = RANDOM(NAME,A,B,C) returns an array of random numbers from the named
%   distribution that requires three parameter arrays A, B, and C.
%
%   The size of R is the common size of A, B, and C if all are arrays.  If
%   any parameters are scalars, the size of R is the size of the other
%   parameter(s).
%
%   R = RANDOM(NAME,A,M,N,...) or R = RANDOM(NAME,A,[M,N,...]) returns an
%   M-by-N-by-... array of random numbers.
%   R = RANDOM(NAME,A,B,M,N,...) or R = RANDOM(NAME,A,B,[M,N,...]) returns
%   an M-by-N-by-... array of random numbers.
%   R = RANDOM(NAME,A,B,C,M,N,...) or R = RANDOM(NAME,A,B,C,[M,N,...])
%   returns an M-by-N-by-... array of random numbers.
%
%   NAME can be one of: 'beta', 'binomial', 'chi-square' or 'chi2',
%   'extreme value' or 'ev', 'exponential', 'f', 'gamma', 'geometric',
%   'hypergeometric' or 'hyge', 'lognormal', 'negative binomial' or 'nbin',
%   'noncentral f' or 'ncf', 'noncentral t' or 'nct', 'noncentral chi-square'
%   or 'ncx2', 'normal', 'poisson', 'rayleigh', 't', 'discrete uniform' or
%   'unid', 'uniform', 'weibull' or 'wbl'.  Partial matches are allowed and
%   case is ignored.

%   RANDOM calls many specialized routines that do the calculations.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.13.4.2 $  $Date: 2003/11/01 04:28:50 $

if ischar(name)
    distNames = {'beta', 'binomial', 'chi-square', 'extreme value', ...
                 'exponential', 'f', 'gamma', 'geometric', 'hypergeometric', ...
                 'lognormal', 'negative binomial', 'noncentral f', ...
                 'noncentral t', 'noncentral chi-square', 'normal', 'poisson', ...
                 'rayleigh', 't', 'discrete uniform', 'uniform', 'weibull'};

    i = strmatch(lower(name), distNames);
    if numel(i) > 1
        error('stats:random:BadDistribution', 'Ambiguous distribution name: ''%s''.',name);
        return
    elseif numel(i) == 1
        name = distNames{i};
    else % it may be an abbreviation that doesn't partially match the name
        name = lower(name);
    end
else
    error('stats:random:BadDistribution', 'The NAME argument must be must be a distribution name.');
end

% Determine, and call, the appropriate subroutine
switch name
case 'beta'
    r = betarnd(varargin{:});
case 'binomial'
    r = binornd(varargin{:});
case {'chi2', 'chi-square', 'chisquare'}
    r = chi2rnd(varargin{:});
case {'ev', 'extreme value'}
    r = evrnd(varargin{:});
case 'exponential'
    r = exprnd(varargin{:});
case 'f'
    r = frnd(varargin{:});
case 'gamma'
    r = gamrnd(varargin{:});
case 'geometric'
    r = geornd(varargin{:});
case {'hyge', 'hypergeometric'}
    r = hygernd(varargin{:});
case 'lognormal'
    r = lognrnd(varargin{:});
case {'nbin', 'negative binomial'}
    r = nbinrnd(varargin{:});
case {'ncf', 'noncentral f'}
    r = ncfrnd(varargin{:});
case {'nct', 'noncentral t'}
    r = nctrnd(varargin{:});
case {'ncx2', 'noncentral chi-square'}
    r = ncx2rnd(varargin{:});
case 'normal'
    r = normrnd(varargin{:});
case 'poisson'
    r = poissrnd(varargin{:});
case 'rayleigh'
    r = raylrnd(varargin{:});
case 't'
    r = trnd(varargin{:});
case {'unid', 'discrete uniform'}
    r = unidrnd(varargin{:});
case 'uniform'
    r = unifrnd(varargin{:});
case {'wbl', 'weibull'}
    if ~strcmp(name,'wbl')
        warning('stats:random:ChangedParameters', ...
                'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    r = wblrnd(varargin{:});
otherwise
    error('stats:random:BadDistribution', 'Unrecognized distribution name: ''%s''.',name);
    return
end
