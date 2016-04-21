function [hThis] = datatip(varargin)

%   Copyright 1984-2004 The MathWorks, Inc. 

isDeserializing = false;

% Syntax: graphics.datatip(host,param1,val1,...)
if ishandle(varargin{1})
  host = varargin{1};
  varargin = {varargin{2:end}};

% Syntax: graphics.datatip('Parent',hAxes) as called by hgload
elseif length(varargin)==2
  hAxes = varargin{2};
  host = hAxes;
  varargin = {varargin{3:end}};
  isDeserializing = true;
end

% Assign this object's parent
hAxes = ancestor(host,'axes');

% Constructor 
hThis = graphics.datatip('Parent',hAxes);

% Create datacursor object which is used for
% vertex picking
hThis.DataCursorHandle = graphics.datacursor;

% Set serialization flag
set(hThis,'IsDeserializing',isDeserializing);

% Assign input host to this datatip
hThis.Host = handle(host); 

% Add property listeners
localAddSelfListeners(hThis);

% Add listeners to host
localAddHostListeners(hThis);

% Create visual marker and text box
localCreateNewMarker(hThis);
localCreateNewTextBox(hThis);

visiblepropval = [];
set_orientation = true;

% Loop through and set specified properties
if nargin>1
  for n = 1:2:length(varargin) 
     propname = varargin{n};
     propval = varargin{n+1};
     % Set the visible property at the end of this constructor
     % since the visible listener requires the datatip to 
     % be fully initialized.
     if strcmpi(propname,'StringFcn')
        % Don't fire updatestring until at the end of the constructor
        set(hThis.SelfListenerHandles,'Enable','off');
        set(hThis,propname,propval);
        set(hThis.SelfListenerHandles,'Enable','on');
     elseif strcmpi(propname,'Visible')
        % Don't set visible property until at the end of the
        % constructor
        visiblepropval = propval;
     elseif strcmpi(propname,'Orientation') || ...
            strcmpi(propname,'OrientationMode')
        set_orientation = false;
     else
        set(hThis,propname,propval);
     end
  end
end

set(hThis.DataCursorHandle,'Target',host);

% Defensive code, datacursor defaults might change
set(hThis.DataCursorHandle,'Interpolate','off'); % datatip default
set(hThis,'UIContextMenu',get(host,'UIContextMenu'));

% Set datatip position and string
update(hThis);

movetofront(hThis);

% Update orientation property if necessary
if set_orientation
   set(hThis,'OrientationMode','manual');
end

% Finally, set the visible property if it was passed into the
% constructor
if ~isempty(visiblepropval)
    set(hThis,'Visible',visiblepropval)
end

%localDebug(hThis,'@datatip\datatip.m : end Datatip constructor');

% Add print behavior, work around for 153417
hBehavior = hggetbehavior(hThis,'Print');
set(hBehavior,'PrePrintCallback',{@localPrePrint,hThis});
set(hBehavior,'PostPrintCallback',{@localPostPrint,hThis});

% Do not allow user to edit datatip in plotedit mode 
hBehavior = hggetbehavior(hThis,'Plotedit');
set(hBehavior,'EnableSelect',false);

% Complete with deserialization
%set(hThis,'IsDeserializing',false);

%-------------------------------------------------%
function localPrePrint(obj,evd,hThis)
% Turn off listeners to prevent positioning bug
% This is a work around for 153417.

hListener = get(hThis,'HostListenerHandle');
set(hListener,'Enable','off');
t = get(hThis,'TextBoxHandle');
set(t,'units','data');

%-------------------------------------------------%
function localPostPrint(obj,evd,hThis)

hListener = get(hThis,'HostListenerHandles');
set(hListener,'Enable','on');

%-------------------------------------------------%
function [hMarker] = localCreateNewMarker(hThis,varargin)
% Create visual datatip marker
% Ignore varargin, required since used in callback

% This function is copied from Control Team's tipack

%localDebug(hThis,'@datatip\datatip.m : start localCreateNewMarker');

% Get axes and figure
hAxes = get(hThis,'HostAxes');
hFigure = ancestor(hAxes,'figure');

lprops = [];
lprops.Tag = 'DataTipMarker';
lprops.Xdata = [];
lprops.YData = [];
lprops.EraseMode = hThis.MarkerEraseMode;
lprops.LineStyle = 'none';
lprops.Marker = hThis.Marker;
lprops.MarkerSize = hThis.MarkerSize;
lprops.MarkerFaceColor = hThis.MarkerFaceColor;
lprops.MarkerEdgeColor = hThis.MarkerEdgeColor;
lprops.LineWidth = 2;
lprops.HandleVisibility = 'off';
lprops.Clipping = 'off';
lprops.Parent = hThis;
lprops.Visible = hThis.Visible;
lprops.XLimInclude = 'off';
lprops.YLimInclude = 'off';

% get function handle for marker's ButtonDownFcn
down = startDrag(hThis);
lprops.ButtonDownFcn = {down,hThis,hFigure};


%hMarker = line('Visible','on');

hMarker = line(lprops);

% Work around for deserializing
set(hMarker,'CreateFcn','delete(gcbo)');

% Unregister from legend
hasbehavior(hMarker,'legend',false);

% Uncomment this code to get a cross hair marker inside a 
% circle marker.
%lprops.Marker = '+';
%lprops.MarkerSize = 8;
%lprops.EraseMode = 'normal';
%lprops.MarkerEdgeColor = [1 1 1];
%hMarker(1,1) = line(lprops);

hThis.MarkerHandle = handle(hMarker);
hThis.MarkerHandleButtonDownFcn = hThis.MarkerHandle.ButtonDownFcn;

%localDebug(hThis,'@datatip\datatip.m : end localCreateNewMarker');

%-------------------------------------------------%
function [hTextBox] = localCreateNewTextBox(hThis,varargin)
% Create visual datatip marker
% Ignore varargin, required since used in callback

% This function is copied from Control Team's tipack

%localDebug(hThis,'@datatip\datatip.m : start localCreateNewTextBox');

hAxes = getaxes(hThis);
if isempty(hAxes)
  error('Assert')
end

hFigure = ancestor(hAxes,'figure');

tprops.Tag = 'DataTipMarker';
tprops.Color = hThis.TextColor;
tprops.Margin = 4;
tprops.EdgeColor = hThis.EdgeColor;
tprops.LineStyle = '-' ;
tprops.BackgroundColor = hThis.BackgroundColor;
tprops.Position = [0 0];
tprops.String = 'error';
tprops.HorizontalAlignment = 'left';
tprops.VerticalAlignment = 'top';
tprops.Interpreter = 'none';
tprops.FontSize = hThis.FontSize;
tprops.HandleVisibility = 'off';
tprops.Clipping = 'off';
tprops.Parent = hThis;
tprops.Visible = hThis.Visible;
tprops.ButtonDownFcn = {@localTextBoxButtonDownFcn,hThis,hFigure};
hTextBox = text(tprops);

% Work around for deserializing
set(hTextBox,'CreateFcn','delete(gcbo)');

hThis.TextBoxHandle = handle(hTextBox);
hThis.TextBoxHandleButtonDownFcn = hThis.TextBoxHandle.ButtonDown;

%localDebug(hThis,'@datatip\datatip.m : end localCreateNewTextBox');

%-------------------------------------------------%
function localTextBoxButtonDownFcn(eventSrc,eventData,hThis,hFig)
% This gets called when the user clicks on the datatip
% textbox (not to be confused with the datatip marker)

% HG timing may get us into a state where this
% function is called but the input instance is stale.
if ~ishandle(hThis)
  return;
end
  
sel_type = get(hFig,'SelectionType');

%localDebug(hThis,'@datatip\datatip.m : start localTextBoxButtonDownFcn',sel_type);

switch sel_type
 case 'normal' % left click
     % Place the datatip in a moveable orientation mode
 case 'open' % double click
     % do nothing
     return;
 case 'alt' % right click
     % do nothing
     return;
 case 'extend' % center click
     % do nothing
     return;
end

% Bring datatip to foreground
movetofront(hThis);

% Allow user to change orientation of text box
% Listen to window motion fcn until user clicks up
uistate = uiclearmode(hThis,hFig);
hThis.uistate = uistate;

% Swap in new callbacks
set(hFig,'WindowButtonMotionFcn',{@localTextBoxMotionFcn,hThis});
set(hFig,'WindowButtonUpFcn',{@localTextBoxButtonUpFcn,hThis});
set(hFig,'Pointer','fleur'); 

% Set to double buffer to avoid flickering
hThis.OriginalDoubleBufferState = get(hFig,'DoubleBuffer');
set(hFig,'DoubleBuffer','on'); 

% Highlite datatip
highlite(hThis,'on');

%localDebug(hThis,'@datatip\datatip.m : end localTextBoxButtonDownFcn');

%-------------------------------------------------%
function localTextBoxMotionFcn(hTextBox,evd,hThis)
% This gets called while the user mouse drags the 
% datatip textbox around.

if ~ishandle(hThis)
  return;
end

%localDebug(hThis,'@datatip\datatip.m : start localTextBoxMotionFcn');

% Get needed handles
hAxes = get(hThis,'HostAxes');
hFig = ancestor(hAxes,'figure');
hHost = hThis.Host;

% Get mouse position in pixels
mouse_pos = localGetAxesMousePixelPosition(hAxes);
xm = mouse_pos(1); 
ym = mouse_pos(2);

% Get datatip position in pixels 
datatip_pos = localGetDatatipPixelPosition(hThis);
xd = datatip_pos(1); 
yd = datatip_pos(2);

% Determine orientation
if xm>=xd && ym>=yd
    hThis.Orientation = 'top-right';
elseif xm>=xd && ym<yd
    hThis.Orientation = 'bottom-right';
elseif xm<xd && ym>=yd
    hThis.Orientation = 'top-left';
else
    hThis.Orientation = 'bottom-left';
end

%localDebug(hThis,'@datatip\datatip.m : end localTextBoxMotionFcn');

%-------------------------------------------------%
function [mouse_pos] = localGetAxesMousePixelPosition(hAxes)
% Get mouse pixel position relative to axes

%localDebug(hThis,'@datatip\datatip.m : start localGetAxesMousePixelPosition');

% Get mouse pixel position relative to figure
hFig = ancestor(hAxes,'figure');
mouse_pos = hgconvertunits(hFig,[0 0 get(hFig,'CurrentPoint')],...
                           get(hFig,'Units'),'pixels',0);
mouse_pos = mouse_pos(3:4);

% Get axes pixel position
axes_pos = hgconvertunits(hFig,get(hAxes,'Position'),...
                           get(hAxes,'Units'),'pixels',get(hAxes,'Parent'));

% Get mouse position relative to axes position
mouse_pos = mouse_pos(1:2) - axes_pos(1:2);

%localDebug(hThis,'@datatip\datatip.m : end localGetAxesMousePixelPosition');


%-------------------------------------------------%
function localTextBoxButtonUpFcn(hTextBox,evd,hThis)
% This gets called when the user mouse clicks up 
% after dragging the datatip textbox around.

%localDebug(hThis,'@datatip\datatip.m : start localTextBoxButtonUpFcn');

hFig = ancestor(get(hThis,'HostAxes'),'figure');

% Restore uistate
uirestoremode(hThis,hFig);
hThis.uistate = [];

% Restore figure properties
set(hFig,'doublebuffer',hThis.OriginalDoubleBufferState); 

% Remove datatip highlite
highlite(hThis,'off');

%localDebug(hThis,'@datatip\datatip.m : end localTextBoxButtonUpFcn');

%-------------------------------------------------%
function localAddSelfListeners(hThis)
% Add listeners for this datatip

%localDebug(hThis,'@datatip\datatip.m : start localAddSelfListeners');

l(1) = handle.listener(hThis,findprop(hThis,'String'),...
                    'PropertyPostSet', {@localSetString});


% font stuff
p(1) = findprop(hThis,'FontAngle');
p(end+1) = findprop(hThis,'FontName');
p(end+1) = findprop(hThis,'FontSize');
p(end+1) = findprop(hThis,'FontUnits');
p(end+1) = findprop(hThis,'FontWeight');
p(end+1) = findprop(hThis,'TextBoxHandle');
p(end+1) = findprop(hThis,'EdgeColor');
l(end+1) = handle.listener(hThis,p,'PropertyPostSet',...
                    {@localSetFont});

% marker stuff
p2(1) = findprop(hThis,'Marker');
p2(end+1) = findprop(hThis,'MarkerSize');
p2(end+1) = findprop(hThis,'MarkerEdgeColor');
p2(end+1) = findprop(hThis,'MarkerFaceColor');
p2(end+1) = findprop(hThis,'MarkerEraseMode');
l(end+1) = handle.listener(hThis,p2,'PropertyPostSet',...
                    {@localSetMarker});

l(end+1) = handle.listener(hThis,findprop(hThis,'Visible'),...
                     'PropertyPostSet',{@localSetVisible});

l(end+1) = handle.listener(hThis,findprop(hThis,'StringFcn'),...
                     'PropertyPostSet',{@localSetStringFcn});

l(end+1) = handle.listener(hThis,findprop(hThis,'Orientation'),...
                     'PropertyPostSet',{@localSetOrientation});
hThis.OrientationPropertyListener = l(end);
l(end+1) = handle.listener(hThis,findprop(hThis,'OrientationMode'),...
                     'PropertyPostSet',{@localSetOrientationMode});

l(end+1) = handle.listener(hThis,findprop(hThis,'Position'),...
                     'PropertyPostSet',{@localSetPosition,hThis});

l(end+1) = handle.listener(hThis,findprop(hThis,'UIContextMenu'),...
                    'PropertyPostSet',{@localSetUIContextMenu});

l(end+1) = handle.listener(hThis,findprop(hThis,'Host'),...
                     'PropertyPostSet', {@localAddHostListeners});

l(end+1) = handle.listener(hThis,findprop(hThis,'Interpolate'),...
                     'PropertyPostSet', {@localSetInterpolate});

% Clean up if datatip is deleted
l(end+1) = handle.listener([hThis,hThis.Host],'ObjectBeingDestroyed',...
                           {@localDestroy});

% Force first argument of all callbacks to hThis
set(l,'CallbackTarget',hThis);

% Store listeners
hThis.SelfListenerHandles = l;

%localDebug(hThis,'@datatip\datatip.m : end localAddSelfListeners');

%-------------------------------------------------%
function localAddHostListeners(hThis,varargin)
% Add listeners to the host and its parents
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localAddHostListeners');

hHost = hThis.Host;
if ~ishandle(hHost)
  return;
end

hAxes = handle(getaxes(hThis));
hFigure = handle(ancestor(hAxes,'figure'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Performance Optimizations %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hDataCursorInfo = get(hThis,'DataCursor');
if ismethod(hHost,'getDatatipText')
   set(hDataCursorInfo,'TargetHasGetDatatipTextMethod',true);
end

if ismethod(hHost,'updateDataCursor')
  set(hDataCursorInfo,'TargetHasUpdateDataCursorMethod',true);
end

hBehavior = hggetbehavior(hHost,'DataCursor','-peek');
if ~isempty(hBehavior) 
  fcn = get(hBehavior,'UpdateFcn');
  set(hDataCursorInfo,'UpdateFcnCache',fcn);
end

set(hThis,'HostAxes',hAxes);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove datatip if the host is deleted
l = handle.listener(hHost,'ObjectBeingDeleted',@localDestroy);

% Update datatip if any host data property changes
host_prop = [ findprop(hHost,'XData'), ...
              findprop(hHost,'YData'), ...
              findprop(hHost,'ZData'), ...
              findprop(hHost,'CData')];
l(end+1) = handle.listener(hHost,host_prop,'PropertyPostSet',...
                           @localHostDataUpdate);

% Update datatip visibility if host visibility changes
l(end+1) = handle.listener(hHost,findprop(hHost,'Visible'),...
                            'PropertyPostSet',@localSetHostVisible);
                                  
% LISTEN TO AXES UPDATE 
% This is a challenge because there are a variety of axes property and events
% to listen to but none of them fire at the correct time. For example,
% listening to AxesInvalidEvent doesn't fire late enough when doing 
% zoom operations. This causes the text box to separate from the
% line marker. Listening to pixel bounds can cause race conditions (see
% g207403). The best compromise is to listen to tick changes which seem
% to fire to often.
axes_prop(1) = findprop(hAxes,'XTick');
axes_prop(2) = findprop(hAxes,'YTick');
axes_prop(3) = findprop(hAxes,'ZTick'); 
l(end+1) = handle.listener(hAxes,axes_prop, ...
                           'PropertyPostSet',...
                            @localAxesUpdate);
                       
% Force first argument of all callbacks to hThis
set(l,'CallbackTarget',hThis);

% Store listeners
hThis.HostListenerHandles = l;

%localDebug(hThis,'@datatip\datatip.m : end localAddHostListeners');

%-------------------------------------------------%
function localSetHostVisible(hThis,hEventData)
% This gets called when the host visible property changes

%localDebug(hThis,'@datatip\datatip.m : start localHostSetVisible');

if strcmp(hEventData.NewValue,'on')
    % TBD: check a VisibleMode property
    set(hThis,'Visible','on');
else
    set(hThis,'Visible','off');
end

%localDebug(hThis,'@datatip\datatip.m : end localHostSetVisible');

%-------------------------------------------------%
function localSetVisible(hThis,hEventData)
% This gets called when the datatip visible property changes

%localDebug(hThis,'@datatip\datatip.m : start localSetVisible',hEventData);

% Return early if no datacursor
if isempty(ishandle(hThis.DataCursorHandle)) || ...
      isempty(hThis.DataCursorHandle.Position)
   hThis.Visible = 'off';
   %localDebug(hThis,'@datatip\datatip.m : end localSetVisible','no data cursor');
   return;
end

hMarker = hThis.MarkerHandle;
hTextBox = hThis.TextBoxHandle;

if strcmp(hEventData.NewValue,'on')
    set(hMarker,'Visible','on');
    set(hTextBox,'Visible','on');
else
    set(hMarker,'Visible','off');
    set(hTextBox,'Visible','off');
end

%localDebug(hThis,'@datatip\datatip.m : end localSetVisible');
%-------------------------------------------------%
function [offset] = localGetTextBoxOffset(hThis)

%localDebug(hThis,'@datatip\datatip.m : start localGetTextBoxOffset');

offset = hThis.PixelOffset; 
orientation = hThis.Orientation;

if strcmp(orientation,'top-left')
  offset = [-offset(1), offset(2)];  
elseif strcmp(orientation,'bottom-left')
  offset = [-offset(1), 2-offset(2)];  
elseif strcmp(orientation,'bottom-right')
  offset = [offset(1), 2-offset(2)];
else
  % keep original offset
end

%localDebug(hThis,'@datatip\datatip.m : end localGetTextBoxOffset');

%-------------------------------------------------%
function localSetOrientationMode(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localSetOrientationMode');

if strcmp(hThis.OrientationMode,'manual')
    % do nothing
elseif strcmp(hThis.OrientationMode,'auto')
    localSetBestOrientation(hThis);
end

%localDebug(hThis,'@datatip\datatip.m : end localSetOrientationMode');

%-------------------------------------------------%
function localSetBestOrientation(h)
% Finds the best orientation of the datatip based
% on location of axes.

%localDebug(h,'@datatip\datatip.m : start localSetBestOrientation');

set(h.OrientationPropertyListener,'enabled','off');
h.Orientation = 'top-right';
localApplyCurrentOrientation(h);
set(h.OrientationPropertyListener,'enabled','on');

% Portions of this implementation was taken from 
% the Control's team tippack.

% Find initial text position in normalized units so we not to clip 
% the axis. We have to juggle the units property in order to
% maintain data position.
orig_units = get(h.TextBoxHandle,'units');
set(h.TextBoxHandle,'Units','data');
PP = get(h.TextBoxHandle,'Position');
set(h.TextBoxHandle,'Units','normalized');
E = get(h.TextBoxHandle,'Extent');
set(h.TextBoxHandle,'Units','data');
set(h.TextBoxHandle,'Position',PP);
set(h.TextBoxHandle,'Units',orig_units);

hAxes = get(h,'HostAxes');
orig_units = get(hAxes,'Units');
set(hAxes,'units','normalized');
A = get(hAxes,'Position');
set(hAxes,'units',orig_units);

E13 = E(1)+E(3);
A13 = A(1)+A(3);
E24 = E(2)+E(4);
A24 = A(2)+A(4);

% If we are to the left of the axes, move datatip to the 
% right side with alignment on the left.
if E13 < A13 
    set(h.TextBoxHandle,'HorizontalAlignment','left');
end

% If we are to the right of the axes, move datatip to the 
% left side with alignment on the left.
if E13 >= A13  
    set(h.TextBoxHandle,'HorizontalAlignment','right');
end

% If we are below the axes, move the datatip to the
% top with alignment on the bottom.
if E24 < A24
    set(h.TextBoxHandle,'VerticalAlignment','bottom');
end

% If we are above the axes, move the datatip to the
% bottom with alignment on the top.
if E24 >= A24  
    set(h.TextBoxHandle,'VerticalAlignment','top');
end

VA = get(h.TextBoxHandle,'VerticalAlignment');
HA = get(h.TextBoxHandle,'HorizontalAlignment');

if  strcmpi(VA,'top') && strcmpi(HA,'right')
    final_orientation = 'bottom-left';
elseif strcmpi(VA,'top') && strcmpi(HA,'left')
    final_orientation = 'bottom-right';
elseif strcmpi(VA,'bottom') && strcmpi(HA,'right')
    final_orientation = 'top-left';
elseif strcmpi(VA,'bottom') && strcmpi(HA,'left')
    final_orientation = 'top-right';
end

set(h.OrientationPropertyListener,'enabled','off');
h.Orientation = final_orientation;
localApplyCurrentOrientation(h);
set(h.OrientationPropertyListener,'enabled','on');

%localDebug(h,'@datatip\datatip.m : end localSetBestOrientation');
    
%-------------------------------------------------%
function localSetOrientation(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localSetOrientation');

% As with all hg objects, explicity setting the 
% property will implicitly change the 
% corresponding mode property from 'auto' to 'manual'
if strcmp(hThis.OrientationMode,'auto')
  hThis.OrientationMode = 'manual';
end
localApplyCurrentOrientation(hThis);

%localDebug(hThis,'@datatip\datatip.m : end localSetOrientation');

%-------------------------------------------------%
function localApplyCurrentOrientation(hThis)
% Determine low level text box properties based on 
% high level datatip orientation property

%localDebug(hThis,'@datatip\datatip.m : start localApplyCurrentOrientation');

offset = hThis.PixelOffset; 
orientation = hThis.Orientation;
if strcmp(orientation,'top-left')
    pixel_offset = [1-offset(1), offset(2)];  
    halignment = 'right';
    valignment = 'bottom';
elseif strcmp(orientation,'bottom-left')
    pixel_offset = [1-offset(1), 1-offset(2)];  
    halignment = 'right';
    valignment = 'top';
elseif strcmp(orientation,'bottom-right')
    pixel_offset = [offset(1), 1-offset(2)];
    halignment = 'left';
    valignment = 'top';
elseif strcmp(orientation,'top-right')
    pixel_offset = [offset(1), offset(2)];
    halignment = 'left';
    valignment = 'bottom';
else
    error('Invalid orientation value')
end

% Update textbox low level properties
hText = hThis.TextBoxHandle;
orig_units = hText.Units;
pixel_pos = localGetDatatipPixelPosition(hThis);
hText.Units = 'pixels'; 

hText.Position = pixel_pos(1:2) + pixel_offset;
hText.HorizontalAlignment = halignment;
hText.VerticalAlignment = valignment;

set(hText,'Units','data');
pos = get(hText,'Position');
set(hText,'position',pos);

%localDebug(hThis,'@datatip\datatip.m : end localApplyCurrentOrientation');

%-------------------------------------------------%
function [pixel_pos] = localGetDatatipPixelPosition(hThis)

%localDebug(hThis,'@datatip\datatip.m : start localGetDatatipPixelPosition');

hMarker = hThis.MarkerHandle;
hText = hThis.TextBoxHandle;
orig_text_pos = get(hText,'Position');
orig_text_units = get(hText,'Units');

% Ideally we can transform from data to pixel via HG
% but currently there is no hook. We can get this 
% transform indirectly via a text object.
hText.Units = 'data';
% Do not use hThis.Position here, that property may be temporarily stale 
% and is intended for client code only
hText.Position = hThis.DataCursorHandle.Position;
hText.Units = 'pixel';
pixel_pos = hText.Position;

% Restore text object state
hText.Units = orig_text_units;
hText.Position = orig_text_pos;

%localDebug(hThis,'@datatip\datatip.m : end localGetDatatipPixelPosition');

%-------------------------------------------------%
function localSetPosition(obj,evd,hThis)

new_position  = get(evd,'NewValue');

if ~ishandle(hThis)
    return;
end

% *Check for stale handles*
% The current datatip implementation is not very safe 
% wrt stale handles. Moving the implementation to use a 
% group object should fix most of these problems since
% deletion will be implicit.
hText = hThis.TextBoxHandle;
if ~isa(hText,'hg.text')
   return;
end

hMarker = hThis.MarkerHandle;
if ~isa(hMarker,'hg.line')
  return;
end

hDataCursor = hThis.DataCursorHandle;

% Return early if we are in an invalid state
if any(isempty(ishandle([hText,hMarker,hDataCursor]))) || ...
    isempty(hThis.Position) || ...
    ~isa(hDataCursor,'graphics.datacursor')
       return;
end

set(hDataCursor,'Position',new_position);
localUpdatePositionFromDataCursor(hThis);

%-------------------------------------------------%
function localUpdatePositionFromDataCursor(hThis)

if ~ishandle(hThis)
    return;
end

%localDebug(hThis,'@datatip\datatip.m : start localSetPosition');

% *Check for stale handles*
% The current datatip implementation is not very safe 
% wrt stale handles. Moving the implementation to use a 
% group object should fix most of these problems since
% deletion will be implicit.
hText = hThis.TextBoxHandle;
if ~isa(hText,'hg.text')
   return;
end

hMarker = hThis.MarkerHandle;
if ~isa(hMarker,'hg.line')
  return;
end

hDataCursor = hThis.DataCursorHandle;

% Return early if we are in an invalid state
if any(isempty(ishandle([hText,hMarker,hDataCursor]))) || ...
    isempty(hThis.Position) || ...
    ~isa(hDataCursor,'graphics.datacursor')
       return;
end

new_position = get(hDataCursor,'Position');
set(hThis,'Position',new_position);

if isempty(new_position)
  % We should never get here
  error('Assert')
  return;
end

% Update parent since this may be changing
% if we have subplots
hAxes = get(hThis,'HostAxes');
set(hThis,'Parent',hAxes);
set(hText,'Parent',hThis);
set(hMarker,'Parent',hThis);

% Set marker position
hMarker = hThis.MarkerHandle;
set(hMarker,'XData',new_position(1));
set(hMarker,'YData',new_position(2));
if length(new_position)>2
  set(hMarker,'ZData',new_position(3));
end

% If orientation is in manual mode
if strcmp(hThis.OrientationMode,'manual')
   localApplyCurrentOrientation(hThis);
elseif strcmp(hThis.OrientationMode,'auto')
   localSetBestOrientation(hThis);
end

% If Z-Stacking is enabled
if ( get(hThis,'EnableZStacking') ...
        && is2D(get(hThis,'HostAxes')) ...
        && length(new_position)>2)
   set(hText,'units','data');
   pos = get(hText,'position');
   pos(3) = new_position(3);
   set(hText,'Position',pos);
end

%localDebug(hThis,'@datatip\datatip : end localSetPosition');

%-------------------------------------------------%
function localSetString(hThis,varargin)
% varargin contains unused callback objects

evd = varargin{1};
  
str = get(evd,'NewValue');
if ~ischar(str) && ~iscellstr(str)
    return
end

private_set_string(hThis,str);

%-------------------------------------------------%
function localAxesUpdate(hThis,varargin)
% This gets fired when the axes limits update

hListeners = get(hThis,'HostListenerHandles');

if ishandle(hThis)

  % Update string and positio nof datatip
  set(hListeners,'Enabled','off');
  localUpdatePositionFromDataCursor(hThis);
  updatePositionAndString(hThis);
  set(hListeners,'Enable','on')
end

%-------------------------------------------------%
function localHostDataUpdate(hThis,varargin)
% The datatip's host object data has been updated. 
% Therefore, update the datatip's position and data 
% cursor so that the index and interpolation factor 
% are preserved. If the original index goes beyond 
% the new data, then delete the datatip altogether.
    
%localDebug(hThis,'@datatip\datatip.m : start localDataUpdate',varargin{:});

evd = varargin{1};
prop = evd.Source;

hHost = hThis.Host;
hAxes = get(hThis,'HostAxes');
hDataCursor = hThis.DataCursorHandle;
ind = hDataCursor.DataIndex;
pfactor = hDataCursor.InterpolationFactor;

if isempty(ind)
    % Delete datatip if we don't have an index to reference and
    % we are not deserializing (via hgload).
    if ~get(hThis,'IsDeserializing')
       delete(hThis);
    end
    return;
else
    % Eventually move this code into data cursor 
    % interface. For now just handle 2-D line scenario.
    if isa(hHost,'hg.line') && is2D(hAxes);
       xdata = get(hHost,'xdata');    
       ydata = get(hHost,'ydata');
       len = length(xdata);
       if pfactor > 0 && ind+1 <= len
           pos(1) = xdata(ind) + pfactor*(xdata(ind+1)-xdata(ind));
           pos(2) = ydata(ind) + pfactor*(ydata(ind+1)-ydata(ind));
       elseif pfactor < 0 && ind <= len
           pos(1) = xdata(ind) + pfactor*(xdata(ind)-xdata(ind-1));
           pos(2) = ydata(ind) + pfactor*(ydata(ind)-ydata(ind-1));
       elseif pfactor == 0 && ind<=len
           pos(1) = xdata(ind);
           pos(2) = ydata(ind);
       else
           delete(hThis);
           return;
       end
       hDataCursor.Position = pos;
      % hThis.Position = pos;
       updatePositionAndString(hThis,hDataCursor);
       % There is a BUG HERE. The datatip does not appear 
       % correctly when doing:
       %    h = plot(1:10); 
       %    dt = graphics.datatip(h,'Visible','on');
       %    set(h,'xdata',1:2,'ydata',1:2);
    else
       % TBD, support all hg primitives and 3-D lines
       delete(hThis);
       return;
    end
end

%localDebug(hThis,'@datatip\datatip.m : end localDataUpdate');

%-------------------------------------------------%
function localInvalidate(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localInvalidate');

hThis.Invalid = logical(1);
hThis.Visible = 'off';

%-------------------------------------------------%
function localSetUIContextMenu(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetUIContextMenu');

h = hThis.MarkerHandle;
h(2) = hThis.TextBoxHandle;
set(h,'UIContextMenu',hThis.UIContextMenu);

%-------------------------------------------------%
function localSetFont(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetFont');

hTextBox = hThis.TextBoxHandle;
hTextBox.FontAngle = hThis.FontAngle;
hTextBox.FontName = hThis.FontName;
hTextBox.FontSize = hThis.FontSize;
hTextBox.FontWeight = hThis.FontWeight;

%-------------------------------------------------%
function localSetMarker(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetMarker');

hMarker = hThis.MarkerHandle;
set(hMarker,'Marker',hThis.Marker);
set(hMarker,'MarkerSize',hThis.MarkerSize);
set(hMarker,'MarkerEdgeColor',hThis.MarkerEdgeColor);
set(hMarker,'MarkerFaceColor',hThis.MarkerFaceColor);
set(hMarker,'EraseMode',hThis.MarkerEraseMode);

%-------------------------------------------------%
function localSetStringFcn(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetStringFcn');

updatestring(hThis);

%-------------------------------------------------%
function localSetInterpolate(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetInterpolate');

% Pass down interpolate state to data cursor
hDataCursor = hThis.DataCursorHandle;
hDataCursor.Interpolate = hThis.Interpolate; 

% Ideally, we would now update the position of the
% datatip for the new interpolation mode. Currently,
% this is not possible since we don't store
% the original target and/or position for both
% interpolation states. 
%update(hThis,target);

%-------------------------------------------------%
function localDestroy(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localDestroy');

% Clean up, make sure handle is valid before deleting
if ishandle(hThis.DataCursorHandle)
   h.DataCursorHandle = [];
   delete(hThis.DataCursorHandle);
end
if all(ishandle(hThis.MarkerHandle))
  delete(hThis.MarkerHandle);
end
if ishandle(hThis.TextBoxHandle)
  delete(hThis.TextBoxHandle);
end
if ishandle(hThis)
    delete(hThis);
end

%localDebug(hThis,'@datatip\datatip.m : end localDestroy');


%-------------------------------------------------%
function localTestUpdate(hThis,varargin)

%localDebug(hThis,'localTestUpdate',varargin{:});

%-------------------------------------------------%
function localDebug(hThis,str,varargin)
% utility for debugging UDD event callbacks 

if ~isa(hThis,'graphics.datatip')
    return;
end

if ~hThis.Debug
    return;
end

if length(varargin)>0
    hEvent = varargin{1};
    if isa(hEvent,'handle.EventData')
       hSrc = hEvent.Source;
       if isa(hSrc,'schema.prop')
          disp(sprintf('%s: %s',str,hSrc.Name))
          return;
       elseif ischar(hEvent)
           disp(sprintf('%s : %s',str,hEvent));
           return
       end
    end
end

disp(str);

