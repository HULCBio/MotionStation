function val = address(varargin)
%ADDRESS I/O address control for hardware driver GUI.
%   ADDRESS is the I/O address control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2003/12/31 19:45:41 $  $Author: batserve $

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
defp.XDIST = 75;
defp.LABEL = 'Address :';
defp.PARM = 1;
defp.MAXBIT = 15;
defp.MINBIT = 4;
defp.OFFSET = 0;
P = mrgstruc(gui(idx), defp);

% draw the address field control

uicontrol('Style','text','Position',[P.X P.Y+18 P.XDIST-5 20],'HorizontalAlignment','Left',...
          'String',P.LABEL);
H.address(idx).field = uicontrol('Style','edit', 'BackgroundColor',[1 1 1], ...
                                 'Position',[P.X P.Y 40 20], 'HorizontalAlignment','left', ...
                                 'UserData', idx, ...
                                 'TooltipString', sprintf('Enter board address\nin hexadecimal notation'), ...
                                 'CallBack','rtdrvgui address FieldChanged');
setappdata(H.address(idx).field, 'Parameters', P);

% draw the address bit controls

H.address(idx).bits = zeros(1, P.MAXBIT+1);
pidx = P.MAXBIT-P.MINBIT;
for i=P.MINBIT:P.MAXBIT
  uicontrol('Style','text','Position',[P.X+P.XDIST-3+27*pidx P.Y+18 24 20], ...
            'String',sprintf('A%d',i));
  H.address(idx).bits(i+1) = uicontrol('Style','check', 'Position',[P.X+P.XDIST+27*pidx P.Y 20 20],...
                                       'UserData', idx, ...
                                       'CallBack','rtdrvgui address BitsChanged');
  pidx = pidx-1;
end;

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

for C = H.address        % process multiple controls if present
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

for C = H.address        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  set(C.field, 'String', dec2hex(X(P.PARM)));
  FieldChanged(C);
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  BITSCHANGED
%  update field if address bits have changed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BitsChanged(C)

if nargin == 0
  [cbo, cbf] = gcbo;
  H = getappdata(cbf,'Handles');
  C = H.address(get(cbo,'UserData'));
end;

vidx = find(C.bits);
bitc = get(C.bits(vidx), 'Value');
bits(vidx) = [bitc{:}];    %#ok
P = getappdata(C.field, 'Parameters');
addr = sum([bitshift(1,find(bits)-1) P.OFFSET]);
set(C.field,'String',dec2hex(addr));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  FIELDCHANGED
%  update bits if address field has changed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function FieldChanged(C)

if nargin == 0
  [cbo, cbf] = gcbo;
  H = getappdata(cbf,'Handles');
  C = H.address(get(cbo,'UserData'));
end;

addr = hex2dec(get(C.field,'String'));
val = bitget(addr,1:length(C.bits));
for idx = find(C.bits);
  set(C.bits(idx),'Value',val(idx));
end;

BitsChanged(C);
