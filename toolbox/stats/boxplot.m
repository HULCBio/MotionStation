function hout=boxplot(x,varargin)
%BOXPLOT Display boxplots of a data sample.
%   BOXPLOT(X) produces a box and whisker plot with one box for each column
%   of X.  The boxes have lines at the lower quartile, median, and upper
%   quartile values.  The whiskers are lines extending from each end of the
%   boxes to show the extent of the rest of the data.  Outliers are data
%   with values beyond the ends of the whiskers.
%
%   BOXPLOT(X,G) produces a box and whisker plot for the vector X
%   grouped by G.  G is a grouping variable defined as a vector, string
%   matrix, or cell array of strings.  G can also be a cell array of 
%   several grouping variables (such as {G1 G2 G3}) to group the values in
%   X by each unique combination of grouping variable values.
%
%   BOXPLOT(...,'PARAM1',val1,'PARAM2',val2,...) specifies optional
%   parameter name/value pairs:
%
%      'notch'       'on' to include notches (default is 'off')
%      'symbol'      Symbol to use for outliers (default is 'r+')
%      'orientation' Box orientation, 'vertical' (default) or 'horizontal'
%      'whisker'     Maximum whisker length (default 1.5)
%      'labels'      Character array or cell array of strings containing
%                    column labels (used only if X is a matrix, and the
%                    default label is the column number)
%
%   In a notched box plot the notches represent a robust estimate of the
%   uncertainty about the medians for box-to-box comparison.  Boxes whose
%   notches do not overlap indicate that the medians of the two groups
%   differ at the 5% significance level.  Whiskers extend from the box
%   out to the most extreme data value within WHIS*IQR, where WHIS is the
%   value of the 'whisker' parameter and IQR is the interquartile range
%   of the sample.
%
%   H=BOXPLOT(...) returns the handle H to the lines in the box plot.
%   H has one column per box, consisting of the handles for the various
%   parts of the box.  Each column contains 7 handles for the upper
%   whisker, lower whisker, upper adjacent value, lower adjacent value,
%   box, median, and outliers.
%
%   Example:  Box plot of car mileage grouped by country
%      load carsmall
%      boxplot(MPG, Origin)
%
%   See also ANOVA1, KRUSKALWALLIS, MULTCOMPARE.

%   Older syntax still supported:
%       BOXPLOT(X,NOTCH,SYM,VERT,WHIS)
% 
%   BOXPLOT calls BOXUTIL to do the actual plotting.

%   References
%   [1] McGill, R., Tukey, J.W., and Larsen, W.A. (1978) "Variations of
%       Boxplots", The American Statistician, 32:12-16.
%   [2] Velleman, P.F. and Hoaglin, D.C. (1981), Applications, Basics, and
%       Computing of Exploratory Data Analysis, Duxbury Press.
%   [3] Nelson, L.S., (1989) "Evaluating Overlapping Confidence
%       Intervals", Technometrics, 21:140-141.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.4.6 $  $Date: 2004/04/01 16:23:33 $

if (nargin==1 & length(x(:))==1 & ishandle(x)), resizefcn(x); return; end

whissw = 0; % don't plot whisker inside the box.

[m n] = size(x);
if min(m,n) > 1 
    xx = x(:,1);
    yy = xx;
else
    n = 1;
    xx = x;
    yy = x;
end

% Detect if there is a grouping variable
nargs = nargin;
if (nargin<2)
   g = [];
else
   g = varargin{1};
   if isempty(g) || isequal(g,1) || isequal(g,0) || (ischar(g) && size(g,1)==1)
      % This is a NOTCH value or a parameter name
      g = [];
   else
      varargin(1) = [];
   end
end

% Define defaults
notch = 0;
sym = 'r+';
vert = 1;
whis = 1.5;
labels = {};

% Determine if we have parameter names or the old syntax
if length(varargin)>0
   if ischar(varargin{1})
      okargs =   {'notch' 'symbol' 'orientation' 'whis' 'labels'};
      defaults = {notch   sym      vert          whis   labels};
      [eid,emsg,notch,sym,vert,whis,labels] = ...
                      statgetargs(okargs,defaults,varargin{:});
      if ~isempty(eid)
         error(sprintf('stats:boxplot:%s',eid),emsg);
      end
   else
      if (length(varargin)>=1) && ~isempty(varargin{1})
         notch = varargin{1};
      end
      if (length(varargin)>=2) && ~isempty(varargin{2})
         sym = varargin{2};
      end
      if (length(varargin)>=3) && ~isempty(varargin{3})
         vert = varargin{3};
      end
      if (length(varargin)>=3) && ~isempty(varargin{4})
         whis = varargin{4}; 
      end
   end
end

% Convert wordy inputs to internal codes
if isequal(notch,'on')
   notch = 1;
elseif isempty(notch) || isequal(notch,'off')
   notch = 0;
elseif ~isscalar(notch) && ~ismember(notch,0:1)
   error('stats:boxplot:InvalidNotch','Invalid value for ''notch'' parameter');
end

if isempty(vert)
   vert = 1;
elseif ischar(vert)
   vert = strmatch(vert,{'horizontal' 'vertical'}) - 1;
end
if isempty(vert) || ~isscalar(vert) || ~ismember(vert,0:1)   
   error('stats:boxplot:InvalidOrientation',...
         'Invalid value for ''orientation'' parameter');
end

if ~isscalar(whis) || ~isnumeric(whis)
   error('stats:boxplot:BadWhisker',...
         'Value of ''whisker'' parameter must be a numeric scalar.');
end

if ~isempty(labels)
   if ~isempty(g)
      warning('stats:boxplot:LabelsIgnored',...
              'Labels are ignored when there is a grouping variable.');
   elseif ~(iscellstr(labels) && numel(labels)==size(x,2)) && ...
          ~(ischar(labels) && size(labels,1)==size(x,2))
      error('stats:boxplot:BadLabels','Incorrect number of column labels');
   end
end

% Deal with grouping variable
xorig = x;
gorig = g;
xvisible = NaN*ones(size(x));
included = 1:prod(size(x));
if (~isempty(g))
   if ~isvector(x)
      error('stats:boxplot:VectorRequired',...
            'X must be a vector when there is a grouping variable.');
   end
   x = x(:);
   
   if (vert)
      sep = '\n';
   else
      sep = ',';
   end

   [g,glabel,gname,multigroup] = mgrp2idx(g,size(x,1),sep);
   n = size(gname,1);
   gorig = g;
   
   if numel(g) ~= numel(x)
      error('stats:boxplot:InputSizeMismatch',...
            'X and G must have the same length.');
   end

   k = (isnan(g) | isnan(x));
   if (any(k))
      x(k) = [];
      g(k) = [];
      included(k) = [];
   end
end

lb = 1:n;

xlims = [0.5 n + 0.5];

k = find(~isnan(x));
ymin = min(min(x(k)));
ymax = max(max(x(k)));
dy = (ymax-ymin)/20;
if dy==0
   dy = 0.5;  % no data range, just use a y axis range of 1
end
ylims = [(ymin-dy) (ymax+dy)];

lf = n*min(0.15,0.5/n);

% Scale axis for vertical or horizontal boxes.
newplot
oldstate = get(gca,'NextPlot');
set(gca,'NextPlot','add','Box','on');
if vert
    axis([xlims ylims]);
    set(gca,'XTick',lb);
    ylabel(gca,'Values');
    if (isempty(g)), xlabel(gca, 'Column Number'); end
else
    axis([ylims xlims]);
    set(gca,'YTick',lb);
    xlabel(gca,'Values');
    if (isempty(g)), ylabel(gca,'Column Number'); end
end
if nargout>0
   hout = [];
end

if (~isempty(g))
   for i=1:n
      thisgroup = (g==i);
      z = x(thisgroup);
      pts = included(thisgroup);
      [outliers,hh] = boxutil(z,notch,lb(i),lf,sym,vert,whis,whissw);
      pts = pts(outliers);
      xvisible(pts) = xorig(pts);
      if nargout>0
         hout = [hout, hh(:)];
      end
   end

   if (multigroup & vert)
      % Turn off tick labels and axis label
      set(gca, 'XTickLabel','');
      setappdata(gca,'NLines',size(gname,2));
      xlabel(gca,'');
      ylim = get(gca, 'YLim');
      
      % Place multi-line text approximately where tick labels belong
      for j=1:n
         ht = text(j,ylim(1),glabel{j,1},'HorizontalAlignment','center',...
              'VerticalAlignment','top', 'UserData','xtick');
      end

      % Resize function will position text more accurately
      set(gcf, 'ResizeFcn', sprintf('boxplot(%d)', gcf), ...
               'Interruptible','off', 'PaperPositionMode','auto');
      resizefcn(gcf);
   elseif (vert)
      set(gca, 'XTickLabel',glabel);
   else
      set(gca, 'YTickLabel',glabel);
   end

elseif n==1
   thisgroup = ~isnan(yy);
   vec = find(thisgroup);
   if ~isempty(vec)
      pts = included(thisgroup);
      [outliers,hh] = boxutil(yy(vec),notch,lb,lf,sym,vert,whis,whissw);
      pts = pts(outliers);
      xvisible(pts) = xorig(pts);
      if nargout>0
         hout = hh(:);
      end
   end
else
   g = repmat(1:n,size(x,1),1);
   notnan = ~isnan(x);
   for i=1:n
      thisgroup = (g==i) & notnan;
      z = x(thisgroup);
      if ~isempty(z)
         pts = included(thisgroup);
         [outliers,hh] = boxutil(z,notch,lb(i),lf,sym,vert,whis,whissw);
         pts = pts(outliers);
         xvisible(pts) = xorig(pts);
      end
      if nargout>0
         hout = [hout, hh(:)];
      end
   end
   if ~isempty(labels)
      if (vert)
         set(gca, 'XTickLabel',labels);
         xlabel(gca, '');
      else
         set(gca, 'YTickLabel',slabels);
         ylabel(gca, '');
      end
   end
end
set(gca,'NextPlot',oldstate);

% Store information for gname
set(gca, 'UserData', {'boxplot' xvisible gorig vert});

% ------------------------
function resizefcn(f)
% Adjust figure layout to make sure labels remain visible
h = findobj(f, 'UserData','xtick');
if (isempty(h))
   set(f, 'ResizeFcn', '');
   return;
end
ax = get(f, 'CurrentAxes');
nlines = getappdata(ax, 'NLines');

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
