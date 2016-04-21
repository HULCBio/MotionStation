function val = ls7266(varargin)
%LS7266 filter frequency control for hardware driver GUI.
%   LS7266 is digital lowpass filter frequency control for hardware driver GUI.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/12/31 19:45:50 $  $Author: batserve $

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
defp.LABEL = '';
defp.PARM = 2;
defp.MAXF = 2500000;
P = mrgstruc(gui(idx), defp);

% draw the label

if ~isempty(P.LABEL)
  uicontrol('Style','text', 'HorizontalAlignment','left', 'String',P.LABEL, 'Position',[P.X P.Y 110 17]);
  P.Y = P.Y-30;
end;

% draw slider

uicontrol('Style','text','Position',[P.X P.Y+2 30 18],...
          'HorizontalAlignment','left','String',sprintf('IRC%1d',idx));
H.ls7266(idx).slid=uicontrol('Style','slider','Position',[P.X+40 P.Y+4 230 18],...
          'UserData',idx,'Min',0,'Max',255,'SliderStep',[1 10]/255,'Value',0,...
          'Tag',sprintf('LS7266_%d',idx),'Callback','rtdrvgui ls7266 SliderMoved');
H.ls7266(idx).edit=uicontrol('Style','edit','Position',[P.X+280 P.Y+4 40 18],...
          'UserData',idx,'HorizontalAlignment','left','BackgroundColor','w',...
          'Tag',sprintf('LS7266_%d',idx),'Callback','rtdrvgui ls7266 FrequencyChanged');
uicontrol('Style','text','Position',[P.X+325 P.Y+2 20 18],...
           'HorizontalAlignment','left','String','kHz');


setappdata(H.ls7266(idx).slid, 'Parameters', P);
setappdata(H.ls7266(idx).edit, 'Parameters', P);

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

for C = H.ls7266        % process multiple controls if present
  P = getappdata(C.slid, 'Parameters');
  X(P.PARM) = round(255-get(C.slid, 'Value'));
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETVALUE
%  set the control value(s)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetValue(H, X)

for C = H.ls7266        % process multiple controls if present
  P = getappdata(C.slid, 'Parameters');
  set(C.slid, 'Value', 255-X(P.PARM));
  SliderMoved(C);
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SLIDERMOVED
%  callback for slider movement
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderMoved(C)

if nargin == 0
  [cbo, cbf] = gcbo;
  H = getappdata(cbf,'Handles');
  C = H.ls7266(get(cbo,'UserData'));
end;

P = getappdata(C.slid, 'Parameters');
v = P.MAXF/(1000*(256-round(get(C.slid,'Value'))));
roundord = 10^fix(log10(v)-4);
v = roundord*round(v/roundord);
set(C.edit,'String',sprintf('%g',v));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  FREQUENCYCHANGED
%  callback for frequency change
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function FrequencyChanged(C)    %#ok called by name from a callback

if nargin == 0
  [cbo, cbf] = gcbo;
  H = getappdata(cbf,'Handles');
  C = H.ls7266(get(cbo,'UserData'));
end;

P = getappdata(C.slid, 'Parameters');
val = max(min(round(P.MAXF/(1000*str2double(get(C.edit,'String')))),256),1);
set(C.slid,'Value',256-val);

