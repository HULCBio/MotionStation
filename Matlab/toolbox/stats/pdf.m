function y = pdf(name,x,varargin)
%PDF    Computes a chosen probability density function.
%   Y = PDF(NAME,X,A) returns the named probability density
%   function, which uses parameter A, at the values in X.
%
%   Y = PDF(NAME,X,A,B,) returns the named probability density
%   function, which uses parameters A and B, at the values in X.
%   Similarly for Y = PDF(NAME,X,A,B,C).
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
%   PDF calls many specialized routines that do the calculations. 

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.2 $  $Date: 2003/11/01 04:27:45 $
 
if nargin<2, 
    error('stats:pdf:TooFewInputs','Requires at least two input arguments.'); 
end

if ~isstr(name), 
    error('stats:pdf:BadDistribution',...
          'Requires the first input to be the name of a distribution.'); 
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

if     strcmpi(name,'beta') || strcmpi(name,'Beta'),  
    y = betapdf(x,a,b);
elseif strcmpi(name,'bino') || strcmpi(name,'Binomial'),  
    y = binopdf(x,a,b);
elseif strcmpi(name,'chi2') || strcmpi(name,'Chisquare'), 
    y = chi2pdf(x,a);
elseif strcmpi(name,'exp') || strcmpi(name,'Exponential'),   
    y = exppdf(x,a);
elseif strcmpi(name,'ev') || strcmpi(name,'Extreme Value'),
    y = evpdf(x,a,b);
elseif strcmpi(name,'f')
    y = fpdf(x,a,b);
elseif strcmpi(name,'gam') || strcmpi(name,'Gamma'),   
    y = gampdf(x,a,b);
elseif strcmpi(name,'geo') || strcmpi(name,'Geometric'),   
    y = geopdf(x,a);
elseif strcmpi(name,'hyge') || strcmpi(name,'Hypergeometric'),  
    y = hygepdf(x,a,b,c);
elseif strcmpi(name,'logn') || strcmpi(name,'Lognormal'),
    y = lognpdf(x,a,b);
elseif strcmpi(name,'nbin') || strcmpi(name,'Negative Binomial'),  
   y = nbinpdf(x,a,b);    
elseif strcmpi(name,'ncf') || strcmpi(name,'Noncentral F'),
    y = ncfpdf(x,a,b,c);
elseif strcmpi(name,'nct') || strcmpi(name,'Noncentral T'),  
    y = nctpdf(x,a,b);
elseif strcmpi(name,'ncx2') || strcmpi(name,'Noncentral Chi-square'),
    y = ncx2pdf(x,a,b);
 elseif strcmpi(name,'norm') || strcmpi(name,'Normal'), 
    y = normpdf(x,a,b);
elseif strcmpi(name,'poiss') || strcmpi(name,'Poisson'),
    y = poisspdf(x,a);
elseif strcmpi(name,'rayl') || strcmpi(name,'Rayleigh'),
    y = raylpdf(x,a);
elseif strcmpi(name,'t'),
    y = tpdf(x,a);
elseif strcmpi(name,'unid') || strcmpi(name,'Discrete Uniform'),  
    y = unidpdf(x,a);
elseif strcmpi(name,'unif')  || strcmpi(name,'Uniform'),  
    y = unifpdf(x,a,b);
elseif strcmpi(name,'weib') || strcmpi(name,'Weibull') || strcmpi(name,'wbl')
    if strcmpi(name,'weib') || strcmpi(name,'Weibull')
        warning('stats:pdf:ChangedParameters', ...
'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    y = wblpdf(x,a,b);
else   
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:pdf:InvalidDistName',...
             'Unrecognized distribution name: ''%s''.',name);
       return
    elseif length(spec)>1
       error('stats:pdf:AmbiguousDistName',...
             'Ambiguous distribution name: ''%s''.',name);
       return
    end
    y = feval(spec.pdffunc,x,varargin{:});
end 
