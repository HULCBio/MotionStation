function [hControl, hContainer] = actxcontrol(progID, position, parent, callback, filename)
%ACTXCONTROL Create an ActiveX control.
%  H = ACTXCONTROL('PROGID') creates an ActiveX control of a type
%  determined by programmatic identifier PROGID in a figure window and
%  returns a handle H to the control.
%
%  H = ACTXCONTROL('PROGID', POSITION) creates an ActiveX control having
%  the location and size specified in the vector POSITION, with format
%  [x y width height] where the units are in pixels.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE, 'EVENT_HANDLER')
%  creates a ActiveX control in the figure with handle FIG_HANDLE that
%  uses the M file EVENT_HANDLER to handle all events.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE,...
%  {'EVENT1', 'EVENTHANDLER1'; 'EVENT2', 'EVENTHANDLER2';...})
%  creates an ActiveX control that responds to EVENT1 by using
%  EVENTHANDLER1, EVENT2 using EVENTHANDLER2, and so on.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE, 'EVENT_HANDLER', 'FILENAME')
%  creates a COM control with the first four arguments, and sets its
%  initial conditions to those found in previously saved control
%  'FILENAME'.
%
%  Example:
%  h = actxcontrol('mwsamp.mwsampctrl.2', [0 0 200 200], gcf, {'Click', ...
%  'myclick'; 'DblClick' 'my2click'; 'MouseDown' 'mymoused'});
%
%  See also ACTXSERVER, REGISTEREVENT, UNREGISTEREVEN, EVENTLISTENERS,
%  ACTXCONTROLLIST

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.10.10.15 $ $Date: 2004/04/15 00:06:45 $

if (nargin == 0)
    hControl=actxcontrollist;
    return;
end

if nargin<2,
    position=[20 20 60 60];
end

if nargin<3,
    parent=gcf;
end

if nargin<4,
    callback='';
end

if nargin<5,
    filename='';
end

createContainer = false;
javacanvas = [];
deletedYet = false;
hObjectListeners ={};

if isfigure(parent) && ~isempty(get(parent,'JavaFrame'))
    jf = get(parent,'JavaFrame');
    javacanvas = jf.getActiveXCanvas;
    if isempty(javacanvas)
        drawnow;
        javacanvas = jf.getActiveXCanvas;
        if isempty(javacanvas)
            error('MATLAB:COM:InvalidFigureContainer', 'Unable to get ActiveX canvas from figure');
        end
    end
    % this may throw an error
    hwnd = getCurrentHwnd(javacanvas);
    
    % make the window non-dockable
    if ~strcmpi(get(parent,'WindowStyle'),'docked')
        set(parent, 'DockControls', 'off');
    end
    
    % if asked for a container handle, create one with listeners
    % for resize and delete
    if nargout > 1
        hContainer = [];
        createContainer = true;
    end
else
    % native window host; hwnd will be ignored by the C++ code that creates the ActiveX control
    hwnd = 0;
end

% workaround for bug parsing control name which ends with dot + integer
convertedProgID = newprogid(progID);

% call feval to create the ActiveX control as a UDD object
try
    % Note: be sure to update other references to this information below if this
    % line changes.
    comstr = ['COM.' convertedProgID];
    hControl = createControl;
catch
    lastid = lasterror; lastid = lastid.identifier;
    if (strcmpi(lastid, 'MATLAB:Undefinedfunction'))
        error('MATLAB:COM:InvalidProgid', sprintf('Control creation failed. Invalid ProgID ''%s''', progID));
    else    
        rethrow(lasterror);
    end
end

% make sure position is correct
if ~isempty(javacanvas)
    move(hControl,position);
end

% reset filename for later use if we need to recreate the control
filename = tempname;

if ~isempty(callback)
    registerevent(hControl, callback);
end

if createContainer
    hContainer = createPanel;
    setappdata(hContainer,'JavaCanvas',javacanvas);
end

    function ctrl = createControl
        ctrl = feval(comstr, 'control', position, parent, '', filename, hwnd);
        
        if ~isempty(javacanvas)
            % funny naming here - this container property
            % is for UDD so we can move the canvas - perhaps the name
            % could be JavaCanvas instead.
            p = ctrl.findprop('MMProperty_Container');
            if isempty(p)
                p = schema.prop(ctrl, 'MMProperty_Container', 'mxArray');
            end

            %turn the property on so that we can set and get
            p.AccessFlags.Publicget = 'on';
            p.AccessFlags.Publicset = 'on';
            p.Visible = 'off';

            set(ctrl, 'MMProperty_Container', javacanvas);

            if isempty(hObjectListeners)
                parentfig = ancestor(parent,'figure');
                fighandle = handle(parentfig);
                
                % add object being destroyed listener to remove the javacanvas from
                % the parent figure
                hObjectListeners{1} = handle.listener(ctrl, 'ObjectBeingDestroyed', {@controlDelete, parentfig});

                % add figure position change listener to move the controls
                hObjectListeners{2} = handle.listener(fighandle,  'ResizeEvent', {@figureResized, parentfig});
            end
        end

        function controlDelete(obj, evd, fig)
            deletedYet = true;
            
            set(ctrl, 'MMProperty_Container', []);

            % delete listeners
            for i=1:length(hObjectListeners)
                if ishandle(hObjectListeners{i})
                    delete(hObjectListeners{i});
                end
            end

            % remove the holding canvas except when the figure is going
            % away, it will get cleaned up by java when the figure disposes
            fig = ancestor(parent,'figure');
            if ishandle(javacanvas) && strcmp(get(fig,'BeingDeleted'),'off')
                jf = get(fig,'javaframe');
                jf.removeActiveXControl(javacanvas);                
            end
                       
            % delete container if it is created
            if createContainer
                if ishandle(hContainer)
                    delete(hContainer);
                end
            end
        end
    
        function figureResized(obj, evd, fig)
            if ~deletedYet && strcmp(get(fig,'BeingDeleted'), 'off')
                hControl.move(hControl.move);
            end
        end
    end

    function out = createPanel
        % add delete listener
        out = uicontainer('Parent', parent, 'Units','Pixels', 'Position', position);
        setappdata(out,'InResize', false);

        % add resize listener (parent must be a figure or this dies quietly)
        h1 = addeventlistener(parent, 'ResizeEvent', @handleResize);
        h2 = addpropertylistener(out, 'Position', @handleResize);

        % force though 1st resize event
        handleResize(parent, []);

        % add a listener on the window so we know when the parent window is coming
        % or going - when we change to or from an opengl renderer.
        listeners = [h1, h2];

        set(out,'DeleteFcn',@panelDelete)

        % let the java canvas know about this container so it can
        % update position after a move event occurs. this is wired strangely
        % through the comcli/com_events, over to the javacanvas class, then
        % back here.
        javacanvas.setContainer(out);

        function panelDelete(obj, evd)
            deletedYet = true;
            
            % delete listeners
            for i = 1:length(listeners)
                if ishandle(listeners(i))
                    delete(listeners(i))
                end
            end

            % delete the instance of the ActiveX control. the javacanvas
            % that holds the control is deleted in the listener of this
            % ActiveX control object.
            if ishandle(hControl)
                delete(hControl)
            end
        end

        function handleResize(obj, evd)
           if getappdata(out,'InResize')
               return
           end
           setappdata(out,'InResize', true);
           hControl.move(getpixelposition(out));
           setappdata(out,'InResize', false);
        end

    end
end % end function actxcontol

function isfig = isfigure(parent)
    % don't use try/catch here cuz it makes mbc hard to debug
    isfig = false;
    if ishandle(parent)
        cls = class(handle(parent));
        % special case for MBC which subclasses figure
        if length(cls) > 6
            cls = cls(end-5:end);
        end
        switch(cls)
         case 'figure'
          isfig = true;
        end
    end
end

function hl=addpropertylistener(hContainer, propertyName, response)
    %  This is a trimmed down version of a function in toolbox/matlab/uitools
    %  when that file becomes publicly visible, this can be removed.

    % make sure we have handle objects
    hContainer = handle(hContainer);
    hSrc = hContainer.findprop(propertyName);
    hl = handle.listener(hContainer, hSrc, 'PropertyPostSet', response);
end
    
function hl=addeventlistener(hContainer, eventName, response)
    %  This is a trimmed down version of a function in toolbox/matlab/uitools
    %  when that file becomes publicly visible, this can be removed.

    % make sure we have handle objects
    hContainer = handle(hContainer);
    hSrc = hContainer;
    hl = handle.listener(hContainer, hSrc, eventName, response);
end

function hwnd = getCurrentHwnd(javacanvas)
  hwnd = javacanvas.getNativeWindowHandle;
  if hwnd <= 0
    for i = 1:100
        hwnd = javacanvas.getNativeWindowHandle;
        if hwnd>0
            break;
        end
        % wait a bit to make sure the window gets on screen
        pause(.01)
    end
    if hwnd <= 0 && i == 100
        error('Cannot get window handle for ActiveX container');
    end
  end
end

