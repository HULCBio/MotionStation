function sf_tictacflow_mex(method,varargin)

%   Copyright 1995-2002 The MathWorks, Inc.

persistent continueTimerLoop;

if nargin == 0
   
   continueTimerLoop = 1;
   inst = game('create');
   
   figH = ttf_fig;
   userData.buttonH(1) = play_button(figH,1,0);
   userData.buttonH(2) = play_button(figH,8,1);
   userData.buttonH(3) = play_button(figH,3,2);
   userData.buttonH(4) = play_button(figH,6,3);
   userData.buttonH(5) = play_button(figH,4,4);
   userData.buttonH(6) = play_button(figH,2,5);
   userData.buttonH(7) = play_button(figH,5,6);
   userData.buttonH(8) = play_button(figH,0,7);
   userData.buttonH(9) = play_button(figH,7,8);
   userData.startButtonH = start_button(figH);
   userData.turnSignalH = turn_signal(figH);
   userData.instance = inst;
   set(figH,'UserData',userData);
   set(figH,'DeleteFcn','sf_tictacflow_mex(''quitTimerLoop'');');
   game('register',inst,'ENABLE_BUTTONS',sprintf('sf_tictacflow_mex(''ENABLE_BUTTONS'',%.32f);',figH));
   
   
   %%% Loop to update buttons and broadcast TENTHS.
   while continueTimerLoop
      pause(0.1);
      game('broadcast',inst,'TENTHS');
      update_button_colors(figH);
   end
   game('destroy',inst);
   
else
   switch method
   case 'start_button'
      % callback from gui start button
      figH = varargin{1};
      ud = get(figH,'UserData');
      game('broadcast',ud.instance,'START');
      update_button_colors(figH);
   case 'play_button'
      % callback from gui playing buttons
      figH = varargin{1};
      buttonNum = varargin{2};
      ud = get(figH,'UserData');
      set(ud.buttonH,'Enable','Off');   % must disable buttons until ENABLE_BUTTONS event
      game('set',ud.instance,'pressedButton',buttonNum);
      game('broadcast',ud.instance,'EXT_PRESS');
      update_button_colors(figH);
   case 'ENABLE_BUTTONS'
      % callback from SF chart output event ENABLE_BUTTONS
      figH = varargin{1};
      ud = get(figH,'UserData');
      set(ud.buttonH,'Enable','On');
   case 'quitTimerLoop'
      continueTimerLoop = 0;
   otherwise
      disp('how did you get here?');
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:53:09 $
function update_button_colors(figH)

% figH may become invalid at end of game when closing figure.
if ~ishandle(figH)
   return;
end

ud = get(figH,'UserData');
for i = 1:9
   color = game('get',ud.instance,'buttonColor',i-1);
   ttf_set_button_color(ud.buttonH(i),color);
end
color = game('get',ud.instance,'buttonColor',9);
ttf_set_button_color(ud.turnSignalH,color);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = ttf_fig

%%% set up basic layout measurements
gap = 10;
buttonWidth = 50;
buttonHeight = 50;
startButtonWidth = 90;
startButtonHeight = 30;
turnSignalWidth = 10;
turnSignalHeight = 10;
figureWidth = 3*buttonWidth + 4*gap;
figureHeight = 3*buttonHeight + 4*gap + startButtonHeight + gap;

%%% open figure in middle of screen
screenSize = get(0,'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);
figurePos = [(screenWidth - figureWidth)/2 (screenHeight-figureHeight)/2 figureWidth figureHeight];

userData.blue = [];
userData.red = [];
%%% create figure
fig = figure('Visible','off'...
   ,'NumberTitle','off'...
   ,'Name','Tic Tac Flow'...
   ,'Position',figurePos...
   ,'Resize','off'...
   ,'MenuBar','none'...
   ,'UserData',userData...
   );

%%% initialize the chart and make it visible
set(fig,'Visible','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function playButtonH = play_button(fig,buttonLocation,buttonNumber)
%%% set up one of 9 playing buttons
%%%

% buttonLocation and buttonNumber should be in 0:8

%%% set up basic layout measurements
gap = 10;
buttonWidth = 50;
buttonHeight = 50;
startButtonWidth = 90;
startButtonHeight = 30;
turnSignalWidth = 10;
turnSignalHeight = 10;
figureWidth = 3*buttonWidth + 4*gap;
figureHeight = 3*buttonHeight + 4*gap + startButtonHeight + gap;

%%% set up playing button
%%% convert buttonLocation into 1-based [row,col] indices
row = 1 + floor(buttonLocation / 3);
col = 1 + rem(buttonLocation,3);
pos = [ col*gap + (col-1)*buttonWidth, figureHeight - row*(gap + buttonHeight), buttonWidth, buttonHeight];
playButtonH = uicontrol(fig...
   ,'Style','PushButton'...
   ,'Position',pos...
   ,'Enable','On'...
   ,'BackgroundColor','Black'...
   ,'Tag',sprintf('button_%d',buttonNumber)...
   );
callback = sprintf('sf_tictacflow_mex(''play_button'',%.20g,%.20g);',fig,buttonNumber);
set(playButtonH,'Callback',callback);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function startButton = start_button(fig)
%%% set up basic layout measurements
gap = 10;
buttonWidth = 50;
buttonHeight = 50;
startButtonWidth = 90;
startButtonHeight = 30;
turnSignalWidth = 10;
turnSignalHeight = 10;
figureWidth = 3*buttonWidth + 4*gap;
figureHeight = 3*buttonHeight + 4*gap + startButtonHeight + gap;

pos = [ (figureWidth-startButtonWidth)/2  gap startButtonWidth startButtonHeight];
callback = sprintf('sf_tictacflow_mex(''start_button'',%.20g);',fig);
startButton = uicontrol(fig...
   ,'Style','PushButton'...
   ,'Position',pos...
   ,'String','Start'...
   ,'Callback',callback...
   );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function turnSignal = turn_signal(fig)
%% set up a button for a turn indicator
%%% set up basic layout measurements
gap = 10;
buttonWidth = 50;
buttonHeight = 50;
startButtonWidth = 90;
startButtonHeight = 30;
turnSignalWidth = 10;
turnSignalHeight = 10;
figureWidth = 3*buttonWidth + 4*gap;
figureHeight = 3*buttonHeight + 4*gap + startButtonHeight + gap;

% first compute center of turnSignal location
center = [ (figureWidth-startButtonWidth)/4  gap + startButtonHeight/2 ];
% then compute position arg
pos = [ center + [ -turnSignalWidth/2 -turnSignalHeight/2 ] turnSignalWidth turnSignalHeight ];
turnSignal = uicontrol(fig...
   ,'Style','PushButton'...
   ,'Position',pos...
   ,'Enable','off'...
   );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ttf_set_button_color(buttonH,buttonColor)

% must tolerate non-existent uicontrols at end of simulation
if buttonH == 0 | ~ishandle(buttonH)
   return;
end

% 4 LSBs are red value
red = rem(buttonColor,16) / 16;

% 4 MSBs are green value
green = floor(buttonColor/16) / 16;


%%% sprintf('%f = %f,%f\n',buttonH,green,red)
newRGB = [ red, green, 0 ];
%newRGB = [ 1 - green, 1 - red, .75 - min(.75,red+green)];

oldRGB = get(buttonH,'BackgroundColor');
if ~isequal(newRGB,oldRGB)
   set(buttonH,'BackgroundColor',newRGB);
end

