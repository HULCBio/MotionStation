function wdstem(varargin)
%WDSTEM Plot discrete sequence data.
%   WDSTEM(AXE,X,Y,COLOR) or
%   WDSTEM(X,Y,COLOR) or
%   WDSTEM(AXE,X,Y,COLOR,FLGZERO)
%   WDSTEM(X,Y,COLOR,FLGZERO)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if ishandle(varargin{1})
    axe     = varargin{1};
    x       = varargin{2};
    y       = varargin{3};
    nextarg = 4;
else
    axe     = newplot;
    x       = varargin{1};
    y       = varargin{2};
    nextarg = 3;
end
if nargin<nextarg
    c       = get(axe,'colororder');
    c       = c(1,:);
    flgZero = 0;
elseif nargin==nextarg
    c       = varargin{nextarg};
    flgZero = 0;
else
    c       = varargin{nextarg};
    flgZero = varargin{nextarg+1};
end

MSize   = 25;
n       = length(x);
xx      = [x;x;nan*ones(size(x))];
yy      = [zeros(1,n);y;nan*ones(size(y))];
tag_axe = get(axe,'Tag');
next    = lower(get(axe,'NextPlot'));
h(2)    = plot(xx(:),yy(:),'Parent',axe,'LineStyle','-','Color',c);
set(axe,'NextPlot','add');

% Added Property Marker
h(1) = plot(x,y,'Parent',axe,...
                'Marker','.',...
                'LineStyle','none',...
                'MarkerSize',MSize,'Color',c);

if ~isequal(flgZero,0)
    i_nul = find(abs(y)<eps);
    plot(x(i_nul),y(i_nul),'Parent',axe,...
            'Marker','.',...
            'LineStyle','none',...
            'MarkerSize',MSize,'Color',get(axe,'xcolor'));
end
q    = get(axe,'Xlim');
h(3) = plot([q(1) q(2)],[0 0],'Parent',axe);
set(h(3),'color',get(axe,'xcolor'))
set(axe,'NextPlot',next,'Tag',tag_axe);
