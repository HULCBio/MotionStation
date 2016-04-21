function rotate3d(varargin)
%ROTATE3D Interactively rotate the view of a 3-D plot.
%   ROTATE3D ON turns on mouse-based 3-D rotation.
%   ROTATE3D OFF turns if off.
%   ROTATE3D by itself toggles the state.
%
%   ROTATE3D(FIG,...) works on the figure FIG.
%   ROTATE3D(AXIS,...) works on the axis AXIS.
%
%   See also ZOOM.

%   rotate3d on enables  text feedback
%   rotate3d ON disables text feedback.

%   Revised by Rick Paxson 10-25-96
%   Clay M. Thompson 5-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 

% rotate style is '-view' | '-orbit'
if nargin<3
    rotatestyle = '-orbit';
else
    rotatestyle = varargin{3};
end

if(nargin == 0)
    setState(gcf,'toggle',rotatestyle);
elseif nargin==1
    arg = varargin{1};
    if ishandle(arg)
        setState(arg,'toggle',rotatestyle)
    else
        switch(lower(arg)) % how much performance hit here
        case 'motion'
            rotaMotionFcn
        case 'down'
            % register axes view state for proper reset 
            rotaButtonDownFcn
        case 'up'
            rotaButtonUpFcn
        case 'on'
            setState(gcf,arg,rotatestyle);
        case 'off'
            setState(gcf,arg,rotatestyle);
        otherwise
            error('Unknown action string.');
        end
    end
elseif nargin>=2
    arg = varargin{1};
    arg2 = varargin{2};
    if ~ishandle(arg), error('Invalid handle.'); end
    switch(lower(arg2)) % how much performance hit here
    case 'on'
        setState(arg,arg2,rotatestyle)
    case 'off'
        setState(arg,arg2,rotatestyle);
    otherwise
        error('Unknown action string.');
    end
end

%--------------------------------
% Set activation state. Options on, off
function setState(target,state,rotatestyle)

% if the target is an axis, restrict to that
if strcmp(get(target,'Type'),'axes')
    hAxes = target;
    fig = ancestor(hAxes, 'figure');
else   % otherwise, allow any axis in this figure
    hAxes = [];
    fig = target;
end
rotaObj = findobj(allchild(fig),'Tag','MATLAB_Rotate3D_Axes');

% toggle 
if(strcmp(state,'toggle'))
    if(~isempty(rotaObj))
        setState(target,'off',rotatestyle);
    else
        setState(target,'on',rotatestyle);
    end
    return;

% turn on
elseif(strcmp(lower(state),'on'))
    if(isempty(rotaObj))
        plotedit(fig,'locktoolbarvisibility');
        rotaObj = makeRotaObj(fig);
        
        % Turn on rotate3d toolbar button
        set(uigettoolbar(fig,'Exploration.Rotate'),'State','on');
    end
    
    rdata = get(rotaObj,'UserData');
    rdata.destAxis = hAxes;
    rdata.rotatestyle = rotatestyle;
    
    % Handle toggle of text feedback. ON means no feedback on means feedback.
    if(strcmp(state,'on'))
        rdata.textState = 1;
    else
        rdata.textState = 0;
    end
    set(rotaObj,'UserData',rdata);
    % set this so we can know if Rotate3d is on
    % for now there is only one on state
    % and this app data will not exist if it is off
    setappdata(fig,'Rotate3dOnState','on');
    scribefiglisten(fig,'on');

% turn off
elseif(strcmp(lower(state),'off'))
    scribefiglisten(fig,'off');
    % Turn on rotate3d toolbar button
    set(uigettoolbar(fig,'Exploration.Rotate'),'State','off');
    if(~isempty(rotaObj))
        destroyRotaObj(rotaObj);
    end
    % get rid of on state appdata
    % if it exists.
    %     if isappdata(fig,'Rotate3dOnState')
    %         rmappdata(fig,'Rotate3dOnState');
    %     end
    
    scribefiglisten(fig,'off');

    % remove
    %state = getappdata(fig,'Rotate3dFigureState');
 
    appdata = localGetData(fig);
    if ~isempty(appdata.uistate)
        % restore figure and non-uicontrol children
        % don't restore uicontrols because they were restored
        % already when rotate3d was turned on
        uirestore(appdata.uistate,'nouicontrols');
        
        % Remove uicontextmenu from parent
        if ishandle(appdata.uicontextmenu)
            delete(appdata.uicontextmenu);
        end
        
        % Remove uistate (required, avoids clashing with other modes)
        appdata.uistate = [];
        localSetData(fig,appdata);
        
        % remove:
        %if isappdata(fig,'Rotate3dFigureState')
        %    rmappdata(fig,'Rotate3dFigureState');
        %end
    end
    if isappdata(fig,'Rotate3dOnState')
        rmappdata(fig,'Rotate3dOnState');
    end
end

%---------------------------
% Button down callback
function rotaButtonDownFcn

hFig = gcbf;

rotaObj = findobj(allchild(hFig),'Tag','MATLAB_Rotate3D_Axes');
if(isempty(rotaObj))
    return;
else
    rdata = get(rotaObj,'UserData');
    
    % Activate axis that is clicked in
    allAxes = findobj(datachildren(hFig),'type','axes');
    axes_found = 0;
    funits = get(hFig,'units');
    set(hFig,'units','pixels');
    for i=1:length(allAxes),
        ax=allAxes(i);
        cp = get(hFig,'CurrentPoint');
        aunits = get(ax,'units');
        set(ax,'units','pixels')
        pos = get(ax,'position');
        set(ax,'units',aunits)
        
        % Check behavior support
        b = hggetbehavior(ax,'Rotate3d','-peek');
        doIgnore = false;
        if ~isempty(b) & ishandle(b)
            if ~get(b,'Enable')
                doIgnore = true;
            end
        end
    
        if ~isappdata(ax,'unrotatable') & ~doIgnore
            if cp(1) >= pos(1) & cp(1) <= pos(1)+pos(3) & ...
                    cp(2) >= pos(2) & cp(2) <= pos(2)+pos(4)
                axes_found = 1;
                set(hFig,'currentaxes',ax);
                break
            end 
        end
    end 
    set(hFig,'units',funits)
    if axes_found==0, return, end
    
    if (not(isempty(rdata.destAxis)) & rdata.destAxis ~= ax) 
        return
    end       
    
    rdata.targetAxis = ax;
    
    % Register view with axes for "Reset to Original View" support
    resetplotview(ax,'InitializeCurrentView'); 
                
    % Reset plot if double click
    sel_type = lower(get(hFig,'selectiontype'));
    if strcmp(sel_type,'open')
        resetplotview(ax,'ApplyStoredView');
        return;
    end

    % store the state on the zlabel:  that way if the user
    % plots over this axis, this state will be cleared and
    % we get to start over.
    viewData = getappdata(get(ax,'ZLabel'),'ROTATEAxesView');
    if isempty(viewData)
        setappdata(get(ax,'ZLabel'),'ROTATEAxesView', get(ax, 'View'));
    end
    
    selection_type = get(hFig,'SelectionType');
    if strcmp(selection_type,'open')
        % this assumes that we will be getting a button up
        % callback after the open button down
        new_azel = getappdata(get(ax,'ZLabel'),'ROTATEAxesView');
        if(rdata.textState)
            set(rdata.textBoxText,'String',...
                sprintf('Az: %4.0f El: %4.0f',new_azel));
        end
        
        set(rotaObj, 'View', new_azel);
        
        return
    elseif strcmp(selection_type,'alt')
        % do nothing
        return;
    end
    
    rdata.oldFigureUnits = get(hFig,'Units');
    set(hFig,'Units','pixels');
    rdata.oldPt = get(hFig,'CurrentPoint');
    rdata.prevPt = rdata.oldPt;
    rdata.oldAzEl = get(rdata.targetAxis,'View');
    
    % Map azel from -180 to 180.
    rdata.oldAzEl = rem(rem(rdata.oldAzEl+360,360)+180,360)-180; 
    if abs(rdata.oldAzEl(2))>90
        % Switch az to other side.
        rdata.oldAzEl(1) = rem(rem(rdata.oldAzEl(1)+180,360)+180,360)-180;
        % Update el
        rdata.oldAzEl(2) = sign(rdata.oldAzEl(2))*(180-abs(rdata.oldAzEl(2)));
    end
    
    set(rotaObj,'UserData',rdata);
    setOutlineObjToFitAxes(rotaObj);
    copyAxisProps(rdata.targetAxis, rotaObj);
    
    rdata = get(rotaObj,'UserData');
    if(rdata.oldAzEl(2) < 0)
        rdata.CrossPos = 1;
        set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
    else
        rdata.CrossPos = 0;
        set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
    end
    set(rotaObj,'UserData',rdata);
    
    if(rdata.textState)
        fig_color = get(hFig,'Color');
        % if the figure color is 'none', setting the uicontrol 
        % backgroundcolor to white and the foreground accordingly.
        if strcmp(fig_color, 'none')
            fig_color = [1 1 1];
        end
        c = sum([.3 .6 .1].*fig_color);
        set(rdata.textBoxText,'BackgroundColor',fig_color);
        if(c > .5)
            set(rdata.textBoxText,'ForegroundColor',[0 0 0]);
        else
            set(rdata.textBoxText,'ForegroundColor',[1 1 1]);
        end
        set(rdata.textBoxText,'Visible','on');
    end
    
    if strcmpi(rdata.rotatestyle,'-view')
       set(rdata.outlineObj,'Visible','on');
    end
    set(gcbf,'WindowButtonMotionFcn','rotate3d(''motion'')');
end

%-------------------------------
% Button up callback
function rotaButtonUpFcn
hFig = gcbf;
rotaObj = findobj(allchild(hFig),'Tag','MATLAB_Rotate3D_Axes');

if isempty(rotaObj) | ...
        ~strcmp(get(hFig,'WindowButtonMotionFcn'),'rotate3d(''motion'')')
    return;
else
    set(hFig,'WindowButtonMotionFcn','');
    rdata = get(rotaObj,'UserData');
    set([rdata.outlineObj rdata.textBoxText],'Visible','off');
    rdata.oldAzEl = get(rotaObj,'View');
    
    % undo/redo not supported for '-orbit'
    if strcmpi(rdata.rotatestyle,'-orbit')
       return;
    end
    
    % Get axes
    hAxes = rdata.targetAxis;
     
    % Call 'view' command
    origView = get(hAxes,'View');
    newView = rdata.oldAzEl;
    
    % Register with undo
    %cmd.Function = @view;
    %cmd.Varargin = {hAxes,newView};
    %cmd.Name = 'Rotate';
    %cmd.InverseFunction = @view;
    %cmd.InverseVarargin = {hAxes,origView};
    %uiundo(hFig,'command',cmd); 
    
    % Set the view
    view(hAxes,newView);
    
    set(hFig,'Units',rdata.oldFigureUnits);
    set(rotaObj,'UserData',rdata)
end

%-----------------------------
% Mouse motion callback
function rotaMotionFcn

rotaObj = findobj(allchild(gcbf),'Tag','MATLAB_Rotate3D_Axes');
rdata = get(rotaObj,'UserData');

if strcmp(rdata.rotatestyle,'-orbit')
    localRotateOrbitMotionFcn(rotaObj);
else 
    localRotateViewMotionFcn(rotaObj); 
end

%-----------------------------
function localRotateViewMotionFcn(rotaObj)
% Change the axes view as the user moves the mouse

rdata = get(rotaObj,'UserData');
new_pt = get(gcbf,'CurrentPoint');
old_pt = rdata.oldPt;
dx = new_pt(1) - old_pt(1);
dy = new_pt(2) - old_pt(2);
new_azel = mappingFunction(rdata, dx, dy);
set(rotaObj,'View',new_azel);
if(new_azel(2) < 0 & rdata.crossPos == 0)
    set(rdata.outlineObj,'ZData',rdata.scaledData(4,:));
    rdata.crossPos = 1;
    set(rotaObj,'UserData',rdata);
end
if(new_azel(2) > 0 & rdata.crossPos == 1) 
    set(rdata.outlineObj,'ZData',rdata.scaledData(3,:));
    rdata.crossPos = 0;
    set(rotaObj,'UserData',rdata);
end
if(rdata.textState)
    set(rdata.textBoxText,'String',sprintf('Az: %4.0f El: %4.0f',new_azel));
end

%----------------------------
function localRotateOrbitMotionFcn(rotateObj)
% Orbit the camera as the user moves the mouse

% Get necessary handles
rdata = get(rotateObj,'UserData');
hFig = ancestor(rotateObj,'hg.figure');
hAxes = rdata.targetAxis;

% Turn on double buffer to avoid flashing
origFigureDoubleBuffer = get(hFig,'doublebuffer');
set(hFig,'doublebuffer','on');

origFigureUnits = get(hFig,'units');
set(hFig,'units','pixels');

% Determine change in pixel position
pt = rdata.prevPt;
new_pt = get(hFig, 'currentpoint');
dx = new_pt(1) - pt(1);
dy = new_pt(2) - pt(2);

% Consider when the axes is upside down
% Assume 'z' based coordinate system for now
% (See cameratoolbar.m code for an example of supporting
% multiple coordinate systems)
up = camup(hAxes);
if (up(3) < 0);
    dx = -dx;
end



% Orbit the camera, assume z based coordinate system
camorbit(hAxes,-dx,-dy,'data','z')

% Update the azimuth/elevation display
if(rdata.textState)    
    axView = get(hAxes,'View');
    set(rdata.textBoxText,'String',sprintf('Az: %4.0f El: %4.0f',axView));
end


% Required for doublebuffer 'on' to avoid flashing
% Calling drawnow will result in hang, see g201318
drawnow expose;


% Restore original double buffer state
set(hFig,'doublebuffer',origFigureDoubleBuffer);
set(hFig,'units',origFigureUnits);

% Update recent point for next time
rdata.prevPt = new_pt;

% Save data
set(rotateObj,'UserData',rdata);

%----------------------------
% Map a dx dy to an azimuth and elevation
function azel = mappingFunction(rdata, dx, dy)
delta_az = round(rdata.GAIN*(-dx));
delta_el = round(rdata.GAIN*(-dy));
azel(1) = rdata.oldAzEl(1) + delta_az;
azel(2) = min(max(rdata.oldAzEl(2) + 2*delta_el,-90),90);
if abs(azel(2))>90
    % Switch az to other side.
    azel(1) = rem(rem(azel(1)+180,360)+180,360)-180; % Map new az from -180 to 180.
    % Update el
    azel(2) = sign(azel(2))*(180-abs(azel(2)));
end

%-----------------------------
% Scale data to fit target axes limits
function setOutlineObjToFitAxes(rotaObj)
rdata = get(rotaObj,'UserData');
ax = rdata.targetAxis;
x_extent = get(ax,'XLim');
y_extent = get(ax,'YLim');
z_extent = get(ax,'ZLim');
X = rdata.outlineData;
X(1,:) = X(1,:)*diff(x_extent) + x_extent(1);
X(2,:) = X(2,:)*diff(y_extent) + y_extent(1);
X(3,:) = X(3,:)*diff(z_extent) + z_extent(1);
X(4,:) = X(4,:)*diff(z_extent) + z_extent(1);
set(rdata.outlineObj,'XData',X(1,:),'YData',X(2,:),'ZData',X(3,:));
rdata.scaledData = X;
set(rotaObj,'UserData',rdata);

%-------------------------------
% Copy properties from one axes to another.
function copyAxisProps(original, dest)
props = {
    'DataAspectRatio'
    'DataAspectRatioMode'
    'CameraViewAngle'
    'CameraViewAngleMode'
    'XLim'
    'YLim'
    'ZLim'
    'PlotBoxAspectRatio'
    'PlotBoxAspectRatioMode'
    'Units'
    'Position'
    'View'
    'Projection'
};
values = get(original,props);
set(dest,props,values);

%-------------------------------------------
% Constructor for the Rotate object.
function rotaObj = makeRotaObj(fig)

% save the previous state of the figure window
% rdata.uistate = uiclearmode(fig,'rotate3d',fig,'off');

rdata.targetAxis = []; % Axis that is being rotated (target axis)
rdata.destAxis = []; % the axis the caller specified (may be [])
rdata.GAIN    = 0.4;    % Motion gain
rdata.oldPt   = [];  % Point where the button down happened
rdata.prevPt = []; % Previous point
rdata.oldAzEl = [];
curax = get(fig,'currentaxes');
rotaObj = axes('Parent',fig,'Visible','off','HandleVisibility','off','Drawmode','fast');
nondataobj = [];
setappdata(rotaObj,'NonDataObject',nondataobj);
% Data points for the outline box.
rdata.outlineData = [0 0 1 0;0 1 1 0;1 1 1 0;1 1 0 1;0 0 0 1;0 0 1 0; ...
        1 0 1 0;1 0 0 1;0 0 0 1;0 1 0 1;1 1 0 1;1 0 0 1;0 1 0 1;0 1 1 0; ...
        NaN NaN NaN NaN;1 1 1 0;1 0 1 0]'; 
rdata.outlineObj = line(rdata.outlineData(1,:),rdata.outlineData(2,:),rdata.outlineData(3,:), ...
    'Parent',rotaObj,'Erasemode','xor','Visible','off','HandleVisibility','off', ...
    'Clipping','off');

% Make text box.
fig_color = get(fig, 'Color');

% if the figure color is 'none', setting the uicontrol 
% backgroundcolor to white and the foreground accordingly.
if strcmp(fig_color, 'none')
    fig_color = [1 1 1];
end
rdata.textBoxText = uicontrol('parent',fig,'Units','Pixels','Position',[2 2 130 20],'Visible','off', ...
    'Style','text','BackgroundColor', fig_color,'HandleVisibility','off');

rdata.textState = [];
rdata.oldFigureUnits = '';
rdata.crossPos = 0;  % where do we put the X at zmin or zmax? 0 means zmin 1 means zmax
rdata.scaledData = rdata.outlineData;

% remove
%state = getappdata(fig,'Rotate3dFigureState');

appdata = localGetData(fig);

if isempty(appdata.uistate)
    % turn off all other interactive modes

    appdata.uistate = uiclearmode(fig,...
                                  'docontext',...
                                  'rotate3d',fig,'off');

    % Create context menu
    c = localUICreateDefaultContextMenu(fig);
        
    % Add context menu to the figure, axes, and axes children
    % but NOT to uicontrols or other widgets at the figure level.
    if ishandle(c)
         set(fig,'UIContextMenu',c);
         ax_child = findobj(fig,'type','axes');
         for n = 1:length(ax_child)
              kids = findobj(ax_child(n));
              set(kids,'UIContextMenu',c);
              set(ax_child(n),'UIContextMenu',c);                  
         end
    end
    
    % Store context menu handle
    appdata.uicontextmenu = c;
    
    % restore button down functions for uicontrol children of the figure
    uirestore(appdata.uistate,'uicontrols');
    localSetData(fig,appdata);
    
    % remove
    %setappdata(fig,'Rotate3dFigureState',state);
end

set(fig,'WindowButtonDownFcn','rotate3d(''down'')');
set(fig,'WindowButtonUpFcn'  ,'rotate3d(''up'')');
set(fig,'WindowButtonMotionFcn','');
set(fig,'ButtonDownFcn','');
setptr(fig,'rotate');
set(rotaObj,'Tag','MATLAB_Rotate3D_Axes','UserData',rdata);
set(fig,'currentaxes',curax)

%-----------------------------------------------%
function [appdata] = localGetData(fig)
appdata = getappdata(fig,'Rotate3dFigureState');
if isempty(appdata)
    appdata.uistate = [];
    appdata.uicontextmenu = [];
end

%-----------------------------------------------%
function localSetData(fig,appdata)
setappdata(fig,'Rotate3dFigureState',appdata);

%----------------------------------
% Deactivate rotate object
function destroyRotaObj(rotaObj)
rdata = get(rotaObj,'UserData');

% uirestore(rdata.uistate);

if ishandle(rdata.textBoxText)
   delete(rdata.textBoxText);
end
if ishandle(rotaObj)
   delete(rotaObj);
end

%----------------------------------
function localUIContextMenuCallback(obj,evd)

% Get axes handle
hFig = gcbf;
hObject = hittest(hFig);
hAxes = ancestor(hObject,'hg.axes');  
if isempty(hAxes)
    hAxes = get(hFig,'CurrentAxes');
    if isempty(hAxes)
        return;
    end
end
       
switch get(obj,'tag')
    case 'Reset';
       resetplotview(hAxes,'ApplyStoredView');
    case 'SnapToXY';
       view(hAxes,0,90);
    case 'SnapToXZ';
       view(hAxes,0,0);
    case 'SnapToYZ';
       view(hAxes,90,0);
end


%----------------------------------
function [hui] = localUICreateDefaultContextMenu(fig)

hui = uicontextmenu('parent',fig);

props = [];
props.Label = 'Reset to Original View';
props.Parent = hui;
props.Separator = 'off';
props.Tag = 'Reset';
props.Callback = {@localUIContextMenuCallback};
u1 = uimenu(props);

props = [];
props.Label = 'Go to X-Y view';
props.Parent = hui;
props.Tag = 'SnapToXY';
props.Separator = 'on';
props.Callback = {@localUIContextMenuCallback};
uA = uimenu(props);

props = [];
props.Label = 'Go to X-Z view';
props.Parent = hui;
props.Tag = 'SnapToXZ';
props.Separator = 'off';
props.Callback = {@localUIContextMenuCallback};
uB = uimenu(props);

props = [];
props.Label = 'Go to Y-Z view';
props.Parent = hui;
props.Tag = 'SnapToYZ';
props.Separator = 'off';
props.Callback = {@localUIContextMenuCallback};
uC = uimenu(props);

props = [];
props.Label = 'Rotate Options';
props.Parent = hui;
props.Separator = 'on';
props.Callback = '';
u2 = uimenu(props);

props = [];
props.Label = 'Plot Box Rotate';
props.Parent = u2;
props.Separator = 'off';
props.Checked = 'off';
props.Tag = 'Rotate_Fast';
p(1) = uimenu(props);

props = [];
props.Label = 'Continuous Rotate';
props.Parent = u2;
props.Separator = 'off';
props.Checked = 'on';
props.Tag = 'Rotate_Continuous';
p(2) = uimenu(props);

set(p(1:2),'Callback',{@localSwitchRotateStyle,p(1),p(2)});

props.Label = 'Stretch-to-Fill Axes';
props.Parent = u2;
props.Separator = 'on';
props.Checked = 'off';
props.Tag = 'StretchToFill';
props.Callback = {@localStretchToFill};
p(1) = uimenu(props);

props.Label = 'Fixed Aspect Ratio Axes';
props.Parent = u2;
props.Separator = 'off';
props.Checked = 'off';
props.Tag = 'FixedAspectRatio';
props.Callback = {@localStretchToFill};
p(2) = uimenu(props);

%----------------------------------
function localStretchToFill(obj,evd)
% Set stretch to fill on/off

hObject = hittest(gcbf);
hAxes = ancestor(hObject,'hg.axes');
if isempty(hAxes) | ~ishandle(hAxes)
    return;
end

tag = get(obj,'Tag');
if strcmpi(tag,'FixedAspectRatio')
    axis(hAxes,'vis3d');
elseif strcmpi(tag,'StretchToFill')
    axis(hAxes,'normal');
end

%----------------------------------
function localSwitchRotateStyle(obj,evd,hFastUIMenu,hContinuousUIMenu)
% Switch rotate style

tag = get(gcbo,'Tag');
hFig = gcbf;

% Radio buttons
if strcmp(tag,'Rotate_Continuous')
   set(hFastUIMenu,'Checked','off');
   set(hContinuousUIMenu,'Checked','on');
   rotate3d(gcbf,'on','-orbit');
elseif strcmp(tag,'Rotate_Fast')
   set(hFastUIMenu,'Checked','on');
   set(hContinuousUIMenu,'Checked','off');   
   rotate3d(gcbf,'on','-view');
end
