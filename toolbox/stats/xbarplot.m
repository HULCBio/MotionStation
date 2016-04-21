function [outliers, h] = xbarplot(data,conf,specs,sigmaest)
%XBARPLOT X-bar chart for monitoring the mean.
%   XBARPLOT(DATA,CONF,SPECS,SIGMAEST) produces an xbar chart of
%   the grouped responses in DATA. The rows of DATA contain
%   replicate observations taken at a given time. The rows
%   should be in time order.
%
%   CONF (optional) is the confidence level of the upper and 
%   lower plotted confidence limits. CONF is 0.9973 by default.
%   This means that 99.73% of the plotted points should fall 
%   between the control limits if the process is in control.
%
%   SPECS (optional) is a two element vector for the lower and
%   upper specification limits of the response.
%
%   SIGMAEST (optional) specifies how XBARPLOT should estimate
%   sigma.  Possible values are 'std' (the default) to use the
%   average within-subgroup standard deviation, 'range' to use the
%   average subgroup range, and 'variance' to use the square root
%   of the pooled variance.
%
%   OUTLIERS = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) returns a vector
%   of indices to the rows where the mean of DATA is out of
%   control.
%
%   [OUTLIERS, H] = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) also returns
%   a vector of handles, H, to the plotted lines.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.3 $  $Date: 2004/03/09 16:17:06 $
 

if nargin < 2
   conf = 0.9973;
end

if isempty(conf)
  conf = 0.9973;
end

[m,n] = size(data);
xbar  = double(mean(data')');
avg   = mean(xbar);
if (n < 2)
   error('stats:xbarplot:SubgroupsRequired',...
         'XBARPLOT requires subgroups of at least 2 observations.');
end

% Need a sigma estimate to compute control limits
if (nargin < 4)
   sigmaest = 's';
elseif ((strcmp(sigmaest,'range') | strcmp(sigmaest,'r')) & (n>25))
   error('stats:xbarplot:RangeNotAllowed',...
         ['XBARPLOT cannot use a range estimate if subgroups have' ...
          ' more than 25 observations.']);
end
if (strcmp(sigmaest,'variance') | strcmp(sigmaest,'v'))  % use pooled variance
   s = sqrt(sum(sum(((data - xbar(:,ones(n,1))).^2)))./(m*(n-1)));
elseif (strcmp(sigmaest,'range') | strcmp(sigmaest,'r'))  % use average range
   r = (range(data'))';
   d2 = [0.000 1.128 1.693 2.059 2.326 2.534 2.704 2.847 2.970 3.078 ...
         3.173 3.258 3.336 3.407 3.472 3.532 3.588 3.640 3.689 3.735 ...
         3.778 3.819 3.858 3.895 3.931];
   s = mean(r ./ d2(n));
else                                 % estimate sigma using average s
   svec = (std(data'))';
   c4 = sqrt(2/(n-1)).*gamma(n/2)./gamma((n-1)/2);
   s = mean(svec ./ c4);
end

smult = norminv(1-.5*(1-conf));

delta = double(smult * s ./ sqrt(n));
UCL = avg + delta;
LCL = avg - delta;

tmp = NaN;
incontrol = tmp(1,ones(1,m));
outcontrol = incontrol;

greenpts = find(xbar > LCL & xbar < UCL);
redpts = find(xbar <= LCL | xbar >= UCL);

incontrol(greenpts) = xbar(greenpts);
outcontrol(redpts) = xbar(redpts);

samples = (1:m);

hh  = plot(samples,xbar,samples,UCL(ones(m,1),:),'r-',samples,avg(ones(m,1),:),'g-',...
           samples,LCL(ones(m,1),:),'r-',samples,incontrol,'b+',...
         samples,outcontrol,'r+');

if any(redpts)
  for k = 1:length(redpts)
     text(redpts(k) + 0.5,outcontrol(redpts(k)),num2str(redpts(k)));
  end
end

text(m+0.5,UCL,'UCL');
text(m+0.5,LCL,'LCL');
text(m+0.5,avg,'CL');
title('Xbar Chart');
         
if nargin>=3 && ~isempty(specs)
   set(gca,'NextPlot','add');
   LSL = specs(1);
   USL = specs(2);
   t3 = text(m + 0.5,USL,'USL');
   t4 = text(m + 0.5,LSL,'LSL');
   hh1 = plot(samples,LSL(ones(m,1),:),'g-',samples,USL(ones(m,1),:),'g-');
   set(gca,'NextPlot','replace');
   hh = [hh; hh1];
end

if nargout > 0
  outliers = redpts;
end

if nargout == 2
 h = hh;
end         

set(hh([3 5 6]),'LineWidth',2);
xlabel('Samples');
ylabel('Measurements');
