function val = lptaddr(varargin)
%LPTADDR LPT address control for hardware driver GUI.
%   LPTADDR is the I/O address control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/12/31 19:45:49 $  $Author: batserve $

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

defp.X = 5;
defp.Y = 150;
defp.PARM = 1;
P = mrgstruc(gui(idx), defp);

% draw the LPT address buttons

strs={'LPT 1','LPT 2','LPT 3','Other:'};
for i=4:-1:1
  H.lptaddr(idx).button(i) = uicontrol('Style','radio', 'Position',[P.X-25+50*i P.Y 20 20], ...
                                       'CallBack','rbutton;rtdrvgui lptaddr ButtonChanged;', ...
                                       'Tag','Address_Button', 'UserData',idx);
  uicontrol('Style','text', 'Position',[P.X-50+50*i P.Y+18 70 20], 'String',strs{i});
end;

% draw the LPT address field

H.lptaddr(idx).field = uicontrol('Style','edit','BackGroundColor',[1 1 1],'Position',[P.X+220 P.Y+2 40 20],...
                                 'HorizontalAlignment','Left', ...
                                 'TooltipString', sprintf('Enter LPT address\nin hexadecimal notation'), ...
                                 'UserData',idx);
setappdata(H.lptaddr(idx).field, 'Parameters', P);

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

for C = H.lptaddr        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  X(P.PARM) = hex2dec(get(C.field, 'String'));
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

addrvals=[888, 632, 956];

for C = H.lptaddr        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  set(C.field, 'String', dec2hex(X(P.PARM)));

  butt = find(addrvals==X(P.PARM));
  if ~isempty(butt)
    rbutton(C.button(butt));
    set(C.field, 'Enable','off');
  else
    rbutton(C.button(4));
    set(C.field, 'Enable','on');
  end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  BUTTONCHANGED
%  update field if address buttons have changed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ButtonChanged    %#ok called by name from a callback

addrvals=[888, 632, 956, 0];

[cbo, cbf] = gcbo;
H = getappdata(cbf,'Handles');
C = H.lptaddr(get(cbo,'UserData'));
idx = find(cbo==C.button);

if idx==4 
  set(C.field, 'Enable','on');
else
  set(C.field, 'Enable','off', 'String', dec2hex(addrvals(idx)));
end;
