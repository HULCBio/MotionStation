function IsOwner = mouseevent(Editor,EventName,EventSrc)
%MOUSEEVENT  Processes mouse events.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.33 $  $Date: 2002/04/10 05:01:33 $

PlotAxes = getaxes(Editor.Axes);

IsOwner = 0;
if strcmp(EventName,'wbm')
   % Top-down handling of mouse motion. Determine if mouse is over any editor axes
   CP = get(PlotAxes,{'CurrentPoint'});  
   CP = cat(1,CP{:});  CP = CP(1:2:end,:);
   Zlim = get(PlotAxes,{'Zlim'});  
   Zlim = cat(1,Zlim{:});
   inFocus = (CP(:,3)==Zlim(:,2) & strcmp(get(PlotAxes,'Visible'),'on'));
   
   % Set ownership flag. Exit if no further action required
   IsOwner = any(inFocus);
   if ~IsOwner | strcmp(Editor.EditMode,'off')
      % Exit if editor does not own the event or is turned off
      return
   end
   
   % Pass event to editor's children and give right of way to any taker
   if strcmp(Editor.EditMode,'idle')
      NextChild = Editor.down;
      while ~isempty(NextChild)
         % REVISIT: should traverse from right to left to respect order of creation and HG layering
         if mouseevent(NextChild,EventName)
            return
         end
         NextChild = NextChild.right;
      end
   end
end

% Process event if no child is taker
EventMgr = Editor.EventManager;
Status = EventMgr.Status;
HostFig = EventMgr.Frame;
SelectType = get(HostFig,'SelectionType');
if Editor.SingularLoop
   % Abort if editor is crippled
   EventMgr.poststatus(sprintf('This editor is disabled due to algebraic loop.'));
   return
end
   
switch EventName
case 'bd'
   % ButtonDown event on Editor axes
   if strcmp(SelectType,'alt')
      % Right-click should behave as normal
      return
   end
   
   switch Editor.EditMode
   case 'idle'
      % Click in normal mode
      if usejava('MWT')    % Creates PropertyEditors related MouseEvents only when Java is enabled
         switch SelectType
         case 'normal'
            PropEdit = PropEditor(Editor,'current');  % handle of (unique) property editor
            if ~isempty(PropEdit) & PropEdit.isVisible
               % Left-click & property editor open: quick target change
               PropEdit.setTarget(Editor);
            end
            % Unselect all objects
            Editor.EventManager.clearselect(PlotAxes);
         case 'open'
            PropEdit = PropEditor(Editor);
            PropEdit.setTarget(Editor)      
         end
      end
   case 'addpz'
      % Initiate add pole/zero
      LocalAdd([],[],'start',Editor,handle(EventSrc));
   case 'deletepz'
      % Delete pole/zero
      if ~Editor.SingularLoop
         Editor.deletepz(handle(EventSrc));
      end
      Editor.EditMode = 'idle';  % resets pointer through listener
   case 'zoom'
      % Initiate zooming
      [i,j] = find(handle(EventSrc)==PlotAxes);
      LocalZoomIn([],[],'start',Editor,PlotAxes,i,j)
   end
   
case 'wbm'
   % WindowButtonMotion event
   switch Editor.EditMode
   case 'idle'
      % Hovering over editor in idle mode
      [PointerType,Status] = hoverstatus(Editor,Status);
      
   case 'addpz'
      % Dragging pole/zero
      Group = Editor.EditModeData.Group;
      if any(strcmp(Group,{'Real','Complex'}))
         PZID = lower(Editor.EditModeData.Root);  % pole or zero
         PointerType = sprintf('add%s',PZID); % addpole or addzero
         Status = sprintf('Left-click where you want to add this %s.',PZID);
      else
         PointerType = 'addpole';  % default
         Status = sprintf('Left-click where you want to add this %s.',lower(Group));
      end
      
   case 'deletepz'
      % Deleting pole/zero
      PointerType = 'eraser';
      Status = sprintf('Left-click on the pole/zero you want to delete.');
      
   case 'zoom'
      % Zooming in: use crosshair
      PointerType = 'crosshair';
      Status = sprintf('Left-click and drag the cursor over the region to magnify.');
      
   otherwise
      % Default
      PointerType = 'arrow'; 
   end  
   
   % Update dynamic status and pointer
   EventMgr.poststatus(Status);
   if xor(strcmp(get(HostFig,'Pointer'),'arrow'),strcmp(PointerType,'arrow'))
      setptr(HostFig,PointerType)
   end
   
end


%----------------------- Local Functions ----------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalZoomIn %%%
%%%%%%%%%%%%%%%%%%%
function LocalZoomIn(hSrc,junk,action,Editor,varargin)
% Callback for zoom button down 
persistent WBMU

EventMgr = Editor.EventManager;
HostFig = EventMgr.Frame;

switch action
case 'start'
   % Initialize zoom. Take over window mouse events
   WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
   set(HostFig,'WindowButtonMotionFcn',{@LocalZoomIn 'update' Editor},...
      'WindowButtonUpFcn',{@LocalZoomIn 'finish' Editor});
   % Initialize zoom
   ZoomType = Editor.EditModeData.Type;
   LocalZoomSM('start',ZoomType,varargin{:})
   
   % Update status message
   EventMgr.poststatus(sprintf('Release the mouse to zoom into the selected region.'));
   
case 'update'
   % Track mouse (zooming)
   LocalZoomSM('update')
   
case 'finish'
   % Zooming ends. Restore initial conditions
   set(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU)
   
   % Complete zooming
   X = Editor.Axes.XlimMode;
   Y = Editor.Axes.YlimMode;
   if ~iscell(X), X = {X}; end
   if ~iscell(Y), Y = repmat({Y},[length(getaxes(Editor.Axes)) 1]); end
   [X,Y] = LocalZoomSM('finish',X,Y);
   Editor.Axes.XlimMode = X;  % updates limits
   Editor.Axes.YlimMode = Y;
   
   % Exit zoom if local in scope (must be done here because mouse may be outside editor)
   if strcmp(Editor.root.GlobalMode,'off')
      Editor.EditMode = 'idle';  % resets pointer through listener to EditMode
      EventMgr.newstatus(sprintf('Zoom completed.\nRight-click on plots for more design options.'));
   else
      EventMgr.newstatus('Zoomed in');
      EventMgr.poststatus(sprintf('Left-click and drag the cursor over the region to magnify.'));
   end
end


%%%%%%%%%%%%%%%%
%%% LocalAdd %%%
%%%%%%%%%%%%%%%%
function LocalAdd(hSrc,junk,action,Editor,CurrentAxes)
% Manages add pole/zero (Add takes place on button up
persistent WBMU

EventMgr = Editor.EventManager;
HostFig = EventMgr.Frame;

switch action
case 'start'
   % Initialize Add. Take over window mouse events
   WBMU = get(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
   set(HostFig,'WindowButtonMotionFcn','',...
      'WindowButtonUpFcn',{@LocalAdd 'finish' Editor CurrentAxes});
   % Update status message
   EventMgr.poststatus(sprintf('Release the mouse to add the pole/zero.'));
   
case 'finish'
   % Add ends. Restore initial conditions
   set(HostFig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU)
   % Add root and return to idle mode (single shot)
   if ~Editor.SingularLoop
      Editor.addpz(CurrentAxes);
   end
   Editor.EditMode = 'idle';  % resets pointer through listener to EditMode
end


%%%%%%%%%%%%%%%
% LocalZoomSM %
%%%%%%%%%%%%%%%
function varargout = LocalZoomSM(Event,varargin)
%ZOOMSM  SISO Tool zoom management.

% Parameters
ZoomFactor = 2/5;

persistent ZoomType AxisGrid Row Col X0 Y0 ZoomLine

% Process events
switch Event
    
case 'start'
    % Start zooming
    % ZOOMSM('start',ZoomType,AxisGrid,i,j)
    [ZoomType,AxisGrid,Row,Col] = deal(varargin{:});
    
    % Get initial position
    CP = get(AxisGrid(Row,Col),'CurrentPoint');
    X0 = CP(1,1);  Y0 = CP(1,2);
    
    % Create zoom line
    props = struct(...
        'Parent',AxisGrid(Row,Col),...
        'Visible','on',...
        'EraseMode','xor',...
        'Color',[0.5 0.5 0.5]);
    switch ZoomType
    case 'x-y'
        ZoomLine = line(NaN,NaN,props);
    case 'in-x'
        Ylim = get(AxisGrid(Row,Col),'Ylim');
        dY = 0.05 * (Ylim(2)-Ylim(1));
        ZoomLine = [line([X0 X0],[Y0-dY Y0+dY],props);...
                line([X0 X0],[Y0 Y0],props);...
                line([X0 X0],[Y0-dY Y0+dY],props)];
    case 'in-y'
        Xlim = get(AxisGrid(Row,Col),'Xlim');
        dX = 0.05 * (Xlim(2)-Xlim(1));
        ZoomLine = [line([X0-dX X0+dX],[Y0 Y0],props);...
                line([X0 X0],[Y0 Y0],props);...
                line([X0-dX X0+dX],[Y0 Y0],props)];
    end
        
    
case 'update'
    % Update zoom lines to track mouse movement
    CP = get(AxisGrid(Row,Col),'CurrentPoint');
    X = CP(1,1);  Y = CP(1,2);

    switch ZoomType
    case 'x-y'
        set(ZoomLine,'Xdata',[X0 X X X0 X0],'Ydata',[Y0 Y0 Y Y Y0])
    case 'in-x'
        set(ZoomLine(2),'Xdata',[X0 X])
        set(ZoomLine(3),'Xdata',[X X])
    case 'in-y'
        set(ZoomLine(2),'Ydata',[Y0 Y])
        set(ZoomLine(3),'Ydata',[Y Y])
    end
    
    
case 'finish'
    % Finish zooming
    [XlimMode,YlimMode] = deal(varargin{:});
	ZoomAxes = AxisGrid(Row,Col);
    
    % Current position
    CP = get(ZoomAxes,'CurrentPoint');
    X = CP(1,1);  Y = CP(1,2);

    % Get new X limits
    Xlim = get(ZoomAxes,'Xlim');
    if any(strcmp(ZoomType,{'x-y','in-x'})),
        NewX = LocalGetLims(sort([X0 X]),Xlim,...
			strcmp(get(ZoomAxes,'Xscale'),'log'));
	end
	
    % Get new Y limits
    Ylim = get(ZoomAxes,'Ylim');
    if any(strcmp(ZoomType,{'x-y','in-y'})),
		NewY = LocalGetLims(sort([Y0 Y]),Ylim,...
			strcmp(get(ZoomAxes,'Yscale'),'log'));
    end
    
    % Set new limits
    switch ZoomType
    case 'x-y'
        % Check if in point mode or rubber band mode
        set(AxisGrid(:,Col),'Xlim',NewX)
        set(AxisGrid(Row,:),'Ylim',NewY)
        XlimMode{Col} = 'manual';
        YlimMode{Row} = 'manual';
    case 'in-x'
        % Check if in point mode or rubber band mode
        set(AxisGrid(:,Col),'Xlim',NewX)
        XlimMode{Col} = 'manual';
    case 'in-y'
        % Check if in point mode or rubber band mode
        set(AxisGrid(Row,:),'Ylim',NewY)
        YlimMode{Row} = 'manual';
    end
    
    % Delete zoom lines
    delete(ZoomLine)
    
    % Return updated lim modes
    varargout = {XlimMode,YlimMode};
    
end

%%%%%%%%%% Local Functions %%%%%%%%%%%%%%%%%%%%%

function NewLims = LocalGetLims(NewLims,Lims,isLogScale)
			
if isLogScale,
	NewLims = log10(NewLims);
	Lims = log10(Lims);
end

if abs(NewLims(2)-NewLims(1))<0.01*(Lims(2)-Lims(1)),
	% Use point zoom (x2/5)
	dL = (Lims(2)-Lims(1))/5;
	NewLims = mean(NewLims) + [-dL,dL];
end

if abs(NewLims(2)-NewLims(1))<sqrt(eps)*max(abs(NewLims))
	% Stop zooming when running out of resolution
	NewLims = Lims;
end

if isLogScale,
	NewLims = 10.^NewLims;
end