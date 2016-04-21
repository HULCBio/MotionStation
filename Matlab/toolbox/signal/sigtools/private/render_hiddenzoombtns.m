function render_hiddenzoombtns(hFig)
%RENDER_HIDDENZOOMBTNS
%       Render hidden zoom buttons with the same tag as the MATLAB built in
%       zoom tag. These buttons will respond to the zoom commands executed
%       at the command prompt. 

% A toolbar with 'Visible' = 'Off' is to be created as invisible buttons
% cannot be rendered onto a toolbar (see G141194, G141199). These buttons
% are required since built-in zoom does not send any event to listen to.

%   Author(s): R. Malladi
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:32:38 $ 

% Create a new invisible toolbar. This is required since invisible buttons
% when rendered onto a toolbar, causes the CData of the icons that follow
% these icons to change (G141199).
hut = uitoolbar(hFig,...
    'HandleVisibility','Off',...
    'visible','off');

% Render invisible zoom buttons that respond to ML zoom cmds.
% a. zoom-in button.   (tag = 'figToolZoomIn')
% b. zoom-out button.  (tag = 'figToolZoomOut')
delete(findall(hFig,'Tag','figToolZoomIn'));
delete(findall(hFig,'Tag','figToolZoomOut'));

% The zoom-in button State is always set to Off whenever it is set to 'On'.
% This is required as a State change from 'Off' to 'On' is the only event
% available to detect a zoom command being executed at the command prompt.
hiddenZoomInBtn = uitoggletool(...
    'Parent',     hut,...
    'OnCallback', {@hiddenzoomin_oncb, hFig},...
    'Tag',        'figToolZoomIn',...
    'State',     'Off',...
    'enable',     'Off',...
    'visible',    'Off');

% This zoom-out button is the one which is used to detect the 'zoom off'
% command being executed at the prompt. This button is always 'On' when in
% zoom-mode and is set to 'Off' when quitting zoom-mode.
hiddenZoomOutBtn = uitoggletool(...
    'Parent',     hut,...
    'OffCallback', {@hiddenzoomout_offcb, hFig},...
    'Tag',        'figToolZoomOut',...
    'State',     'On',...
    'enable',     'Off',...
    'visible',    'Off');

figHndl = handle(hFig);
% Setup a listener on the 'WindowButtonDownFcn' to catch the 'zoom xon'
% and 'zoom yon'commands executed at command prompt.
L = handle.listener(figHndl,...
    figHndl.findprop('WindowButtonDownFcn'),...
    'PropertyPostSet', {@lcldisablemlzoom, hFig});
setappdata(hFig,'mlzoomlistener',L);

%--------------------------------------------------------------------------
function hiddenzoomin_oncb(h,e,hFig)
%HIDDENZOOMIN_ONCB On callback for the zoom-in button.
% Check the zoom button based on the command executed.

% Turn off the MATLAB built-in zoom.
zoom off;

% Turn the custom-zoom On.
hZoom = siggetappdata(hFig,'siggui','mousezoom');
if ~isempty(hZoom)
    if ~strcmpi(hZoom.zoomState,'zoomin')
        callbacks(hZoom,'zoomin');
    end
else
    zoom_cbs(hFig,'zoomin');
    % Set-up a listener on the currentAxes property of the zoom object.
    set_caxlistener(hFig);
end

%--------------------------------------------------------------------------
function hiddenzoomout_offcb(h,e,hFig)
%HIDDENZOOMOUT_OFFCB Off callback for the zoom-out button.
% Uncheck the zoom buttons when 'zoom off' is executed.

% The zoom-out button State is set to 'Off' when 'zoom off' is executed.
% Hence this event is used to turn the custom-zoom also off. As the zoom-out
% button is turned 'Off' on many other occasions, it is also required to
% check the stack to know if a 'zoom off' command was executed.

hZoom = siggetappdata(hFig,'siggui','mousezoom');
if isempty(hZoom)
    return;
end

% Check the stack for the doZoomOff string. This is a subfunction in the
% zoom function which is executed when the 'zoom off' command is executed.

% Also the string position in the stack is to be checked as the doZoomOff
% subfunction is executed multiple times. Hence a stack position of 2
% would mean that the zoom off command is executed.
% i.e., stack: zoom, doZoomOff, hiddenzoomout_offcb and instack functions.

if instack('doZoomOff',2)
    % Setting the zoomState to its current state turns the zoom to off.
    callbacks(hZoom,hZoom.zoomState);

    % Remove the built-in zoom appdata stored in the figure.
    if ~isempty(getappdata(hFig, 'ZOOMFigureMode'))
        rmappdata(hFig, 'ZOOMFigureMode')
    end
    if ~isempty(getappdata(hFig, 'ZoomOnState'))
        rmappdata(hFig, 'ZoomOnState')
    end
    return;
end

if instack('setzoomstate')
    % Check if the button has been clicked directly. In this case, the
    % setzoomstate function is being called and a currentAxes listener
    % is to be set-up and return.
    set_caxlistener(hFig);
    return;
end

% In all the other cases just turn the zoom-out button to 'On'.
set(h,'State','on');

%--------------------------------------------------------------------------
function lcldisablemlzoom(h,e,hFig)
%LCLDISABLEMLZOOM Disable MATLAB built-in zoom and enable custom zoom.

% Enable the custom x-only and y-only zooms when 'zoom xon' and
% 'zoom yon' commands are executed at the command prompt.
winBtnDwnFcn = get(hFig,'WindowButtonDownFcn');

if isempty(winBtnDwnFcn) || ~ischar(winBtnDwnFcn)
    return;
end

% Get the mousezoom object stored in the application data.
if sigisappdata(hFig,'siggui','mousezoom')
    hZoom = siggetappdata(hFig,'siggui','mousezoom');
end

switch winBtnDwnFcn
    case 'zoom(gcbf,''xdown'')'
        callbacks(hZoom,'zoomx');
        
    case 'zoom(gcbf,''ydown'')'
        callbacks(hZoom,'zoomy');
end

%--------------------------------------------------------------------------
function set_caxlistener(hFig)
%SET_CAXLISTENER
%  Setup a listener on the currentAxes property of the mousezoom object.

L = getappdata(hFig,'caxlistener');

if isempty(L)
    hZoom = siggetappdata(hFig,'siggui','mousezoom');
    L = handle.listener(hZoom, hZoom.findprop('currentAxes'),...
        'PropertyPostSet', {@set_ylimlistener, hZoom});
    setappdata(hFig,'caxlistener',L);
end

%--------------------------------------------------------------------------
function set_ylimlistener(hcbo, eventData, hZoom)
%SET_YLIMLISTENER Setup a listener on the Ylimit property of the axes.

currentAxes = eventData.NewValue;
if isempty(currentAxes)
    return;
end

% The first element in currentAxes property is the axes on the top. Hence
% set-up a listener on this axes.
cAx = currentAxes(1);
L = getappdata(cAx, 'ylimlistener');

if isempty(L)
    hcAx = handle(cAx);
    L = handle.listener(cAx, hcAx.findprop('YLim'),...
        'PropertyPostSet',{@ylimlistener,hZoom});
    setappdata(cAx,'ylimlistener',L);
end

%--------------------------------------------------------------------------
function ylimlistener(hcbo, eventData, hZoom)
%YLIMLISTENER Listener on the ylimit of the axes. This listener is used to
%             respond to the 'zoom out' command executed at command prompt.

% Check the stack for the 'zoom.m' string. This is to be done to see if the
% 'zoom out' command is executed. Also check for the string position in the
% stack as this listener will be fired on many occasions. The postion of the
% string in the stack is 1 when the 'zoom out' command is executed.
% i.e., stack: zoom.m, ylimlistener and instack functions.
if instack('zoom',1)
    % If the 'zoom out' command is, call the zoom2fullview method.
    zoom2fullview(hZoom);
    
    % Get the axes whose limits are currently changed by the built-in zoom.
    ax = eventData.AffectedObject;
    axz = get(ax,'ZLabel');
    % Set this appdata to empty to avoid further 'zoom out'.
    setappdata(axz,'ZOOMAxesData',[]);
end

%--------------------------------------------------------------------------
function b = instack(str,strpos)
%INSTACK Check for the given string (STR) in the stack.

stack = dbstack;
b = false;

% Search the stack for string (STR) specified.
for k = 1:length(stack)
    if isequal(stack(k).name,str)
        b = true;
        break;
    end
end

spos = length(stack) - k + 1;
% Also check for the string position in the stack.
if nargin > 1
    b = b && (spos == strpos);
end
