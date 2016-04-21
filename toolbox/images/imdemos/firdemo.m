function firdemo(action,varargin);
%FIRDEMO 2-D FIR filtering and filter design demo.
%   This demo lets you explore 2-D Finite Impulse Response (FIR) 
%   filters.  By changing the cut-off frequency and filter order   
%   you can design your own filter.  The designed filter's 
%   coefficients and frequency response are shown in the two 
%   axes at the bottom of the figure.  The filter is designed 
%   using the method specified by the selected radio button.
%                                         
%   Press the "Apply Filter" button to apply the filter to the 
%   original image and display the results.
%                                       
%   Use the top menu to select from a number of possible images.
%   The next menu controls whether a highpass or lowpass filter 
%   is designed.  The third menu lets you choose among various 
%   window functions.  The window functions are used only if 
%   FWIND1 or FWIND2 is chosen as the design method.
%                                       
%   You can change the cutoff frequency or filter order by 
%   editing the numbers displayed.  Only odd-sized orders and 
%   cutoff frequencies between 0.0 and 1.0 are valid for this 
%   demo.   
%                                         
%   The Saturn image is courtesy of NASA.
%  
%   See also FREQZ2, FSAMP2, FTRANS2, FWIND1, FWIND2.

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 1.19.4.6 $  $Date: 2004/04/01 16:12:07 $

% Function Subroutines:
%
% InitializeFIRDEMO   - sets up controls, axes, images, and initializes
%                       them.   Calls LoadNewImage and DesignFilter
%
% DesignFilter -        Designs the filter and plots the filter 
%                       coefficients and frequency response
% 
% ApplyFilter -         Applies the filter to the original image and 
%                       displays results
%
% LoadNewImage -        Loads a new image which is selected from the 
%                       popup
% 
% RadioUpdate -         Turns on the Radio Button which is clicked 
%                       on and turns the other radio buttons off.
%
% cutoff -              update the cutoff for desired frequency 
%                       response and call DesignFilter
% 
% order -               update filter order and call DesignFilter

if nargin<1,
   action='InitializeFIRDEMO';
end;

feval(action,varargin{:});
return;



%%%
%%%  Sub-function - InitializeFIRDEMO
%%%

function InitializeFIRDEMO()

% If firdemo is already running, bring it to the foreground.
h = findobj(allchild(0), 'tag', '2D FIR Filtering Demo');
if ~isempty(h)
   figure(h(1))
   return
end

% Do we have the needed Signal Processing Toolbox functions?
if (exist('remez','file') ~= 2)
    errString = {'FIRDEMO requires the Signal Processing Toolbox'};
    dlgName = 'FIRDEMO error';
    errordlg(errString, dlgName);
    return
end

screenD = get(0, 'ScreenDepth');
if screenD>8
   grayres=256;
else
   grayres=128;
end
 
FirDemoFig = figure( ...
   'Name','2-D FIR Filtering Demo', ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', '2D FIR Filtering Demo', ...
   'Visible','off', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off', ...
   'IntegerHandle', 'off', ...
   'doublebuffer', 'on', ...
   'Colormap', gray(grayres));

figpos = get(FirDemoFig, 'position');

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
    delete(fig);
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
set(FirDemoFig, 'position', figpos);

%==================================
% Set up the image axes
row = figpos(4); col = figpos(3);  % dimensions of figure window

% The original image
hdl.OrigImageAxes = axes('Parent', FirDemoFig, ...
   'Units','pixels', ...
   'BusyAction','Queue','Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 1], ...
   'Position',[50  247 128 128], ...
   'XTick',[],'YTick',[]);
hdl.OriginalImage = image('Parent', hdl.OrigImageAxes,...
   'CData', [], ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'normal');   % should be none, HG geck 

% The Filtered Image
hdl.FiltImageAxes = axes('Parent', FirDemoFig, ...
   'Units','pixels', ...
   'BusyAction','Queue','Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 1], ...
   'Position',[240 247 128 128], ...
   'XTick',[],'YTick',[]);
hdl.FilteredImage = image('Parent', hdl.FiltImageAxes,...
   'CData', [], ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'normal');   % should be none, HG geck

title('Filtered Image')

% The Axes for plotting filter coefficients
hdl.Filter = axes('Parent', FirDemoFig, ...
   'Units','pixels', ...
   'Position', [50 74 128 128]);
title('Filter Coefficients');

% The Axes for plotting filter frequency response
hdl.Response = axes('Parent', FirDemoFig, ...
   'Units','pixels', ...
   'Position', [240 74 128 128]);
title('Frequency Response');

%====================================
% Information for all buttons (and menus)
bgc = [0.45 0.45 0.45];
c = get(FirDemoFig,'Color');
labelColor=[0.8 0.8 0.8];
yInitPos=0.90;
menutop=0.95;
btnTop = 0.6;
top=0.75;
left=0.785;
btnWid=0.185;
btnHt=0.055;
textHeight = 0.05;
textWidth = 0.07;
% Spacing between the button and the next command's label
spacing=0.018;
txtsp=.043;   % This can be changed

%====================================
% The CONSOLE frame
frmBorder=0.019; frmBottom=0.04; 
frmHeight = 0.92; frmWidth = btnWid;
yPos=frmBottom-frmBorder;
frmPos=[left-frmBorder yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
h=uicontrol( 'Parent', FirDemoFig, ...
   'Style','frame', ...
   'Units','normalized', ...
   'Position',frmPos, ...
   'BackgroundColor',bgc);

%====================================
% The LoadNewImage menu
menuNumber=1;
yPos=menutop-(menuNumber-1)*(btnHt+spacing)-.7*txtsp;

btnPos=[left yPos-btnHt btnWid btnHt];
hdl.ImgPop=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','popupmenu', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'Enable','on', ...
   'String','Vertigo|Saturn|Pepper|Quarter|Glass', ...
   'Tag','ImagesPop',...
   'Callback','firdemo(''LoadNewImage'')');
labelPos = [left btnPos(2)+btnHt*1.0 btnWid txtsp];
h = uicontrol('Parent', FirDemoFig, ...
   'Style','text', ...
   'Units','normalized', ...
   'Position',labelPos, ...
   'Horiz','left', ...
   'String','Select an Image:', ...
   'Interruptible','off', ...
   'BackgroundColor',bgc, ...
   'ForegroundColor','white');

%====================================
% The FiltBand Menu
menuNumber=2;
yPos=menutop-(menuNumber-1)*(btnHt+spacing)-1.4*txtsp;
labelStr='lowpass|highpass';
callbackStr='firdemo(''DesignFilter'');';

btnPos=[left yPos-btnHt btnWid btnHt];
hdl.FiltBand=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','popupmenu', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'Interruptible','on', ...
   'Callback',callbackStr);
labelPos = [left btnPos(2)+btnHt*1.0 btnWid txtsp];
h = uicontrol('Parent', FirDemoFig, ...
   'Style','text', ...
   'Units','normalized', ...
   'Position',labelPos, ...
   'Horiz','left', ...
   'String','Type of filter:', ...
   'Interruptible','off', ...
   'BackgroundColor',bgc, ...
   'ForegroundColor','white');

%====================================
% The Window Menu
menuNumber=3;
yPos=menutop-(menuNumber-1)*(btnHt+spacing)-2.1*txtsp;
labelStr=str2mat('Bartlett','Hamming','Hanning','Blackman');
callbackStr='firdemo(''DesignFilter'')';

% Generic button information
btnPos=[left yPos-btnHt btnWid btnHt];
hdl.Window=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','popupmenu', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'Interruptible','on', ...
   'Enable', 'off', ...
   'Callback',callbackStr);
labelPos = [left btnPos(2)+btnHt*1.0 btnWid txtsp];
h = uicontrol('Parent', FirDemoFig, ...
   'Style','text', ...
   'Units','normalized', ...
   'Position',labelPos, ...
   'Horiz','left', ...
   'String','Window method:', ...
   'Interruptible','off', ...
   'BackgroundColor',bgc, ...
   'ForegroundColor','white');

%===================================
% Cutoff label and text field
top = yPos - btnHt - spacing;
labelWidth = frmWidth-textWidth-.01;
labelBottom=top-textHeight;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol('Parent', FirDemoFig, ...
   'Style','text', ...
   'Units','normalized', ...
   'Position',labelPos, ...
   'Horiz','left', ...
   'String','Cutoff:', ...
   'Interruptible','off', ...
   'BackgroundColor',[0.45 0.45 0.45], ...
   'ForegroundColor','white');
% Text field
textPos = [labelLeft+labelWidth labelBottom textWidth textHeight];
callbackStr = 'firdemo(''cutoff'')';
hdl.Cutoff = uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','edit', ...
   'Units','normalized', ...
   'Position',textPos, ...
   'Horiz','right', ...
   'Background','white', ...
   'Foreground','black', ...
   'String','0.5','Userdata',0.5, ...
   'callback',callbackStr);

%===================================
% Filter order label and text field
labelBottom=top-2*textHeight-spacing;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol('Parent', FirDemoFig, ...
   'Style','text', ...
   'Units','normalized', ...
   'Position',labelPos, ...
   'String','Order:', ...
   'Horiz','left', ...
   'Interruptible','off', ...
   'Background',[0.45 0.45 0.45], ...
   'Foreground','white');
% Text field
textPos = [labelLeft+labelWidth labelBottom textWidth textHeight];
callbackStr = 'firdemo(''order'')';
hdl.Order = uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','edit', ...
   'Units','normalized', ...
   'Position',textPos, ...
   'Horiz','center', ...
   'Background','white', ...
   'Foreground','black', ...
   'String','15','Userdata',15, ...
   'Callback',callbackStr);

%====================================
% Label for Design Methods
lblTop = labelBottom-spacing-(txtsp*1.2)+.1*btnHt;
labelPos = [left lblTop btnWid txtsp];
h = uicontrol('Parent', FirDemoFig, ...
   'Style','text', ...
   'Units','normalized', ...
   'Position',labelPos, ...
   'Horiz','left', ...
   'String','Design Method:', ...
   'Interruptible','off', ...
   'BackgroundColor',bgc, ...
   'ForegroundColor','white');

radioHt = btnHt*.9;
%====================================
% fsamp2 radio button
btnTop = labelBottom-spacing-(txtsp*1.2);
btnNumber=1;
yPos=btnTop-(btnNumber-1)*(radioHt+spacing);
labelStr='fsamp2';
callbackStr='firdemo(''RadioUPDATE'',1);';

% Generic button information
btnPos=[left yPos-radioHt btnWid radioHt];
hdl.Btn1=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','radiobutton', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'value',1,'Userdata',1, ...
   'Callback',callbackStr);

%====================================
% fwind1 radio button
btnNumber=2;
yPos=btnTop-(btnNumber-1)*(radioHt+spacing);
labelStr='fwind1';
callbackStr='firdemo(''RadioUPDATE'',2);';

% Generic button information
btnPos=[left yPos-radioHt btnWid radioHt];
hdl.Btn2=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','radiobutton', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'value',0, ...
   'Callback',callbackStr);

%====================================
% fwind2 radio button
btnNumber=3;
yPos=btnTop-(btnNumber-1)*(radioHt+spacing);
labelStr='fwind2';
callbackStr='firdemo(''RadioUPDATE'',3);';

% Generic button information
btnPos=[left yPos-radioHt btnWid radioHt];
hdl.Btn3=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','radiobutton', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'Callback',callbackStr);

%====================================
% ftrans2 radio button
btnNumber=4;
yPos=btnTop-(btnNumber-1)*(radioHt+spacing);
labelStr='ftrans2';
% Setting userdata to -1 (=stop) will stop the demo.
callbackStr='firdemo(''RadioUPDATE'',4);';

% Generic button information
btnPos=[left yPos-radioHt btnWid radioHt];
hdl.Btn4=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','radiobutton', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'Callback',callbackStr);

%====================================
% Apply Filter Frame
framePos=[5*spacing spacing btnWid+2*spacing btnHt+2*spacing];
h=uicontrol( 'Parent', FirDemoFig, ...
   'Style','frame', ...
   'Units','normalized', ...
   'Position',framePos, ...
   'BackgroundColor',bgc);

%====================================
% The APPLY FILTER button
labelStr='Apply Filter';
callbackStr='firdemo(''ApplyFilter'')';
btnPos=[framePos(1)+spacing framePos(2)+spacing btnWid btnHt];
hdl.Apply=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'Enable','off', ...
   'String',labelStr, ...
   'Callback',callbackStr);

%====================================
% The INFO button
labelStr='Info';
callbackStr='helpwin firdemo';
hdl.Help=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[left frmBottom+btnHt+spacing btnWid btnHt], ...
   'String',labelStr, ...
   'Enable','off', ...
   'Callback',callbackStr);

%====================================
% The CLOSE button
labelStr='Close';
callbackStr='close(gcbf)';
hdl.Close=uicontrol('Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[left frmBottom btnWid btnHt], ...
   'String',labelStr, ...
   'Enable','off', ...
   'Callback',callbackStr);

%====================================
% Status bar
hdl.Status = uicontrol( ...
   'Parent', FirDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[190 10 230 18], ...
   'Foreground', [.8 0 0], ...
   'Background',c, ...
   'Horiz','center', ...
   'Tag', 'Status', ...
   'String','Initializing Demo...');

set(FirDemoFig, 'Userdata', hdl, 'Visible', 'on');

% rotate3d ON;
LoadNewImage(FirDemoFig);
DesignFilter(FirDemoFig)
ApplyFilter(FirDemoFig);
set(FirDemoFig,'HandleVisibility','Callback');
set([hdl.Help hdl.Close] , 'enable', 'on');
return


%%%
%%%  Sub-Function - cutoff
%%%

function cutoff()
v = get(gcbo,'Userdata');
s = get(gcbo,'String');
vv = eval(s,num2str(v));
if isempty(vv) | ~isreal(vv) | vv(1) > 1 | vv(1) <= 0
   vv = v; 
   set(gcbo, 'String', num2str(v))
   return
end
vv = round(vv(1)*100)/100;
set(gcbo,'Userdata',vv,'String',num2str(vv))
DesignFilter;
return


%%%
%%%  Sub-Function - order
%%%

function order()
v = get(gcbo,'Userdata');
s = get(gcbo,'String');
vv = eval(s,num2str(v));
if isempty(vv)  | ~isreal(vv) | vv(1)<5, 
   vv = v; 
   set(gcbo, 'String', num2str(v))
   return
end
vv = round((vv(1)-1)/2)*2+1;
set(gcbo,'Userdata',vv,'String',num2str(vv))
DesignFilter
return


%%%
%%%  Sub-Function - RadioUPDATE
%%%

function RadioUPDATE(s)
DemoFig = gcbf;
hdl=get(DemoFig,'Userdata');
set([hdl.Btn1 hdl.Btn2 hdl.Btn3 hdl.Btn4], 'value', 0);
switch s %  Enable selected button
case 1
   set(hdl.Btn1,'value',1)
   set(hdl.Window, 'Enable', 'off')
case 2
   set(hdl.Btn2,'value',1) 
   set(hdl.Window, 'Enable', 'on')
case 3
   set(hdl.Btn3,'value',1) 
   set(hdl.Window, 'Enable', 'on')
case 4
   set(hdl.Btn4,'value',1) 
   set(hdl.Window, 'Enable', 'off')
end
set(hdl.Btn1,'Userdata',s) 
DesignFilter(DemoFig);
return


%%%
%%%  Sub-Function - DesignFilter
%%%

function DesignFilter(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

setstatus(DemoFig, 'Designing Filter...');
set(gcf,'Pointer','watch');
hdl=get(DemoFig,'Userdata');

edgecolor = get(gca,'colororder'); edgecolor = edgecolor(1,:);

order = get(hdl.Order,'UserData'); % Filter order
cutoff = get(hdl.Cutoff,'UserData'); % Filter cutoff frequency

% Create desired frequency response
[f1,f2] = freqspace(order,'meshgrid');
d = find(f1.^2+f2.^2 < cutoff^2);
Hd = zeros(order);
Hd(d) = 1;
if get(hdl.FiltBand,'value')==2, Hd = 1-Hd; end % If highpass

method = get(hdl.Btn1,'Userdata');

% Get window if necessary
if method==2 | method==3, % Get window
   wind = get(hdl.Window,'value');
   windows = get(hdl.Window,'string');
   w = feval(lower(deblank(windows(wind,:))), order);
end

% Design filter
switch method
case 1,
   h = fsamp2(Hd);
case 2,
   h = fwind1(Hd,w);
case 3,
   h = fwind2(Hd,w*w');
case 4,
   F = [0 cutoff-0.05 cutoff+0.05 1];
   M = [1 1 0 0];
   if get(hdl.FiltBand,'value')==2, M = 1-M; end
   h = ftrans2(remez(order-1,F,M));
end

hmin = min(h(:)); hmax = max(h(:));
facecolor=get(hdl.Filter, 'color');

% Get rid of old surface if one exists
delete(findobj(get(hdl.Filter,'Children'),'type','surface'))

hndl = surface(h,'Parent',hdl.Filter,'FaceColor',facecolor,...
   'EdgeColor',edgecolor,'FaceLighting','none','EdgeLighting', 'flat');
set(hdl.Filter, 'view',[-37.5, 30]); 
set(hdl.Filter,'xlim',[1 order],'ylim',[1 order])
set(hdl.Filter,'zlim',[hmin-(.05*abs(hmin)) hmax*1.05])
set(hdl.Filter, 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on');
% set(get(hdl.Filter,'title'),'string','Filter coefficients')

% Compute frequency response
facecolor=get(hdl.Response, 'color');
[r,f1,f2] = freqz2(h,32,32);
rmin = min(r(:)); rmax = max(r(:));

% Get rid of old surface if one exists
delete(findobj(get(hdl.Response,'Children'),'type','surface'))

hndl = surface(f1,f2,r,'Parent',hdl.Response,'FaceColor',facecolor,...
   'EdgeColor',edgecolor,'FaceLighting','none','EdgeLighting', 'flat');
% set(get(hdl.Response,'title'),'string','Frequency Response')
set(hdl.Response, 'view',[-37.5, 30]); 
set(hdl.Response,'zlim',[rmin-(.05*abs(rmin)) rmax*1.05])
set(hdl.Response, 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on');
set(DemoFig,'Pointer','arrow')
% rotate3d on;

drawnow
setstatus(DemoFig, 'Press ''Apply Filter'' to filter the image.');
set(hdl.Apply, 'Enable', 'on')
return

   
%%%
%%%  Sub-Function - ApplyFilter
%%%

function ApplyFilter(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

setstatus(DemoFig, 'Filtering image...');
set(DemoFig,'Pointer','watch');
hdl=get(DemoFig,'Userdata');
I = getimage(hdl.OriginalImage);
h = get(findobj(hdl.Filter,'Type','surface'),'zdata');
J = mat2gray(filter2(h,I));
set(hdl.FilteredImage, 'Cdata', J);
set(DemoFig,'Pointer','arrow');
set(hdl.Apply, 'Enable', 'off')
drawnow
setstatus(DemoFig, '');
return


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
case 'Saturn'
   saturn = [];      % Make sure saturn is parsed as a variable
   load imdemos saturn
   img = saturn;
case 'Pout'
   pout = [];     
   load imdemos pout
   img = pout;
case 'Trees',
   trees = [];  
   load imdemos trees
   img = trees;
case 'Quarter',
   quarter = [];  
   load imdemos quarter
   img = quarter;
case 'Circuit',
   circuit = [];  
   load imdemos circuit
   img = circuit;
case 'Pepper',
   pepper = [];  
   load imdemos pepper
   img = pepper;
case 'Vertigo',
   vertigo = [];  
   load imdemos vertigo
   img = vertigo;
case 'Glass',
   glass = [];  
   load imdemos glass
   img = glass;
otherwise 
   error('FIRDEMO: Unknown Image Option!');
end

img = double(img)/255;
set(hdl.OriginalImage, 'Cdata', img);
set(get(hdl.OrigImageAxes,'title'),'string',['Original ' name ' Image']);
drawnow
set(DemoFig,'Pointer','arrow')
if callb
   ApplyFilter(DemoFig); 
end
drawnow
return;
