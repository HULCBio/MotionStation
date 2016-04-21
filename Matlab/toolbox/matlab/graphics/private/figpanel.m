function [out] = figpanel(varargin)
%FIGPANEL Create figure window panel 
%
% HFRAME = FIGPANEL('Parent',FIG,'Title','...')  
%            Create panel object in parent figure, FIG, with 
%            specified title.
%
% BOOL = FIGPANEL(HFRAME,'String',str) 
%            Set the string inside panel
%
% BOOL = FIGPANEL(hFRAME,'Title',...)
%            Set the title
%
% BOOL = FIGPANEL(hFRAME,'CloseFcn',...)
%            Set the close function
%
% BOOL = FIGPANEL(hFrame,'UIContextMenu',UIC)
%            Set uicontext menu
%
% Example:
%
%   fig = figure;
%   h = figpanel('parent',fig,'title','my title');

% Copyright 2003 The MathWorks, Inc.

if nargin==0
  return;
end

arg1 = varargin{1};
if isstr(arg1) && strcmpi(arg1,'parent')
   out = localCreatePanel(varargin{2},varargin{4});  
elseif ishandle(arg1)    
   hFrame = arg1;
   option = lower(varargin{2});
   switch option  
      case 'string'
          localSetString(hFrame,varargin{3});
      case 'closefcn'
          localSetCloseFcn(hFrame,varargin{3});
      case 'uicontextmenu'
          localSetUIContextMenu(hFrame,varargin{3});
      case 'title'
          localSetTitle(hFrame,varargin{3});    
   end
end

%-----------------------------------------------%
function localSetUIContextMenu(hFrame,uic);

if ~ishandle(hFrame)
  return;
end

% Get app data containing hFrame components
ph = getappdata(hFrame,'PanelHandles');
set(ph.title_bar,'UIContextMenu',uic);
set(ph.text_field,'UIContextMenu',uic);
set(hFrame,'UIContextMenu',uic);

%-----------------------------------------------%
function localSetCloseFcn(hFrame,fcn);

if ~ishandle(hFrame)
  return;
end

% Get app data containing hFrame components
ph = getappdata(hFrame,'PanelHandles');
set(ph.close_button,'Callback',fcn);

%-----------------------------------------------%
function localSetString(hFrame,str);

if ~ishandle(hFrame)
  return;
end

% Get app data containing hFrame components
ph = getappdata(hFrame,'PanelHandles');
set(ph.text_field,'string',str);

%-----------------------------------------------%
function localSetTitle(hFrame,str);

if ~ishandle(hFrame)
  return;
end

% Get app data containing hFrame components
ph = getappdata(hFrame,'PanelHandles');
set(ph.title_bar,'string',str);


%-----------------------------------------------%
function [hFrame] = localCreatePanel(hFig,title_str)

% Get figure position in pixel units
fig_position = hgconvertunits(hFig,...
               get(hFig,'position'),...
               get(hFig,'units'),...
               'pixel', 0);
frame_width = 200;
frame_height = 60; 
frame_position = [fig_position(3)-frame_width-3, 3, frame_width, frame_height];

% Create frame, replace with hgpanel container when available
hFrame = uicontrol('Parent', hFig, ...
                  'Style', 'frame', ...
                  'Units', 'pixels', ...
                  'Background',[1 1 1],...
                  'Tag','figpanel',...
                  'Position', frame_position, ...
                  'BusyAction', 'queue', ...
                  'ButtonDownFcn','',...
                  'Enable','inactive',...
                  'Interruptible', 'off',...
                  'Visible','off');
            
set(hFrame,'DeleteFcn',{@local_delete,hFrame});

% Create aggregate panel components

title_bar = uicontrol('Parent',hFig,...
                      'Style','text',...
                      'Units','pixels',...
                      'Foreground',[1 1 1],...
                      'Background',[.4 .4 .5],...
                      'Horiz','center',...
                      'BusyAction','queue',...
                      'ButtonDownFcn',{@local_titlebarclick,hFrame},...
                      'Enable','inactive',...
                      'Interruptible','off',...
                      'FontName','Sans Serif',...
                      'FontSize',7,...
                      'Tag','figpanel: title bar',...
                      'String',title_str,...
                      'Visible','off');

text_field = uicontrol('Parent', hFig, ...
                       'Style','text', ...
                       'Units','pixels', ...
                       'Foreground', [0 0 0], ...
                       'Background', [1 1 1], ...
                       'Horiz','left', ...
                       'Tag', 'figpanel:text field', ...
                       'String','', ...
                       'FontName', 'Sans Serif', ...
                       'BusyAction', 'queue', ...
                       'Enable', 'inactive', ...
                       'Interruptible', 'off',...
                       'Visible','off');

close_button = uicontrol('Parent', hFig, ...
                         'Style', 'pushbutton', ...
                         'Units', 'pixels', ...
                         'String', 'X', ...
                         'Callback', {@local_delete,hFrame}, ...
                         'BusyAction', 'queue', ...
                         'Interruptible', 'off',...
                         'Tag','figpanel: close button',...
                         'Visible','off');

% Cast from double to handle so we can attach
% UDD listeners
close_button = handle(close_button);
title_bar = handle(title_bar);
text_field = handle(text_field);
hFrame = handle(hFrame);

% Create app data structure containing all handles
panelhandles.close_button = close_button;
panelhandles.title_bar = title_bar;
panelhandles.text_field = text_field;
setappdata(hFrame,'PanelHandles',panelhandles);

% Add listeners to keep all positions relative to frame
% This code can be removed when the frame becomes a true container
l(1) = handle.listener(hFrame,findprop(hFrame,'position'),...
                    'PropertyPostSet',...
                    {@local_set_position,hFrame});
l(end+1) = handle.listener(hFrame,findprop(hFrame,'visible'),...
                    'PropertyPostSet',...
                    {@local_set_visible,hFrame});
l(end+1) = handle.listener(hFrame,'ObjectBeingDeleted',{@local_delete,hFrame});
setappdata(hFrame,'datapanel',l);

% Update position of components
local_update_position(hFrame);

% Turn visible on
set(hFrame,'Visible','on');

%--------------------------------------------------------%
function local_titlebarclick(obj,evd,hFrame)

hFig = ancestor(hFrame,'figure');
appdata.wbm = get(hFig,'WindowButtonMotionFcn');
appdata.wbu = get(hFig,'WindowButtonUpFcn');
setappdata(hFrame,'figpanel',appdata);

set(hFig,'WindowButtonMotionFcn',{@local_motion,hFig,hFrame});
set(hFig,'WindowButtonUpFcn',{@local_up,hFig,hFrame});

setappdata(hFrame,'figpanel_frameposition',get(hFrame,'Position'));

%--------------------------------------------------------%
function local_motion(obj,evd,hFig,hFrame)

% Get current mouse location
orig_units = get(hFig,'Units');
set(hFig,'Units','pixels');
cp = get(hFig,'CurrentPoint');
set(hFig,'Units',orig_units);

orig_fp = getappdata(hFrame,'figpanel_frameposition');
orig_cp = getappdata(hFrame,'figpanel_mouseposition');
if isempty(orig_cp)
  setappdata(hFrame,'figpanel_mouseposition',cp);
else
  dp = orig_cp-cp;
  fp = get(hFrame,'Position');
  set(hFrame,'Position',[orig_fp(1)-dp(1),orig_fp(2)-dp(2),fp(3),fp(4)]);
end

%--------------------------------------------------------%
function local_up(obj,evd,hFig,hFrame)

appdata = getappdata(hFrame,'figpanel');
if isstruct(appdata) && ~isempty(appdata)
  set(hFig,'WindowButtonMotionFcn',appdata.wbm);
  set(hFig,'WindowButtonUpFcn',appdata.wbu);
end

% Clear out orig
setappdata(hFrame,'figpanel_mouseposition',[]);
  
%--------------------------------------------------------%
function local_set_visible(obj,evd,hFrame)

if ~ishandle(hFrame)
  return;
end
  
on_off = get(hFrame,'Visible');

% Get app data containing frame components
panelhandles = getappdata(hFrame,'PanelHandles');
close_button = panelhandles.close_button;
title_bar = panelhandles.title_bar;
text_field = panelhandles.text_field;

if ishandle(close_button)
  set(close_button,'Visible','on');
end
if ishandle(title_bar)
  set(title_bar,'Visible','on');
end
if ishandle(text_field)
  set(text_field,'Visible','on');
end

%--------------------------------------------------------%
function local_delete(obj,evd,hFrame)

% This code can be removed when frame becomes a true
% container object

if ~ishandle(hFrame)
  return;
end

% Get app data containing all handles
panelhandles = getappdata(hFrame,'PanelHandles');
close_button = panelhandles.close_button;
title_bar = panelhandles.title_bar;
text_field = panelhandles.text_field;

% Delete frame components
if ishandle(close_button)
  delete(close_button);
end
if ishandle(title_bar)
  delete(title_bar);
end
if ishandle(text_field)
  delete(text_field);
end

% Finally, delete frame
if ishandle(hFrame)
   delete(hFrame);
end

%--------------------------------------------------------%
function local_set_position(obj,evd,hFrame)

local_update_position(hFrame);

%--------------------------------------------------------%
function local_update_position(hFrame)

% Add app data containing all handles
panelhandles = getappdata(hFrame,'PanelHandles');
close_button = panelhandles.close_button;
title_bar = panelhandles.title_bar;
text_field = panelhandles.text_field;

title_height = 13;

pos = get(hFrame,'Position');
frame_x = pos(1);
frame_y = pos(2);
frame_width = pos(3);
frame_height = pos(4);

text_x = frame_x+5;
text_y = frame_y+1;
text_width = frame_width - 6;
text_height = frame_height - 2 - title_height;
set(text_field,'Position',[text_x, text_y, text_width, text_height]);

button_width = title_height;
button_height = title_height;
button_x = text_x + text_width - button_width; 
button_y = text_y + text_height;
set(close_button,'Position',[button_x, button_y, button_width, button_height]);

title_x = frame_x;
title_y = text_y + text_height;
title_width = frame_width;
set(title_bar,'Position',[title_x, title_y, title_width, title_height]);







