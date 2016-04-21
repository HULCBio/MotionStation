function h = ewmaplot(data,lambda,alpha,specs)
%EWMAPLOT Exponentially weighted moving average chart.
%   H = EWMAPLOT(DATA,LAMBDA,ALPHA,SPECS) produces an EWMA chart 
%   of the grouped responses in DATA. The rows of DATA contain
%   replicate observations taken at a given time. The rows
%   should be in time order.
%
%   LAMBDA (optional) is the parameter that controls how much 
%   the current prediction is influenced by past observations. 
%   Higher values of LAMBDA give less weight to past observations
%   and more weight to the current observation.  By default,
%   LAMBDA = 0.4, and LAMBDA must be between 0 and 1. 
%
%   ALPHA (optional) is the significance level of the upper and 
%   lower plotted confidence limits. ALPHA is 0.0027 by default.
%   This means that 99.73% of the plotted points should fall 
%   between the control limits if the process is in control.
%
%   SPECS (optional) is a two element vector for the lower and
%   upper specification limits of the response.
%
%   H is a vector of handles to the plotted lines.

%   Reference: Montgomery, Douglas, Introduction to Statistical
%   Quality Control, John Wiley & Sons 1991 p. 299.

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 2.12.4.3 $  $Date: 2004/01/24 09:33:32 $ 
 

if nargin < 3
   alpha = 0.0027;
end

if nargin < 2
   lambda = 0.4;
end

if isempty(alpha)
  alpha = 0.0027;
end

if isempty(lambda)
   lambda = 0.4;
end

if lambda < 0 | lambda > 1
   error('stats:ewmaplot:BadLambda',...
         'LAMBDA must be a scalar between 0 and 1.');
end
if alpha <= 0 | alpha >= 1
   error('stats:ewmaplot:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end
ciprob = 1-alpha/2;

[m,n] = size(data);
if n == 1
   xbar = data;
else
   xbar  = (mean(data'))';
end

avg   = double(mean(xbar));
z     = filter(lambda,[1 (lambda - 1)],xbar,(1-lambda)*avg);

if (n > 1)
   sbar  = mean(std(data'));
   c4 = sqrt(2/(n-1)).*gamma(n/2)./gamma((n-1)/2);
   s = mean(sbar ./ c4);
else
   s = Inf;
end

smult = norminv(ciprob);

lambdacoef = sqrt(lambda./((2-lambda).*n));
UCL = double(avg + smult*s*lambdacoef);
LCL = double(avg - smult*s*lambdacoef);

tmp = NaN;
incontrol = tmp(ones(1,m));
outcontrol = incontrol;

greenpts = find(z > LCL & z < UCL);
redpts = find(z <= LCL | z >= UCL);

incontrol(greenpts) = z(greenpts);
outcontrol(redpts) = z(redpts);

samples = (1:m);

hh  = plot(samples,z,samples,UCL(ones(m,1),:),'b-',...
           samples,avg(ones(m,1),:),'r-',...
           samples,LCL(ones(m,1),:),'b-',samples,incontrol,'b+',...
         samples,outcontrol,'r+');

offset = .02 * m;
if any(redpts)
  for k = 1:length(redpts)
     text(redpts(k)+offset, outcontrol(redpts(k)),num2str(redpts(k)));
  end
end

text(m+offset,UCL,'UCL');
text(m+offset,LCL,'LCL');
text(m+offset,avg,'CL');
title('Exponentially Weighted Moving Average (EWMA) Chart');
         
if nargin == 4
   set(gca,'NextPlot','add');
   LSL = double(specs(1));
   USL = double(specs(2));
   t3 = text(m+offset, USL,'USL');
   t4 = text(m+offset, LSL,'LSL');
   hh1 = plot(samples,LSL(ones(m,1),:),'g-',samples,USL(ones(m,1),:),'g-');
   set(gca,'NextPlot','replace');
   hh = [hh; hh1];
end

if nargout == 1
   h = hh;
end         

set(hh(3),'LineWidth',2);

xlabel('Sample Number');
ylabel('EWMA');
