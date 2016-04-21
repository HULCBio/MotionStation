function imsource = cfsectionpreview(outlier, width, height)
% For use by CFTOOL

%   $Revision: 1.2.2.2 $
%   Copyright 2001-2004 The MathWorks, Inc.

if nargin < 2
    width = 180;
    height = 180;
end

tempfigure=figure('units','pixels','position',[0 0 width height], ...
      'handlevisibility','off', ...
      'integerhandle','off', ...
      'visible','off', ...
      'paperpositionmode', 'auto', ...
      'color','w');

xlim = [0 4];
ylim = [0 4];
ax=axes('position',[.05 .05 .9 .9], ...
      'parent',tempfigure, ...
      'xtick',[],'ytick',[], ...
      'box','on', ...
      'visible','off', 'XLim',xlim,'YLim',ylim);

gr = [.9 .9 .9];
o = handle(outlier);

xlo = o.domainLow;
if ~isempty(xlo)
    patch([0 1 1 0], [0 0 4 4], gr,'LineStyle','none','Parent',ax); 
end

xhi = o.domainHigh;
if ~isempty(xhi)
    patch([3 4 4 3], [0 0 4 4], gr,'LineStyle','none','Parent',ax); 
end

ylo = o.rangeLow;
if ~isempty(ylo)
    patch([0 4 4 0], [0 0 1 1], gr,'LineStyle','none','Parent',ax); 
end

yhi = o.rangeHigh;
if ~isempty(yhi)
    patch([0 4 4 0], [3 3 4 4], gr,'LineStyle','none','Parent',ax);
end

x=hardcopy(tempfigure,'-dzbuffer','-r0');
% give the image a black edge
x(1,:,:)=0; x(end,:,:)=0; x(:,1,:)=0; x(:,end,:)=0;
imsource=im2mis(x);

delete(tempfigure);
