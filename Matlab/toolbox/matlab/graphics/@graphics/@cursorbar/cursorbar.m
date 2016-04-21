function hThis = cursorbar(hTarget,varargin)
%CURSORBAR cursorbar constructor

% Copyright 2003 The MathWorks, Inc.

% initialize cursorbar
hThis = graphics.cursorbar;

% uncomment calls to debug and set the undocumented
% 'Debug' datatip property to true, for debugging,
hThis.Debug = true;
% debug(hThis,'@cursorbar\cursorbar.m : start cursorbar constructor');

% make sure the HandleVisibility is 'off'
set(hThis,'HandleVisibility','off');

% force hTarget to column vector of handles
hTarget = handle(hTarget(:));

% set cursorbar Parent, based on Target
% debug(hThis,'@cursorbar\cursorbar.m : set Parent');
if numel(hTarget) == 1
    if isa(hTarget,'hg.line')
        set(hThis,'Parent',handle(ancestor(hTarget,'axes')));    
    elseif isa(hTarget,'hg.axes')
        set(hThis,'Parent',handle(hTarget))
    else
        % delete cursorbar and error if Target isn't a line or axes
        delete(hThis);
        error('Target must be a single axes handle, or an array of line handles');
    end
else
    if all(isa(hTarget,'hg.line'))
        set(hThis,'Parent',handle(ancestor(hTarget(1),'axes')))
    else
        % delete cursorbar if Target isn't a line or axes
        delete(hThis);
        error('Target must be a single axes handle, or an array of line handles');
    end
end

% set the Target property
% debug(hThis,'@cursorbar\cursorbar.m : set Target');
set(hThis,'Target',hTarget);

% store vectors of Targets' XData and YData, sorted by X
[x,y] = getTargetXYData(hThis);
hThis.TargetXData = x;
hThis.TargetYData = y;

% add self property listeners
localAddSelfListeners(hThis);

% add listeners for the target and its ancestors
localAddTargetListeners(hThis);

% create cursorbar and marker line
hLines = localCreateNewCursorBarLines(hThis);
set(hLines,'Parent',handle(hThis))

%??? visible problems with context menu?
% create context menu
%hCtxtMenu = localCreateUIContextMenu(hThis);
%set([hLines; hThis],'UIContextMenu',hCtxtMenu)

% % set Parent of lines to hThis
% set(hThis.CursorLineHandle,'Parent',hThis);
% set(hThis.BottomHandle,'Parent',hThis);
% set(hThis.TopHandle,'Parent',hThis);
% set(hThis.TargetMarkerHandle,'Parent',hThis);


% set the UpdateFcn
set(hThis,'UpdateFcn',@defaultUpdateFcn);


% set Position and Visible later, if they are specified as inputs
visiblepropval = [];
positionpropval = [];
orientationpropval = [];

% Loop through and set specified properties
if nargin>1
    for n = 1:2:length(varargin)
        propname = varargin{n};
        propval = varargin{n+1};
        if strcmpi(propname,'Visible')
            % Set the visible property at the end of this constructor
            % since the visible listener requires the datatip to
            % be fully initialized.
            visiblepropval = propval;
        elseif strcmpi(propname,'Position')
            % set the Position property just before setting Visible property
            % force to a row vector
            if numel(propval) > 3 || numel(propval) < 2
                error('Position must have 2 or 3 elements')
            end            
            positionpropval = propval(:).';
        elseif strcmpi(propname,'Orientation')
            orientationpropval = propval;
        else
            set(hThis,propname,propval);
        end
    end
end

% create new datacursor
hThis.DataCursorHandle = graphics.datacursor;

% set Position
if ~isempty(positionpropval)
%     debug(hThis,'@cursorbar\cursorbar.m : Position is an input');
    %set Position for datacursor from input    
    if isTargetAxes(hThis)
        % if the Target is an axes, use the Position directly
        set(hThis.DataCursorHandle,'Position',positionpropval); 
        set(hThis,'Position',positionpropval); 
    else
        % not an axes
        [x,y] = closestvertex(hThis,positionpropval);
        pos = [x y 0];
        set(hThis.DataCursorHandle,'Position',pos);
        set(hThis,'Position',pos);        
    end
else % Position not set
%     debug(hThis,'@cursorbar\cursorbar.m : Position is not an input');
    hAxes = get(hThis,'Parent');    
    xLim = get(hAxes,'XLim');
    yLim = get(hAxes,'YLim');    
    pos = [mean(xLim) mean(yLim)];    
%     debug(hThis,['@cursorbar\cursorbar.m : original pos = ' num2str(pos)]);
    if isTargetAxes(hThis)
        % set the datacursor's Position to the middle of the axes
        % use the 'pos' we already have
    else
        % choose the closest vertex to 'pos'
        [x,y] = closestvertex(hThis,pos);
        pos = [x y 0];        
    end
%     debug(hThis,['@cursorbar\cursorbar.m : pos = ' num2str(pos)]);
    set(hThis.DataCursorHandle,'Position',pos);
    set(hThis,'Position',pos);
end

% set Orientation
if ~isempty(orientationpropval)
    set(hThis,'Orientation',orientationpropval);
end


% update cursorbar
update(hThis,[],'-nomove');

% Set the visible property if it was passed into the constructor
if ~isempty(visiblepropval)
    set(hThis,'Visible',visiblepropval)
end



% debug(hThis,'@cursorbar\cursorbar.m : end cursorbar constructor');


% --------------------------------------
function hLines = localCreateNewCursorBarLines(hThis)
%LOCALCREATENEWCURSORBARLINES create lines for cursorbar, and line for markers

% debug(hThis,'@cursorbar\cursorbar.m : start localCreateNewCursorBarLines');

% Get axes and figure
hAxes = get(hThis,'Parent');
hFigure = get(hAxes,'Parent');

% white line on dark axes, black line on light axes
AXCOLOR = get(hAxes,'Color');


% --------- cursor line ---------
lineprops = struct;
lineprops.Tag = 'DataCursorLine';
lineprops.Parent = hAxes;
lineprops.XData = [NaN NaN];
lineprops.YData = [NaN NaN];
lineprops.Color = hThis.CursorLineColor;
% light colored axes
if sum(AXCOLOR) < 1.5
    lineprops.Color = [1 1 1];
end
lineprops.Marker = 'none';
lineprops.LineStyle = '-';
lineprops.LineWidth = 2;
lineprops.HandleVisibility = 'off';
lineprops.Clipping = 'on';
lineprops.Visible =hThis.Visible;
lineprops.ButtonDownFcn = {@localCursorButtonDownFcn,hThis};

cursorline = line(lineprops);
hThis.CursorLineHandle = handle(cursorline);
hThis.ButtonDownFcn = lineprops.ButtonDownFcn;


% --------- top,bottom affordances ---------
lineprops.XData = [NaN];
lineprops.YData = [NaN];
lineprops.Tag = 'DataCursorLineTop';
lineprops.Marker  = hThis.TopMarker;
lineprops.MarkerFaceColor = hThis.CursorLineColor;
lineprops.LineStyle = 'none';
topdragline = line(lineprops);
hThis.TopHandle = handle(topdragline);

lineprops.Tag = 'DataCursorLineBottom';
lineprops.Marker  = hThis.BottomMarker;
bottomdragline = line(lineprops);
hThis.BottomHandle = handle(bottomdragline);

% --------- marker line ---------
lineprops.Tag = 'DataCursorTargetMarker';
lineprops.Marker = hThis.TargetMarkerStyle;
lineprops.MarkerSize = hThis.TargetMarkerSize;
lineprops.MarkerEdgeColor = hThis.TargetMarkerEdgeColor;
lineprops.MarkerFaceColor = hThis.TargetMarkerFaceColor;
lineprops.LineStyle = 'none';
markerline = line(lineprops);
hThis.TargetMarkerHandle = handle(markerline);

% debug(hThis,'@cursorbar\cursorbar.m : end localCreateNewCursorLine');

hLines = handle([ cursorline;
                topdragline;
                bottomdragline;
                markerline ]);

% --------------------------------------            
function hCtxtMenu = localCreateUIContextMenu(hThis)
%LOCALCREATEUICONTEXTMENU

if ismethod(hThis,'createUIContextMenu')
    hCtxtMenu = hThis.createUIContextMenu;
else
    hCtxtMenu = hThis.defaultUIContextMenu;
end


% --------------------------------------
function localAddTargetListeners(hThis,evd)
%LOCALADDTARGETLISTENERS add listeners for Target and its parent axes

% debug(hThis,'@cursorbar\cursorbar.m : start localAddTargetListeners');

% check Target
hTarget = hThis.Target;
if ~ishandle(hTarget)
    return;
end

% get handles for axes and figure
hAxes = handle(get(hThis,'Parent'));
hFigure = handle(get(hAxes,'Parent'));

% listen for changes to axes' Limits
axesLimProps = [ findprop(hAxes,'XLim');
                           findprop(hAxes,'YLim');
                           findprop(hAxes,'ZLim')];
l = handle.listener(hAxes,axesLimProps,'PropertyPostSet',{@localAxesLimUpdate,hThis});

% Update if Target is line(s) and any target _Data property changes
if ~isTargetAxes(hThis)
    for n = 1:length(hTarget)
        target_prop = [ findprop(hTarget(n),'XData');
                              findprop(hTarget(n),'YData');
                              findprop(hTarget(n),'ZData')];
        l(end+1) = handle.listener(hTarget(n),target_prop,'PropertyPostSet',...
            @localTargetDataUpdate);
    end
end

% Listen to axes pixel bound resize events
axes_prop = findprop(hAxes,'PixelBound');
l(end+1) = handle.listener(hAxes,axes_prop, 'PropertyPostSet',...
    {@localAxesPixelBoundUpdate,hThis});

% Clean up if cursorbar or its Target is deleted
l(end+1) = handle.listener(hThis.Target,'ObjectBeingDestroyed',...
    {@localTargetDestroy});

% Uncomment here for debugging axes events
%  cls = hAxes.classhandle;
%  test_prop = cls.Properties;
%  l(end+1) = handle.listener(hAxes,test_prop, 'PropertyPostSet',...
%                             @localTestUpdate);

% Force first argument of all callbacks to hThis
set(l,'CallbackTarget',hThis);

% Store listeners
hThis.TargetListenerHandles = l;

% debug(hThis,'@cursorbar\cursorbar.m : end localAddTargetListeners');

% --------------------------------------
function localAddSelfListeners(hThis)
%LOCALADDSELFLISTENERS add listeners to cursorbar's properties

% debug(hThis,'@cursorbar\cursorbar.m : start localAddSelfListeners');

% Visible
l = handle.listener(hThis,findprop(hThis,'Visible'),...
    'PropertyPostSet',{@localSetVisible});

% ShowText
l = handle.listener(hThis,findprop(hThis,'ShowText'),...
    'PropertyPostSet',{@localSetShowText});

% Orientation 
l(end+1) = handle.listener(hThis,findprop(hThis,'Orientation'),...
    'PropertyPostSet',{@localSetOrientation});

% Position
l(end+1) = handle.listener(hThis,findprop(hThis,'Position'),...
    'PropertyPostSet',{@localSetPosition});

% UIContextMenu
l(end+1) = handle.listener(hThis,findprop(hThis,'UIContextMenu'),...
    'PropertyPostSet',{@localSetUIContextMenu});

% ButtonDownFcn
l(end + 1) = handle.listener(hThis,findprop(hThis,'ButtonDownFcn'),...
    'PropertyPostSet', {@localSetButtonDownFcn});

% Target
l(end+1) = handle.listener(hThis,findprop(hThis,'Target'),...    
    'PropertyPreSet', {@localPreSetTarget});
l(end+1) = handle.listener(hThis,findprop(hThis,'Target'),...
    'PropertyPostSet', {@localPostSetTarget});
l(end+1) = handle.listener(hThis,findprop(hThis,'Target'),...
    'PropertyPostSet', {@localAddTargetListeners});

% Cursorbar appearance properties
p = [ findprop(hThis,'CursorLineColor');
        findprop(hThis,'CursorLineStyle');
        findprop(hThis,'CursorLineWidth');
        findprop(hThis,'TopMarker');
        findprop(hThis,'BottomMarker')]; 
l(end + 1) = handle.listener(hThis,p,'PropertyPostSet', {@localSetCursorProps});

% Marker properties
p = [ findprop(hThis,'TargetMarkerStyle');...
        findprop(hThis,'TargetMarkerSize')];
l(end + 1) = handle.listener(hThis,p,'PropertyPostSet',{@localSetMarkerProps});


% Listen for update event
l(end+1) = handle.listener(hThis,'UpdateCursorBar',@updateDisplay);

% Clean up if cursorbar is deleted
l(end+1) = handle.listener(hThis,'ObjectBeingDestroyed',...
    {@localCursorBarDestroy});

% Force first argument of all callbacks to hThis
set(l,'CallbackTarget',hThis);

% Store listeners
hThis.SelfListenerHandles = l;

% debug(hThis,'@cursorbar\cursorbar.m : end localAddSelfListeners');

% --------------------------------------
function localAxesPixelBoundUpdate(obj,evd,hThis)
%LOCALAXESPIXELBOUNDUPDATE

% debug(hThis,'@cursorbar\cursorbar.m : start localAxesUpdate');

update(hThis);

% debug(hThis,'@cursorbar\cursorbar.m : end localAxesUpdate');

% --------------------------------------
function localSetOrientation(hThis,evd)
%LOCALSETORIENTATION

% debug(hThis,'@cursorbar\cursorbar.m : start localSetOrientation');

% get new Orientation value
newval = get(evd,'NewValue');

% get datacursor's Position
pos = get(hThis.DataCursorHandle,'Position');
x = pos(1);
y = pos(2);

hAxes = get(hThis,'Parent');

% get axes' limits
xlimits = get(hAxes,'XLim');
ylimits = get(hAxes,'YLim');

% get axes' directions
xdir = get(hAxes,'XDir');
ydir = get(hAxes,'YDir');

% setting Marker for 'affordances' at ends of cursorbar
switch newval
    case 'vertical'
        set(hThis.CursorLineHandle,'XData',[x x],'YData',ylimits);
        switch ydir
            case 'normal'
                set(hThis.BottomHandle,'Marker','^')
                set(hThis.TopHandle,'Marker','v')                
            case 'reverse'
                set(hThis.BottomHandle,'Marker','v')
                set(hThis.TopHandle,'Marker','^')
        end
    case 'horizontal'        
        set(hThis.CursorLineHandle,'XData',xlimits,'YData',[y y]);
        switch xdir
            case 'normal'
                set(hThis.BottomHandle,'Marker','<')
                set(hThis.TopHandle,'Marker','>')
            case 'reverse'
                set(hThis.BottomHandle,'Marker','>')
                set(hThis.TopHandle,'Marker','<')
        end
    otherwise
        error('Cursorbar''s Orientation can only be set to ''vertical'' or ''horizontal''')
end

% update cursorbar
update(hThis)

% debug(hThis,'@cursorbar\cursorbar.m : end localSetOrientation');

% --------------------------------------
function localSetLocation(hThis,evd)
%LOCALSETLOCATION

% debug(hThis,'@cursorbar\cursorbar.m : start localSetLocation');

loc = get(evd,'NewValue');

pos = get(hThis,'Position');

switch get(hThis,'Orientation')
    case 'vertical'
        pos(1) = loc;
    case 'horizontal'
        pos(2) = loc;
end

set(hThis.DataCursorHandle,'Position',pos)

update(hThis);

% debug(hThis,'@cursorbar\cursorbar.m : end localSetLocation');
% --------------------------------------
function localSetPosition(hThis,evd)
%LOCALSETPOSITION

% debug(hThis,'@cursorbar\cursorbar.m : start localSetPosition');

% return early if not a handle
if ~ishandle(hThis)
    return;
end

% get new Position
pos = get(evd,'NewValue');

% Position should be [X Y] or [X Y Z]
if numel(pos) ~= 2 && numel(pos) ~= 3
    return
end

x = pos(1);
y = pos(2);

hCursorLine = hThis.CursorLineHandle;
hTopLine = hThis.TopHandle;
hBottomLine = hThis.BottomHandle;
hAxes = get(hThis,'Parent');


switch get(hThis,'Orientation')    
    case 'vertical'        
        if isempty(hThis.Location) || hThis.Location ~= x            
            set(hThis,'Location',x);
        end
        
        yLim = get(hAxes,'YLim');
        set(hCursorLine,'XData',[x x],'YData',yLim);
        set(hBottomLine,'XData',x,'YData',yLim(1));
        set(hTopLine,'XData',x,'YData',yLim(2));
    case 'horizontal'
        if isempty(hThis.Location) || hThis.Location ~= y
            set(hThis,'Location',y);
        end
        xLim = get(hAxes,'XLim');
        set(hCursorLine,'YData',[y y],'XData',xLim);
        set(hBottomLine,'XData',xLim(2),'YData',y);
        set(hTopLine,'XData',xLim(1),'YData',y);
end

% debug(hThis,'@cursorbar\cursorbar.m : end localSetPosition');


% --------------------------------------
function localSetShowText(hThis,evd)
%LOCALSETSHOWTEXT

% debug(hThis,'@cursorbar\cursorbar.m : start localSetShowText');

switch evd.NewValue
    case 'on'
        if all(ishandle(hThis.DisplayHandle))
            set(hThis.DisplayHandle,'Visible','on');
        end        
    case 'off'
        if all(ishandle(hThis.DisplayHandle))
            set(hThis.DisplayHandle,'Visible','off');
        end
end

% debug(hThis,'@cursorbar\cursorbar.m : end localSetShowText');

% --------------------------------------
function localSetUIContextMenu(hThis,evd)
%LOCALSETUICONTEXTMENU

% debug(hThis,'@cursorbar\cursorbar.m : start localSetUIContextMenu');

contextmenu = get(evd,'NewValue');

hndls = [hThis.CursorLineHandle;
             hThis.TargetMarkerHandle;
             hThis.TopHandle;
             hThis.BottomHandle];
         
set(hndls,'UIContextMenu',contextmenu);

% debug(hThis,'@cursorbar\cursorbar.m : end localSetUIContextMenu');

% --------------------------------------
function localSetButtonDownFcn(hThis,evd)
%LOCALSETBUTTONDOWNFCN

% debug(hThis,'@cursorbar\cursorbar.m : start localSetButtonDownFcn');

newVal = evd.NewValue;

hLines = [hThis.CursorLineHandle;
             hThis.TargetMarkerHandle;
             hThis.TopHandle
             hThis.BottomHandle];

set(hLines,'ButtonDownFcn',newVal);

% debug(hThis,'@cursorbar\cursorbar.m : end localSetButtonDownFcn');

% --------------------------------------
function localSetCursorProps(hThis,evd)
%LOCALSETCURSORPROPS

% debug(hThis,'@cursorbar\cursorbar.m : start localSetCursorProps');

propname = get(evd.Source,'Name');
propval = get(evd,'NewValue');

switch propname
    case 'CursorLineColor'
        newpropname = 'Color';
        hLine = [hThis.CursorLineHandle; hThis.TopHandle; hThis.BottomHandle];
    case 'CursorLineStyle'
        newpropname = 'LineStyle';
        hLine = hThis.CursorLineHandle;
    case 'CursorLineWidth'
        newpropname = 'LineWidth';
        hLine = hThis.CursorLineHandle;
    case 'TopMarker'
        newpropname = 'Marker';
        hLine = hThis.TopHandle;
    case 'BottomMarker'
        newpropname = 'Marker';
        hLine = hThis.BottomHandle;
end

set(hLine,newpropname,propval); 

% debug(hThis,'@cursorbar\cursorbar.m : end localSetCursorProps');
 

% --------------------------------------
function localSetMarkerProps(hThis,evd)
%LOCALSETMARKERPROPS

% debug(hThis,'@cursorbar\cursorbar.m : start localSetMarkerProps');

propname = get(evd.Source,'Name');
propval = get(evd,'NewValue');

switch propname
    case 'TargetMarkerStyle'
        newpropname = 'Marker';
    case 'TargetMarkerSize'
        newpropname = 'MarkerSize';
end

set(hThis.TargetMarkerHandle,newpropname,propval)

% debug(hThis,'@cursorbar\cursorbar.m : end localSetMarkerProps');


% --------------------------------------
function localPreSetTarget(hThis,evd)
%LOCALPRESETTARGET

%debug(hThis,'@cursorbar\cursorbar.m : start localPreSetTarget');

% check new Target value
newTarget = get(evd,'NewValue');
if ~isa(newTarget,'hg.line') && ~isa(newTarget,'hg.axes')
    error('Target must be a line or axes object.')
end

%debug(hThis,'@cursorbar\cursorbar.m : end localPreSetTarget');

% --------------------------------------
function localPostSetTarget(hThis,evd)
%LOCALPOSTSETTARGET

% debug(hThis,'@cursorbar\cursorbar.m : start localPostSetTarget');

newTarget = get(evd,'NewValue');
% if it's a line, set it close to the current location of the cursorbar
if isTargetAxes(hThis)
    % do nothing for axes, no need to change Position
    return
end

% debug(hThis,'@cursorbar\cursorbar.m : localPostSetTarget update Target- XY -Data');

% update the Target_Data
[x,y] = getTargetXYData(hThis);
hThis.TargetXData = x;
hThis.TargetYData = y;

% update cursorbar
hThis.update([],'-nomove');

% debug(hThis,'@cursorbar\cursorbar.m : end localPostSetTarget');

% --------------------------------------
function localSetVisible(hThis,evd)
%LOCALSETVISIBLE

% debug(hThis,'@cursorbar\cursorbar.m : start localSetVisible');

% Return early if no datacursor
if isempty(ishandle(hThis.DataCursorHandle)) || ...
        isempty(hThis.DataCursorHandle.Position)
    hThis.Visible = 'off';
    % debug(hThis,'@cursorbar\cursorbar.m : end localSetVisible','no data cursor');
    return;
end

set(hThis.CursorLineHandle,'Visible',evd.NewValue)

% debug(hThis,'@cursorbar\cursorbar.m : end localSetVisible');

% --------------------------------------
function localCursorBarDestroy(hThis,varargin)
%LOCALCURSORBARDESTROY called when the cursorbar is destroyed

% debug(hThis,'@cursorbar\cursorbar.m : start localCursorbarDestroy');

% delete all child objects

if ishandle(hThis.CursorLineHandle)
    delete(hThis.CursorLineHandle);
end
if ishandle(hThis.TargetMarkerHandle)
    delete(hThis.TargetMarkerHandle);
end
if ishandle(hThis.TopHandle)
    delete(hThis.TopHandle);
end
if ishandle(hThis.BottomHandle)
    delete(hThis.BottomHandle);
end
if ishandle(hThis.DataCursorHandle)
    delete(hThis.DataCursorHandle)
end
if all(ishandle(hThis.DisplayHandle))  && all(isa(hThis.DisplayHandle,'text'))
    delete(hThis.DisplayHandle)
end



% debug(hThis,'@cursorbar\cursorbar.m : end localCursorbarDestroy');

% --------------------------------------
function localTargetDestroy(hThis,evd,varargin)
%LOCALTARGETDESTROY called when the any of the cursorbar's Target objects are destroyed

% debug(hThis,'@cursorbar\cursorbar.m : start localTargetDestroy');

% if there is a single Target, then cursorbar should be destroyed when it is
% destroyed
if length(hThis.Target) == 1
    delete(hThis);    
    return
else
    % determine which Target was deleted
    deletedTarget = handle(get(evd,'Source'));
    
    % remove from Target list
    hTargets = handle(hThis.Target);
    hTargets(hTargets == deletedTarget) = [];
    set(hThis,'Target',hTargets);
    
    % update the Target_Data
    [x,y] = getTargetXYData(hThis);
    hThis.TargetXData = x;
    hThis.TargetYData = y;
       
%     % throw event indicating that the cursorbar was updated
%     hEvent = handle.EventData(hThis,'UpdateCursorBar');
%     send(hThis,'UpdateCursorBar',hEvent);
    
end

update(hThis,[],'-nomove');

% debug(hThis,'@cursorbar\cursorbar.m : end localTargetDestroy');

% --------------------------------------
function localAxesLimUpdate(hprop,evd,hThis)
%LOCALAXESLIMUPDATE update cursor line after limits change

% debug(hThis,'@cursorbar\cursorbar.m : start localAxesLimUpdate');

% get the cursorbar's orientation
orient = get(hThis,'Orientation');

hAxes = handle(get(hThis,'Parent'));
hCursorLine = get(hThis,'CursorLineHandle');

switch orient
    case 'vertical'
        ylim = get(hAxes,'YLim');
        set(hCursorLine,'YData',ylim)
    case 'horizontal'
        xlim = get(hAxes,'XLim');
        set(hCursorLine,'XData',xlim)
end

% debug(hThis,'@cursorbar\cursorbar.m : end localAxesLimUpdate');

% --------------------------------------
function localTargetDataUpdate(hThis,evd,varargin)
%LOCALTARGETDATAUPDATE 

% debug(hThis,'@cursorbar\cursorbar.m : start localTargetDataUpdate');

hTarget = hThis.Target;
hAxes = get(hThis,'Parent');
hDataCursor = hThis.DataCursorHandle;

oldpos = hDataCursor.Position;

% use the old position to determine the new position
[x,y] = closestvertex(hThis,oldpos);
pos = [x y 0];
set(hDataCursor,'Position',pos);
update(hThis);

% debug(hThis,'@cursorbar\cursorbar.m : end localTargetDataUpdate');

% --------------------------------------
function localCursorButtonDownFcn(hLine,evd,hThis)
%LOCALCURSORBUTTONDOWNFCN click on cursorbar

% debug(hThis,'@cursorbar\cursorbar.m : start localCursorButtonDownFcn');

hFig = ancestor(hThis,'Figure');

% swap out the WindowButton...Fcns
uistate = struct;
uistate.WindowButtonUpFcn = get(hFig,'WindowButtonUpFcn');
uistate.WindowButtonMotionFcn = get(hFig,'WindowButtonMotionFcn');
uistate.Pointer = get(hFig,'Pointer');

% save figure's current state
setappdata(hFig,'CursorBarOriginalFigureCallbacks',uistate);

% modify uistate
uistate = uistate;
uistate.WindowButtonUpFcn = {@localWindowButtonUpFcn,hThis};
uistate.WindowButtonMotionFcn = {@localWindowButtonMotionFcn,hThis};
uistate.Pointer = 'fleur';

% set new state
set(hFig,uistate);

% send BeginDrag event
hEvent = handle.EventData(hThis,'BeginDrag');
send(hThis,'BeginDrag',hEvent);

% debug(hThis,'@cursorbar\cursorbar.m : end localCursorButtonDownFcn');

% --------------------------------------
function localWindowButtonMotionFcn(hFig,evd,hThis)
%LOCALWINDOWBUTTONMOTIONFCN move cursorbar

% debug(hThis,'@cursorbar\cursorbar.m : start localWindowButtonMotionFcn');

% update the cursorbar while moving
update(hThis);

% debug(hThis,'@cursorbar\cursorbar.m : end localWindowButtonMotionFcn');

% --------------------------------------
function localWindowButtonUpFcn(hFig,evd,hThis)
%LOCALWINDOWBUTTONUPFCN restore orginal figure callbacks and pointer

% debug(hThis,'@cursorbar\cursorbar.m : start localWindowButtonUpFcn');

% get stored callbacks
uistate = getappdata(hFig,'CursorBarOriginalFigureCallbacks');

if ~isempty(uistate)
    set(hFig,uistate);
end

% send EndDrag event
hEvent = handle.EventData(hThis,'EndDrag');
send(hThis,'EndDrag',hEvent);

% debug(hThis,'@cursorbar\cursorbar.m : end localWindowButtonUpFcn');

% --------------------------------------
function localTestUpdate(obj,evd)
%LOCALTESTUPDATE test for property listeners

% debug(hThis,'@cursorbar/cursorbar start localTestUpdate');

disp(get(evd))

% debug(hThis,'@cursorbar/cursorbar end localTestUpdate');