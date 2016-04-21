function cfadjustlayout(cffig,showctrl)
%ADJUSTLAYOUT Adjust layout of buttons and graph in figure window

%   $Revision: 1.13.2.1 $  $Date: 2004/02/01 21:39:36 $
%   Copyright 2001-2004 The MathWorks, Inc.

% Get some measurements
ufig = get(cffig,'Units');
set(cffig,'Units','points');
fpos = get(cffig,'Position');
fwidth = fpos(3);
fheight = max(1,fpos(4));

% Adjust all button positions
% *** "tags" also defined in cfaddbuttons, and they must match
tags = {'cfimport' 'cffit' 'cfexclude' 'cfplot' 'cfanalyze'};
hbuttons = findobj(cffig,'Type','uicontrol','Style','pushbutton');
nbuttons = length(tags);
if isempty(hbuttons)
   bheight = 0;
   border = 0;
else
   hb = zeros(nbuttons,1);
   set(hbuttons,'Units','points');
   extents = zeros(nbuttons,4);
   for j=1:nbuttons
      hb(j) = findobj(hbuttons,'flat','Tag',tags{j});
      extents(j,:) = get(hb(j),'Extent');
   end
   bheight = 1.5 * extents(1,4);  % 1.5 * text height
   border = bheight/2;            % border above buttons
   gutter = bheight/4;            % between buttons
   margin = bheight/2;            % around text within button
   bwidth = extents(:,3)' + 2*margin;
   totalwidth = sum(bwidth) + gutter*(nbuttons-1);
   startpos = max(0, (fwidth/2) - (totalwidth/2));
   bleft = startpos + [0, cumsum(bwidth + gutter)];
   for j=1:nbuttons
      pos = [bleft(j), max(1,fheight-bheight-border), bwidth(j), bheight];
      set(hb(j),'Units','points', 'Position',pos);
   end
end

% Position the axes in the remaining area
ax1 = findall(cffig,'Type','axes','Tag','main');
ax2 = findall(cffig,'Type','axes','Tag','resid');
allax = [ax1;ax2];
uax1 = get(ax1,'Units');
xpos = [.13 .775];
if isempty(ax2)
   ytop = [.110 .815];
else
   ytop = [.5811 .3439];
   ybot = [.11 .3439];
   uax2 = get(ax2,'Units');
end

set(allax,'Units','normalized');
p1 = get(ax1,'Position');
p1([2 4]) = max(1e-6,ytop * max(1,fheight-bheight-border)/fheight);
p1([1 3]) = xpos;
set(ax1,'Position',p1);
set(ax1,'Units',uax1);
if ~isempty(ax2)
   p2 = get(ax2,'Position');
   p2([2 4]) = ybot * max(1,fheight-bheight-border)/fheight;
   p2([1 3]) = p1([1 3]);
   set(ax2,'Position',p2);
   set(ax2,'Units',uax2);
end

set(cffig,'Units',ufig);

if nargin<2
   showctrl = cfgetset('showaxlimctrl');
end
if isequal(showctrl,'on')
   cfaxlimctrl(cffig,'off');
   cfaxlimctrl(cffig,'on');
end
