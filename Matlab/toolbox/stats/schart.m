function [outliers, h] = schart(data,conf,specs)
%SCHART S chart for monitoring the standard deviation.
%   SCHART(DATA,CONF,SPECS) produces an S chart of
%   the grouped responses in DATA. The rows of DATA contain
%   replicate observations taken at a given time. The rows
%   must be in time order.
%
%   CONF (optional) is the confidence level of the upper and 
%   lower plotted confidence limits. CONF is 0.9973 by default.
%   This means that 99.73% of the plotted points should fall 
%   between the control limits.
%
%   SPECS (optional) is a two element vector for the lower and
%   upper specification limits of the response.
%
%   OUTLIERS = SCHART(DATA,CONF,SPECS) returns  a vector of 
%   indices to the rows where the standard deviation of DATA is 
%   out of control.
%
%   [OUTLIERS, H] = SCHART(DATA,CONF,SPECS) also returns a vector
%   of handles, H, to the plotted lines.

%   Reference: Montgomery, Douglas, Introduction to Statistical
%   Quality Control, John Wiley & Sons 1991 p. 235.

%   B.A. Jones 2-13-95
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.2 $  $Date: 2004/01/24 09:36:52 $
 

if nargin < 2
   conf = 0.9973;
end

if isempty(conf)
  conf = 0.9973;
end
ciprob = 1-(1-conf)/2;

[m,n] = size(data);
xbar  = double(mean(data')');
s     = double(std(data')');
sbar   = mean(s);

c4 = sqrt(2/(n-1)).*gamma(n/2)./gamma((n-1)/2);
cicrit = norminv(ciprob);
b3 = 1 - cicrit*sqrt(1-c4*c4)/c4;
b4 = 1 + cicrit*sqrt(1-c4*c4)/c4;

%chi2crit = chi2inv([(1-conf)/2 1-(1-conf)/2],n-1);
%sigmaci =  sbar*sqrt((n-1)./chi2crit)

LCL = b3*sbar;
if LCL < 0, LCL = 0; end
UCL = b4*sbar;

tmp = NaN;
incontrol = tmp(1,ones(1,m));
outcontrol = incontrol;

greenpts = find(s > LCL & s < UCL);
redpts = find(s <= LCL | s >= UCL);

incontrol(greenpts) = s(greenpts);
outcontrol(redpts) = s(redpts);

samples = (1:m);

hh  = plot(samples,s,samples,UCL(ones(m,1),:),'r-',samples,sbar(ones(m,1),:),'g-',...
           samples,LCL(ones(m,1),:),'r-',samples,incontrol,'b+',...
         samples,outcontrol,'r+');

if any(redpts)
  for k = 1:length(redpts)
     text(redpts(k) + 0.5,outcontrol(redpts(k)),num2str(redpts(k)));
  end
end

t1 = text(m+0.5,UCL,'UCL');
t2 = text(m+0.5,LCL,'LCL');
text(m+0.5,sbar,'CL');
title('S Chart');
         
if nargin == 3
   set(gca,'NextPlot','add');
   LSL = double(specs(1));
   USL = double(specs(2));
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
xlabel('Sample Number');
ylabel('Standard Deviation');
