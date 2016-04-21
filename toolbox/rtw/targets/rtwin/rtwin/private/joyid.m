function val = joyid(varargin)
%JOYID Joystick ID control for hardware driver GUI.
%   JOYID is the Joystick ID control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/12/31 19:45:48 $  $Author: batserve $

if nargout==1                 % the switchyard
  val = feval(varargin{:});
else
  feval(varargin{:});
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  DRAW
%  draws the control
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H = Draw(H, gui, opt)    %#ok called by name from a callback

for idx=1:length(gui)    % process multiple controls if present

% set defaults to non-specified parameters

defp.X = 20;
defp.Y = 150;
defp.PARM = 1;
P = mrgstruc(gui(idx), defp);

% draw the joystick ID control

uicontrol('Style','text','Position',[P.X P.Y 60 20],'HorizontalAlignment','Left',...
          'String','Joystick ID:');
H.joyid(idx).field = uicontrol('Style','edit','BackgroundColor',[1 1 1],'Position',[P.X+70 P.Y+3 40 20],...
                               'HorizontalAlignment','Left', ...
                               'TooltipString', 'Enter joystick ID', ...
                               'UserData',idx);
setappdata(H.joyid(idx).field, 'Parameters', P);

end;  % of multiple controls loop

% set the defaults

SetValue(H, opt);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  GETVALUE
%  return the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X = GetValue(X, H)    %#ok called by name from a callback

for C = H.joyid        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  X(P.PARM) = str2double(get(C.field, 'String'));
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.joyid        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  set(C.field, 'String', X(P.PARM));
end;
