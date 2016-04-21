function A = celltext(theFrame, varargin)
%CELLTEXT/CELLTEXT Make celltext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2004/01/15 21:12:11 $

if nargin==0
   A.Class = 'celltext';
   A.HorizontalAlignment = [];
   A.VerticalAlignment = [];
   A.FontUnits = [];
   A.FontSize = [];
   A.CellPadding = [];
   A = class(A,'celltext',axistext);
   return
end

pos = get(theFrame,'Position');

% center initially

x = pos(1)+pos(3)/2;
y = pos(2)+pos(4)/2;

if nargin==1
   t = text(x,y,'','Visible','off');
else
   t = text(x,y, varargin{:},'Visible','off');
end
set(t,...
	'HorizontalAlignment','center',...
	'VerticalAlignment','middle',...
	'Editing','on',...
        'Clipping','on',...
	'EraseMode','xor',...
	'ButtonDownFcn','doclick(gcbo)');

A.Class = 'celltext';
A.HorizontalAlignment = 'center';
A.VerticalAlignment = 'middle';

axobj = getobj(get(t,'Parent'));
if ~isempty(axobj)
   zoomScale = get(axobj,'ZoomScale');
else
   zoomScale = 1;
end

A.FontUnits = get(t,'FontUnits');
A.FontSize = get(t,'FontSize');
set(t,'FontSize', A.FontSize*zoomScale,...
        'Visible','on');

A.CellPadding = .05;
% A.CellPaddingUnits = 'pixels';
axistextObj = axistext(t);
A = class(A,'celltext',axistextObj);
Ah = scribehandle(A);
theFrame.NewItem = scribehandle(A);

A = Ah.Object;

% tweak the context menus

uic = getscribecontextmenu(t);
% use the HG context menu dispatching, rather than the scribeeventhandler
set(t,'UIContextMenu',uic);
menus = allchild(uic);
colorMenu = findall(menus,'Tag','ScribeAxistextObjColorMenu');

delete([findall(menus,'Tag','ScribeAxistextObjCutMenu'),...
           findall(menus,'Tag','ScribeAxistextObjCopyMenu'),...
           findall(menus,'Tag','ScribeAxistextObjPasteMenu'),...
           findall(menus,'Tag','ScribeAxistextObjClearMenu')]);

set(colorMenu,'Callback','domethod(getobj(gco),''editcolor'')');

set(findall(allchild(uic),'Tag','ScribeAxistextObjStringMenu'),...
        'Separator','off');



