function h = normplot(x)
%NORMPLOT Displays a normal probability plot.
%   H = NORMPLOT(X) makes a normal probability plot of the  
%   data in X. For matrix, X, NORMPLOT displays a plot for each column.
%   H is a handle to the plotted lines.
%   
%   The purpose of a normal probability plot is to graphically assess
%   whether the data in X could come from a normal distribution. If the
%   data are normal the plot will be linear. Other distribution types 
%   will introduce curvature in the plot.  

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.2.1 $  $Date: 2004/01/24 09:34:47 $

[n, m] = size(x);
if n == 1
   x = x';
   n = m;
   m = 1;
end

[sx i]= sort(x);
minx  = min(sx(:));
maxx  = max(sx(:));
range = maxx-minx;

if range>0
  minxaxis  = minx-0.025*range;
  maxxaxis  = maxx+0.025*range;
else
  minxaxis  = minx - 1;
  maxxaxis  = maxx + 1;
end

% Use the same Y vector if all columns have the same count
if (~any(isnan(x(:))))
   eprob = [0.5./n:1./n:(n - 0.5)./n]';
else
   nvec = sum(~isnan(x));
   eprob = repmat((1:n)', 1, m);
   eprob = (eprob-.5) ./ repmat(nvec, n, 1);
   eprob(isnan(sx)) = NaN;
end
   
y  = norminv(eprob,0,1);

minyaxis  = norminv(0.25 ./n,0,1);
maxyaxis  = norminv((n-0.25) ./n,0,1);


p     = [0.001 0.003 0.01 0.02 0.05 0.10 0.25 0.5...
         0.75 0.90 0.95 0.98 0.99 0.997 0.999];

label1= str2mat('0.001','0.003', '0.01','0.02','0.05','0.10','0.25','0.50');
label2= str2mat('0.75','0.90','0.95','0.98','0.99','0.997', '0.999');
label = [label1;label2];

tick  = norminv(p,0,1);

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

if nargout == 1
   h = plot(sx,y,'+',qx,qy,'-',mx,my,'-.');
else 
   plot(sx,y,'+',qx,qy,'-',mx,my,'-.');
end

set(gca,'YTick',tick,'YTickLabel',label);
set(gca,'YLim',[minyaxis maxyaxis],'XLim',[minxaxis maxxaxis]);
xlabel('Data');
ylabel('Probability');
title('Normal Probability Plot');

grid on;
