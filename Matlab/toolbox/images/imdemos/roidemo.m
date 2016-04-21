function ud = roidemo(action, varargin)
%ROIDEMO Region-of-interest processing demo.
%
%   This demo illustrates the use of region-of-interest (ROI)
%   operations for processing selected portions of images.
%
%   Select an image from the menu on the left.  Move the pointer
%   over the image on the left; notice that the cursor changes to
%   a crosshair.  Click on points in the image to select vertices
%   of the region of interest. Select the final point with a
%   double-click, shift-click, or right-click. (You can also end
%   the selection without adding a vertex by pressing <enter> or
%   <return> on the keyboard.)  When you complete your selection,
%   the region will be displayed in the center as a binary image.  
%
%   Select the operation to perform from the "Region of Interest
%   Operations" menu on the right, and press the "Apply" button.
%   The original image is filtered using the binary image as a
%   mask; the operation is applied only to the portion of the
%   original image which corresponds to the white area of the
%   mask.
%   
%   When you select a new image, you may notice that the ROI
%   operation has changed also.  The images all have appropriate
%   default operations associated with them, but you can
%   experiment with different operations for each image.  
%
%   For example, the image called "Lifting Body and Noise" is an image of a
%   lifting body in tow corrupted with salt & pepper noise.  The default
%   operation is "Median Filter", because median filtering is especially
%   effective at removing this type of noise.
%
%   Another example is the "Coins" image, whose default operation
%   is "Unsharp masking".  This operation sharpens fine details within an
%   arbitrary region. Try selecting a polygon that entirely
%   surrounds one of the coins; this will effectively increase the contrast
%   of that coin.
%
%   The Saturn and Lifting Body images are courtesy of NASA.
%
%   See also ROIPOLY, ROIFILT2, ROIFILL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.17.4.5 $  $Date: 2003/05/03 17:59:53 $

%   Function Subroutines:
%
%   InitializeROIDEMO - Set up controls and Images.
%
%   LoadNewImage  -  Load a new image from a mat-file and call
%                    ApplyOperation to do the ROI operation on it.
%
%   ApplyOperation - Look at the popup to see what operation we 
%                    are doing and then do it to the original image
%                    only in the Region-of-Interest specified by 
%                    the mask.
%
%   MyGetline -      A pirated version of Getline for this demo only.
%                    This version stores information in the figure's
%                    userdata structure instead of in global variables.
%                    This routine stores the first point and then sets
%                    the button down function and motion function for
%                    the remainder of the ROI selection process.
% 
%   ButtonDown -     Button down function for adding new vertices of
%                    the polygonal ROI mask.
%   
%   ButtonMotion -   Motion function for animating the polygon selection.
%                     
%   KeyPress -       What to do in case of a Key press on the keyboard
%                    during the ROI selection process.
%
%   CompleteGetline - Completes selection of ROI and returns the Figure
%                    window more or less to the state in which it was
%                    before MyGetline was called.   Resets the button
%                    down function, motion function, and key press fcn. It 
%                    also calculates the mask using roipoly and displays it.
%
%   UpdateOperation - Updates the ROI operation from the current value of
%                     the operation popup menu.
% 
%   NormalMotionFcn - This is the default motion function of the figure 
%                    window, it sets the pointer to an arrow when not over
%                    the original image and sets it to a cross-hair when it
%                    IS over the original image.


if nargin<1,
   action='InitializeROIDEMO';
   if nargout>0  % If user wants the UserData, give it to them. 
      ud = feval(action,varargin{:});
      return
   end
end

feval(action,varargin{:})
return

%%%
%%%  Sub-function - InitializeROIDEMO
%%%

function udout = InitializeROIDEMO()

% If roidemo is already running, bring it to the foreground
h = findobj(allchild(0), 'tag', 'Region-of-Interest Processing Demo');
if ~isempty(h)
   figure(h(1))
   if nargout>0
      udout = get(h(1), 'UserData');
   end
   return
end

screenD = get(0, 'ScreenDepth');
if screenD>8
   grayres=256;
else
   grayres=128;
end


RoiDemoFig = figure( ...
   'Name','Region-of-Interest Processing Demo', ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', 'Region-of-Interest Processing Demo', ...
   'Visible','off', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off', ...
   'Color', [.8 .8 .8], 'IntegerHandle', 'off', ......
   'WindowButtonMotionFcn', 'roidemo(''NormalMotionFcn'');', ...
   'DoubleBuffer', 'on', 'Colormap', gray(grayres));

ud.FigureHandle = RoiDemoFig;

figpos = get(RoiDemoFig, 'position');
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
set(RoiDemoFig, 'position', figpos);

rows = figpos(4); cols = figpos(3);

% Colors
bgcolor = [0.45 0.45 0.45];  % Background color for frames
wdcolor = [.8 .8 .8];  % Window color
fgcolor = [1 1 1];  % For text

hs = (cols-(3*128)) / 4;        % Horizantal Spacing
vs = hs/2;                      % Vertical Spacing
ifs = hs/4;                     % Intraframe spacing


%====================================
% Parameters for all buttons and menus

Std.Interruptible = 'off';
Std.BusyAction = 'queue';

% Defaults for image axes
Ax = Std;
Ax.Units = 'Pixels';
Ax.Parent = RoiDemoFig;
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
Ctl.Parent = RoiDemoFig;

Frame = Ctl;
Frame.Style = 'Frame';

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

imageBot = rows-hs-128-editHt;
%================================
% Original Image 
ud.h.OriginalAxes = axes(Ax, ...
   'Position', [hs imageBot 128 128]);
% title('Original Image');
ud.h.OriginalImage = image(Img, ...
   'Parent', ud.h.OriginalAxes, ...
   'ButtonDownFcn', 'roidemo(''MyGetline'')');

%================================
% Mask Image 
ud.h.MaskAxes = axes(Ax, ...
   'Position', [2*hs+128 imageBot 128 128]);
title('Region of Interest');
ud.h.MaskImage = image(Img, ...
   'Parent', ud.h.MaskAxes);
def_x =  [ 9  124   96    9];
def_y =  [ 108  3  126  108];
ud.DefaultMask = roipoly(128, 128, def_x, def_y);
set(ud.h.MaskImage, 'CData', ud.DefaultMask);

%================================
% Output Image 
ud.h.OutputAxes = axes(Ax, ...
   'Position', [3*hs+256 imageBot 128 128]);
title('Output Image');
ud.h.OutputImage = image(Img, ...
   'Parent', ud.h.OutputAxes);

%=================================
%  The frame
fleft = ifs;
fbot = vs*1.5;
fwid = cols - 2*hs/3;
fht = imageBot-vs-fbot;
ud.h.ControlFrame = uicontrol(Frame, ...
   'Position', [fleft fbot fwid fht], ...
   'BackgroundColor', bgcolor);

menuWid = (fwid)/3;
menuBot = fbot+fht-vs-menuHt;
labelBot = fbot+fht-22;    % For the labels above the three top menus
labelWid = menuWid/2;      % For the labels in front of edit boxes
btnWid = 128;

%================================
% Image popup menu
ipleft = fleft+ifs;
ipbot = imageBot+128+vs*.5;
ud.h.ImgPop = uicontrol(Menu, ...
   'Position',[ipleft ipbot (fwid-4*ifs)/3 menuHt], ...
   'String',['Moon|Pepper|Coins|Circuit|Rice|Pout' ...
      '|Trees|Saturn|Quarter|Glass|Lifting Body and Noise'], ...
   'Callback','roidemo(''LoadNewImage'')');
% Text label for Image Menu Popup
uicontrol( Text, ...
   'Position',[ipleft ipbot+menuHt menuWid txtHt], ...
   'Background', wdcolor, ...
   'Foreground', 'black', ...
   'String','Select an Image:');

%================================
% Operations Menu:
opleft = fleft+fwid-menuWid-ifs;
ud.h.OperationsPop = uicontrol(Menu, ...
   'Position',[opleft menuBot menuWid menuHt], ...
   'String',...
   {  'Unsharp Masking', ...
      'Histogram Equalization', ...
      'Lowpass Filter', ...
      'Median Filter', ...
      'Brighten', 'Darken', ...
      'Increase Contrast', ...
      'Decrease Contrast', ...
      'Boundary Interpolation', ...
      'Add Gaussian Noise' }, ...
   'Callback','roidemo(''UpdateOperation'')');
% Text label for Image Menu Popup
uicontrol( Text, ...
   'Position',[opleft labelBot menuWid txtHt], ...
   'String','Region of Interest Operations:');

%====================================
% Buttons - Apply, Info and Close
ud.h.Close=uicontrol(Btn, ...
   'Position',[opleft fbot+ifs menuWid btnHt], ...
   'String','Close', ...
   'Callback','close(gcbf)');

ud.h.Info=uicontrol(Btn, ...
   'Position',[opleft fbot+2*ifs+btnHt menuWid btnHt], ...
   'String','Info', ...
   'Callback','helpwin roidemo');

ud.h.Apply=uicontrol(Btn, ...
   'Position',[opleft fbot+3*ifs+2*btnHt menuWid btnHt], ...
   'String','Apply', ...
   'Callback','roidemo(''ApplyOperation'')');


%====================================
% Frame for the text
ftleft = ipleft;
ftbot = fbot+ifs;
ftwid = 256;
ftht = fht - 2*ifs;
ud.h.TextFrame = uicontrol(Frame, ...
   'Position', [ftleft ftbot ftwid ftht], ...
   'BackgroundColor', [.9 .9 .9]);
ud.h.ExplanatoryText = uicontrol( Text, ...
   'Position',[ftleft+8 ftbot+8 ftwid-16 ftht-16], ...
   'BackgroundColor', [.9 .9 .9], ...
   'ForegroundColor', [0 0 0], ...
   'HorizontalAlignment', 'Left', ...
   'String',...
   [  'Specify a region of interest by clicking on the ' ...
      'image on the left to select vertices of a polygon.  ' ... 
      'Each click adds another vertex.  Shift-click (or Right-click) to ' ...
      'select the final vertex and display the region.']);

%====================================
% Status bar
ud.h.Status = uicontrol( Text, ...
   'Background', wdcolor, ...
   'Foreground', [.8 0 0], ...
   'Position',[0 2 cols txtHt], ...
   'Horiz','center', ...
   'Tag', 'Status', ...
   'String','Initializing ROIDEMO...');

ud.GetlineX = [];
ud.GetlineY = [];

set(RoiDemoFig, 'Userdata', ud);
set(RoiDemoFig, 'visible','on','HandleVisibility','callback');
LoadNewImage(RoiDemoFig);
ApplyOperation(RoiDemoFig);
set([ud.h.Info ud.h.Close ud.h.Apply], 'Enable', 'on');
if nargout>0
   udout = ud;
end
return




%%%
%%%  Sub-Function - MyGetline
%%%

function MyGetline
% Pirated from the Image Processing Toolbox function getline.m,
% this version is specific to this demo.  First button down function.

DemoFig = gcbf;
ud = get(DemoFig, 'UserData');
   
pt = get(gca, 'CurrentPoint');
startingPoint = pt(1,1:2);
ud.GetlineX = [pt(1,1) pt(1,1)];
ud.GetlineY = [pt(1,2) pt(1,2)];

set(DemoFig, 'Pointer', 'crosshair'); 
set(DemoFig, 'WindowButtonDownFcn', 'roidemo(''ButtonDown'');');
set(DemoFig, 'KeyPressFcn', 'roidemo(''KeyPress'');');

% Initialize the lines to be used for the drag
ud.GetlineH1 = line('XData', ud.GetlineX, ...
   'YData', ud.GetlineY, ...
   'Clipping', 'on', ...
   'Color', 'k', ...
   'LineStyle', '-', ...
   'EraseMode', 'xor');

ud.GetlineH2 = line('XData', ud.GetlineX, ...
   'YData', ud.GetlineY, ...
   'Clipping', 'on', ...
   'Color', 'w', ...
   'LineStyle', '--', ...
   'EraseMode', 'xor');

set(DemoFig, 'UserData', ud);
if ~strcmp(get(DemoFig, 'SelectionType'), 'normal')
   % We're done!
   CompleteGetline(DemoFig);
else
   % Let the motion functions take over:
   set(DemoFig, 'WindowButtonMotionFcn', 'roidemo(''ButtonMotion'');', ...
      'WindowButtonDownFcn', 'roidemo(''ButtonDown'');');
   % And so that we don't start MyGetline again:
   set(ud.h.OriginalImage, 'ButtonDownFcn', ''); 
end



%%%
%%%  Sub-Function - ButtonDown
%%%

function ButtonDown
DemoFig = gcbf;
ud = get(DemoFig, 'UserData');

selectionType = get(DemoFig, 'SelectionType');
if ~strcmp(selectionType, 'open')
   % We don't want to add a point on the second click
   % of a double-click
   
   pt2 = get(ud.h.OriginalAxes, 'CurrentPoint');
   if ~isempty(ud.GetlineX)
      ud.GetlineX = [ud.GetlineX(1:end-1) pt2(1,1) ud.GetlineX(end)];
      ud.GetlineY = [ud.GetlineY(1:end-1) pt2(1,2) ud.GetlineY(end)];
   else
      ud.GetlineX = pt2(1,1);
      ud.GetlineY = pt2(1,2);
   end
   
   set([ud.GetlineH1 ud.GetlineH2], 'XData', ud.GetlineX, ...
      'YData', ud.GetlineY);
   
end
set(DemoFig, 'UserData', ud);

if (~strcmp(get(DemoFig, 'SelectionType'), 'normal'))
   % We're done!
   CompleteGetline(DemoFig);
end



%%%
%%%  Sub-Function - ButtonMotion
%%%

function ButtonMotion
DemoFig = gcbf;
ud = get(DemoFig, 'UserData');

pt2 = get(ud.h.OriginalAxes, 'CurrentPoint');
if length(ud.GetlineX) >= 3
   x = [ud.GetlineX(1:end-1) pt2(1,1) ud.GetlineX(end)];
   y = [ud.GetlineY(1:end-1) pt2(1,2) ud.GetlineY(end)];
else
   x = [ud.GetlineX pt2(1,1)];
   y = [ud.GetlineY pt2(1,2)];
end

set([ud.GetlineH1 ud.GetlineH2], 'XData', x, 'YData', y);



%%%
%%%  Sub-Function - KeyPress
%%%

function KeyPress
DemoFig = gcbf;
ud = get(DemoFig, 'UserData');

key = real(get(DemoFig, 'CurrentCharacter'));

if isempty(key), % switch statement was triggering error in Unix, the 
   return;       % "Shift" key was causing the variable key to be []
end 

switch key
case {8, 127}  % delete and backspace keys
   % remove the previously selected point
   switch length(ud.GetlineX)
   case 0
      % nothing to do
   case 1
      ud.GetlineX = [];
      ud.GetlineY = [];
      % remove point and start over
      set([ud.GetlineH1 ud.GetlineH2], ...
         'XData', ud.GetlineX, ...
         'YData', ud.GetlineY);
      set(ud.h.OriginalImage, 'ButtonDownFcn', ...
         'roidemo(''MyGetline'');');
      set(DemoFig, 'WindowButtonMotionFcn', 'roidemo(''NormalMotionFcn'');',...
         'WindowButtonDownFcn', '');
      
   otherwise
      % remove last point
      ud.GetlineX(end-1) = [];
      ud.GetlineY(end-1) = [];
      set([ud.GetlineH1 ud.GetlineH2], ...
         'XData', ud.GetlineX, ...
         'YData', ud.GetlineY);
   end
    
case {13, 3}   % enter and return keys
   % We're done
   CompleteGetline(DemoFig);
end

set(DemoFig, 'UserData', ud);



%%%
%%%  Sub-Function - CompleteGetline
%%%

function CompleteGetline(DemoFig)

ud = get(DemoFig, 'UserData');

% Get the rect info and call roipoly to create the mask
mask = roipoly(128,128,ud.GetlineX,ud.GetlineY);
set(ud.h.MaskImage,'Cdata', mask);
set(ud.h.Apply, 'Enable', 'on');

% Clean up after getline and prepare it for the next MyGetline Callback
set(DemoFig, 'Pointer', 'arrow');
ud.GetlineX = [];
ud.GetlineY = [];

% Delete the animation objects
if (ishandle(ud.GetlineH1))
    delete(ud.GetlineH1);
end
if (ishandle(ud.GetlineH2))
    delete(ud.GetlineH2);
end

% Reset the Figure's Motion and Button Down functions and Key Press Fcn
set(DemoFig, 'WindowButtonMotionFcn', 'roidemo(''NormalMotionFcn'');', ...
   'WindowButtonDownFcn', '', 'UserData', ud, 'KeyPressFcn', '');

% Reset the ButtonDownFunction of the Image
set(ud.h.OriginalImage, 'ButtonDownFcn', 'roidemo(''MyGetline'')'); 
setstatus(DemoFig, 'Press "Apply" to perform the operation on the region of interest.');



%%%
%%%  Sub-Function - UpdateOperation
%%%

function UpdateOperation(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

ud = get(DemoFig, 'UserData');
opval = get(ud.h.OperationsPop, 'value');
opstr = get(ud.h.OperationsPop, 'string');
ud.Operation = opstr{opval};
set(DemoFig, 'UserData', ud);
set(ud.h.Apply, 'Enable', 'on');
setstatus(DemoFig, 'Press "Apply" to perform the operation on the region of interest.');

%%%
%%%  Sub-Function - ApplyOperation
%%%

function ApplyOperation(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

setptr(DemoFig, 'watch');
ud = get(DemoFig, 'UserData');
orig = get(ud.h.OriginalImage, 'Cdata');
mask = logical(get(ud.h.MaskImage, 'Cdata'));
result = orig;
setstatus(DemoFig, ['Applying ' lower(ud.Operation) ' operation...']);

switch ud.Operation
case 'Histogram Equalization'
   J = histeq(orig(mask));
   result(mask) = J;
  
case 'Lowpass Filter'
   order = 15;
   cutoff = 0.3;
   [f1,f2] = freqspace(order,'meshgrid');
   d = find(f1.^2+f2.^2 < cutoff^2);
   Hd = zeros(order);
   Hd(d) = 1;
   % Use hanning(15) as the window.  The window coefficients
   % are inlined to remove dependency on the Signal Processing
   % Toolbox.
   h = fwind1(Hd, ...
           [0.0381 0.1464 0.3087 0.5000 0.6913 0.8536 ...
            0.9619 1.0000 0.9619 0.8536 0.6913 0.5000 ...
            0.3087 0.1464 0.0381]);
   result = roifilt2(h, orig, mask);
   
case 'Unsharp Masking'
   h = fspecial('unsharp');
   result = roifilt2(h, orig, mask);
   
case 'Median Filter'
   med_orig = medfilt2(orig,[5 5]);
   result(mask) = med_orig(mask);
   
case 'Brighten'
   bright_orig = imadjust(orig, [], [.25 1]);
   result(mask) = bright_orig(mask);
   
case 'Darken'
   dark_orig = imadjust(orig, [], [0 .75]);
   result(mask) = dark_orig(mask);
   
case 'Increase Contrast'
   ic_orig = imadjust(orig, [.25 .75], []);
   result(mask) = ic_orig(mask);
   
case 'Decrease Contrast'
   dc_orig = imadjust(orig, [], [.25 .75]);
   result(mask) = dc_orig(mask);
   
case 'Boundary Interpolation'
   result = roifill(orig, mask);
   
case 'Add Gaussian Noise' 
   noisy_orig = imnoise(orig, 'Gaussian', 0, .01);
   result(mask) = noisy_orig(mask);

otherwise 
   warning('Invalid ROIDEMO operation');
   result = repmat(uint8(0),128,128);
end

set(ud.h.OutputImage, 'Cdata', result);
set(ud.h.Apply, 'Enable', 'off');
setstatus(DemoFig, '');
setptr(DemoFig, 'arrow');
return

%%%
%%%  Sub-Function - LoadNewImage
%%%

function LoadNewImage(DemoFig)

callb = 0;
if nargin<1
   DemoFig = gcbf;
   callb = 1;   % We are in a callback
end

set(DemoFig,'Pointer','watch');
ud=get(DemoFig,'Userdata');
v = get(ud.h.ImgPop,{'value','String'});
name = deblank(v{2}(v{1},:));
drawnow

switch name
case 'Coins'
   coins = [];
   load imdemos coins
   img = coins;
   set(ud.h.OperationsPop, 'Value', 1);
case 'Saturn',
   saturn = [];
   load imdemos saturn
   img = saturn;
   set(ud.h.OperationsPop, 'Value', 1);
case 'Pout',
   pout = [];
   load imdemos pout
   img = pout;
   set(ud.h.OperationsPop, 'Value', 2);
case 'Quarter',
   quarter = [];
   load imdemos quarter
   img = quarter;
   set(ud.h.OperationsPop, 'Value', 1);
case 'Circuit',
   circuit = [];
   load imdemos circuit
   img = circuit;
   set(ud.h.OperationsPop, 'Value', 1);
case 'Lifting Body and Noise',
   liftbody128 = [];
   load imdemos liftbody128
   img = imnoise(liftbody128,'Salt & Pepper', .05);
   set(ud.h.OperationsPop, 'Value', 4);
case 'Trees',
   trees = [];
   load imdemos trees
   img = trees;
   set(ud.h.OperationsPop, 'Value', 10);
case 'Pepper',
   pepper = [];
   load imdemos pepper
   img = pepper;
   set(ud.h.OperationsPop, 'Value', 7);
case 'Rice',
   rice = [];
   load imdemos rice
   img = rice;
   set(ud.h.OperationsPop, 'Value', 3);
case 'Moon',
   moon = [];
   load imdemos moon
   img = moon;
   set(ud.h.OperationsPop, 'Value', 1);
case 'Glass',
   glass = [];
   load imdemos glass
   img = glass; 
   set(ud.h.OperationsPop, 'Value', 5);
otherwise 
   error('roidemo: Unknown Image Option!');
end

UpdateOperation(DemoFig);
img = double(img)/255;
set(ud.h.OriginalImage, 'Cdata', img);
if callb
   set(ud.h.Apply, 'Enable', 'on');
end
set(DemoFig, 'Pointer', 'arrow');
setstatus(DemoFig, 'Press "Apply" to perform the operation on the region of interest.');



%%%
%%%  Sub-Function - NormalMotionFcn
%%%

function NormalMotionFcn
% Set the cursor to a Cross-Hair when above the Original image, and back
% to an arrow when not.
% This is the normal motion function for the window when we are not in
% a MyGetline selection state.

DemoFig = gcbf;
ud = get(DemoFig, 'Userdata');
pos = get(ud.h.OriginalAxes, 'Position');

pt = get(DemoFig, 'CurrentPoint');
x = pt(1,1);
y = pt(1,2);

if (x>pos(1) & x<pos(1)+pos(3) & y>pos(2) & y<pos(2)+pos(4))
   set(DemoFig, 'Pointer', 'cross');
else
   set(DemoFig, 'Pointer', 'arrow');
end
