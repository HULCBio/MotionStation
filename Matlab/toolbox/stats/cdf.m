function p = cdf(name,x,varargin)
%CDF    Computes a chosen cumulative distribution function.
%   P = CDF(NAME,X,A) returns the named cumulative distribution
%   function, which uses parameter A, at the values in X.
%
%   P = CDF(NAME,X,A,B) returns the named cumulative distribution
%   function, which uses parameters A and B, at the values in X.
%   Similarly for P = CDF(NAME,X,A,B,C).
%
%   The name can be: 'beta' or 'Beta', 'bino' or 'Binomial',
%   'chi2' or 'Chisquare', 'exp' or 'Exponential',
%   'ev' or 'Extreme Value', 'f' or 'F', 
%   'gam' or 'Gamma', 'geo' or 'Geometric', 
%   'hyge' or 'Hypergeometric', 'logn' or 'Lognormal', 
%   'nbin' or 'Negative Binomial', 'ncf' or 'Noncentral F', 
%   'nct' or 'Noncentral t', 'ncx2' or 'Noncentral Chi-square',
%   'norm' or 'Normal', 'poiss' or 'Poisson', 'rayl' or 'Rayleigh',
%   't' or 'T', 'unif' or 'Uniform', 'unid' or 'Discrete Uniform',
%   'wbl' or 'Weibull'.
% 
%   CDF calls many specialized routines that do the calculations. 

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.2 $  $Date: 2003/11/01 04:25:24 $
 
if nargin<2, error('stats:cdf:TooFewInputs','Not enough input arguments'); end

if ~isstr(name)
   error('stats:cdf:BadDistribution',...
         'First argument must be distribution name');
end

if nargin<5 
    a3=0;
else
    a3 = varargin{3};
end 
if nargin<4
    a2=0;
else
    a2 = varargin{2};
end 
if nargin<3
    a1=0;
else
    a1 = varargin{1};
end 

if     strcmp(name,'beta') | strcmp(name,'Beta'),  
    p = betacdf(x,a1,a2);
elseif strcmp(name,'bino') | strcmp(name,'Binomial'),  
    p = binocdf(x,a1,a2);
elseif strcmp(name,'chi2') | strcmp(name,'Chisquare'), 
 p = chi2cdf(x,a1);
elseif strcmp(name,'exp') | strcmp(name,'Exponential'),
    p = expcdf(x,a1);
elseif strcmp(name,'ev') | strcmp(name,'Extreme Value'),
    p = evcdf(x,a1,a2);
elseif strcmp(name,'f') | strcmp(name,'F'),     
    p = fcdf(x,a1,a2);
elseif strcmp(name,'gam') | strcmp(name,'Gamma'),   
    p = gamcdf(x,a1,a2);
elseif strcmp(name,'geo') | strcmp(name,'Geometric'),   
    p = geocdf(x,a1);
elseif strcmp(name,'hyge') | strcmp(name,'Hypergeometric'),  
    p = hygecdf(x,a1,a2,a3);
elseif strcmp(name,'logn') | strcmp(name,'Lognormal'),
    p = logncdf(x,a1,a2);
elseif strcmp(name,'nbin') | strcmp(name,'Negative Binomial'), 
   p = nbincdf(x,a1,a2);    
elseif strcmp(name,'ncf') | strcmp(name,'Noncentral F'),
    p = ncfcdf(x,a1,a2,a3);
elseif strcmp(name,'nct') | strcmp(name,'Noncentral T'), 
    p = nctcdf(x,a1,a2);
elseif strcmp(name,'ncx2') | strcmp(name,'Noncentral Chi-square'), 
    p = ncx2cdf(x,a1,a2);
elseif strcmp(name,'norm') | strcmp(name,'Normal'), 
    p = normcdf(x,a1,a2);
elseif strcmp(name,'poiss') | strcmp(name,'Poisson'),
    p = poisscdf(x,a1);
elseif strcmp(name,'rayl') | strcmp(name,'Rayleigh'),
    p = raylcdf(x,a1);
elseif strcmp(name,'t') | strcmp(name,'T'),     
    p = tcdf(x,a1);
elseif strcmp(name,'unid') | strcmp(name,'Discrete Uniform'),  
    p = unidcdf(x,a1);
elseif strcmp(name,'unif')  | strcmp(name,'Uniform'),  
    p = unifcdf(x,a1,a2);
elseif strcmp(name,'weib') | strcmp(name,'Weibull') | strcmp(name,'wbl')
    if strcmp(name,'weib') | strcmp(name,'Weibull')
        warning('stats:cdf:ChangedParameters', ...
'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    p = wblcdf(x,a1,a2);
else   
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:cdf:BadDistribution',...
             'Unrecognized distribution name: ''%s''.',name);
       return
    elseif length(spec)>1
       error('stats:cdf:BadDistribution',...
             'Ambiguous distribution name: ''%s''.',name);
       return
    end

    p = feval(spec.cdffunc,x,varargin{:});
end 
