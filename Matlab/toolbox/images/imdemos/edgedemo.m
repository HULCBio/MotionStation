function edgedemo(action, varargin)
%EDGEDEMO Edge detection demo.
%   This demo uses the EDGE function to apply different edge detection
%   methods to a variety of images.  Use the pop-up menus to select an
%   image and an edge detection method.  You can control the parameters
%   for the different methods by setting the values in the middle frame
%   at the bottom of the figure.  (The set of parameters differs
%   depending on the method you choose.)  Press the "Apply" button to
%   calculate the edge map using the specified method and parameters.
%
%   For the Sobel, Prewitt, and Roberts methods, the EDGE function
%   finds edges by thresholding the gradient.  For the Laplacian of
%   Gaussian method, EDGE thresholds the slope of the zero crossings
%   after filtering the image with a LoG filter.  For the Canny method,
%   EDGE thresholds the gradient using the derivative of a Gaussian
%   filter.
%
%   By default, the EDGE function automatically computes the threshold
%   to use.  To specify a different threshold manually (in order to
%   detect more or fewer edges), click the radio button next to the
%   edit box in the middle frame and enter the value in the text field.
%   If you are using the Canny method, two thresholds are used:  the
%   high threshold is the value you specify, and the low threshold is
%   0.4 times the high threshold.
%
%   For the Sobel and Prewitt methods, you can choose to detect
%   horizontal edges, vertical edges, or both.
%
%   For the Laplacian of Gaussian and Canny methods, you can specify
%   sigma, the parameter that controls the spread of the Gaussian
%   function.  The size of the filter is set automatically by EDGE,
%   based on the value of sigma.
%
%   The Saturn and Lifting Body images are courtesy of NASA.
%  
%   See also EDGE.

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 1.19.4.7 $  $Date: 2004/04/01 16:12:06 $

% Function subroutines:
% 
% InitializeEDGEDEMO -      Initialization of controls, axes, and
%                           Images.
%
% ComputeEdgeMap -          Computes the Edge map of the original 
%                           image using edge.m
%
% SelectMethod -            Selects Edge Detection method and enable/disable
%                           the appropriate controls
%
% LoadNewImage -            Loads the selected Image
%
% UpdateThreshCtrl -     Grabs the threshold from the Edit box and 
%                           enables the Apply button
% 
% UpdateDirectionality -    Sets the directionality string based on the 
%                           popup menu.
%
% Radio -                   Sets values for Radio Buttons and enables/disables
%                           the threshold edit box.
%
% UpdateLOGSize -           Grabs the LOG filter size from edit box
%
% UpdateLOGSigma -          Grabs LOG filter Sigma from edit box
% 
% ActivateSPRControls -     Turns on controls for Sobel, Prewitt, Roberts
%
% ActivateLOGControls -     Turns on controls for LOG.

if nargin<1,
   action='InitializeEDGEDEMO';
end;

feval(action,varargin{:});
return;


%%%
%%%  Sub-function - InitializeEDGEDEMO
%%%

function InitializeEDGEDEMO()

% If dctdemo is already running, bring it to the foreground.
h = findobj(allchild(0), 'tag', 'Edge Detection Demo');
if ~isempty(h)
   figure(h(1))
   return
end

screenD = get(0, 'ScreenDepth');
if screenD>8
   grayres=256;
else
   grayres=128;
end


EdgeDemoFig = figure( ...
   'Name','Edge Detection Demo', ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', 'Edge Detection Demo', ...
   'Visible','off', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off', ...
   'Color', [.8 .8 .8], ...
   'IntegerHandle', 'off', ...
   'DoubleBuffer', 'on', ...
   'Colormap', gray(grayres));

figpos = get(EdgeDemoFig, 'position');

% Adjust the size of the figure window
figpos(3:4) = [560 420];
horizDecorations = 10;  % resize controls, etc.
vertDecorations = 45;   % title bar, etc.
screenSize = get(0,'ScreenSize');
if (screenSize(3) <= 1)
    % No display connected (apparently)
    screenSize(3:4) = [100000 100000]; % don't use Inf because of vms
end
if (((figpos(3) + horizDecorations) > screenSize(3)) | ...
            ((figpos(4) + vertDecorations) > screenSize(4)))
    % Screen size is too small for this demo!
    delete(EdgeDemoFig);
    error(['Screen resolution is too low ', ...
          '(or text fonts are too big) to run this demo']);
end
dx = screenSize(3) - figpos(1) - figpos(3) - horizDecorations;
dy = screenSize(4) - figpos(2) - figpos(4) - vertDecorations;
if (dx < 0)
    figpos(1) = max(5,figpos(1) + dx);
end
if (dy < 0)
    figpos(2) = max(5,figpos(2) + dy);
end
set(EdgeDemoFig, 'position', figpos);

rows = figpos(4); cols = figpos(3);
hs = (cols-512) / 3;        % Horizantal Spacing
bot = rows-2*hs-256;        % Bottom of the images

%====================================
% Parameters for all buttons and menus
ifs = hs/2;   % Intraframe Spacing

Std.Interruptible = 'off';
Std.BusyAction = 'queue';    

%================================
% Original Image Axes
hdl.ImageAxes = axes(Std, ...
   'Units', 'Pixels', ...
   'Parent',EdgeDemoFig,...
   'ydir', 'reverse', ...
   'XLim', [.5 256.5], ...
   'YLim', [.5 256.5],...
   'CLim', [0 255], ...
   'Position',[hs bot 256 256], ...
   'XTick',[],'YTick',[]);
set(get(hdl.ImageAxes, 'title'), 'string', 'Original Image');

%================================
% Edge Map Axes
hdl.EdgeAxes = axes(Std, ...
   'Units', 'Pixels', ...
   'Parent',EdgeDemoFig,...
   'ydir', 'reverse', ...
   'XLim', [.5 256.5], ...
   'YLim', [.5 256.5],...
   'CLim', [0 1], ...
   'Position',[cols-hs-256 bot 256 256], ...
   'XTick',[],'YTick',[]);
set(get(hdl.EdgeAxes, 'title'), 'string', 'Edge Map');

%================================
% Original Image 
hdl.Image = image(Std, ...
   'CData', [], ...
   'CDataMapping', 'scaled', ...
   'Parent',hdl.ImageAxes,...
   'Xdata', [1 256],...
   'Ydata', [1 256],...
   'EraseMode', 'none');

%================================
% Edge Map Image
hdl.Edge = image(Std, ...
   'CData', [], ...
   'CDataMapping', 'scaled', ...
   'Parent',hdl.EdgeAxes,...
   'Xdata', [1 256],...
   'Ydata', [1 256],...
   'EraseMode', 'none');

% Background color for frames
bgcolor = [0.45 0.45 0.45];
fgcolor = [1 1 1];  % For text

%================================
% The Menu frame - image and method popups go here
mfleft=hs; 
mfbot=hs; 
mfwid=(3*cols/8)-1.5*hs; % 2*cols/7
mfht=bot-2*hs;
hdl.MenuFrame = uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style', 'frame', ...
   'Units', 'pixels', ...
   'Position', [mfleft mfbot mfwid mfht], ...
   'BackgroundColor', bgcolor);

%====================================
% The LoadNewImage menu : ip-> Image Popup
ipwid = mfwid-2*ifs;
ipht = 21;       % (mfht-5*ifs)/3;
ipleft = mfleft+ifs;
ipbot = mfbot+1.7*ifs + 2*ipht;
hdl.ImgPop=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','popupmenu', ...
   'Units','pixels', ...
   'Position',[ipleft ipbot ipwid ipht], ...
   'Enable','on', ...
   'String','Coins|Circuit|Vertigo|Lifting Body|Rice|Saturn|Eight Bit|Glass', ...
   'Tag','ImagesPop',...
   'Callback','edgedemo(''LoadNewImage'')');

% Text label for Image Menu Popup
uicontrol( Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[ipleft ipbot+ipht ipwid 18], ...
   'Horiz','left', ...
   'Background',bgcolor, ...
   'Foreground',fgcolor, ...
   'String','Select an Image:');


%====================================
% The Method menu : mp-> Method Popup
hdl.Method = 'Sobel';
mpwid = ipwid;
mpht = ipht;
mpleft = ipleft;
mpbot = mfbot+1.2*ifs;
hdl.MethodPop=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','popupmenu', ...
   'Units','pixels', ...
   'Position',[mpleft mpbot mpwid mpht], ...
   'Enable','on', ...
   'String','Sobel|Prewitt|Roberts|Laplacian of Gaussian|Canny', ...
   'Tag','MethodPop',...
   'Callback','edgedemo(''SelectMethod'')');

% Text label for Method Popup
uicontrol( Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[mpleft mpbot+mpht mpwid 18], ...
   'Horiz','left', ...
   'Background',bgcolor, ...
   'Foreground',fgcolor, ...
   'String','Edge Detection Method:');


%================================
% The Parameter frame - method specific parameters go here
pfleft =(3*cols/8)+0.5*hs; % 2*cols/7
pfbot = 1.5*hs; 
pfwid =(3*cols/8)-hs; % 3*cols/7
pfht = bot-2.5*hs;
hdl.ParamFrame = uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style', 'frame', ...
   'Units', 'pixels', ...
   'Position', [ pfleft pfbot pfwid pfht ], ...
   'BackgroundColor', bgcolor);

%====================================
% Controls for Sobel/Prewitt/Roberts edge detectors:

% Text label for Threshold Controls
labelleft = pfleft+ifs;
labelwid = pfwid/2-hs;
labelbot = pfbot+2*pfht/3;
hdl.sprThLbl = uicontrol(Std,...
   'Parent', EdgeDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[labelleft labelbot labelwid 18], ...
   'Horiz','left', ...
   'String','Threshold:', ...
   'BackgroundColor',bgcolor, ...
   'ForegroundColor',fgcolor);
hdl.Threshold = 0;             % Initial value

raleft = pfleft + pfwid/2 - hs/2;
rabot = pfbot+2*pfht/3+hs/6;
rawid = pfwid/2;
raht = ipht;
hdl.RadioAutomatic=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','radiobutton', ...
   'Units','pixels', ...
   'Position',[raleft rabot rawid raht], ...
   'String','Automatic', ...
   'value',1,'Userdata',1, ...
   'Callback','edgedemo(''Radio'',''auto'')');

rmleft = pfleft + pfwid/2 - hs/2;
rmbot = pfbot+pfht/3+hs/3;
rmwid = hs*1.5;
rmht = ipht;
hdl.RadioManual=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','radiobutton', ...
   'Units','pixels', ...
   'Position',[rmleft rmbot rmwid rmht], ...
   'String','', ...
   'value',0,'Userdata',0, ...
   'Callback','edgedemo(''Radio'',''manual'')');

thleft = rmleft+rmwid;
thwid = rawid-rmwid;
thbot = rmbot;
thht = rmht;
hdl.ThreshCtrl = uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Enable', 'off', ...
   'Style','edit', ...
   'Units','pixels', ...
   'Position',[thleft thbot thwid thht], ...
   'Horiz','right', ...
   'Background','white', ...
   'Foreground','black', ...
   'String','0',...
   'callback','edgedemo(''UpdateSprThresh'')');



% The Directionality Popup menu : dp-> Direction Popup
dpwid = pfwid/2;
dpht = ipht;
dpleft = pfleft + pfwid/2 - hs/2;
dpbot = pfbot+.4*hs;
hdl.sprDirPop=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','popupmenu', ...
   'Units','pixels', ...
   'Position',[dpleft dpbot dpwid dpht], ...
   'Enable','on', ...
   'String','Both|Horizontal|Vertical', ...
   'Tag','DirectionPop',...
   'Callback','edgedemo(''UpdateDirectionality'')');
% Text label for Directionality Popup
labelleft = pfleft+ifs;
labelwid = pfwid/2-hs;     %5*hs/4
labelbot = dpbot;
hdl.sprDirLbl = uicontrol( Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[labelleft labelbot labelwid 18], ...
   'Horiz','left', ...
   'Background',bgcolor, ...
   'Foreground',fgcolor, ...
   'String','Direction:');
hdl.Directionality = 'both';


hdl.logSigmaCtrl=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','edit', ...
   'Units','pixels', ...
   'Position',[dpleft dpbot dpwid dpht], ...
   'Horiz','right', ...
   'Background','white', ...
   'Foreground','black', ...
   'String','2', ...
   'Tag','DirectionPop',...
   'Visible', 'off', ...
   'Callback','edgedemo(''UpdateLOGSigma'')');
% Text label for Sigma edit box
hdl.logSigmaLbl = uicontrol( Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[labelleft labelbot labelwid 18], ...
   'Horiz','left', ...
   'Background',bgcolor, ...
   'Foreground',fgcolor, ...
   'Visible', 'off', ...
   'String','Sigma:');
hdl.LogSigma = 2;

%====================================
% Status bar
colr = get(EdgeDemoFig,'Color');
hdl.Status = uicontrol( Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Background', colr, ...
   'Foreground', [.8 0 0], ...
   'Position',[pfleft 2 pfwid 18], ...
   'Horiz','center', ...
   'Tag', 'Status', ...
   'String','Initializing Edge Detection Demo...');

%================================
% The Button frame - Apply, Info, and Close buttons go here
bfleft = (3*cols/4)+.5*hs; % 5*cols/7
bfbot = hs; 
bfwid = (cols/4)-1.5*hs; % 2*cols/7
bfht = bot-2*hs;
hdl.ButtonFrame = uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style', 'frame', ...
   'Units', 'pixels', ...
   'Position', [ bfleft bfbot bfwid bfht ], ...
   'BackgroundColor', bgcolor);


%====================================
% The APPLY button
btnwid = bfwid - 2*ifs;
btnht =  (bfht-4*ifs)/3;     % 21
btnleft = bfleft + ifs;
btnbot = bfbot + bfht - ifs - btnht;
hdl.Apply=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','pushbutton', ...
   'Units','pixels', ...
   'Position',[btnleft btnbot btnwid btnht], ...
   'Enable','off', ...
   'String','Apply', ...
   'Callback','edgedemo(''ComputeEdgeMap'')');

%====================================
% The INFO button
btnbot = bfbot + bfht - 2*ifs - 2*btnht;
hdl.Help=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','pushbutton', ...
   'Units','pixels', ...
   'Position',[btnleft btnbot btnwid btnht], ...
   'Enable','off', ...
   'String','Info', ...
   'Callback','helpwin edgedemo');

%====================================
% The CLOSE button
btnbot = bfbot + ifs;
hdl.Close=uicontrol(Std, ...
   'Parent', EdgeDemoFig, ...
   'Style','pushbutton', ...
   'Units','pixels', ...
   'Position',[btnleft btnbot btnwid btnht], ...
   'Enable','off', ...
   'String','Close', ...
   'Callback','close(gcbf)');


set(EdgeDemoFig, 'Userdata', hdl, 'Visible', 'on');
drawnow
LoadNewImage(EdgeDemoFig);
drawnow
set(EdgeDemoFig, 'HandleVisibility', 'Callback');
set([hdl.Apply hdl.Help hdl.Close] , 'Enable', 'on');
return


%%%
%%%  Sub-Function - ComputeEdgeMap
%%%

function ComputeEdgeMap(DemoFig)

if nargin<1
   callb = 1;    % We're in a callback
   DemoFig = gcbf;
else 
   callb = 0;    % We're in the initialization
end

set(DemoFig,'Pointer','watch');
setstatus(DemoFig, 'Computing the edge map...');
hdl=get(DemoFig,'Userdata');
img = getimage(hdl.Image);

autothresh = get(hdl.RadioAutomatic, 'Value');

switch hdl.Method
case {'Sobel','Roberts','Prewitt'}
   if autothresh
      [edgemap,thresh] = edge(img, hdl.Method, hdl.Directionality);
      setstatus(['The threshold is ' num2str(thresh) '.']);
   else
      edgemap = edge(img, ...
         hdl.Method, hdl.Threshold, hdl.Directionality);
      setstatus(DemoFig, '');
   end
case 'Laplacian of Gaussian'
   if autothresh
      [edgemap,thresh] = edge(img, 'log', [], hdl.LogSigma);
      setstatus(DemoFig, ['The threshold is ' num2str(thresh) '.']);
   else
      edgemap = edge(img, 'log', hdl.Threshold, hdl.LogSigma);
      setstatus(DemoFig, '');
   end
case 'Canny'
   if autothresh
      [edgemap,thresh] = edge(img, 'canny', [], hdl.LogSigma);
      % statstr = sprintf('Thresholds are [%0.4f,0.4f].', thresh(1),thresh(2));
      % setstatus(DemoFig, statstr);
      setstatus(DemoFig, ['High threshold is ' num2str(thresh(2)) '.']);
   else
      [edgemap,thresh] = edge(img, 'canny', hdl.Threshold, hdl.LogSigma);
      % statstr = sprintf('Thresholds are [%0.4f,0.4f].', thresh(1),thresh(2));
      % setstatus(DemoFig, statstr);
      setstatus(DemoFig, '');
   end
otherwise
   error('EDGEDEMO: Invalid edge detection method.');
end

set(hdl.Edge, 'CData', edgemap);
set(hdl.Apply, 'Enable', 'off');
set(DemoFig,'Pointer','arrow');
drawnow


%%%
%%%  Sub-Function - SelectMethod
%%%

function SelectMethod

DemoFig = gcbf;

hdl = get(DemoFig, 'userdata');
v = get(hdl.MethodPop,{'value','String'});
hdl.Method = deblank(v{2}(v{1},:));
switch hdl.Method
case {'Sobel','Prewitt'}
   ActivateSPRControls(DemoFig);
   set(hdl.sprDirPop, 'Enable', 'on');
case 'Laplacian of Gaussian'
   ActivateLOGControls(DemoFig);
   set(hdl.logSigmaCtrl, 'String', '2');
   hdl.LogSigma = 2;
case 'Canny'
   ActivateLOGControls(DemoFig);
   set(hdl.logSigmaCtrl, 'String', '1');
   hdl.LogSigma = 1;
case 'Roberts'
   ActivateSPRControls(DemoFig);
   set(hdl.sprDirPop, 'Enable', 'off', 'value', 1);
otherwise
   error('EDGEDEMO: invalid method specifier.');
end
   
set(hdl.Apply, 'Enable', 'on');
set(DemoFig, 'userdata', hdl);
% BlankOutEdgeMap(DemoFig);
setstatus(DemoFig, ['Press ''Apply'' to compute edges.']);


%%%
%%%  Sub-Function - LoadNewImage
%%%

function LoadNewImage(DemoFig)

if nargin<1
   callb = 1;    % We're in a callback
   DemoFig = gcbf;
else 
   callb = 0;    % We're in the initialization
end

set(DemoFig,'Pointer','watch');
hdl=get(DemoFig,'Userdata');
v = get(hdl.ImgPop,{'value','String'});
name = deblank(v{2}(v{1},:));
setstatus(DemoFig, ['Loading the ' name ' image...']);
drawnow

switch name
case 'Lifting Body',
   liftbody256 = [];                     % Parser hint
   load imdemos liftbody256
   img = liftbody256;
case 'Coins',
   coins2 = [];                 
   load imdemos coins2
   img = coins2;
case 'Rice',
   rice3 = [];                    
   load imdemos rice3
   img = rice3;
case 'Saturn',
   saturn2 = [];              
   load imdemos saturn2
   img = saturn2; 
case 'Eight Bit',
   eight = [];       
   load imdemos eight
   img = eight; 
case 'Circuit',
   circuit4 = [];       
   load imdemos circuit4
   img = circuit4; 
case 'Vertigo',
   vertigo2 = [];       
   load imdemos vertigo2
   img = vertigo2; 
case 'Glass',
   glass2 = [];       
   load imdemos glass2
   img = glass2; 
otherwise 
   error('EDGEDEMO: Unknown Image Option!');
end

set(hdl.Image, 'Cdata', img);
set(get(hdl.ImageAxes,'title'),'string',['Original ' name ' Image']);
set(DemoFig,'Pointer','arrow');
if callb
   set(hdl.Apply, 'Enable', 'on');
end
drawnow
% If we are not using LOG, make sure we enable auto-threshold computation
% since whatever thresholds you have from one image won't work for another.
if ~strcmp(hdl.Method, 'Laplacian of Gaussian')
   if get(hdl.RadioAutomatic, 'Value')==0
      Radio('auto',DemoFig);
   end
end
ComputeEdgeMap(DemoFig);
return;


%%%
%%%  Sub-function - UpdateThreshCtrl
%%%

function UpdateSprThresh()
DemoFig = gcbf;
hdl = get(DemoFig, 'UserData');
v = hdl.Threshold;
s = get(hdl.ThreshCtrl,'String');
vv = real(evalin('base',['[' s ']'],num2str(v)));
% Validate the threshold which was passed in
if isempty(vv) | ~isreal(vv) | vv(1)<0 
   vv = v;
   set(gcbo,'String',num2str(vv));
   return
end
vv = round(vv(1)*1000000)/1000000;
set(gcbo,'String',num2str(vv));
hdl.Threshold = vv;
set(hdl.Apply, 'Enable', 'on');
setstatus(DemoFig, 'Press ''Apply'' to compute edges.');
set(DemoFig, 'UserData', hdl);
return

%%%
%%%  Sub-function - UpdateDirectionality
%%%

function UpdateDirectionality()

DemoFig = gcbf;
hdl = get(DemoFig, 'UserData');
v = get(hdl.sprDirPop,{'value','String'});
dir = deblank(v{2}(v{1},:));
set(hdl.sprDirPop, 'userdata', dir);
hdl.Directionality = dir;
set(hdl.Apply, 'Enable', 'on');
setstatus(DemoFig, 'Press ''Apply'' to compute edges.');
set(DemoFig, 'UserData', hdl);
return


%%%
%%%  Sub-function - Radio
%%%

function Radio(control, DemoFig)

if nargin<2
   DemoFig = gcbf;
end

hdl = get(DemoFig, 'UserData');
if strcmp(control, 'auto')
   set(hdl.RadioAutomatic, 'Value', 1);
   set(hdl.RadioManual, 'Value', 0);
   set(hdl.ThreshCtrl, 'Enable', 'off');
   set(hdl.Apply, 'Enable', 'on');
   setstatus(DemoFig, 'Press ''Apply'' to compute edges.');
elseif strcmp(control, 'manual')
   set(hdl.RadioAutomatic, 'Value', 0);
   set(hdl.RadioManual, 'Value', 1);
   set(hdl.ThreshCtrl, 'Enable', 'on');
   set(hdl.Apply, 'Enable', 'on');
   setstatus(DemoFig, 'Press ''Apply'' to compute edges.');
end
return


%%%
%%%  Sub-function - UpdateLOGSigma
%%%

function UpdateLOGSigma()
DemoFig = gcbf;
hdl = get(DemoFig, 'UserData');
v = hdl.LogSigma;
s = get(hdl.logSigmaCtrl,'String');
vv = real(evalin('base',s,num2str(v)));
if isempty(vv) | ~isreal(vv) | vv(1)<0      % Validate the threshold which was passed in
   vv = v;
   set(hdl.logSigmaCtrl,'String',num2str(vv));
   return
end
vv = round(vv(1)*100)/100;
set(hdl.logSigmaCtrl,'String',num2str(vv));
hdl.LogSigma = vv;
set(hdl.Apply, 'Enable', 'on');
setstatus(DemoFig, 'Press ''Apply'' to compute edges.');
set(DemoFig, 'UserData', hdl);
return


%%%
%%%  Sub-function - ActivateSPRControls
%%%

function ActivateSPRControls(DemoFig)

hdl = get(DemoFig, 'UserData');

set([hdl.sprDirPop hdl.sprDirLbl], 'Visible', 'on');

set([hdl.logSigmaCtrl hdl.logSigmaLbl], 'Visible', 'off');


%%%
%%%  Sub-function - ActivateLOGControls
%%%

function ActivateLOGControls(DemoFig)

hdl = get(DemoFig, 'UserData');

set([hdl.logSigmaCtrl hdl.logSigmaLbl],'Visible', 'on');

set([hdl.sprDirPop hdl.sprDirLbl], 'Visible', 'off');
