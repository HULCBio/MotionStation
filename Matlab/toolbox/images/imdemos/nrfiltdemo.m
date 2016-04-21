function nrfiltdemo(action, varargin)
%NRFILTDEMO Noise reduction filtering demo.
%
%   This demo enables you to explore noise reduction in images using
%   linear and non-linear filtering techniques applied to several 
%   kinds of noise.
%   
%   The image on the left side of the figure window is the original
%   uncorrupted image.  Use the menu under the original image to 
%   select among a number of images.  
%
%   The center image is the original image with noise added.  Use the 
%   menu below the center image to select among three different types 
%   of noise.  Edit the fields below the menu to specify parameters 
%   for the noise.  Press "Add Noise" to apply the noise.  
%   
%   The image on the right shows the result of applying a noise removal
%   filter to the center image.  Use the menus under the third image to
%   select the type of noise removal filter and the size of the 
%   neighborhood.  Press "Apply Filter" to filter the corrupted image.
%
%   The Saturn and Lifting Body images are courtesy of NASA.
%
%   See also IMNOISE, MEDFILT2, ORDFILT2, WIENER2.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.15.4.5 $  $Date: 2003/05/03 17:53:55 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunctions & Callbacks:   
%
%   InitializeNRFILTDEMO - Performs initialization of uicontrols and HG 
%                         objects.  Calls LoadNewImage to load the first
%                         image and do the initial processing.
%
%   AddNoise -            Gets noise string from the Noise Type popup menu
%                         and calls imnoise to corrupt the original image,
%                         then it displays the corrupted image in middle 
%                         axes.
%   
%   ApplyFilter -         Get the filter type from the popup menu and 
%                         apply the appropriate filter (with the correct
%                         neighborhood size) to the corrupted image.  Then
%                         display the results in the Filtered Image axes.
% 
%   LoadNewImage -        Load a new image from a MAT file then display it.
%                         Calls AddNoise and ApplyFilter.
%
%   EditBoxUpdate -       This is a callback which updates values in the 
%                         userdata structure based on values in one of the
%                         edit boxes.   Its input argument specifies which
%                         edit box the update is occuring for.
%
%   AddNoiseOff_ApplyFilterOn - Disable the Add Noise button and enable the
%                               Apply Filter button.
% 
%   AddNoiseOn_ApplyFilterOff - Enable the Add Noise button and disable the
%                               Apply Filter button.
% 
%   UpdateNoiseType -     Updates the noise type in the userdata structure
%                         based upon the current value of the noise type 
%                         popup - this is the menu's callback.
% 
%   UpdateFilterType -    Updates the filter type in the userdata structure
%                         based upon the current value of the filter type 
%                         popup - this is the menu's callback.
% 
%   UpdateNeighborhoodSize - Updates the Neighborhood size in the userdata 
%                            structure based upon the current value of the   
%                            Neighborhood size popup - this is the menu's 
%                            callback.
%
%   BringUpGaussianControls - Enable edit boxes for Gaussian noise and
%                             disable other edit boxes.
%
%   BringUpSaltNPepperControls - Enable edit boxes for S & P noise and
%                                disable other edit boxes.
%
%   BringUpSpeckleControls - Enable edit boxes for Speckle noise and
%                            disable other edit boxes.

if nargin<1,
   action='InitializeNRFILTDEMO';
end;

feval(action,varargin{:})
return;

%%%
%%%  Sub-function - InitializeNRFILTDEMO
%%%

function InitializeNRFILTDEMO()

% If nrfiltdemo is already running, bring it to the foreground
h = findobj(allchild(0), 'tag', 'Noise Reduction Filtering Demo');
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


NrfiltDemoFig = figure( ...
   'Name','Noise Reduction Filtering Demo', ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', 'Noise Reduction Filtering Demo', ...
   'Visible','off', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off', ...
   'Color', [.8 .8 .8], ...
   'IntegerHandle', 'off', ...
   'DoubleBuffer', 'on', ...
   'Colormap', gray(grayres));

figpos = get(NrfiltDemoFig, 'position');
figpos(3:4) = [560 420];
% Adjust the size of the figure window
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
set(NrfiltDemoFig, 'position', figpos);

rows = figpos(4); cols = figpos(3);

% Colors
bgcolor = [0.45 0.45 0.45];  % Background color for frames
wdcolor = [.8 .8 .8];  % Window color
fgcolor = [1 1 1];  % For text

hs = (cols-(3*128)) / 4;        % Horizantal Spacing
vs = hs/2;                     % Vertical Spacing
ifs = hs/3;                     % Intraframe spacing


%====================================
% Parameters for all buttons and menus

Std.Interruptible = 'off';
Std.BusyAction = 'queue';

% Defaults for image axes
Ax = Std;
Ax.Units = 'Pixels';
Ax.Parent = NrfiltDemoFig;
Ax.ydir = 'reverse';
Ax.XLim = [.5 128.5];
Ax.YLim = [.5 128.5];
Ax.CLim = [0 1];
Ax.XTick = [];
Ax.YTick = [];

Img = Std;
Img.CData = [];
Img.Xdata = [1 128];
Img.Ydata = [1 128];
Img.CDataMapping = 'Scaled';
Img.Erasemode = 'none';

Ctl = Std;
Ctl.Units = 'Pixels';
Ctl.Parent = NrfiltDemoFig;

Btn = Ctl;
Btn.Style = 'pushbutton';
Btn.Enable = 'off';

Edit = Ctl;
Edit.Style = 'edit';
Edit.HorizontalAlignment = 'right';
Edit.BackgroundColor = 'white';
Edit.ForegroundColor = 'black';

Menu = Ctl;
Menu.Style = 'Popupmenu';

Text = Ctl;
Text.Style = 'text';
Text.HorizontalAlignment = 'left';
Text.BackgroundColor = bgcolor;
Text.ForegroundColor = fgcolor;

btnHt = 26;
txtHt = 18;
menuHt = 26;
editHt = 21;

%================================
% Original Image 
ud.hOriginalAxes = axes(Ax, ...
   'Position', [hs rows-vs*1.3-128 128 128]);
title('Original Image');
ud.hOriginalImage = image(Img, ...
   'Parent', ud.hOriginalAxes);

%================================
% Corrupted Image 
ud.hCorruptedAxes = axes(Ax, ...
   'Position', [2*hs+128 rows-vs*1.3-128 128 128]);
title('Corrupted Image');
ud.hCorruptedImage = image(Img, ...
   'Parent', ud.hCorruptedAxes);
ud.CorruptedImageIsStale = 1;

%================================
% Filtered Image 
ud.hFilteredAxes = axes(Ax, ...
   'Position', [3*hs+256 rows-vs*1.3-128 128 128]);
title('Filtered Image');
ud.hFilteredImage = image(Img, ...
   'Parent', ud.hFilteredAxes);

%=================================
%  The frame
fleft = ifs;
fbot = btnHt+3.2*ifs;
fwid = cols - 2*hs/3;
fht = rows-vs-hs/2-128-btnHt-3.2*ifs;
ud.hControlFrame = uicontrol(Std, ...
   'Parent', NrfiltDemoFig, ...
   'Style', 'Frame', ...
   'Units', 'pixels', ...
   'Position', [fleft fbot fwid fht], ...
   'BackgroundColor', bgcolor);

menuWid = (fwid-4*ifs)/3;
menuBot = fbot+fht-vs-menuHt;
labelBot = fbot+fht-22;    % For the labels above the three top menus
labelWid = menuWid/2;      % For the labels in front of edit boxes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The three menus at the top of the frame:
%%%

%================================
% Image popup menu
ipleft = fleft+ifs;
ud.hImgPop = uicontrol(Menu, ...
   'Position',[ipleft menuBot menuWid menuHt], ...
   'String','Pepper|Coins|Circuit|Rice|Pout|Saturn|Quarter|Glass|Lifting Body', ...
   'Callback','nrfiltdemo(''LoadNewImage'')');
% Text label for Image Menu Popup
uicontrol( Text, ...
   'Position',[ipleft labelBot menuWid txtHt], ...
   'String','Select an Image:');


%================================
% Add Noise menu:
anleft = fleft+2*ifs+menuWid;
ud.hAddNoisePop = uicontrol(Menu, ...
   'Position',[anleft menuBot menuWid menuHt], ...
   'String','Salt & Pepper|Gaussian|Speckle', ...
   'Callback','nrfiltdemo(''UpdateNoiseType'')');
% Text label for Image Menu Popup
uicontrol( Text, ...
   'Position',[anleft labelBot menuWid txtHt], ...
   'String','Image Noise Type:');

%================================
% Noise Removal menu:
nrleft = fleft+3*ifs+2*menuWid;
ud.hNoiseRemovalPop = uicontrol(Menu, ...
   'Position',[nrleft menuBot menuWid menuHt], ...
   'String','Median|Averaging|Adaptive', ...
   'Callback','nrfiltdemo(''UpdateFilterType'')');
% Text label for Image Menu Popup
uicontrol( Text, ...
   'Position',[nrleft labelBot menuWid txtHt], ...
   'String','Noise Removal Filter:');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The controls for the different types of noise
%%%

%=================================================
%  Mean and Variance edit boxes for Gaussian noise
ud.hGaussianMean = uicontrol(Edit, ...
   'Position',[anleft+labelWid menuBot-editHt-ifs menuWid-labelWid editHt], ...
   'String','0.0',...
   'callback','nrfiltdemo(''EditBoxUpdate'',''GaussianMean'')');
ud.hTxtGaussianMean = uicontrol( Text, ...
   'Position',[anleft menuBot-editHt-ifs labelWid txtHt], ...
   'String','Mean:');
ud.GaussianMean = 0.0;

ud.hGaussianVariance = uicontrol(Edit, ...
   'Position',[anleft+labelWid menuBot-2*editHt-2*ifs menuWid-labelWid editHt], ...
   'String','0.005',...
   'callback','nrfiltdemo(''EditBoxUpdate'',''GaussianVariance'')');
ud.hTxtGaussianVariance = uicontrol( Text, ...
   'Position',[anleft menuBot-2*editHt-2*ifs labelWid txtHt], ...
   'String','Variance:');
ud.GaussianVariance =0.005;

%=================================================
%  Noise Density for Salt & Pepper noise
ud.hSaltNPepperDensity = uicontrol(Edit, ...
   'Position',[anleft+labelWid menuBot-editHt-ifs menuWid-labelWid editHt], ...
   'String','0.1',...
   'callback','nrfiltdemo(''EditBoxUpdate'',''SaltNPepperDensity'')');
ud.hTxtSaltNPepperDensity = uicontrol( Text, ...
   'Position',[anleft menuBot-editHt-ifs labelWid txtHt], ...
   'String','Density:');
ud.SaltNPepperDensity = 0.1;

%=================================================
%  Noise Variance for Speckle noise
ud.hSpeckleVariance = uicontrol(Edit, ...
   'Position',[anleft+labelWid menuBot-editHt-ifs menuWid-labelWid editHt], ...
   'String','0.04',...
   'callback','nrfiltdemo(''EditBoxUpdate'',''SpeckleVariance'')');
ud.hTxtSpeckleVariance = uicontrol( Text, ...
   'Position',[anleft menuBot-editHt-ifs labelWid txtHt], ...
   'String','Variance:');
ud.SpeckleVariance = 0.04;

%==========================================
%  Add noise button
ud.hAddNoiseBtn = uicontrol(Btn, ...
   'Position',[anleft fbot+ifs menuWid btnHt], ...
   'String','Add Noise', ...
   'Callback','nrfiltdemo(''AddNoise'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The controls for the noise removal filters
%%%

%===================================================
%  Neighborhood selection for median filter

ud.hNeighborhoodPop = uicontrol(Menu, ...
   'Position',[nrleft menuBot-menuHt-ifs-txtHt menuWid menuHt], ...
   'String','3-by-3|5-by-5|7-by-7', ...
   'Callback','nrfiltdemo(''UpdateNeighborhoodSize'')');
% Text label for Image Menu Popup
uicontrol( Text, ...
   'Position',[nrleft menuBot-ifs-txtHt  menuWid txtHt], ...
   'String','Filtering Neighborhood:');

%==========================================
%  Apply Filter button
ud.hApplyFilterBtn = uicontrol(Btn, ...
   'Position',[nrleft fbot+ifs menuWid btnHt], ...
   'String','Apply Filter', ...
   'Callback','nrfiltdemo(''ApplyFilter'')');



%====================================
%  Frame for Info and Close
spac = ifs*2/3;
ficleft = cols/2;
ficbot = ifs;
ficht = btnHt+2*spac;
ficwid = cols/2-ifs;
ud.hInfoCloseFrame = uicontrol(Std, ...
   'Parent', NrfiltDemoFig, ...
   'Style', 'Frame', ...
   'Units', 'pixels', ...
   'Position', [ficleft ficbot ficwid ficht], ...
   'BackgroundColor', bgcolor);

%====================================
% Buttons - Info and Close
ud.hInfo=uicontrol(Btn, ...
   'Position',[ficleft+spac ficbot+spac (ficwid-3*spac)/2 btnHt], ...
   'String','Info', ...
   'Callback','helpwin nrfiltdemo');

ud.hClose=uicontrol(Btn, ...
   'Position',[ficleft+ficwid/2+spac/2 ficbot+spac (ficwid-3*spac)/2 btnHt], ...
   'String','Close', ...
   'Callback','close(gcbf)');



%====================================
% Status bar
ud.hStatus = uicontrol(Std, ...
   'Parent', NrfiltDemoFig, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[ifs ifs cols/2-2*ifs txtHt*2], ...
   'Foreground', [.8 0 0], ...
   'Background',wdcolor, ...
   'Horiz','center', ...
   'Tag', 'Status', ...
   'String','Initializing nrfiltdemo...');

set(NrfiltDemoFig, 'UserData', ud);
UpdateNoiseType(NrfiltDemoFig);
UpdateFilterType(NrfiltDemoFig);
UpdateNeighborhoodSize(NrfiltDemoFig);
set(NrfiltDemoFig, 'visible','on','HandleVisibility','callback');

LoadNewImage(NrfiltDemoFig)
set([ud.hAddNoiseBtn ud.hApplyFilterBtn ud.hInfo ud.hClose], 'Enable', 'on');
return




%%%
%%%  Sub-Function - AddNoise
%%%

function AddNoise(DemoFig)
% Add noise to the original image.   Optional input is Demo figure handle.

if nargin<1
   DemoFig = gcbf;
end
set(DemoFig,'Pointer','watch');
setstatus(DemoFig,'Adding noise to the original image...');
ud=get(DemoFig,'Userdata');
orig = getimage(ud.hOriginalImage);

switch ud.NoiseType
case 'Salt & Pepper'
   noisy = imnoise(orig, 'salt & pepper', ud.SaltNPepperDensity);
case 'Gaussian'
   noisy = imnoise(orig, 'gaussian', ud.GaussianMean, ud.GaussianVariance);
case 'Speckle'
   noisy = imnoise(orig, 'speckle', ud.SpeckleVariance);
end

set(ud.hCorruptedImage, 'Cdata', noisy);
AddNoiseOff_ApplyFilterOn(DemoFig);
set(DemoFig,'Pointer','arrow');
setstatus(DemoFig,'Press "Apply Filter" to denoise the corrupted image.');
ud.CorruptedImageIsStale = 0;
set(DemoFig, 'UserData', ud);

drawnow
return;



%%%
%%%  Sub-Function - ApplyFilter
%%%

function ApplyFilter(DemoFig)
% Apply noise removal filter to the corrupted image.   
% Optional input is Demo figure handle.

if nargin<1
   DemoFig = gcbf;
end
set(DemoFig,'Pointer','watch');
setstatus(DemoFig,'Applying noise removal filter to the corrupted image...');
ud=get(DemoFig,'Userdata');
noisy = getimage(ud.hCorruptedImage);
hood = ud.NeighborhoodSize;

switch ud.FilterType
case 'Median'
   filtered = medfilt2(noisy, [hood hood]);
case 'Averaging'
   myfilt = ones(hood)/(hood^2);   % Boxcar filter
   filtered = filter2(myfilt,noisy,'same');
case 'Adaptive'
   filtered = wiener2(noisy,[hood hood]);
end

set(ud.hFilteredImage, 'Cdata', filtered);

setstatus(DemoFig,'');
set(ud.hApplyFilterBtn, 'enable', 'off');
set(DemoFig,'Pointer','arrow');
drawnow
return;



%%%
%%%  Sub-Function - LoadNewImage
%%%

function LoadNewImage(DemoFig)
% Load a new image from a mat-file

if nargin<1
   DemoFig = gcbf;
end

set(DemoFig,'Pointer','watch');
ud=get(DemoFig,'Userdata');
v = get(ud.hImgPop,{'value','String'});
name = deblank(v{2}(v{1},:));
drawnow

switch name
case 'Coins'
   coins = [];          % Hint for the parser to avoid confusing it when load
   load imdemos coins % creates a new variable.
   img = coins;
case 'Saturn',
   saturn = [];
   load imdemos saturn
   img = saturn;
case 'Pout',
   pout = [];
   load imdemos pout
   img = pout;
case 'Quarter',
   quarter = [];
   load imdemos quarter
   img = quarter;
case 'Circuit',
   circuit = [];
   load imdemos circuit
   img = circuit;
case 'Lifting Body',
   liftbody128 = [];
   load imdemos liftbody128
   img = liftbody128;
case 'Pepper',
   pepper = [];
   load imdemos pepper
   img = pepper;
case 'Rice',
   rice = [];
   load imdemos rice
   img = rice;
case 'Glass',
   glass = [];
   load imdemos glass
   img = glass; 
otherwise 
   error('nrfiltdemo: Unknown Image Option!');
end

img = double(img)/255;
set(ud.hOriginalImage, 'Cdata', img);
set(ud.hAddNoiseBtn, 'Enable', 'on');
AddNoise(DemoFig);
ApplyFilter(DemoFig);
return;



%%%
%%%  Sub-Function - EditBoxUpdate
%%%

function EditBoxUpdate(whichBox)
% Update the values in the userdata structure from the string in the 
% whichBox edit box.   whichBox is the string which specifies which
% edit box the callback came from.

DemoFig = gcbf;
ud=get(DemoFig,'Userdata');
switch whichBox
case 'SpeckleVariance'
   str = get(ud.hSpeckleVariance, 'String');
   new = str2double(str);
   if isempty(new) | prod(size(new))>1 | new>1 | new<0 
      errordlg('The variance for Speckle noise should be a scalar in [0,1]');
   else
      ud.SpeckleVariance = real(new(1));
   end
   set(ud.hSpeckleVariance, 'String', num2str(ud.SpeckleVariance));
case 'SaltNPepperDensity'
   str = get(ud.hSaltNPepperDensity, 'String');
   new = str2double(str);
   if isempty(new) | prod(size(new))>1 | abs(new)>1 
      errordlg('The noise density for Salt & Pepper noise should be a scalar in [0,1]');
   else
      ud.SaltNPepperDensity = real(new(1));
   end
   set(ud.hSaltNPepperDensity, 'String', num2str(ud.SaltNPepperDensity));
case 'GaussianVariance'
   str = get(ud.hGaussianVariance, 'String');
   new = str2double(str);
   if isempty(new) | prod(size(new))>1  | new>1 | new<0 
      errordlg('The variance for Gaussian noise should be a scalar in [0,1]');
   else
      ud.GaussianVariance = real(new(1));
   end
   set(ud.hGaussianVariance, 'String', num2str(ud.GaussianVariance))
case 'GaussianMean'
   str = get(ud.hGaussianMean, 'String');
   new = str2double(str);
   if isempty(new) | prod(size(new))>1  | abs(new)>1 
      errordlg('The mean for Gaussian noise should be a scalar in [-1,1]');
   else
      ud.GaussianMean = real(new(1));
   end
   set(ud.hGaussianMean, 'String', num2str(ud.GaussianMean))
end
AddNoiseOn_ApplyFilterOff(DemoFig);
ud.CorruptedImageIsStale = 1;
setstatus('Press "Add Noise" to add noise to the original image.');
set(DemoFig,'Userdata',ud);


%%%
%%%  Sub-Function - AddNoiseOff_ApplyFilterOn
%%%

function AddNoiseOff_ApplyFilterOn(DemoFig)
% Enable Apply Filter button, disable the Add Noise button.

ud = get(DemoFig, 'UserData');
set(ud.hAddNoiseBtn, 'enable', 'off');
set(ud.hApplyFilterBtn, 'enable', 'on');


%%%
%%%  Sub-Function - AddNoiseOn_ApplyFilterOff
%%%

function AddNoiseOn_ApplyFilterOff(DemoFig)
% Disable Apply Filter button, enable the Add Noise button.

ud = get(DemoFig, 'UserData');
set(ud.hAddNoiseBtn, 'enable', 'on');
set(ud.hApplyFilterBtn, 'enable', 'off');
return

%%%
%%%  Sub-Function - UpdateNoiseType
%%%

function UpdateNoiseType(DemoFig)
% Update the noise type in the userdata structure based on the
% value of the noise popup.

if nargin<1
   DemoFig = gcbf;
end
set(DemoFig,'Pointer','watch');
ud=get(DemoFig,'Userdata');
v = get(ud.hAddNoisePop,{'value','String'});
noisetype = deblank(v{2}(v{1},:));
ud.NoiseType = noisetype;
drawnow

switch noisetype
case 'Salt & Pepper'
   BringUpSaltNPepperControls(DemoFig);
case 'Gaussian'
   BringUpGaussianControls(DemoFig);
case 'Speckle'
   BringUpSpeckleControls(DemoFig);
end
AddNoiseOn_ApplyFilterOff(DemoFig);
setstatus('Press "Add Noise" to add noise to the original image.');
ud.CorruptedImageIsStale = 1;
set(DemoFig,'Pointer','arrow','Userdata', ud);
return


%%%
%%%  Sub-Function - BringUpGaussianControls
%%%

function BringUpGaussianControls(DemoFig)

if nargin<1
   DemoFig = gcbf;
end
ud = get(DemoFig,'Userdata');
% Salt & Pepper
set([ud.hSaltNPepperDensity ud.hTxtSaltNPepperDensity], ...
   'Enable', 'off', 'visible', 'off');
%Speckle
set([ud.hSpeckleVariance ud.hTxtSpeckleVariance], ...
   'Enable', 'off', 'visible', 'off');
% Gaussian
set([ud.hGaussianMean ud.hTxtGaussianMean ud.hGaussianVariance ...
      ud.hTxtGaussianVariance], 'Enable', 'on', 'visible', 'on');
return


%%%
%%%  Sub-Function - BringUpSaltNPepperControls
%%%

function BringUpSaltNPepperControls(DemoFig)

if nargin<1
   DemoFig = gcbf;
end
ud = get(DemoFig,'Userdata');
% Gaussian
set([ud.hGaussianMean ud.hTxtGaussianMean ud.hGaussianVariance ...
      ud.hTxtGaussianVariance], 'Enable', 'off', 'visible', 'off');
%Speckle
set([ud.hSpeckleVariance ud.hTxtSpeckleVariance], ...
   'Enable', 'off', 'visible', 'off');
% Salt & Pepper
set([ud.hSaltNPepperDensity ud.hTxtSaltNPepperDensity], ...
   'Enable', 'on', 'visible', 'on');



%%%
%%%  Sub-Function - BringUpSpeckleControls
%%%

function BringUpSpeckleControls(DemoFig)

if nargin<1
   DemoFig = gcbf;
end
ud = get(DemoFig,'Userdata');
% Gaussian
set([ud.hGaussianMean ud.hTxtGaussianMean ud.hGaussianVariance ...
      ud.hTxtGaussianVariance], 'Enable', 'off', 'visible', 'off');
% Salt & Pepper
set([ud.hSaltNPepperDensity ud.hTxtSaltNPepperDensity], ...
   'Enable', 'off', 'visible', 'off');
%Speckle
set([ud.hSpeckleVariance ud.hTxtSpeckleVariance], ...
   'Enable', 'on', 'visible', 'on');



%%%
%%%  Sub-Function - UpdateFilterType
%%%

function UpdateFilterType(DemoFig)
% Update the filter type in the userdata structure based on the
% value of the filter type popup.

if nargin<1
   DemoFig = gcbf;
end
ud=get(DemoFig,'Userdata');
v = get(ud.hNoiseRemovalPop,{'value','String'});
ud.FilterType =  deblank(v{2}(v{1},:));
if ~ud.CorruptedImageIsStale
   set(ud.hApplyFilterBtn, 'Enable', 'on');   
   setstatus('Press "Apply Filter" to denoise the corrupted image.');
end
set(DemoFig, 'UserData', ud);



%%%
%%%  Sub-Function - UpdateNeighborhoodSize
%%%

function UpdateNeighborhoodSize(DemoFig)
% Update the nbhood size in the userdata structure based on the
% value of the Nieghborhood popup.

if nargin<1
   DemoFig = gcbf;
end
set(DemoFig,'Pointer','watch');
ud=get(DemoFig,'Userdata');
v = get(ud.hNeighborhoodPop,{'value','String'});
neighborhood = deblank(v{2}(v{1},:));
ud.NeighborhoodSize = str2double(neighborhood(1));
if ~ud.CorruptedImageIsStale
   set(ud.hApplyFilterBtn, 'Enable', 'on');   
   setstatus('Press "Apply Filter" to denoise the corrupted image.');
end
set(DemoFig, 'UserData', ud, 'Pointer', 'arrow');
