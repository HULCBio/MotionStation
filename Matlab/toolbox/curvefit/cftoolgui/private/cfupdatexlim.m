function cfupdatexlim(newminmax)
%CFUPDATEXLIM Update the stored x axis min/max values

%   $Revision: 1.6.2.4 $  $Date: 2004/03/02 21:46:13 $
%   Copyright 2001-2004 The MathWorks, Inc.

minmax = [];                     % to become new x limits
oldminmax = cfgetset('xminmax'); % previous limits

if nargin==0
   % Update limits from datasets with a plotting flag on
   a = cfgetalldatasets;
   for j=1:length(a)
      b = a{j};
      if b.plot == 1
         minmax = combineminmax(minmax,b.xlim);
      end
   end

   % Update from fits with a plotting flag on
   a = cfgetallfits;
   for j=1:length(a)
      b = a{j};
      if b.plot == 1
         minmax = combineminmax(minmax,xlim(b));
      end
   end
else
   minmax = combineminmax(oldminmax,newminmax);
end

% Now update plot
cffig = cfgetset('cffig');
if ~isempty(minmax) && ~zoom(cffig,'ison')
   ax = findall(cffig,'Type','axes','Tag','main');
   dx = diff(minmax) * 0.01 * [-1 1];
   if all(dx==0)
      dx = [-1 1] * max(1,eps(minmax(1)));
   end
   set(ax,'XLim',minmax+dx);
end
cfgetset('xminmax',minmax);

% ------------ Helper to combine old and new minmax values
function bothmm = combineminmax(oldmm,newmm)

if isempty(oldmm)
   bothmm = newmm;
elseif isempty(newmm)
   bothmm = oldmm;
else
   bothmm = [min(oldmm(1),newmm(1)) max(oldmm(2),newmm(2))];
end
