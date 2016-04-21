function IsOwner = mouseevent(Constr,EventName,EventSrc)
%MOUSEEVENT  Processes mouse events.

%   Authors: N. Hickey
%   Revised: B. Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.26 $  $Date: 2002/04/10 05:12:13 $

%REVISIT
IsOwner = 0;
HostFig = Constr.Parent.Parent;
HG = Constr.HG;
gObjects = ghandles(Constr);

switch EventName
case 'bd'
    % Button down event
    SelectionType = get(HostFig, 'SelectionType');
    % Constraint editor management
    if strcmp(SelectionType, 'open') 
        % Open constraint editor
        Constr.TextEditor.show(Constr);
    elseif Constr.TextEditor.isVisible
        % Silently retarget editor
        Constr.TextEditor.target(Constr);
    end
    % Interaction with constraint
    if any(strcmp(SelectionType,{'normal','extend'}))
       % Left click or shift click
       if any(EventSrc == HG.Markers(:))
          % Initialize resize
          setptr(HostFig, 'closedhand');
          LocalResize([], [], Constr, 'init', EventSrc);
       elseif any(EventSrc == gObjects)
          % Selecting or moving constraint 
          setptr(HostFig, 'fleur');
          LocalMove([],[], 'init', Constr);
       end
    end
    
 case 'wbm'
    % Mouse motion.  REVISIT: upgrade to local event when available
    % Get object currently hovered
    HitObject = hittest(HostFig);   
    IsOwner = any(HitObject == gObjects);
    if any(HitObject == HG.Markers(:))
       % Over resize markers
       setptr(HostFig, 'hand');
       Constr.EventManager.poststatus(Constr.status('hovermarker'));
    elseif IsOwner
       % Over patch or edge
       setptr(HostFig,'fleur');
       Constr.EventManager.poststatus(Constr.status('hover'));
    end
 end


%-------------------- Callback functions -------------------

% %%%%%%%%%%%%%%%%%
% %%% LocalMove %%%
% %%%%%%%%%%%%%%%%%
function LocalMove(eventSrc,eventData,action,Constr)
% Callback for button down on gain magnitude constraint

persistent WBMU MoveCounter TransAction

EventMgr = Constr.EventManager;    % @eventmgr object
HostFig = double(Constr.Parent.Parent);

switch action
case 'init'
    % Initialize constraint moving algorithm. hSrc is handle of selected line
    setptr(HostFig,'fleur');
    Constr.Selected = 'on';

    % Switch to mouse edit mode (ensures quick update with no axis limit adjustment)
    % and initialize move for selected objects in axes
    EventMgr.moveselect('init');
    MoveCounter = 0;   % Counts WBM calls
    
    % Take over window mouse events
    WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
    set(HostFig,'WindowButtonMotionFcn',{@LocalMove 'acquire' Constr},...
        'WindowButtonUpFcn',{@LocalMove 'finish' Constr});
    
case 'acquire'
    % Move selected objects
    % RE: Disregard single WBM event issued when adjusting pointer location
    if MoveCounter
        if MoveCounter==1
            % Start recording move
            TransAction = ctrluis.transaction(Constr,'Name','Move Constraint',...
                'OperationStore','on','InverseOperationStore','on','Compression','on');
        end
        % Move selected objects (issues MouseEdit event)
        Status = EventMgr.moveselect('track');
        EventMgr.poststatus(Status);
    end
    MoveCounter = MoveCounter+1;
    
case 'finish'
    % Restore initial conditions
    set(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
    
    % Finish move
    Status = EventMgr.moveselect('finish');
    if MoveCounter>1
       % Record transaction and update status
       EventMgr.record(TransAction);
       EventMgr.newstatus(Status);
       % Issue DataChanged even to force full observer update 
       Constr.send('DataChanged');
    end
    TransAction = [];   % release persistent object
    
end


%%%%%%%%%%%%%%%%%
%% LocalResize %%
%%%%%%%%%%%%%%%%%
function LocalResize(eventSrc,eventData,Constr,action,marker)
% Resizes gain constraint when button down on end marker

persistent WBMU TransAction

EventMgr = Constr.EventManager;    % @eventmgr object
HostFig = double(Constr.Parent.Parent);

switch action
case 'init'
    % Initialize constraint resizing algorithm
    setptr(HostFig,'closedhand');
    
    % Select constraint
    EventMgr.clearselect;   % resize is always single-select
    Constr.Selected = 'on';
    
    % Switch to mouse edit mode (ensures quick update with no axis limit adjustment)
    EventMgr.MouseEditMode = 'on';
    
    % Find if left or right marker is being moved, and initialize resize
    markerend = find(marker == Constr.HG.Markers);
    Constr.resize('init',markerend);
    
    % Take over window mouse events
    WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
    set(HostFig,'WindowButtonMotionFcn',{@LocalResize Constr 'acquire'},...
        'WindowButtonUpFcn',{@LocalResize Constr 'finish'});
    
    % Start recording
    TransAction = ctrluis.transaction(Constr,'Name','Resize Constraint',...
        'OperationStore','on','InverseOperationStore','on','Compression','on');
    
case 'acquire'
   % Call to get X and Y values during constraint resize
   % RE: RESIZE should issue MouseEdit event with proper data for axes rescale
   Constr.resize('acquire');
      
case 'finish'
    % Record transaction
    EventMgr.record(TransAction);
    TransAction = [];   % release persistent object
    
    % Restore initial conditions
    set(HostFig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'}, ...
        WBMU, 'Pointer', 'arrow')
    
    % Call to finish resize
    Constr.resize('finish');   
    EventMgr.MouseEditMode = 'off';
    
    % Issue DataChanged even to force full observer update 
    Constr.send('DataChanged');
end
