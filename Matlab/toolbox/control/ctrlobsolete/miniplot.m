function [h,Axes,BigAx] = miniplot(rows,cols,x1,y1,x2,y2)
%MINIPLOT A many small multiples plot.
%       [H,AX,BigAx] = MINIPLOT(ROWS,COLS,X1,Y1, ...) plots data into
%       a ROWS*COLS matrix of axes.  For example, try
%       miniplot(4,3,(1:10)',rand(10,12))
%
%       H is a matrix of handles to the lines created.  The first column of H
%       contains handles to the lines generated for x1 and y1, the second column 
%       contains handles to the lines generated for x2 and y2.
%
%       AX is a vector of the subaxes in column order.
%
%       BigAx is the handle to a big (invisible) axes which frames the subaxes.
%
%       Notes:
%       ------
%       The Xi and Yi can be *column* vectors and "the right thing" will happen.
%
%       When the function finshes, BigAx is the CurrentAxes.   In this way, one 
%       can call MINIPLOT and then issue label and title commands and the labels 
%       and titles should appear in "the right place."
%
%       For speed, only 2 lines per axes may be created.
%
%       The figure's NextPlot property is set to replace if hold is *not* on.  
%       This should result in the "right behavior" with respect to other plotting 
%       commands and hold.
%
%       See also: SUBAXES

%       Author(s): A. Potvin, 11-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:56 $

ni = nargin;
if ~any(ni==[4 6]),
   error('Wrong number of input arguments.')
end
fig = newfig;

% Create/find BigAx and make it invisible
DefAxesPos = get(fig,'DefaultAxesPosition');
BigAx = findobj(fig,'Type','axes','Position',DefAxesPos);
if isempty(BigAx),
   BigAx = axes;
else
   BigAx = BigAx(1);
   delete(BigAx(2:length(BigAx)))
end
set(BigAx,'Visible','off')

% Create Axes
% Note: subaxes automatically sets Visible to on
Axes = subaxes(rows,cols,DefAxesPos,fig);
n = length(Axes);

% Will later return BigAx as the CurrentAxes
IsHoldOn = strcmp(get(fig,'NextPlot'),'add') & strcmp(get(BigAx,'NextPlot'),'add');
if IsHoldOn,
   set([BigAx; Axes],'NextPlot','add')
else
   set([BigAx; Axes],'NextPlot','replace')
end
% Delete children of BigAx if more than one plot
if n>1,
   delete(get(BigAx,'Children'))
end

l = size(x1,2);
if l==1,
   Xind = ones(1,n);
elseif l==n,
   Xind = 1:n;
else
   error('x1 must have ROWS*COLS columns.')
end
l = size(y1,2);
if l==1,
   Yind = ones(1,n);
elseif l==n,
   Yind = 1:n;
else
   error('y1 must have ROWS*COLS columns.')
end
if ni>=6,
   l = size(x2,2);
   if l==1,
      Xind = [Xind; ones(1,n)];
   elseif l==n,
      Xind = [Xind; 1:n];
   else
      error('x2 must have ROWS*COLS columns.')
   end
   l = size(y2,2);
   if l==1,
      Yind = [Yind; ones(1,n)];
   elseif l==n,
      Yind = [Yind; 1:n];
   else
      error('y2 must have ROWS*COLS columns.')
   end
end

% Cycle through Axes and plot data
PlotH = zeros(n,1);
LineH = zeros(n,1);
for i=1:length(Axes),
   ax = Axes(i);
   set(fig,'CurrentAxes',ax)

   % Use plot for x1 and y1 to obey NextPlot
   PlotH(i) = plot(x1(:,Xind(1,i)),y1(:,Yind(1,i)));

   % Could do the many lines with a for loop and an eval, but that would be slow
   % Inline the code for now
   % In v5, varargin will allow the for loop approach to be fast

   % Use line for other data
   if ni==6,
      LineH(i) = line(x2(:,Xind(2,i)),y2(:,Yind(2,i)));
   end
end

% Try to smart about TickLabels and Make BigAx the CurrentAxes
set(Axes,'XTickLabels','','YTickLabels','')
set(BigAx,'XTickLabelMode','auto','YTickLabelMode','auto')
set(fig,'CurrentAx',BigAx)
if ~IsHoldOn,
   set(fig,'NextPlot','replace')
end
% Also set Title and X/YLabel visibility to on and strings to empty
set([get(BigAx,'Title'); get(BigAx,'XLabel'); get(BigAx,'YLabel')], ...
 'String','','Visible','on')

no = nargout;
if no~=0,
   h = PlotH;
   if ni==6,
      h = [h LineH];   
   end
end   

% end miniplot
