function handle = sf_tictacflowgui(method,varargin)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 00:53:11 $

% persistent vars for injecting button events into chart

persistent ioStart;
persistent ioPress;
persistent ioButtonNumber;
if isempty(ioStart)
	ioStart = 0;	% default value at t = 0;
end
if isempty(ioPress)
	ioPress = 0;	% default value at t = 0;
end
if isempty(ioButtonNumber)
	ioButtonNumber = 0;	% default value at t = 0;
end

handle = [];

if nargin < 1
	return;
end
if isnumeric(method)
	switch method
	case 0
		handle = ioStart;
	case 1
		handle = ioPress;
	case 2
		handle = ioButtonNumber;
	otherwise
		error('unknown numeric method in sf_tictacflowgui');
	end
else
	switch method
	case 'fig'
		handle = sf_tictacflow_fig;
	case 'play_button'
		handle = play_button(varargin{1},varargin{2},varargin{3});
	case 'start_button'
		handle = start_button(varargin{1});
	case 'turn_signal'
		handle = turn_signal(varargin{1});
	case 'set_button_color'
		sf_tictacflow_set_button_color(varargin{1},varargin{2});
	case 'ioStartToggle'
		ioStart = double(~ioStart);
		handle = ioStart;
	case 'ioPressToggle'
		ioPress = double(~ioPress);
		handle = ioPress;
	case 'ioButtonNumber';
		ioButtonNumber = varargin{1};
		handle = ioButtonNumber;
	otherwise
		error('unknown char method in sf_tictacflowgui');
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = sf_tictacflow_fig

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

instance = 17;

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
   ,'DeleteFcn',''...
   );

%%% initialize the chart and make it visible
set(fig,'Visible','on');

%%% destroy figure when simulation terminates
set_param('sf_tictacflow/simulink io','StopFcn',sprintf('if ishandle(%f); delete(%f); end;',fig,fig));

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
%callback = sprintf('set_param(''sf_tictacflow/simulink io/ioPressedButton'',''Value'',''%.20g'');sf_tictacflowgui(''ioPressToggle'');',buttonNumber);
callback = sprintf('sf_tictacflowgui(''ioButtonNumber'',%.20g);sf_tictacflowgui(''ioPressToggle'');',buttonNumber);
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
%callback = sprintf('sf_tictacflowctl_sfm(''send'',%d,''START'')',instance);
callback = 'sf_tictacflowgui(''ioStartToggle'');';
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
function sf_tictacflow_set_button_color(buttonH,sf_tictacflowButtonColor)

% must tolerate non-existent uicontrols at end of simulation
if buttonH == 0 | ~ishandle(buttonH)
   return;
end

% 4 LSBs are red value
red = rem(sf_tictacflowButtonColor,16) / 16;

% 4 MSBs are green value
green = floor(double(sf_tictacflowButtonColor)/16) / 16;


%%% sprintf('%f = %f,%f\n',buttonH,green,red)
newRGB = [ red, green, 0 ];
%newRGB = [ 1 - green, 1 - red, .75 - min(.75,red+green)];

oldRGB = get(buttonH,'BackgroundColor');
if ~isequal(newRGB,oldRGB)
   set(buttonH,'BackgroundColor',newRGB);
end
