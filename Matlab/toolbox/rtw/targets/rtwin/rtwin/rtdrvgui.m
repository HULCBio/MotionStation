function opt = rtdrvgui(varargin)
%RTDRVGUI Generic hardware driver GUI.
%   RTDRVGUI is the GUI interface to the Real-Time Windows Target board setup.
%
%   Not to be called directly.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.2 $  $Date: 2004/04/15 00:29:58 $  $Author: batserve $

if nargout == 1                 % the switchyard
  opt = feval(varargin{:});
else
  feval(varargin{:});
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  OPEN
%  opens the GUI window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function opt = Open(board,oldopt)    %#ok called by name from a callback

% get GUI figure parameters

dispdrvname = board;
dispdrvname(dispdrvname=='/' | dispdrvname=='_') = ' ';
eval(rtdrvfn('GetGUIControls',board));     % creates the FIG and GUI structures

% if old options not specified, read driver defaults

if nargin<2
  oldopt = rtdrvfn('GetDefaultParameters', board);
end

% draw the GUI dialog

scrsize = get(0,'ScreenSize');
pos(3:4) = [FIG.WIDTH FIG.HEIGHT];
pos(1:2) = (scrsize(3:4)-pos(3:4))/2;
figh = dialog('Name', dispdrvname, 'HandleVisibility', 'on', ...
              'Position', pos, ...
              'KeyPressFcn', 'rtdrvgui KeyPress');

% draw buttons

buttwidth = 0.7*FIG.WIDTH/4;   % we have 4 buttons that take 70% of the figure
buttxspace = 0.3*FIG.WIDTH/5;  % and 5 spaces between them
buttxpos = (0:3)*(buttwidth+buttxspace) + buttxspace;

uicontrol('Style','push','Position',[buttxpos(1) 10 buttwidth 25],'String','OK',...
          'CallBack','rtdrvgui OK');
uicontrol('Style','push','Position',[buttxpos(2) 10 buttwidth 25],'String','Test',...
          'CallBack','rtdrvgui Test');
uicontrol('Style','push','Position',[buttxpos(3) 10 buttwidth 25],'String','Revert',...
          'CallBack','rtdrvgui Revert');
uicontrol('Style','push','Position',[buttxpos(4) 10 buttwidth 25],'String','Cancel',...
          'CallBack','close(gcbf)');
  
% draw all the remaining controls

H = [];
for ctrl=fieldnames(GUI)'
  ctrl = ctrl{:};
  H = feval(ctrl, 'Draw', H, GUI.(ctrl), oldopt);
end

% wait for user response

setappdata(figh, 'Handles',H);
setappdata(figh, 'Board',board);
setappdata(figh, 'OldOptions',oldopt);
set(figh, 'Visible','on', 'HandleVisibility','callback');
uiwait(figh)

% if figure was not closed by Cancel, get parameters;
% otherwise just return empty result

if nargout>0
  if ishandle(figh)
    opt = GetValues(H);
  else
    opt = [];
  end
end

% close figure if it still exists

if ishandle(figh)
  close(figh)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  REVERT
%  revert original values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Revert

figh = gcbf;
H = getappdata(figh, 'Handles');
opt = getappdata(figh, 'OldOptions');
for ctrl=fieldnames(H)'
  ctrl = ctrl{:};
  feval(ctrl, 'SetValue', H, opt);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  TESTBOARD
%  test for board presence
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ok = TestBoard

% retrieve board parameters

figh = gcbf;
board = getappdata(figh, 'Board');
H = getappdata(figh, 'Handles');
opt = GetValues(H);

% try to load the board driver

try
  rttool('Load',board,opt(1),opt(2:end));
  ok = 1;
catch
  ok = 0;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  TEST
%  test button callback
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Test

okicon = [
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1;
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1;
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1;
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1;
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2;
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2 2;
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2;
2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2;
2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2;
2 2 1 1 1 1 1 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2;
2 1 1 1 1 1 1 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2 2;
1 1 1 1 1 1 1 2 2 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2 2 2;
1 1 1 1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2;
1 1 1 1 1 1 1 1 2 2 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2;
1 1 1 1 1 1 1 1 2 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2;
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2;
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2;
2 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
2 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
2 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
2 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
2 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
2 2 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
];

erricon = [
2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 2 2;
2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2 1 1 1 2;
2 2 1 1 1 1 2 2 2 2 2 2 2 2 1 1 1 1 1 1;
2 2 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 1;
2 2 1 1 1 1 1 1 2 2 2 2 1 1 1 1 1 1 1 2;
2 2 2 1 1 1 1 1 2 2 2 2 1 1 1 1 1 1 2 2;
2 2 2 1 1 1 1 1 1 2 2 1 1 1 1 1 1 2 2 2;
2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2;
2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2;
2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2;
2 2 2 2 2 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2;
2 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2 2 2;
2 2 2 2 2 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2;
2 2 2 2 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2;
2 2 2 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2;
2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2;
2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2;
2 1 1 1 1 1 1 1 2 1 1 1 1 1 1 1 1 2 2 2;
1 1 1 1 1 1 1 2 2 2 1 1 1 1 1 1 1 2 2 2;
2 1 1 1 1 1 2 2 2 2 1 1 1 1 1 1 1 2 2 2;
1 1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 2 2 2 2;
2 1 1 1 1 2 2 2 2 2 2 2 1 2 1 2 2 2 2 2;
2 2 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
];

bgclr = get(0,'DefaultUIControlBackgroundColor');

if TestBoard
  msgbox('The board presence at the selected address was verified.', ...
         'Board test OK', 'custom', okicon, [0 0.65 0;bgclr], 'modal');
else
  msgbox('The board has not been found at the selected address.', ...
         'Board not found', 'custom', erricon, [1 0 0;bgclr], 'modal');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  OK
%  OK button callback
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OK

% display confirmation dialog if board not successfully tested

if ~TestBoard
  yn = questdlg('The board has not been found at the selected address. Do you want to add it to the list of installed boards anyway?',...
                'Board not found','Yes','No','No');
  if ~strcmp(yn,'Yes')
    return;
  end
end

uiresume(gcbf);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  GETVALUES
%  get all control values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function opt = GetValues(H)

opt = [];
for ctrl=fieldnames(H)'
  ctrl = ctrl{:};
  opt = feval(ctrl, 'GetValue', opt, H);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  KEYPRESS
%  evaluate keypress
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function KeyPress    %#ok called by name from a callback

figh = gcbf;
switch upper(get(figh,'CurrentCharacter'))

  case {char(13), 'K'}
    OK;

  case {char(27), 'C'}
    close(figh);

  case 'R'
    Revert;

  case 'T'
    Test;

end
