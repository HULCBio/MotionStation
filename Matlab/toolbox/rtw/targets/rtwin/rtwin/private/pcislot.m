function val = pcislot(varargin)
%PCISLOT PCI slot number control for hardware driver GUI.
%   PCISLOT is the PCI slot number control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/12/31 19:45:53 $  $Author: batserve $

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
defp.XDIST = 120;
defp.LABEL = 'PCI slot:';
defp.PARM = 1;
defp.MAXBIT = 15;
defp.MINBIT = 4;
defp.OFFSET = 0;
P = mrgstruc(gui(idx), defp);

% draw PCI slot field control

uicontrol('Style','text','Position',[P.X P.Y-2 P.XDIST-5 20],'HorizontalAlignment','Left',...
          'String',P.LABEL);
H.pcislot(idx).field = uicontrol('Style','edit','BackGroundColor',[1 1 1],'Position',[P.X+55 P.Y 40 20],...
                                 'UserData', idx, ...
                                 'TooltipString', sprintf('Enter PCI slot number\nin hexadecimal notation'), ...
                                 'HorizontalAlignment','Left');
setappdata(H.pcislot(idx).field, 'Parameters', P);

% draw auto-detect control

H.pcislot(idx).autodetect = uicontrol('Style','check','Position',[P.X+P.XDIST P.Y 90 20],...
                                      'String',' Auto-detect', ...
                                      'UserData', idx, ...
                                      'CallBack','rtdrvgui pcislot AutoDetectChanged;');

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

for C = H.pcislot        % process multiple controls if present
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

for C = H.pcislot        % process multiple controls if present
  P = getappdata(C.field, 'Parameters');
  addr = X(P.PARM);
  if addr==4294967295            % this is 0xFFFFFFFF
    set(C.autodetect,'Value',1)
    set(C.field,'String','0');
  else
    set(C.field, 'String', dec2hex(addr));
  end;
  AutoDetectChanged(C);
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  AUTODETECTCHANGED
%  enable/disable manual slot selection depending on Auto-detect checkbox
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AutoDetectChanged(C)

if nargin == 0
  [cbo, cbf] = gcbo;
  H = getappdata(cbf,'Handles');
  C = H.pcislot(get(cbo,'UserData'));
end;

onoff = {'on','off'};
set(C.field, 'Enable',onoff{get(C.autodetect,'Value')+1});
