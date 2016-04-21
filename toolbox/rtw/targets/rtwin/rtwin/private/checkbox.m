function val = checkbox(varargin)
%CHECKBOX I/O checkbox control for hardware driver GUI.
%   CHECKBOX is the I/O checkbox control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/12/31 19:45:44 $  $Author: batserve $

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
defp.Y = 60;
defp.LABEL = 'Checkbox :';
defp.PARM = 2;
P = mrgstruc(gui(idx), defp);

% draw the checkbox

H.checkbox(idx) = uicontrol('Style','checkbox', ...
                            'String', P.LABEL, ...
                            'Visible','off', ...
                            'HorizontalAlignment','left', ...
                            'UserData', idx);
ext = get(H.checkbox(idx),'Extent');
set(H.checkbox(idx), 'Position',[P.X P.Y ext(3)+20 20], 'Visible','on');
setappdata(H.checkbox(idx), 'Parameters', P);

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

for C = H.checkbox        % process multiple controls if present
  P = getappdata(C, 'Parameters');
  X(P.PARM) = get(C, 'Value');
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.checkbox        % process multiple controls if present
  P = getappdata(C, 'Parameters');
  set(C, 'Value', X(P.PARM)~=0);
end;

