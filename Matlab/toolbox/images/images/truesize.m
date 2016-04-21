function truesize(varargin)
%TRUESIZE Adjust display size of image.
%   TRUESIZE(FIG,[MROWS NCOLS]) adjusts the display size of an
%   image. FIG is a figure containing a single image or a single 
%   image with a colorbar. [MROWS MCOLS] is a 1-by-2 vector that
%   specifies the requested screen area (in pixels) that the
%   image should occupy.
%
%   TRUESIZE(FIG) uses the image height and width for 
%   [MROWS MCOLS]. This results in the display having one screen
%   pixel for each image pixel.
%
%   If you omit the figure argument, TRUESIZE works on the
%   current figure.
%
%   Remarks
%   -------
%   If the 'TruesizeWarning' toolbox preference is 'on', TRUESIZE
%   displays a warning if the image is too large to fit on the
%   screen. (The entire image is still displayed, but at less
%   than true size.) If 'TruesizeWarning' is 'off', TRUESIZE does
%   not display the warning. Note that this preference applies
%   even when you call TRUESIZE indirectly, such as through
%   IMSHOW.
%
%   See also IMSHOW, IPTSETPREF, IPTGETPREF.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.25.4.5 $  $Date: 2003/08/23 05:54:45 $

[axHandle, imHandle, colorbarHandle, imSize, resizeType] = ...
        ParseInputs(varargin{:});

figHandle = get(axHandle, 'Parent');
if strcmp(get(figHandle, 'WindowStyle'), 'docked')
    wid = 'Images:truesize:dockedFigure';
    warning(wid, 'TRUESIZE cannot adjust the size of a docked figure.');
    return
end

switch resizeType
case 1
    % Figure contains one image and nothing else
    Resize1(axHandle, imHandle, imSize);
    
case 2
    % Figure contains other noncolorbar axes
    % or uicontrols.
    Resize2(axHandle, imHandle, imSize);
    
case 3
    % Figure contains one image and a colorbar.
    Resize3(axHandle, imHandle, imSize, colorbarHandle);
end

%--------------------------------------------
% Subfunction ParseInputs
%--------------------------------------------
function [axHandle,imHandle,colorbarHandle,imSize,resizeType] = ...
        ParseInputs(varargin)

imSize = [];
colorbarHandle = [];
msg = '';
axHandle = [];
imHandle = [];
resizeType = [];

if (nargin == 0)
    axHandle = gca;
end
    
if (nargin >= 1)
    if ((nargin == 1) && isequal(size(varargin{1}), [1 2]))
        % truesize([M N])
        figHandle = gcf;
        imSize = varargin{1};
        
    else
        % truesize(FIG, ...)
        if (~ishandle(varargin{1}) || ~strcmp(get(varargin{1},'type'), ...
                                              'figure'))
            msg = 'FIG must be a valid figure handle';
            eid = sprintf('Images:%s:figMustBeValid',mfilename);    
            error(eid,'%s',msg);
        else
            figHandle = varargin{1};
        end
    end
    
    axHandle = get(figHandle, 'CurrentAxes');
    if (isempty(axHandle))
        msg = 'Current figure has no axes';
        eid = sprintf('Images:%s:currentFigureMissingAxes',mfilename);    
        error(eid,'%s',msg);
    end
end

if (nargin >= 2)
    imSize = varargin{2};
    if (~isequal(size(imSize), [1 2]))
        msg = 'REQSIZE must be a 1-by-2 vector';
        eid = sprintf('Images:%s:reqsizeMustBe1by2',mfilename);    
        error(eid,'%s',msg);
    end
end

figHandle = get(axHandle, 'Parent');

% Find all the images and texturemapped surfaces
% in the current figure.  These are the candidates.
h = [findobj(figHandle, 'Type', 'image') ;
    findobj(figHandle, 'Type', 'surface', ...
            'FaceColor', 'texturemap')];

% If there's a colorbar, ignore it.
colorbarHandle = findobj(figHandle, 'type', 'image', ...
        'Tag', 'TMW_COLORBAR');
if (~isempty(colorbarHandle))
    for k = 1:length(colorbarHandle)
        h(h == colorbarHandle(k)) = [];
    end
end

if (isempty(h))
    msg = 'No images or texturemapped surfaces in the figure';
    eid = sprintf('Images:%s:noImagesOrSurfaces',mfilename);    
    error(eid,'%s',msg);
end

% Start with the first object on the list as the
% initial candidate.  If it's not in the current
% axes, look for another one that is.
imHandle = h(1);
if (get(imHandle,'Parent') ~= axHandle)
    for k = 2:length(h)
        if (get(h(k),'Parent') == axHandle)
            imHandle = h(k);
            break;
        end
    end
end

figKids = allchild(figHandle);
if ((length(findobj(figKids, 'flat', 'Type', 'axes')) == 1) && ...
            (isempty(findobj(figKids, 'flat', 'Type', 'uicontrol', ...
            'Visible', 'on'))) && ...
            (length(imHandle) == 1))
    % Resize type 1
    % Figure contains only one axes object, which contains only
    % one image.
    resizeType = 1;

elseif (isempty(colorbarHandle))
    % Figure contains other objects and not a colorbar.
    resizeType = 2;
    
else
    % Figure contains a colorbar.  Do we have a one image
    % one colorbar situation?
    if (length(colorbarHandle) > 1)
        % No
        resizeType = 2;
    else
        colorbarAxes = get(colorbarHandle, 'Parent');
        uimenuKids = findobj(figKids, 'flat', 'Type', 'uimenu');
        invisUicontrolKids = findobj(figKids, 'flat', 'Type', 'uicontrol', ...
                'Visible', 'off');
        otherKids = setdiff(figKids, ...
                [uimenuKids ; colorbarAxes ; axHandle ; invisUicontrolKids]);
        if (length(otherKids) > 1)
            % No
            resizeType = 2;
        else
            % Yes, one image and one colorbar
            resizeType = 3;
        end
    end
end


%--------------------------------------------
% Subfunction Resize1
%--------------------------------------------
function Resize1(axHandle, imHandle, imSize)
% Resize figure containing a single axes
% object with a single image.

if (isempty(imSize))
    % How big is the image?
    imageWidth = size(get(imHandle, 'CData'), 2);
    imageHeight = size(get(imHandle, 'CData'), 1);
else
    imageWidth = imSize(2);
    imageHeight = imSize(1);
end

if (imageWidth * imageHeight == 0)
    % Don't try to handle the degenerate case.
    return;
end

axUnits = get(axHandle, 'Units');
set(axHandle, 'Units', 'pixels');
axPos = get(axHandle, 'Position');

figHandle = get(axHandle, 'Parent');
figUnits = get(figHandle, 'Units');
rootUnits = get(0, 'Units');
set(figHandle, 'Units', 'pixels');
set(0, 'Units', 'pixels');

figLeftBorder = 10;  % assume left figure decorations are 10 pixels
figRightBorder = 10;
figBottomBorder = 10;
figTopBorder = 100;

minFigWidth = 128; % don't try to display a figure smaller than this.
minFigHeight = 128;

% What are the gutter sizes?
figPos = get(figHandle, 'Position');
gutterLeft = max(axPos(1) - 1, 0);

% What are the screen dimensions
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);
if ((screenWidth <= 1) || (screenHeight <= 1))
    screenWidth = Inf;
    screenHeight = Inf;
end

scale = 100;
done = 0;
defAxesPos = get(0,'DefaultAxesPosition');
nonzeroGutters = (gutterLeft > 0);
while (~done)
    if (nonzeroGutters)
        gutterWidth = round((1 - defAxesPos(3)) * imageWidth / defAxesPos(3));
        gutterHeight = round((1 - defAxesPos(4)) * imageHeight / defAxesPos(4));
        newFigWidth = imageWidth + gutterWidth;
        newFigHeight = imageHeight + gutterHeight;
    else
        newFigWidth = imageWidth;
        newFigHeight = imageHeight;
    end
    if (((newFigWidth + figLeftBorder + figRightBorder) > screenWidth) || ...
                ((newFigHeight + figBottomBorder + figTopBorder) > screenHeight))
        scale = 3 * scale / 4;
        imageWidth = round(imageWidth * scale / 100);
        imageHeight = round(imageHeight * scale / 100);
    else
        done = 1;
    end
end

newFigWidth = max(newFigWidth, minFigWidth);
newFigHeight = max(newFigHeight, minFigHeight);

figPos(1) = max(1, figPos(1) - floor((newFigWidth - figPos(3))/2));
figPos(2) = max(1, figPos(2) - floor((newFigHeight - figPos(4))/2));
figPos(3) = newFigWidth;
figPos(4) = newFigHeight;

% Translate figure position if necessary
deltaX = (screenSize(3) - figRightBorder) - (figPos(1) + figPos(3));
if (deltaX < 0)
    figPos(1) = figPos(1) + deltaX;
end
deltaY = (screenSize(4) - figTopBorder) - (figPos(2) + figPos(4));
if (deltaY < 0)
    figPos(2) = figPos(2) + deltaY;
end

% Figure out where to place the axes object in the
% resized figure.  Make sure axes width and height are at least 1.
gutterWidth = figPos(3) - imageWidth;
gutterHeight = figPos(4) - imageHeight;
gutterLeft = floor(gutterWidth/2);
gutterBottom = floor(gutterHeight/2);

axPos(1) = gutterLeft + 1;
axPos(2) = gutterBottom + 1;
axPos(3) = max(imageWidth,1);
axPos(4) = max(imageHeight,1);

set(figHandle, 'Position', figPos)
set(axHandle, 'Position', axPos);

% Restore the units
drawnow;  % necessary to work around HG bug   -SLE
set(figHandle, 'Units', figUnits);
set(axHandle, 'Units', axUnits);
set(0, 'Units', rootUnits);

% Set the nextplot property of the figure so that the
% axes object gets deleted and replaced for the next plot.
% That way, the new plot gets drawn in the default position.
set(figHandle, 'NextPlot', 'replacechildren');

% Warn if the display is not truesize, unless warning is disabled
% according to toolbox preference setting.
if ((scale < 100) && strcmp(iptgetpref('TruesizeWarning'), 'on'))
    wid = sprintf('Images:%s:imageTooBigForScreen',mfilename);
    message = ['Image is too big to fit on screen; ', ...
                sprintf('displaying at %d%% scale.', floor(scale))];
    warning(wid,'%s',message);
end

%--------------------------------------------
% Subfunction Resize2
%--------------------------------------------
% Resize figure containing multiple axes or
% other objects.  Basically we're going to
% compute a global figure scaling factor
% that will bring the target image into
% truesize mode.  This works reasonably well
% for subplot-type figures as long as all
% the images have the same size.  This is
% basically the guts of truesize.m from IPT
% version 1.
function Resize2(axHandle, imHandle, imSize)

if (isempty(imSize))
    imSize = size(get(imHandle, 'CData'));
end

if (prod(imSize) == 0)
    % Don't try to handle the degenerate case.
    return;
end

axUnits = get(axHandle, 'Units');
set(axHandle, 'Units', 'pixels');
axPosition = get(axHandle, 'Position');
% Do we need to do anything?
if norm(axPosition(3:4) - imSize([2 1])) < sqrt(eps)
    set(axHandle, 'Units', axUnits)
    return;
end

figHandle = get(axHandle, 'Parent');
figUnits = get(figHandle, 'Units');
rootUnits = get(0,'Units');
set(axHandle, 'Units', 'normalized');
axPosition = get(axHandle, 'Position');
set([figHandle 0], 'Units', 'pixels');
figPosition = get(figHandle, 'Position');
screenSize = get(0,'ScreenSize');

% What should the new figure size be?
dx = ceil(imSize(2)/axPosition(3) - figPosition(3));
dy = ceil(imSize(1)/axPosition(4) - figPosition(4));
newFigWidth = figPosition(3) + dx;
newFigHeight = figPosition(4) + dy;

% Is the new figure size too big or too small?
figLeftBorder = 10;
figRightBorder = 10;
figBottomBorder = 10;
figTopBorder = 100;
minFigWidth = 128;
minFigHeight = 128;

if ((newFigWidth + figLeftBorder + figRightBorder) > screenSize(3))
    scaleX = (screenSize(3) - figLeftBorder - figRightBorder) / newFigWidth;
else
    scaleX = 1;
end

if ((newFigHeight + figBottomBorder + figTopBorder) > screenSize(4))
    scaleY = (screenSize(4) - figBottomBorder - figTopBorder) / newFigHeight;
else
    scaleY = 1;
end

if (newFigWidth < minFigWidth)
    scaleX = minFigWidth / newFigWidth;
end
if (newFigHeight < minFigHeight)
    scaleY = minFigHeight / newFigHeight;
end

if (min(scaleX, scaleY) < 1)
    % Yes, the new figure is too big for the screen.
    scale = min(scaleX, scaleY);
    newFigWidth = floor(newFigWidth * scale);
    newFigHeight = floor(newFigHeight * scale);
elseif (max(scaleX, scaleY) > 1)
    % Yes, the new figure is too small.
    scale = max(scaleX, scaleY);
    newFigWidth = floor(newFigWidth * scale);
    newFigHeight = floor(newFigHeight * scale);
else
    scale = 1;
end

figPosition(3) = newFigWidth;
figPosition(4) = newFigHeight;

% Translate figure position if necessary
deltaX = (screenSize(3) - figRightBorder) - (figPosition(1) + figPosition(3));
if (deltaX < 0)
    figPosition(1) = figPosition(1) + deltaX;
end
deltaY = (screenSize(4) - figTopBorder) - (figPosition(2) + figPosition(4));
if (deltaY < 0)
    figPosition(2) = figPosition(2) + deltaY;
end

% Change axes position to get exactly one pixel per image pixel.
% That is, as long as scale = 1.
dx = scale*imSize(2)/figPosition(3) - axPosition(3);
dy = scale*imSize(1)/figPosition(4) - axPosition(4);
axPosition = axPosition + [-dx/2 -dy/2 dx dy];
axPosition(3:4) = max(axPosition(3:4),eps);

% OK, make the changes
set(axHandle, 'Position', axPosition);
set(figHandle, 'Position', figPosition);

% Restore the original units
set(axHandle, 'Units', axUnits);
set(figHandle, 'Units', figUnits);
set(0, 'Units', rootUnits);

% Warn if the display is not truesize, unless the truesize warning
% has been disabled according to a toolbox preference setting.
if (strcmp(iptgetpref('TruesizeWarning'), 'on'))
    if (scale < 1)
        wid = sprintf('Images:%s:imageTooBigForScreen',mfilename);
        message = ['Image is too big to fit on screen; ', ...
                    sprintf('displaying at %d%% scale.', round(100*scale))];
        warning(wid,'%s',message);
    elseif (scale > 1)
        wid = sprintf('Images:%s:imageTooSmallToScale',mfilename);        
        message = ['Image is too small for truesize figure scaling; ', ...
                    sprintf('\ndisplaying at %d%% scale.', round(100*scale))];
        warning(wid,'%s',message);
    end
end

%--------------------------------------------
% Subfunction Resize3
%--------------------------------------------
function Resize3(axHandle, imHandle, imSize, colorbarHandle)
% Resize figure containing an image, a colorbar, 
% and nothing else.

if (isempty(imSize))
    % How big is the image?
    imageWidth = size(get(imHandle, 'CData'), 2);
    imageHeight = size(get(imHandle, 'CData'), 1);
else
    imageWidth = imSize(2);
    imageHeight = imSize(1);
end

if (imageWidth * imageHeight == 0)
    % Don't try to handle the degenerate case.
    return;
end

axUnits = get(axHandle, 'Units');
set(axHandle, 'Units', 'pixels');
axPos = get(axHandle, 'Position');

figLeftBorder = 10;  % assume left figure decorations are 10 pixels
figRightBorder = 10;
figBottomBorder = 10;
figTopBorder = 100;

minFigWidth = 128; % don't try to display a figure smaller than this.
minFigHeight = 128;

colorbarGap = 30;   % pixels
colorbarWidth = 20; % pixels

caxHandle = get(colorbarHandle, 'Parent');
figHandle = get(axHandle, 'Parent');
figUnits = get(figHandle, 'Units');
caxUnits = get(caxHandle, 'Units');
rootUnits = get(0, 'Units');
set(figHandle, 'Units', 'pixels');
set(0, 'Units', 'pixels');
set(caxHandle, 'Units', 'pixels');

caxPos = get(caxHandle, 'Position');
figPos = get(figHandle, 'Position');

if ((axPos(1) + axPos(3)) < caxPos(1))
    orientation = 'vertical';
else
    orientation = 'horizontal';
end

% Use MATLAB's default gutters
defFigPos = get(0,'FactoryFigurePosition');
defAxPos = get(0,'FactoryAxesPosition');
gutterLeft = round(defAxPos(1) * defFigPos(3));
gutterRight = round((1 - defAxPos(1) - defAxPos(3)) * defFigPos(3));
gutterBottom = round(defAxPos(2) * defFigPos(4));
gutterTop = round((1 - defAxPos(2) - defAxPos(4)) * defFigPos(4));

% What are the screen dimensions
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);
if ((screenWidth <= 1) || (screenHeight <= 1))
    screenWidth = Inf;
    screenHeight = Inf;
end

scale = 100;
done = 0;
while (~done)
    if (strcmp(orientation, 'vertical'))
        newFigWidth = imageWidth + gutterLeft + gutterRight + ...
                colorbarGap + colorbarWidth;
        newFigHeight = imageHeight + gutterBottom + gutterTop;
    else
        newFigWidth = imageWidth + gutterLeft + gutterRight;
        newFigHeight = imageHeight + gutterBottom + gutterTop + ...
                colorbarGap + colorbarWidth;
    end
    if (((newFigWidth + figLeftBorder + figRightBorder) > screenWidth) || ...
                ((newFigHeight + figBottomBorder + figTopBorder) > ...
                screenHeight))
        scale = 3 * scale / 4;
        imageWidth = round(imageWidth * scale / 100);
        imageHeight = round(imageHeight * scale / 100);
    else
        done = 1;
    end
end
        
newFigWidth = max(newFigWidth, minFigWidth);
newFigHeight = max(newFigHeight, minFigHeight);
figPos(3) = newFigWidth;
figPos(4) = newFigHeight;

% Translate figure position if necessary
deltaX = (screenSize(3) - figRightBorder) - (figPos(1) + figPos(3));
if (deltaX < 0)
    figPos(1) = figPos(1) + deltaX;
end
deltaY = (screenSize(4) - figTopBorder) - (figPos(2) + figPos(4));
if (deltaY < 0)
    figPos(2) = figPos(2) + deltaY;
end

axPos = [gutterLeft gutterBottom max(imageWidth,1) max(imageHeight,1)];

if (strcmp(orientation, 'vertical'))
    left = gutterLeft + imageWidth + colorbarGap;
    bottom = gutterBottom;
    width = colorbarWidth;
    height = imageHeight;
else
    left = gutterLeft;
    bottom = gutterBottom;
    width = imageWidth;
    height = colorbarWidth;
    axPos(2) = axPos(2) + colorbarGap + colorbarWidth;
end
caxPos = [left bottom width height];

set(figHandle, 'Position', figPos);
set(axHandle, 'Position', axPos);
set(caxHandle, 'Position', caxPos);

% Restore the units
drawnow;  % necessary to work around HG bug      -SLE
set(figHandle, 'Units', figUnits);
set(axHandle, 'Units', axUnits);
set(caxHandle, 'Units', caxUnits);
set(0, 'Units', rootUnits);

% Set the nextplot property of the figure so that the
% axes object gets deleted and replaced for the next plot.
% That way, the new plot gets drawn in the default position.
set(figHandle, 'NextPlot', 'replacechildren');

% Warn if the display is not truesize, unless the truesize warning
% has been disabled according to a toolbox preference setting.
if ((scale < 100) && strcmp(iptgetpref('TruesizeWarning'), 'on'))
    wid = sprintf('Images:%s:imageTooBigForScreen',mfilename);
    message = ['Image is too big to fit on screen; ', ...
                sprintf('displaying at %d%% scale.', floor(scale))];
    warning(wid,'%s',message);
end
