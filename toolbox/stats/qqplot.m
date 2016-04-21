function h = qqplot(x,y,pvec)
%QQPLOT Display an empirical quantile-quantile plot.
%   QQPLOT(X) makes an empirical QQ-plot of the quantiles of
%   the data set X versus the quantiles of a standard Normal distribution.
%
%   QQPLOT(X,Y) makes an empirical QQ-plot of the quantiles of
%   the data set X versus the quantiles of the data set Y.
%
%   H = QQPLOT(X,Y,PVEC) allows you to specify the plotted quantiles in 
%   the vector PVEC. H is a handle to the plotted lines. 
%
%   When both X and Y are input, the default quantiles are those of the 
%   smaller data set.
%
%   The purpose of the quantile-quantile plot is to determine whether
%   the sample in X is drawn from a Normal (i.e., Gaussian) distribution,
%   or whether the samples in X and Y come from the same distribution
%   type.  If the samples do come from the same distribution (same shape),
%   even if one distribution is shifted and re-scaled from the other
%   (different location and scale parameters), the plot will be linear.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.2.1 $  $Date: 2004/01/24 09:36:41 $

if nargin == 1
   y  =  sort(x);
   [x,n]  = plotpos(y);
   x  = norminv(x);
   xx = x;
   yy = y;
else
   n = -1;
   if nargin < 3
      nx = sum(~isnan(x));
      if (length(nx) > 1)
         nx = max(nx);
      end
      ny = sum(~isnan(y));
      if (length(ny) > 1)
         ny = max(ny);
      end
      n    = min(nx, ny);
      pvec = 100*((1:n) - 0.5) ./ n;
   end

   if (((size(x,1)==n) | (size(x,1)==1 & size(x,2)==n)) & ~any(isnan(x)))
      xx = sort(x);
   else
      xx = prctile(x,pvec);
   end
   if (((size(y,1)==n) | (size(y,1)==1 & size(y,2)==n)) & ~any(isnan(y)))
      yy = sort(y);
   else
      yy=prctile(y,pvec);
   end
end

q1x = prctile(x,25);
q3x = prctile(x,75);
q1y = prctile(y,25);
q3y = prctile(y,75);
qx = [q1x; q3x];
qy = [q1y; q3y];


dx = q3x - q1x;
dy = q3y - q1y;
slope = dy./dx;
centerx = (q1x + q3x)/2;
centery = (q1y + q3y)/2;
maxx = max(x);
minx = min(x);
maxy = centery + slope.*(maxx - centerx);
miny = centery - slope.*(centerx - minx);

mx = [minx; maxx];
my = [miny; maxy];


hh = plot(xx,yy,'+',qx,qy,'-',mx,my,'-.');
if nargout == 1
  h = hh;
end

if nargin == 1
   xlabel('Standard Normal Quantiles')
   ylabel('Quantiles of Input Sample')
   title ('QQ Plot of Sample Data versus Standard Normal')
else
   xlabel('X Quantiles');
   ylabel('Y Quantiles');
end

%===================== helper function ====================
function [pp,n] = plotpos(sx)
%PLOTPOS Compute plotting positions for a probability plot
%   PP = PLOTPOS(SX) compute the plotting positions for a probabilty
%   plot of the columns of SX (or for SX itself if it is a vector).
%   SX must be sorted before being passed into PLOTPOS.  The ith
%   value of SX has plotting position (i-0.5)/n, where n is
%   the number of rows of SX.  NaN values are removed before
%   computing the plotting positions.
%
%   [PP,N] = PLOTPOS(SX) also returns N, the largest sample size
%   among the columns of SX.  This N can be used to set axis limits.

[n, m] = size(sx);
if n == 1
   sx = sx';
   n = m;
   m = 1;
end

nvec = sum(~isnan(sx));
pp = repmat((1:n)', 1, m);
pp = (pp-.5) ./ repmat(nvec, n, 1);
pp(isnan(sx)) = NaN;

if (nargout > 1)
   n = max(nvec);  % sample size for setting axis limits
end


