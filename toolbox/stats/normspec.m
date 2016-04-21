function [p, h] = normspec(specs,mu,sigma)
%NORMSPEC Plots normal density between specification limits.
%   NORMSPEC(SPECS,MU,SIGMA) plots the normal density between the lower and
%   upper bounds contained in SPECS. MU and SIGMA are the parameters of the
%   plotted distribution.
%
%   [P, H] = NORMSPEC(SPECS,MU,SIGMA) returns the probability, P, of a
%   sample falling between the lower and upper limits. H is a handle
%   to the line objects.
%
%   If SPECS(1) is -Inf there is no lower limit, and similarly if
%   SPECS(2) = Inf there is no upper limit. By default, MU and SIGMA
%   are zero and one respectively.

%   Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 2.16.2.1 $  $Date: 2003/11/01 04:27:41 $

if prod(size(specs)) ~= 2,
   error('stats:normspec:BadSpecs',...
         'Requires SPECS to be a two element vector.');
end

lb = specs(1);
ub = specs(2);
if lb > ub
  lb = specs(2);
  ub = specs(1);
end

if lb == -Inf & ub == Inf
   error('stats:normspec:BadSpecs',...
         'The SPECS vector must have at least one finite element.');
end

if nargin < 2
  mu = 0;
  sigma = 1;
end

if max(size(mu)) > 1 | max(size(sigma)) > 1 ,
   error('stats:normspec:ScalarRequired',...
         'Requires scalar 2nd and 3rd input arguments.');
end

prob = (0.0002:0.0004:0.9998)';

x = norminv(prob,mu,sigma);
y = normpdf(x,mu,sigma);
if lb == -Inf,
   p = normcdf(ub,mu,sigma);
elseif ub == Inf,
   p = 1 - normcdf(lb,mu,sigma);
else  
   p = diff(normcdf([lb ub],mu,sigma));
end

nspecfig = figure;
nspecaxes = axes;
set(nspecaxes, 'Parent', nspecfig);

set(nspecaxes,'Nextplot','add');
hh = plot(x,y,'b-');
xl = get(nspecaxes,'Xlim');
lbinf = isinf(lb);
ubinf = isinf(ub);
if lbinf,
  lb = xl(1);
  yll = [0; eps];
else
  yll = normpdf(lb,mu,sigma);
  yll = [0; yll];
end

if ubinf,
   ub = xl(2);
   yul = [eps; 0];
else
   yul = normpdf(ub,mu,sigma);
   yul = [yul; 0];
end
    
ll = [lb; lb];
ul = [ub; ub];
  


if ubinf
   str = ['Probability Greater than Lower Bound is ',num2str(p)];
   k = find(x > lb);
   hh1 = plot(ll,yll,'b-');
elseif lbinf
   str = ['Probability Less than Upper Bound is ',num2str(p)];
   k = find(x < ub);
   hh1 = plot(ul,yul,'b-');
else
   str = ['Probability Between Limits is ',num2str(p)];
   k = find(x > lb & x < ub);
   hh1 = plot(ll,yll,'b-',ul,yul,'b-');
end
xfill = x(k);
xfill = [ll; xfill; ul];
yfill = [yll; y(k); yul];
fill(xfill,yfill,'b');
title(str); 

if nargout == 2
  h = [hh; hh1];
end

xaxis = refline(0,0);
set(xaxis,'Color','k');
ylabel('Density');
xlabel('Critical Value');
