function val = none(varargin)
%NONE Empty control for hardware driver GUI.
%   NONE is the empty control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/31 19:45:52 $  $Author: batserve $

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
defp.X = 30;
defp.Y = 60;
defp.PARM = 1;
P = mrgstruc(gui(idx), defp);

% draw the info text
H.none(idx).text = uicontrol('Style','text','Position',[P.X P.Y 200 20],'HorizontalAlignment','Left',...
                             'String','This board has no selectable options.');
setappdata(H.none(idx).text, 'Parameters', P);

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

for C = H.none        % process multiple controls if present
  P = getappdata(C.text, 'Parameters');
  X(P.PARM) = 0;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)    %#ok input values not used

% no action
