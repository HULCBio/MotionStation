function slideg(varargin)
%SLIDEG Slider Gain block helper function.
%   SLIDEG manages the dialog box for the Slider Gain block.
%   All block and Handle Graphics callbacks are funneled through
%   this SLIDEG.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.45.4.3 $

%
% Some older versions of the slider gain used 3 or 6 input args.
% Update them behind the scenes to the newest API.
%
switch nargin,
  case 6,
    low  = varargin{3};    % used to be hi
    gain = varargin{4};    % used to be flag
    high = varargin{5};    % used to be trash1
    set_param(gcb,'MaskPromptString','Low|Gain|High',...
                  'MaskValueString',  LocalParamsToMaskEntries(low, gain, high),...
                  'OpenFcn',          'slideg Open',...         % for double click
                  'CloseFcn',         'slideg Close',...        % for close_system
                  'DeleteFcn',        'slideg DeleteBlock',...  % for delete
                  'CopyFcn',          'slideg Copy',...         % for copy (update copy's user data)
                  'LoadFcn',          'slideg Load',...         % restore open state of dialog
                  'NameChangeFcn',    'slideg NameChange',...   % for name changes
                  'ParentCloseFcn',   'slideg ParentClose');    % for parental closure

    Action = 'Open';

  case 4,
    low  = varargin{1};    % used to be low
    gain = varargin{2};    % used to be Gain
    high = varargin{3};    % used to be high
    set_param(gcb,'MaskPromptString','Low|Gain|High',...
                  'MaskValueString',      LocalParamsToMaskEntries(low, gain, high),...
                  'OpenFcn',         'slideg Open',...         % for double click
                  'DeleteFcn',       'slideg DeleteBlock',...  % for delete
                  'CopyFcn',         'slideg Copy',...         % for copy (update copy's user data)
                  'LoadFcn',         'slideg Load',...         % restore open state of dialog
                  'NameChangeFcn',   'slideg NameChange',...   % for name changes
                  'ParentCloseFcn',  'slideg ParentClose');    % for parental closure

    Action = 'Open';

  otherwise,
    Action = varargin{1};
end

switch Action,
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Open - double click on the block %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Open',
    LocalOpenBlockFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Close - close_system call %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Close',
    LocalCloseBlockFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DeleteBlock - block is being deleted %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'DeleteBlock',
    LocalDeleteBlockFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Copy - block is being copied %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Copy',
    LocalCopyBlockFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load - block is being loaded %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Load',
    LocalLoadBlockFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % NameChange - block name has been changed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'NameChange',
    LocalNameChangeBlockFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ParentClose - block's parent has closed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'ParentClose',
    LocalParentCloseBlockFcn

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DeleteFigure - figure is being deleted %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'DeleteFigure',
    LocalDeleteFigureFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CloseRequest - figure is being closed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'CloseRequest',
    LocalCloseRequestFigureFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Help - help button has been pressed %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Help',
    LocalHelpFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Slider - slider is clicked on %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'Slider',
    LocalSliderFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % LowEdit - low edit box edited %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'LowEdit',
    LocalLowEditFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GainEdit - gain edit box edited %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'GainEdit',
    LocalGainEditFcn;

  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % HighEdit - high edit box edited %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  case 'HighEdit',
    LocalHighEditFcn;

  otherwise,
    error(['Unknown action ' Action]);

end % switch

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalParamsToMaskEntries
% Pass in the low, gain, and high values for the slider gain, and the
% appropriate MaskEntries string will be created from it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function maskEntries=LocalParamsToMaskEntries(low, gain, high)

maskEntries = [num2str(low) '|' num2str(gain) '|' num2str(high)];

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMaskEntriesToParams
% Convert the MaskEntries parameter of the current block to a vector with the
% low, gain, and high limits for the slider gain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [low,gain,high]=LocalMaskEntriesToParams(block)

parms = get_param(block,'MaskValues');
low   = str2num(parms{1});
gain  = str2num(parms{2});
high  = str2num(parms{3});

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOpenBlockFcn
% Called when the slider gain is clicked on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalOpenBlockFcn

BlockHandle = get_param(gcb,'handle');

%
% The slider gain dialog handle is stored in the block's user data
% If the figure is still valid and it's a slider gain figure, then
% bring it forward.  Otherwise, the dialog needs to be recreated.
%
FigHandle = get_param(gcb,'UserData');
if ishandle(FigHandle),
  set(FigHandle,'Visible','on');
  figure(FigHandle);
else,
  if strcmp(get_param(bdroot(gcb),'Lock'), 'on') || ...
     strcmp(get_param(gcb,'LinkStatus'),'implicit')
    errordlg(['The Slider Gain is in a locked system.  You must place it ' ...
              'in a model in order to operate.'],...
          'Error', 'modal')
    return
  end
  
  ScreenUnit = get(0,'Units');
  set(0,'Units','pixels');
  ScreenSize = get(0,'ScreenSize');
  layout;
  ButtonWH = [mStdButtonWidth mStdButtonHeight];
  HS = 5;
  FigW = 3*mStdButtonWidth + 4*mFrameToText;
  FigH = 3*mStdButtonHeight + 5*HS + mLineHeight;
  FigurePos = [(ScreenSize(3)-FigW)/2 (ScreenSize(4)-FigH)/2 FigW FigH];

  bdPos  = get_param(get_param(gcb,'Parent'), 'Location');
  blkPos = get_param(gcb, 'Position');
  bdPos  = [bdPos(1:2)+blkPos(1:2) bdPos(1:2)+blkPos(1:2)+blkPos(3:4)];
  hgPos  = rectconv(bdPos,'hg');

  FigurePos(1) = hgPos(1)+(hgPos(3)-FigurePos(3));
  FigurePos(2) = hgPos(2)+(hgPos(4)-FigurePos(4));
  
  % make sure the dialog is not off the screen
  if FigurePos(1)<0
    FigurePos(1) = 1;
  elseif FigurePos(1)> ScreenSize(3)-FigurePos(3) 
    FigurePos(1) = ScreenSize(3)-FigurePos(3);
  end
  if FigurePos(2)<0
    FigurePos(2) = 1;
  elseif FigurePos(2)> ScreenSize(4)-FigurePos(4) 
    FigurePos(2) = ScreenSize(4)-FigurePos(4);
  end
  %
  % Remark: consider putting figure in middle of Simulink window
  %
  FigHandle=figure('Pos',            FigurePos,...
                   'Name',           get_param(gcb,'Name'), ...
                   'Color',          get(0,'DefaultUIControlBackgroundColor'),...
                   'Resize',         'off',...
                   'NumberTitle',    'off',...
                   'MenuBar',        'none',...
                   'HandleVisibility','callback',...
                   'IntegerHandle',  'off',...
                   'CloseRequestFcn','slideg CloseRequest',...
                   'DeleteFcn',      'slideg DeleteFigure');

  %
  % Create static text
  %
  uicontrol('Parent',FigHandle,...
            'Style','text',...
            'String','Low',...
            'HorizontalAlignment','left',...
            'Position',[2*mFrameToText 2*mStdButtonHeight+3*HS mStdButtonWidth mLineHeight]);

  uicontrol('Parent',FigHandle,...
            'Style','text',...
            'String','High',...
            'HorizontalAlignment','right', ...
            'Position',[2*mFrameToText+2*mStdButtonWidth 2*mStdButtonHeight+3*HS mStdButtonWidth mLineHeight]);

  %
  % Create slider
  % Remark: possibly check for value between zero and one
  %
  [low, gain, high] = LocalMaskEntriesToParams(gcb);
  value = (gain-low)/(high-low);
  position=[2*mFrameToText 2*mStdButtonHeight+mLineHeight+4*HS ...
            3*mStdButtonWidth mStdButtonHeight];
  ud.Slider = uicontrol('Parent',FigHandle,...
                        'Style','slider',...
                        'Value',value,...
                        'Position',position,...
                        'Callback','slideg Slider');

  % Create editable controls
  Bup = 2*HS+mStdButtonHeight;
  ud.LowEdit=uicontrol('Parent',FigHandle,...
                       'Style','edit',...
                       'BackgroundColor','white', ...
                       'Position',[mFrameToText Bup ButtonWH], ...
                       'String',num2str(low),...
                       'UserData',low, ...
                       'Callback','slideg LowEdit');

  ud.GainEdit=uicontrol('Parent',FigHandle,...
                        'Style','edit',...
                        'BackgroundColor','white', ...
                        'Position',[2*mFrameToText+mStdButtonWidth Bup ButtonWH], ...
                        'String',num2str(gain),...
                        'UserData',gain, ...
                        'Callback','slideg GainEdit');
  ud.HighEdit=uicontrol('Parent',FigHandle,...
                        'Style','edit',...
                        'BackgroundColor','white', ...
                        'Pos',[3*mFrameToText+2*mStdButtonWidth Bup ButtonWH], ...
                        'String',num2str(high),...
                        'UserData',high, ...
                        'Callback','slideg HighEdit');

  %
  % Create Close pushbutton
  %
  ud.Close=uicontrol('Parent',FigHandle,...
                    'Style','push',...
                    'String','Close', ...
                    'Position',[2*mStdButtonWidth+3*mFrameToText HS ButtonWH], ...
                    'Callback','slideg CloseRequest');

  %
  % Create Help pushbutton
  %
  ud.Help=uicontrol('Parent',FigHandle,...
                    'Style','push',...
                    'String','Help', ...
                    'Position',[mStdButtonWidth+2*mFrameToText HS ButtonWH], ...
                    'Callback','slideg Help');

  set(0,'Units',ScreenUnit);

  %
  % Set the vitals in the figure's user data
  %
  ud.Block=get_param(gcb,'Handle');
  set(FigHandle,'UserData',ud);

  %
  % Save this figure's handle in the block's user data
  %
  set_param(gcb,'UserData',FigHandle)

 end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteBlockFcn
% Called when the slider gain block is deleted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalDeleteBlockFcn

FigHandle=get_param(gcb,'UserData');
if ishandle(FigHandle),
  delete(FigHandle);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCloseBlockFcn
% Called when the slider gain block is closed via close_system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalCloseBlockFcn

FigHandle=get_param(gcb,'UserData');
if ishandle(FigHandle),
  delete(FigHandle);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteFigureFcn
% Called when the slider gain figure is deleted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalDeleteFigureFcn

FigHandle=get(0,'CallbackObject');
ud=get(FigHandle,'UserData');

set_param(ud.Block,'UserData',[]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCloseRequestFigureFcn
% Called when the slider gain figure is closed by various means.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalCloseRequestFigureFcn

cbo=get(0,'CallbackObject');
switch get(cbo,'type')
  case 'uicontrol',
    FigHandle = get(cbo,'Parent');
  case 'figure'
    FigHandle = cbo;
  otherwise,
    error(['Unexpected object in ' mfilename]);
end

delete(FigHandle);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHelpFcn
% Called when the slider gain Help button is pressed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalHelpFcn

ud = get(gcf,'userdata');
slhelp(ud.Block);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCopyBlockFcn
% Called when the slider gain block is copied
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalCopyBlockFcn

% If the UserData is empty, the block might still be in a locked library,
% so don't bother trying to reset it unnecessarily.
if (~isempty(get_param(gcb,'UserData')))
  set_param(gcb,'UserData',[]);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLoadBlockFcn
% Called when the slider gain block is loaded
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalLoadBlockFcn

if strcmp(get_param(bdroot,'BlockDiagramType'),'Model')
  set_param(gcb,'UserData',[]);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalNameChangeBlockFcn
% Called when the slider gain block name is changed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalNameChangeBlockFcn

FigHandle=get_param(gcb,'UserData');
if ishandle(FigHandle),
  set(FigHandle,'Name',get_param(gcb,'Name'));
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalParentCloseBlockFcn
% Called when the slider gain block's parent is closed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalParentCloseBlockFcn

FigHandle=get_param(gcb,'UserData');
if ishandle(FigHandle),
  delete(FigHandle);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSliderFcn
% Called when the slider gain block slider is clicked on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalSliderFcn

FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high] = LocalMaskEntriesToParams(ud.Block);

gain=low+get(ud.Slider,'Value')*(high-low);

LocalSetLowGainHigh(ud, low, gain, high);
set(ud.GainEdit,'String',num2str(gain));

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLowEditFcn
% Called when the slider gain block low edit field is edited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalLowEditFcn

FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high]        = LocalMaskEntriesToParams(ud.Block);
[lowMask, count, errstr] = sscanf(get(ud.LowEdit,'String'),'%f');

if ~isempty(lowMask)
  low = lowMask;
end

if count==0,
  if isempty(errstr),
    errstr='Invalid input string';
  end
elseif low > gain,
  errstr='Low > Gain. Change the Gain first. Setting Low = Gain.';
  low = gain;
end

if ~isempty(errstr),
  LocalBeep;
  errordlg(errstr,'Error','modal');
end

value = (gain-low)/(high-low);
set(ud.Slider,'Value',value);

LocalSetLowGainHigh(ud, low, gain, high);
set(ud.LowEdit ,'string',num2str(low))
set(ud.GainEdit,'string',num2str(gain))
set(ud.HighEdit,'string',num2str(high))

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGainEditFcn
% Called when the slider gain block gain edit field is edited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalGainEditFcn

FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high]       = LocalMaskEntriesToParams(ud.Block);
[gainMask,count,errstr] =sscanf(get(ud.GainEdit,'String'),'%f');

if ~isempty(gainMask)
  gain = gainMask;
end

if count==0,
  if isempty(errstr),
    errstr='Invalid input string';
  end
elseif (low > gain) 
  low = gain;
elseif (gain > high),
  high = gain;
end

value = (gain-low)/(high-low);
set(ud.Slider,'Value',value);

LocalSetLowGainHigh(ud, low, gain, high);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHighEditFcn
% Called when the slider gain block gain edit field is edited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalHighEditFcn

FigHandle=gcf;
ud=get(FigHandle,'UserData');

[low, gain, high]       = LocalMaskEntriesToParams(ud.Block);
[highMask,count,errstr] = sscanf(get(ud.HighEdit,'String'),'%f');

if ~isempty(highMask)
  high = highMask;
end

if count==0,
  if isempty(errstr),
    errstr='Invalid input string';
  end
elseif (gain > high),
  errstr='High < Gain. Change the Gain first. Setting High = Gain';
  high = gain;
end

if ~isempty(errstr),
  LocalBeep;
  errordlg(errstr,'Error','modal');
end

value = (gain-low)/(high-low);
set(ud.Slider,'Value',value);

LocalSetLowGainHigh(ud, low, gain, high);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalBeep
% Beeps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalBeep

disp(char(7));

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSetLowGainHigh
% Beeps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function LocalSetLowGainHigh(ud, low, gain, high)

try
  set_param(ud.Block,'MaskValueString',LocalParamsToMaskEntries(low, gain, high));
  set(ud.LowEdit ,'string',num2str(low))
  set(ud.GainEdit,'string',num2str(gain))
  set(ud.HighEdit,'string',num2str(high))
catch
  LocalBeep
  errmsg = sprintf(['Error setting slider gain value.  ' ...
                    'MATLAB error message:\n ''%s'''], lasterr);
  errordlg(errmsg, gcb, 'modal');
end
