function [p, h] = capaplot(data,specs)
%CAPAPLOT Capability plot.
%   CAPAPLOT(DATA,SPECS) fits the observations in the vector DATA
%   assuming a normal distribution with unknown mean and variance and
%   plots the estimated distribution of a new observation.  The part
%   of the distribution between the lower and upper bounds contained
%   in the two element vector, SPECS, is shaded in the plot.
%
%   [P, H] = CAPAPLOT(DATA,SPECS) returns the probability of the new
%   observation being within spec in P and handles to the plot
%   elements in H.

%   Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 2.16.2.1 $  $Date: 2003/11/01 04:25:21 $

if prod(size(specs)) ~= 2,
   error('stats:capaplot:BadSpecs','SPECS must be a two element vector.');
end

lb = specs(1);
ub = specs(2);
if lb > ub
  lb = specs(2);
  ub = specs(1);
end

if lb == -Inf & ub == Inf
   error('stats:capaplot:BadSpecs',...
         'The SPECS vector must have at least one finite element');
end

[m,n] = size(data);
if min(m,n) ~= 1
   error('stats:capaplot:VectorRequired','First argument must be a vector.');
end

if m == 1
   m = n;
   data = data(:);
end

mu = mean(data);
sigma = std(data);

prob = (0.002:0.004:0.998)';

x = norminv(prob, mu, sigma);
y = normpdf(x, mu, sigma);
if lb == -Inf,
   p = normcdf(ub, mu, sigma);
elseif ub == Inf,
   p = 1 - normcdf(lb, mu, sigma);
else  
   p = diff(normcdf([lb ub], mu, sigma));
end

hh = plot(x,y,'b-');
np = get(gca,'NextPlot');
set(gca,'Nextplot','add');
xl = get(gca,'Xlim');
if lb == -Inf,
  lb = xl(1);
  yll = [0; eps];
else
  yll = normpdf(lb, mu, sigma);
  yll = [0; yll];
end

if ub == Inf,
   ub = xl(2);
   yul = [eps; 0];
else
   yul = normpdf(ub, mu, sigma);
   yul = [yul; 0];
end
    
ll = [lb; lb];
ul = [ub; ub];
  
hh1 = plot(ll,yll,'b-',ul,yul,'b-');
if nargout == 2
  h = [hh; hh1];
end

k = find(x > lb & x < ub);
xfill = x(k);
xfill = [ll; xfill; ul];
yfill = [yll; y(k); yul];
fill(xfill,yfill,'y');

str = ['Probability Between Limits = ',num2str(p)];
title(str);
if ~isempty(np) 
   set(gca,'NextPlot',np);
end
xaxis = refline(0,0);
