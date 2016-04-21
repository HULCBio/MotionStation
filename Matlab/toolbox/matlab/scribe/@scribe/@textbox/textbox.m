function h=textbox(varargin)
%TEXTBOX creates the annotation textbox object
%  H=scribe.TEXTBOX creates an annotation textbox instance

%   Copyright 1984-2004 The MathWorks, Inc. 

fig = [];
if (nargin == 0) || ischar(varargin{1})
  parind = find(strcmpi(varargin,'parent'));
  if ~isempty(parind)
    fig = get(varargin{parind(end)+1},'Parent');
  end
else
  [fig,varargin,nargs] = graph2dhelper('hgcheck','hg.figure',varargin{:});
end
if isempty(fig)
    fig=gcf;
end
curax = get(fig,'currentaxes');
% if no scribeaxes for this figure create one.
scribeaxes = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if isempty(scribeaxes)
    scribeaxes = scribe.scribeaxes(fig);
end
set(scribeaxes,'HandleVisibility','on');

h = scribe.textbox('Parent',double(scribeaxes));
scribeaxes.methods('addshape',h);

% set hittest for the group off
set(double(h),'HitTest','off');

setappdata(double(h),'scribeobject','on');

% Create the main rectangle and affordance rectangles
% some locals for positions
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),'normalized',fig);
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
px = [x1 x2 x2 x1];
py = [y1 y1 y2 y2];
pz = 0;
[x,y,z]=meshgrid([x1,x2],[y1,y2],pz);
if isempty(h.Rect) || ~ishandle(h.Rect)
    h.Rect = hg.surface(...
        'Visible','off',...
        'EdgeColor',h.EdgeColor,...
        'FaceAlpha',h.FaceAlpha,...
        'LineStyle',h.LineStyle,...
        'LineWidth',h.LineWidth,...
        'FaceColor','flat',...
        'CData',NaN,...
        'FaceLighting','none',...
        'Parent',double(h),...
        'Interruptible','off');
end
set(double(h.Rect),'XData',x,'YData',y,'ZData',z);
setappdata(double(h.Rect),'ScribeGroup',h);
set(double(h.Rect),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Rect),'bdown'});
% normalized main rect upper left corner x and y
ulx = x1;
uly = y2;
rx = pos(3);
ry = pos(4);
cx = pos(1)+pos(3)/2;
cy = pos(2)+pos(4)/2;
% selection handle size;
afsiz = h.Afsiz;  % pixels
%THE AFFORDANCES
px = [ulx,ulx+rx,ulx+rx,ulx,ulx,cx,ulx+rx,cx];
py = [uly,uly,uly-ry,uly-ry,cy,uly,cy,uly-ry];
if isempty(h.Srect) || ~all(ishandle(h.Srect))
    for k=1:8
        sr(k) = hg.line('XData', px(k), 'YData', py(k), 'ZData', 0, 'LineWidth', 0.01, 'Color', 'k', ...
            'Marker','square','Markersize',afsiz,'MarkerFaceColor','k','MarkerEdgeColor','w',...
            'Visible','off','Parent',double(h),'Interruptible','off');
        setappdata(double(sr(k)),'ScribeGroup',h);
        set(double(sr(k)),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(sr(k)),'srbdown',k});
    end
end
h.Srect = sr;

% text
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),'pixels',fig);
h.Text = hg.text('Units','pixels',...
    'Visible','off',...
    'Color',h.Color,...
    'BackgroundColor','none',...
    'EdgeColor','none',...
    'Editing','off',...
    'Position',[pos(1) , pos(2)+pos(4) , 0],...
    'FontAngle',h.FontAngle,...
    'FontName',h.FontName,...
    'FontSize',h.FontSize,...
    'FontUnits',h.FontUnits,...
    'FontWeight',h.FontWeight,...
    'HorizontalAlignment',h.HorizontalAlignment,...
    'Margin',1,...
    'Rotation',h.Rotation,...
    'String',h.String,... % Cstring,...
    'Interpreter',h.Interpreter,...
    'VerticalAlignment',h.VerticalAlignment,...
    'Parent',double(h),...
    'Interruptible','off'); 

setappdata(double(h.Text),'ScribeGroup',h);
set(double(h.Text),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Text),'tbdown'});

% initialize pin affordance
h.Pinrect = [];
%set up listeners-----------------------------------------
% text object properties
p= [h.findprop('Color'); ...
    h.findprop('FontAngle'); ...
    h.findprop('FontName'); ...
    h.findprop('FontSize'); ...
    h.findprop('FontUnits'); ...
    h.findprop('FontWeight'); ...
    h.findprop('HorizontalAlignment'); ...
    h.findprop('Margin'); ...
    h.findprop('Rotation'); ...
    h.findprop('Interpreter'); ...
    h.findprop('VerticalAlignment')];
l = [handle.listener(h,h.findprop('Position'),...
                     'PropertyPostSet',@changedPos); ...
     handle.listener(h,h.findprop('Position'),...
                     'PropertyPreSet',@changedPosPreSet); ...
     handle.listener(h,h.findprop('BackgroundColor'),...
                     'PropertyPostSet',@changedBackgroundColor);...
     handle.listener(h,h.findprop('FaceAlpha'),...
                     'PropertyPostSet',@changedAlpha); ...
     handle.listener(h,h.findprop('Image'),...
                     'PropertyPostSet',@changedImage); ...
     handle.listener(h,h.findprop('EraseMode'),...
                     'PropertyPostSet',@changedEraseMode);...
     handle.listener(h,h.findprop('EdgeColor'),...
                     'PropertyPostSet',@changedEdgeProps);...
     handle.listener(h,h.findprop('LineWidth'),...
                     'PropertyPostSet',@changedEdgeProps);...
     handle.listener(h,h.findprop('LineStyle'),...
                     'PropertyPostSet',@changedEdgeProps);...
     handle.listener(h,h.findprop('Selected'),...
                     'PropertyPostSet',@changedSelected);...
     handle.listener(h,h.findprop('Editable'),...
                     'PropertyPreSet',@changingOutOfEditProperties); ...
     handle.listener(h,p,'PropertyPostSet',@changedTextStyle);
     handle.listener(h,h.findprop('FitHeightToText'),...
                     'PropertyPostSet',@changedFitHeightToText); ...
     handle.listener(h,h.findprop('String'),...
                     'PropertyPreSet',@changingOutOfEditProperties); ...
     handle.listener(h,h.findprop('String'),...
                     'PropertyPostSet',@changedString)];
h.PropertyListeners = l;
l = handle.listener(h,'ObjectBeingDestroyed',{@beingDeleted,h});
h.DeleteListener = l;

% set other properties passed in varargin
set(h,varargin{:});
h.methods('updatetextposition');

set(h.Rect,'Visible','on');
set(h.Text,'Visible','on');

scribeaxes.methods('scribe_contextmenu',h,'on');
scribeaxes.CurrentShape=h;

set(scribeaxes,'HandleVisibility','off');

if ~isempty(curax)
    set(fig,'currentaxes',curax);
end

%-------------------------------------------------------%
function beingDeleted(hProp,eventData,h)

if ishandle(h) 
  if ishandle(h.Rect)
    uic = get(h.Rect,'UIContextMenu');
    if ishandle(uic)
      delete(uic);
    end
  end
  if ishandle(h.Pin)
    delete(h.Pin);
  end
end

%-------------------------------------------------------%
function changedPos(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObservePos,'on')
  % don't let changes made here cause calls to this
  h.methods('updatePinnedPosition');
  h.methods('updateXYData');
  h.methods('updateaffordances');
  h.methods('resizetext',false);
end

%-------------------------------------------------------%
function changedPosPreSet(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObservePos,'on')
  newval = eventData.newValue;
  oldval = get(h,'Position');
  if (oldval(4) ~= newval(4))
    list = h.PropertyListeners;
    oldstate = get(list(end-3),'enabled');
    set(list(end-3),'enabled','off');
    h.FitHeightToText = 'off';
    set(list(end-3),'enabled',oldstate);
  end
end

%-------------------------------------------------------%
function changedBackgroundColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Rect),'facecolor',h.BackgroundColor);

%-------------------------------------------------------%
function changedEdgeProps(hProp,eventData)

h=eventData.affectedObject;
h.Rect.EdgeColor = h.EdgeColor;
h.Rect.LineStyle = h.LineStyle;
h.Rect.LineWidth = h.LineWidth;

%-------------------------------------------------------%
function changedAlpha(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Rect),'facealpha',h.FaceAlpha);
    
%-------------------------------------------------------%
function changedImage(hProp,eventData)

h = eventData.affectedObject;
if isempty(h.Image)
    set(double(h.Rect),'faceColor',h.BackgroundColor);
else
    set(double(h.Rect),'cdata',flipud(h.Image));
    set(double(h.Rect),'faceColor','texture');
end

%-------------------------------------------------------%
function changedEraseMode(hProp,eventData)

h = eventData.affectedObject;
mode = get(h,'EraseMode');
if ishandle(h.Text)
  set(h.Text,'EraseMode',mode);
end
if ishandle(h.Rect)
  set(h.Rect,'EraseMode',mode);
end

%-------------------------------------------------------%
function changedTextStyle(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveText,'on')
  propname = hProp.name;
  set(double(h.Text),propname,get(h,propname));
  if strcmp(propname,'FontUnits')
    oldstate = h.ObserveText;
    h.ObserveText = 'off';
    set(h,'FontSize',get(double(h.Text),'FontSize'));
    h.ObserveText = oldstate;
  else
    h.methods('updatetextposition');
    h.methods('resizetext',true);
  end
end

%-------------------------------------------------------%
function changingOutOfEditProperties(hProp,eventData)

h=eventData.affectedObject;
if strcmpi(h.Editing,'on')
    h.methods('endedit');
end

%-------------------------------------------------------%
function changedFitHeightToText(hProp,eventData)
h=eventData.affectedObject;
h.methods('updatetextposition');
h.methods('resizetext',true);

%-------------------------------------------------------%
function changedString(hProp,eventData)

h=eventData.affectedObject;
if strcmpi(h.Editing,'on')
    h.methods('endedit');
end

% h.Cstring = h.methods('char2cell',h.String);
if isequal(h.ObserveText,'on')
    %     set(double(h.Text),'string',h.Cstring);
    set(double(h.Text),'string',h.String);
    h.methods('updatetextposition');
    h.methods('resizetext',true);
end

%-------------------------------------------------------%

% function changedCellString(hProp,eventData)
% 
% h=eventData.affectedObject;
% if strcmpi(h.Editing,'on')
%     h.methods('endedit');
% end
% 
% if isequal(h.ObserveText,'on')
%     set(double(h.Text),'string',h.Cstring);
%     if isequal(h.Autosize,'on')
%         h.methods('autosize');
%     else
%         h.methods('updatetextposition');
%         h.methods('resizetext',true);
%     end
% end
% 

%-------------------------------------------------------%
function changedSelected(hProp,eventData)

h=eventData.affectedObject;
methods(h,'setselected',h.Selected);


%-------------------------------------------------------%
function textObjectEditingChanged(hProp,eventData,tbox)

h = eventData.affectedObject;
e=h.Editing;
tbox.Editing=e;
if strcmpi(e,'on')
    tbox.methods('setselected','on');
    set(double(h),'string',tbox.String);
else
    s=get(double(h),'string');
    tbox.String = s;
    tbox.methods('resizetext',true);
end

%-------------------------------------------------------%
function textObjectStringChanged(hProp,eventData,tbox)

% h = eventData.affectedObject;
% s=h.String;


%-------------------------------------------------------%