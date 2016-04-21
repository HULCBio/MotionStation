function [means, sem, counts, gname] = grpstats(x,group,alpha)
%GRPSTATS Summary statistics by group.
%   GRPSTATS(X,GROUP) Returns the MEANS of each column of X by GROUP. X is
%   a matrix of observations.  GROUP is a grouping variable defined
%   as a vector, string array, or cell array of strings.  GROUP can also
%   be a cell array of several grouping variables (such as {G1 G2 G3})
%   to group the values in X by each unique combination of grouping
%   variable values.
%
%   [MEANS,SEM,COUNTS,GNAME] = GRPSTATS(X,GROUP) supplies the standard error
%   of the mean in SEM, the number of elements in each group in COUNTS,
%   and the name of each group in GNAME.
%
%   GRPSTATS(X,GROUP,ALPHA) displays a plot of the means versus index with
%   100(1 - ALPHA)%  confidence intervals around each mean.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.2.3 $  $Date: 2004/01/16 20:09:26 $

if (nargin==1 & length(x(:))==1 & ishandle(x)), resizefcn(x); return; end

if (nargin<2)
   error('stats:grpstats:TooFewInputs',...
         'GRPSTATS requires at least two arguments.')
elseif (nargin==3)
   if (prod(size(alpha))~=1)
      error('stats:grpstats:BadAlpha','ALPHA must be a scalar.');
   elseif ((~isnumeric(alpha)) | alpha<=0 | alpha>=1)
      error('stats:grpstats:BadAlpha',...
            'ALPHA must be a number larger than 0 and smaller than 1.');
   end
end

% Get grouping variable information
[row,cols] = size(x);
[group,glabel,gname,multigroup] = mgrp2idx(group,row);

n = max(group(~isnan(group)));
if isa(x,'single')
   means = zeros(n,cols,'single');
else
   means = zeros(n,cols);
end
sem    = means;
counts = means;

for idx1 = 1:cols
   k = find(~isnan(x(:,idx1)) & ~isnan(group));
   y = x(k,idx1);
   idx = group(k);
   if any(any(group)) < 0 | any(any(group)) ~= floor(group)
     error('stats:grpstats:BadGroup',...
       'Requires a vector second input argument with only positive integers.');
   end

   for idx2 = 1:n
     k = find(idx == idx2);
     means(idx2,idx1)  = mean(y(k));
     sem(idx2,idx1)    = std(y(k));
     sem(idx2,idx1)    = sem(idx2,idx1) ./ sqrt(length(k));
     counts(idx2,idx1) = length(k);
   end
end

if nargin == 3
   p = 1 - alpha/2;
   xd = (1:n)';
   xd = xd(:,ones(cols,1));
   h = errorbar(xd,means,tinv(p,counts-1) .* sem);
   set(h(1+end/2:end),'LineStyle','none','Marker','o','MarkerSize',2);
   set(gca,'Xlim',[0.5 n+0.5],'Xtick',(1:n));
   xlabel('Group');
   ylabel('Mean');
   if (multigroup)
      % Turn off tick labels and axis label
      set(gca, 'XTickLabel','','UserData',size(gname,2));
      xlabel('');
      ylim = get(gca, 'YLim');
      
      % Place multi-line text approximately where tick labels belong
      for j=1:n
         ht = text(j,ylim(1),glabel{j,1},'HorizontalAlignment','center',...
              'VerticalAlignment','top', 'UserData','xtick');
      end

      % Resize function will position text more accurately
      set(gcf, 'ResizeFcn', sprintf('grpstats(%d)', gcf), ...
               'Interruptible','off');
      resizefcn(gcf);
   else
      set(gca, 'XTickLabel',glabel);
   end
   title('Means and Confidence Intervals for Each Group');
   set(gca, 'YGrid', 'on');
end

function resizefcn(f)
% Adjust figure layout to make sure labels remain visible
h = findobj(f, 'UserData','xtick');
if (isempty(h))
   set(f, 'ResizeFcn', '');
   return;
end
ax = get(f, 'CurrentAxes');
nlines = get(ax, 'UserData');

% Position the axes so that the fake X tick labels have room to display
set(ax, 'Units', 'characters');
p = get(ax, 'Position');
ptop = p(2) + p(4);
if (p(4) < nlines+1.5)
   p(2) = ptop/2;
else
   p(2) = nlines + 1;
end
p(4) = ptop - p(2);
set(ax, 'Position', p);
set(ax, 'Units', 'normalized');

% Position the labels at the proper place
xl = get(gca, 'XLabel');
set(xl, 'Units', 'data');
p = get(xl, 'Position');
ylim = get(gca, 'YLim');
p2 = (p(2)+ylim(1))/2;
for j=1:length(h)
   p = get(h(j), 'Position') ;
   p(2) = p2;
   set(h(j), 'Position', p);
end
