function val = autoaddr(varargin)
%AUTOADDR auto-detected I/O address control for hardware driver GUI.
%   AUTOADDR is the auto-detected I/O address control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/12/31 19:45:43 $  $Author: batserve $

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
defp.XDIST = 90;
defp.LABEL = 'Address :';
defp.PARM = 1;
defp.MAXBIT = 15;
defp.MINBIT = 4;
defp.OFFSET = 0;
P = mrgstruc(gui(idx), defp);

% draw the autodetect control

uicontrol('Style','text','Position',[P.X P.Y+18 70 20],'String','Auto-detect');
H.autoaddr(idx).autodetect = uicontrol('Style','check','Position',[P.X+25 P.Y 20 20],...
                                       'UserData', idx, ...
                                       'CallBack','rtdrvgui autoaddr AutoDetectChanged;');

% draw the address field control

uicontrol('Style','text','Position',[P.X+P.XDIST P.Y+18 85 20],'HorizontalAlignment','Left',...
          'String',P.LABEL);
H.autoaddr(idx).field = uicontrol('Style','edit', 'BackgroundColor',[1 1 1], ...
                                  'Position',[P.X+P.XDIST P.Y 40 20], 'HorizontalAlignment','left', ...
                                  'UserData', idx, ...
                                  'TooltipString', sprintf('Enter board address\nin hexadecimal notation'), ...
                                  'CallBack','rtdrvgui autoaddr FieldChanged');
setappdata(H.autoaddr(idx).field, 'Parameters', P);

% draw the address bit controls

H.autoaddr(idx).bits = zeros(1, P.MAXBIT+1);
pidx =P.MAXBIT-P.MINBIT;
for i=P.MINBIT:P.MAXBIT
  uicontrol('Style','text','Position',[P.X+P.XDIST+60+27*pidx P.Y+18 24 20], ...
            'String',sprintf('A%d',i));
  H.autoaddr(idx).bits(i+1) = uicontrol('Style','check', 'Position',[P.X+P.XDIST+63+27*pidx P.Y 20 20],...
                                        'UserData', idx, ...
                                        'CallBack','rtdrvgui autoaddr BitsChanged');
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

for C = H.autoaddr        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  if get(C.autodetect,'Value')==1
    X(P.PARM) = 4294967295;      % this is 0xFFFFFFFF
  else
    X(P.PARM) = hex2dec(get(C.field, 'String'));
  end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.autoaddr        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  addr = X(P.PARM);
  if addr==4294967295            % this is 0xFFFFFFFF
    set(C.autodetect,'Value',1)
    set(C.field,'String','0');
  else
    set(C.field, 'String', dec2hex(addr));
  end;
  FieldChanged(C);
  AutoDetectChanged(C);
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
  C = H.autoaddr(get(cbo,'UserData'));
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
  C = H.autoaddr(get(cbo,'UserData'));
end;

addr = hex2dec(get(C.field,'String'));
val = bitget(addr,1:length(C.bits));
for idx = find(C.bits);
  set(C.bits(idx),'Value',val(idx));
end;

BitsChanged(C);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  AUTODETECTCHANGED
%  enable/disable manual address selection depending on Auto-detect checkbox
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AutoDetectChanged(C)

if nargin == 0
  [cbo, cbf] = gcbo;
  H = getappdata(cbf,'Handles');
  C = H.autoaddr(get(cbo,'UserData'));
end;

onoff = {'on','off'};
set([C.field C.bits(find(C.bits))],'Enable',onoff{get(C.autodetect,'Value')+1});
