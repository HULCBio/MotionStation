function dctdemo(action,varargin);
%DCTDEMO 2-D DCT image compression demo.
%                                                                         
%   This demo lets you explore image compression using the 2-D
%   discrete cosine transform (DCT).  The original image is 
%   transformed in 8-by-8 blocks and then inverse transformed in 
%   8-by-8 blocks to create the reconstructed image.  The inverse 
%   DCT is performed using the subset of DCT coefficients that 
%   are shown in white.  The error image (the difference between
%   the original and reconstructed image) is also displayed.
%                                                                       
%   Use the slider to select a subset of the DCT coefficients and then 
%   press the "Apply" button to produce the corresponding reconstructed  
%   image.  The DCT coefficients with small variance are discarded   
%   first, as they have the least effect on the reconstruction. 
%   Try to find out how few coefficients are needed to create a
%   reasonable approximation to the original.                  
%
%   The Saturn image is courtesy of NASA.
%                                                      
%   See also DCT2, BLKPROC.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $  $Date: 2003/05/03 17:52:50 $

%   Callback Routines:
%   
%   InitializeDCTDEMO() sets up the demo.  It is run only once upon
%   the demo comes up.
%
%   ApplyDCT(DemoFig)  will call MakeDCT if it hasn't been called yet
%   and it will apply the DCT Matrix to the image and update the 
%   reconstructed image.   When ApplyDCT is called from the initialization
%   routine, it is called with an argument which is the figure handle of
%   the demo.   From a callback routine, it gets the figure handle with 
%   gcbf.
%
%   SliderUpdate() updates the mask which is applied to the DCT 
%   coefficients before reconstruction.  Update the surface which is
%   the DCT Coefficient display.
%   
%   MakeDCT()  will grab the current image and calculate its 
%   8x8 blocked DCT.  It puts it in the userdata of the 
%   original image.   This is not used as a callback.
%   
%   ShowInfo() will pull up helpwin with the info for the demo in it.


if nargin<1,
   action='InitializeDCTDEMO';
end;

feval(action,varargin{:});
return;



%%%
%%%  Sub-function - InitializeDCTDEMO
%%%

function InitializeDCTDEMO()

% If dctdemo is already running, bring it to the foreground.
h = findobj(allchild(0), 'tag', '2D DCT Image Compression Demo');
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
 
DctDemoFig=figure( ...
   'Name','2-D DCT Image Compression Demo', ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', '2D DCT Image Compression Demo', ...
   'Visible','off', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off',...
   'IntegerHandle', 'off', ...
   'Doublebuffer', 'on', ...
   'Colormap', gray(grayres));

%====================================
% Information for all buttons (and menus)
top=0.92;
left=0.785;
btnWid=0.175;
btnHt=0.06;

% Spacing between the button and the next command's label
spacing=0.025;

%====================================
% The CONSOLE frame
frmBorder=0.02; frmBottom=0.05; frmHeight = 0.46;
yPos=frmBottom-frmBorder;
frmPos=[left-frmBorder yPos btnWid+2*frmBorder frmHeight+2*frmBorder];
h=uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','frame', ...
   'Units','normalized', ...
   'Position',frmPos, ...
   'BackgroundColor',[0.45 0.45 0.45]);

%====================================
% The Apply button
labelStr='Apply';
callbackStr='dctdemo(''ApplyDCT'')';
yPos=frmBottom+frmHeight-btnHt-spacing;
applyHndl=uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[left yPos btnWid btnHt], ...
   'String',labelStr, ...
   'Enable', 'off', ...
   'Callback',callbackStr);

%====================================
% The Images Popup
yPos=frmBottom;
hImgPop=uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','popupmenu', ...
   'BackgroundColor',[.8 .8 .8], ...
   'Units','normalized', ...
   'Position',[left yPos+3*btnHt+2*spacing btnWid btnHt], ...
   'String','Saturn|Pepper|Pout|Trees|Quarter|Circuit', ...
   'Tag','ImagesPop', ...
   'Callback','dctdemo(''LoadNewImage'')');
%====================================
% The Images Label
h = uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','normalized', ...
   'Position',[left yPos+4*btnHt+2*spacing btnWid .035 ], ...
   'Horiz','center', ...
   'Background',[0.45 0.45 0.45], ...
   'Foreground','white', ...
   'String','Select Image:');



%====================================
% The Info button
labelStr='Info';
callbackStr='helpwin dctdemo';
yPos=frmBottom;
helpHndl=uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[left yPos+btnHt+2*spacing btnWid btnHt], ...
   'String',labelStr, ...
   'Enable', 'off', ...
   'Callback',callbackStr);

%====================================
% The CLOSE button
labelStr='Close';
callbackStr='close(gcf)';
yPos=frmBottom;
closeHndl=uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[left yPos btnWid btnHt], ...
   'Enable', 'off', ...
   'String',labelStr, ...
   'Callback',callbackStr);

%===================================
% Set up scroll bar
barHeight = 0.04; barWidth = btnWid+2*frmBorder;
sbBottom=top-barWidth-2*barHeight;
sbLeft = left-frmBorder;
textWidth = barWidth/2;
scrollPos = [sbLeft sbBottom barWidth barHeight];
callbackStr = 'dctdemo(''SliderUpdate'')';
hSlider = uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','slider', ...
   'Units','normalized', ...
   'Position',scrollPos, ...
   'Value',64, ...
   'min',1, ...
   'max',64, ...
   'Interruptible','off', ...
   'Callback',callbackStr);
% Left and right range indicators
c = get(DctDemoFig,'Color');
if [.298936021 .58704307445 .114020904255]*c'<.5,
   fgColor = [1 1 1];
else
   fgColor = [0 0 0];
end
rangePos = [sbLeft sbBottom-barHeight textWidth barHeight];
uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','normalized', ...
   'Position',rangePos, ...
   'Horiz','left', ...
   'Background',c, ...
   'Foreground',fgColor, ...
   'String','1');
rangePos = [sbLeft+barWidth/2 sbBottom-barHeight textWidth barHeight];
uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','normalized', ...
   'Position',rangePos, ...
   'Horiz','right', ...
   'Background',c, ...
   'Foreground',fgColor, ...
   'String','64');

%==================================
% Set up the 8-by-8 array
aPos = [sbLeft sbBottom+2*barHeight barWidth barWidth];
h8x8 = axes( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Units','normalized', ...
   'Position',aPos, ...
   'XTick',[],'YTick',[], ...
   'ydir','reverse', ...
   'Box','on', ...
   'xlim',[1 9], ...
   'ylim',[1 9], ...
   'clim',[0 1], ...
   'DataAspectRatio',[1 1 1]);
title('DCT coefficients');

rangePos = [sbLeft sbBottom-(2*barHeight) barWidth barHeight];
hNumCof = uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','normalized', ...
   'Position',rangePos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground',fgColor, ...
   'String','64 Coefficients Selected');


hSurf=surface(ones(9),'facecolor','flat','edgecolor',[1 1 1]/2);

%==================================
% Set up the image axes
figpos = get(DctDemoFig, 'position');
row = figpos(4); col = figpos(3);  % dimensions of figure window

vertSpac = (row-256)/3;
leftSide = col*0.25;
axHeight = (top-(frmBottom-frmBorder)-3*spacing)/2;
hTrueAx = axes('Parent', DctDemoFig, ...
   'units', 'pixels', ...
   'BusyAction','Queue','Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 1], ...
   'XTick',[],'YTick',[], ...
   'Position', [leftSide row-118-vertSpac 128 128]);

hNewAx = axes('Parent', DctDemoFig, ...
   'units', 'pixels', ...
   'BusyAction','Queue', 'Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 1], ...
   'XTick',[],'YTick',[], ...
   'Position', [leftSide-64-vertSpac/2 vertSpac+10 128 128]);
title('Reconstructed Image');

hErrAx = axes('Parent', DctDemoFig, ...
   'units', 'pixels', ...
   'BusyAction','Queue', 'Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [-0.8 0.8], ...
   'XTick',[],'YTick',[], ...
   'Position', [leftSide+64+vertSpac/2 vertSpac+10 128 128]);
title('Error Image');

blank = repmat(uint8(0),128,128);
hTrueImage = image('Parent', hTrueAx,...
   'CData', blank, ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'none');

hNewImage = image('Parent', hNewAx,...
   'CData', blank, ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'none');

hErrImage = image('Parent', hErrAx,...
   'CData', blank, ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'none');

% Status bar
% rangePos = [64 3 280 15];
rangePos = [0 .01 .75 .05];
hStatus = uicontrol( ...
   'Parent', DctDemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','normalized', ...
   'Position',rangePos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground',[.8 0 0], ...
   'Tag', 'Status', ...
   'String','Status bar');


set(DctDemoFig,'defaultaxesposition',[0.10 0.1 0.60 0.85])
setstatus(DctDemoFig, 'Initializing DCT Demo...');
set(DctDemoFig, 'Pointer', 'watch');
drawnow
set(DctDemoFig, 'Visible','on');

% Put handles to graphics objects and controls in the figure's userdata
handles.TrueImage = hTrueImage;
handles.NewImage = hNewImage; 
handles.ErrImage = hErrImage;
handles.h8x8 = h8x8;
handles.Slider = hSlider; 
handles.Surface = hSurf;
handles.ImgPop = hImgPop;
handles.TrueAx = hTrueAx;
handles.NewAx = hNewAx;
handles.ErrAx = hErrAx;
handles.NumCof = hNumCof;
set(DctDemoFig, 'UserData',handles);

LoadNewImage(DctDemoFig)  % Load the defaultImage

set(DctDemoFig, 'HandleVisibility','Callback')
set([helpHndl closeHndl applyHndl], 'Enable', 'on');
return


%%%
%%%  Sub-Function - LoadNewImage
%%%

function LoadNewImage(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

set(DemoFig,'Pointer','watch');
handles = get(DemoFig,'UserData');
hTrueImage=handles.TrueImage;
hTrueAx = handles.TrueAx;
hImgPop=handles.ImgPop;
v = get(hImgPop,{'value','String'});
name = deblank(v{2}(v{1},:));
setstatus(DemoFig, ['Loading the ' name ' image...']);
drawnow

switch name
case 'Saturn',
   saturn = [];  % Make sure saturn is parsed as a variable
   load imdemos saturn
   img = double(saturn)/255;
   set(handles.ErrAx, 'CLim', [-.45 .45]);
case 'Pout',
   pout = [];  % Make sure pout is parsed as a variable
   load imdemos pout
   img = double(pout)/255;
   set(handles.ErrAx, 'CLim', [-.33 .33]);
case 'Trees',
   trees = [];  % Make sure trees is parsed as a variable
   load imdemos trees
   img = double(trees)/255;
   set(handles.ErrAx, 'CLim', [-.72 .72]);
case 'Quarter',
   quarter = [];  % Make sure quarter is parsed as a variable
   load imdemos quarter
   img = double(quarter)/255;
   set(handles.ErrAx, 'CLim', [-.52 .52]);
case 'Circuit',
   circuit = [];  % Make sure circuit is parsed as a variable
   load imdemos circuit
   img = double(circuit)/255;
   set(handles.ErrAx, 'CLim', [-.32 .32]);
case 'Pepper',
   pepper = [];  % Make sure pepper is parsed as a variable
   load imdemos pepper
   img = double(pepper)/255;
   set(handles.ErrAx, 'CLim', [-.65 .65]);
otherwise 
   error('DCTDEMO: Unknown Image Option!');
end

set(hTrueImage, 'Cdata', img);
set(get(hTrueAx,'title'),'string',['Original ' name ' Image']);
blank = repmat(uint8(0),128,128);
set(handles.NewImage, 'Cdata', blank);
set(handles.ErrImage, 'Cdata', blank);
drawnow

MakeDCT(DemoFig);
SliderUpdate(DemoFig);
ApplyDCT(DemoFig);
return;


%%%
%%%  Sub-Function - ApplyDCT
%%%

function ApplyDCT(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

set(DemoFig,'Pointer','watch'); drawnow;
handles = get(DemoFig,'UserData');
hTrueImage=handles.TrueImage;
hNewImage=handles.NewImage;
hErrImage=handles.ErrImage;
h8x8=handles.h8x8;
hSlider=handles.Slider;
hSurf=handles.Surface;
hNewAx=handles.NewAx;

imageDCT = get(hTrueImage,'UserData');
if isempty(imageDCT),  % Create imageDCT and DCTvar if necessary
   MakeDCT(DemoFig);
   imageDCT = get(hTrueImage,'UserData');
end

setstatus(DemoFig, 'Reconstructing image...'); drawnow;
% Determine 8x8 image
mask = get(hSurf,'Cdata');

% Get 8-by-8 DCT matrix
dctm = dctmtx(8);

% Reconstruct and display image
%   newImage = blkproc(imageDCT,[8 8],'idct2(x.*P1)',mask(1:8,1:8));
newImage = blkproc(imageDCT,[8 8],'P1*(x.*P2)*P3',dctm.',mask(1:8,1:8),dctm);

set(hNewImage, 'CData', newImage);
drawnow;

trueImage = getimage(hTrueImage);

set(hErrImage, 'CData', trueImage-newImage); 
error = (trueImage.^2 - newImage.^2);
MSE = sum(error(:))/prod(size(trueImage));

if MSE < 1e-10,  MSE=0; end
msestr = sprintf('%0.3g',MSE);
setstatus(DemoFig, ['The MSE (with images normalized) is ' msestr ' .']);
set(DemoFig,'Pointer','arrow'); drawnow
return


%%%
%%%  Sub-function - SliderUpdate
%%%

function SliderUpdate(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

handles = get(DemoFig,'UserData');
hSlider=handles.Slider;
hSurf=handles.Surface;

axHndl=gca;
v = 64-floor(get(hSlider,'value'));
var = get(hSlider,'UserData');
DCTvar = var(1,:); order = var(2,:);
if v==63
   set(handles.NumCof, 'String', [int2str(64-v) ' Coefficient Selected']);
else
   set(handles.NumCof, 'String', [int2str(64-v) ' Coefficients Selected']);
end

% Determine 8x8 image and display
mask = ones(8,8); mask(order(1:v)) = zeros(1,v);
im8x8 = zeros(9,9); im8x8(1:8,1:8) = mask;
set(hSurf,'Cdata',im8x8);

% If we were called from LoadNewImage (nargin==1), we don't want to update the
% status bar since LoadNewImage will call ApplyDCT anyways.
if nargin==0   
   setstatus(DemoFig, 'Press ''Apply'' to reconstruct the image.');
end
return



%%%
%%%  Sub-Function - MakeDCT
%%%
%%%  This function is not used as a call back.  It is called 
%%%  only from LoadNewImage.

function MakeDCT(DemoFig)

setstatus(DemoFig, 'Computing DCT...');
handles = get(DemoFig,'UserData');
hTrueImage=handles.TrueImage;
hNewImage=handles.NewImage;
h8x8=handles.h8x8;
hSlider=handles.Slider;
hSurf=handles.Surface;

I = getimage(hTrueImage);

% Get 8-by-8 DCT matrix
dctm = dctmtx(8);

% Old call:  imageDCT = blkproc(I,[8 8],'dct2');
imageDCT = blkproc(I,[8 8],'P1*x*P2',dctm,dctm.');
DCTvar = im2col(imageDCT,[8 8],'distinct').';
n = size(DCTvar,1);
DCTvar = (sum(DCTvar.*DCTvar) - (sum(DCTvar)/n).^2)/n;
[dum,order] = sort(DCTvar);
set(hTrueImage,'UserData',imageDCT)
set(hSlider,'UserData',[DCTvar;order])
return

