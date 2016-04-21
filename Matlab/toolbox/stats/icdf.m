function x = icdf(name,p,varargin)
%ICDF   Computes a chosen inverse cumulative distribution function.
%   X = ICDF(NAME,P,A) returns the named inverse cumulative distribution
%   function, which uses parameter A, at the values in X.
%
%   X = ICDF(NAME,P,A,B) returns the named cumulative distribution
%   function, which uses parameters A and B, at the values in X.
%   Similarly for X = ICDF(NAME,P,A,B,C).
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
%   ICDF calls many specialized routines that do the calculations. 

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.4.3 $  $Date: 2004/01/24 09:34:09 $

if nargin<2
   error('stats:icdf:TooFewInputs','Not enough input arguments');
end
if ~isstr(name)
   error('stats:icdf:BadDistribution',...
         'First argument must be distribution name');
end

if nargin<5
   c = 0;
else
   c = varargin{3};
end
if nargin<4
   b = 0;
else
   b = varargin{2};
end
if nargin<3
   a = 0;
else
   a = varargin{1};
end

if     strcmp(name,'beta') | strcmp(name,'Beta'),  
    x = betainv(p,a,b);
elseif strcmp(name,'bino') | strcmp(name,'Binomial'),  
    x = binoinv(p,a,b);
elseif strcmp(name,'chi2') | strcmp(name,'Chisquare'), 
    x = chi2inv(p,a);
elseif strcmp(name,'exp') | strcmp(name,'Exponential'),   
    x = expinv(p,a);
elseif strcmp(name,'ev') | strcmp(name,'Extreme Value'),   
    x = evinv(p,a,b);
elseif strcmp(name,'f') | strcmp(name,'F'),     
    x = finv(p,a,b);
elseif strcmp(name,'gam') | strcmp(name,'Gamma'),   
    x = gaminv(p,a,b);
elseif strcmp(name,'geo') | strcmp(name,'Geometric'),   
    x = geoinv(p,a);
elseif strcmp(name,'hyge') | strcmp(name,'Hypergeometric'),  
    x = hygeinv(p,a,b,c);
elseif strcmp(name,'logn') | strcmp(name,'Lognormal'),
    x = logninv(p,a,b);
elseif strcmp(name,'nbin') | strcmp(name,'Negative Binomial'), 
   x = nbininv(p,a,b);    
elseif strcmp(name,'ncf') | strcmp(name,'Noncentral F'),
    x = ncfinv(p,a,b,c);
elseif strcmp(name,'nct') | strcmp(name,'Noncentral T'),  
    x = nctinv(p,a,b);
elseif strcmp(name,'ncx2') | strcmp(name,'Noncentral Chi-square'), 
    x = ncx2inv(p,a,b);
elseif strcmp(name,'norm') | strcmp(name,'Normal'), 
    x = norminv(p,a,b);
elseif strcmp(name,'poiss') | strcmp(name,'Poisson'),
    x = poissinv(p,a);
elseif strcmp(name,'rayl') | strcmp(name,'Rayleigh'),
    x = raylinv(p,a);
elseif strcmp(name,'t') | strcmp(name,'T'),     
    x = tinv(p,a);
elseif strcmp(name,'unid') | strcmp(name,'Discrete Uniform'),  
    x = unidinv(p,a);
elseif strcmp(name,'unif')  | strcmp(name,'Uniform'),  
    x = unifinv(p,a,b);
elseif strcmp(name,'weib') | strcmp(name,'Weibull') | strcmp(name,'wbl')
    if strcmp(name,'weib') | strcmp(name,'Weibull')
        warning('stats:icdf:ChangedParameters', ...
'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    x = wblinv(p,a,b);
else   
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:icdf:BadDistribution',...
             'Unrecognized distribution name: ''%s''.',name);
       return
    elseif length(spec)>1
       error('stats:icdf:BadDistribution',...
             'Ambiguous distribution name: ''%s''.',name);
       return
    end
    x = feval(spec.invfunc,p,varargin{:});
end 
