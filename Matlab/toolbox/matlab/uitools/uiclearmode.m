function uistate = uiclearmode(fig, varargin)
%UICLEARMODE Clears the current interactive figure mode;
%  UISTATE=UICLEARMODE(FIG) suspends the interactive properties of a 
%  figure window and returns the previous state in the structure
%  UISTATE.  This structure contains information about the figure's
%  WindowButton* functions and the cursor.  It also contains the 
%  ButtonDownFcn's for all children of the figure.
%
%  UISTATE=UICLEARMODE(FIG, FUNCTION [, ARGS]) suspends the
%  interactive properties of the figure FIG in two ways.
%  First, uiclearmode notifies the currently active mode, if
%  any are active, that the current mode should deinstall its
%  event handlers, such as its Figure WindowButtonDown
%  callbacks.  Next, UICLEARMODE installs the function
%  FUNCTION as the deinstaller for the new mode.  Finally, 
%  UICLEARMODE, like UISUSPEND, resets the WindowButton* 
%  functions and returns that information in a struct which
%  can be saved and passed back to UIRESTORE.
%
%  UISTATE=UICLEARMODE(FIG,'docontext',...) also suspends
%  uicontext menus
%
%  Example:
%      
%  The following function defines a new interactive mode that
%  cooperates with other modes such as plotedit and rotate3d.
%
%  That is, before myinteractivemode is activated, plot
%  editing or rotate3d is turned off.  If myinteractivemode
%  is active, then activating plot editing calls
%  myinteractive(fig,'off').  The calling syntax for
%  myinteractivemode is:
%
%     myinteractivemode(gcf,'on')   % display figure current
%                                    % point on mouse down
%   
%   function myinteractivemode(fig,newstate)
%   %MYINTERACTIVEMODE.M
%   persistent uistate;
%      switch newstate
%      case 'on'
%         disp('myinteractivemode: on');
%         uistate = uiclearmode(fig,'myinteractivemode',fig,'off');
%         set(fig,'UserData',uistate,...
%                 'WindowButtonDownFcn',...
%                 'get(gcbf,''CurrentPoint'')',...
%                 'Pointer','crosshair');
%      case 'off'
%         disp('myinteractivemode: off');
%         if ~isempty(uistate)
%            uirestore(uistate);
%            uistate = [];
%         end
%      end
%
%  See also UISUSPEND, UIRESTORE, SCRIBECLEARMODE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $ $Date: 2004/04/10 23:34:29 $

%  *** Undocumented Syntax ***
%  UISTATE=UICLEARMODE(FIG,'docontext_preserve',...) stores
%  uicontext menus in output state, but does not remove them 
%  from the current plot like 'docontext'
%  UISTATE=UICLEARMODE(FIG,'keepWatch',...) treats watch
%  cursors specially by not reseting them and not storing
%  them in UISTATE.

nargs = nargin;
docontext = 0;
docontext_preserve = 0;
keepWatch = false;
firstarg = 1;

% catch docontext flag
if nargs>1
    if isa(varargin{1},'char')
        if strcmp(varargin{1},'docontext')
            docontext=1;
        elseif strcmpi(varargin{1},'docontext_preserve')
            docontext_preserve=1;
        elseif strcmp(varargin{1},'keepWatch')
          keepWatch = true;
          firstarg = 2;
        end
    end
end

if (docontext | docontext_preserve)
    scribeclearmode(fig,varargin{2:nargs-1});
else
    scribeclearmode(fig, varargin{firstarg:end});
end

% treat watch cursors specially since they are telling users
% something time consuming is happening and we shouldn't reset
% to the default cursor until the action is done.
ptr = get(fig,'Pointer');
newptr = get(0,'DefaultFigurePointer');
if strcmp(ptr,'watch') && keepWatch
  newptr = ptr;
  ptr = get(0,'DefaultFigurePointer'); % for uistate
end

uistate = struct(...
    'ploteditEnable', [], ...  % supress restoration
    'figureHandle', fig, ...
    'children', findobj(fig), ...
    'WindowButtonMotionFcn', {get(fig, 'WindowButtonMotionFcn')}, ...
    'WindowButtonDownFcn', {get(fig, 'WindowButtonDownFcn')}, ...
    'WindowButtonUpFcn', {get(fig, 'WindowButtonUpFcn')}, ...
    'KeyPressFcn', {get(fig, 'KeyPressFcn')}, ...
    'Pointer', ptr, ...
    'PointerCdata', get(fig, 'PointerShapeCData'), ...
    'PointerHotSpot', get(fig, 'PointerShapeHotSpot'));

set(fig, 'pointer', newptr,...
   'WindowButtonMotionFcn', get(0, 'DefaultFigureWindowButtonMotionFcn'),...
   'WindowButtonDownFcn', get(0, 'DefaultFigureWindowButtonDownFcn'),...
   'WindowButtonUpFcn', get(0, 'DefaultFigureWindowButtonUpFcn'));

for i=1:length(uistate.children)
    uistate.ButtonDownFcns(i) = {get(uistate.children(i),'buttondownfcn')};
end
uistate.Interruptible = get(uistate.children, {'Interruptible'});
uistate.BusyAction = get(uistate.children, {'BusyAction'});
uistate.UIContextMenu = get(uistate.children, {'UIContextMenu'});
set(uistate.children, 'buttondownfcn', '', 'BusyAction', 'Queue', ...
   'Interruptible', 'on');

% extra gets and sets if doing the uicontextmenus
if docontext
    uistate.docontext=1;
    uistate.WindowUIContextMenu = get(fig,'UIContextMenu');
    uistate.UIContextMenu = get(uistate.children, {'UIContextMenu'});
    nulluicontext = [];
    set(fig, 'UIContextMenu', nulluicontext);
    set(uistate.children, 'UIContextMenu', nulluicontext);

% Same thing as docontext, but don't null out menus
elseif docontext_preserve
    uistate.docontext=1;
    uistate.WindowUIContextMenu = get(fig,'UIContextMenu');
    uistate.UIContextMenu = get(uistate.children, {'UIContextMenu'});
else  
    uistate.docontext=0;
end



