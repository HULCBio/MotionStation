function varargout = qtdemo(varargin)
%QTDEMO Quadtree decomposition demo.
%   
%   Quadtree decomposition is an operation that subdivides an
%   image into blocks that contain "similar" pixels. Usually the
%   blocks are square, although sometimes they may be
%   rectangular.  For the purpose of this demo, pixels in a block
%   are said to be "similar" if the range of pixel values in the
%   block are not greater than some threshold.  Quadtree
%   decomposition is used in variety of image analysis and
%   compression applications. 
%
%   In the demo window, try adjusting the threshold value for
%   different images.  A large threshold value results in fewer,
%   larger blocks, and the "Block means" image doesn't look very
%   much like the original.  A small threshold value results in
%   more, smaller blocks, and the "Block means" image looks more
%   like the original. 
%
%   The function QTDECOMP works by successive refinement of
%   blocks.  For example, suppose the input image is 128-by-128.
%   QTDECOMP starts with a single 128-by-128 block.  If the
%   pixels in the block are not similar, QTDECOMP subdivides the
%   block into four 64-by-64 blocks. QTDECOMP then subdivides the
%   nonsimilar 64-by-64 block into 4 32-by-32 blocks, and so on.
%
%   To see the successive refinement in action, check the
%   "Animated computation" box in the demo window, and then press
%   "Apply".
%
%   QTDECOMP returns the quadtree decomposition as a sparse
%   matrix S, which is shown in the lower left of the demo
%   window.  Each nonzero element in S corresponds to the
%   upper-left corner of a block.  The value of the nonzero
%   element is the block size.  This representation lends itself
%   to further analysis.  For example, the following line shows
%   how to determine the locations of all 8-by-8 blocks in the
%   quadtree decomposition:
%
%        [i,j] = find(S == 8);
%
%   QTDECOMP has other options that are not shown in the demo.
%   For example, you can specify maximum and minimum block sizes,
%   and you can supply your own block similarity function.  The
%   functions QTSETBLK and QTGETBLK are used to set and get image
%   pixel values within blocks of a specified size.
%
%   The Lifting Body image is courtesy of NASA.
%
%   See also QTDECOMP, QTSETBLK, QTGETBLK.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.21.4.4 $  $Date: 2003/05/03 17:59:51 $

% Syntaxes
%    qtdemo                Start demo or bring it forward
%    h = qtdemo            Return demo figure handle (useful for debugging)

% Public functions
%    qtdemo('Slider')      Threshold slider callback
%    qtdemo('Apply')       Apply button callback
%    qtdemo('Edit')        Threshold edit-text callback
%    qtdemo('Animate')     Animated computation checkbox callback
%    qtdemo('NewImage')    Image selection popup callback

% Private functions:
%    Initialize            Create figure and HG objects
%    PositionControls      Layout the controls on the figure
%    DemoFigHandle         Find the demo figure
%    ShowBusy              Disable controls and set watch pointer during
%                               computation
%    ShowReady             Enable controls and set arrow pointer after
%                               computation finishes
%    Status                Set the status string
%    SplitTest             Block splitting criterion for qt decomposition
%    ComputeBlocks         Compute blocks image given S
%    ComputeMeans          Compute means image given I and S
%    SetThreshold          Set initial threshold when input image changes


if (nargin >= 1)
    switch varargin{1}
    case 'Slider'
        Slider;

    case 'Apply'
        Apply;
        
    case 'Edit'
        Edit;
        
    case 'Animate'
        Animate;
        
    case 'NewImage'
        NewImage;
    end
else
    % Initialize
    fig = DemoFigHandle;
    if (isempty(DemoFigHandle))
        % QTDEMO does not already exist; create it
        fig = Initialize;
        PositionControls(fig);
        set(fig, 'Visible', 'on');
        drawnow;
        NewImage;
    else
        figure(fig);
    end
    if (nargout > 0)
        varargout{1} = fig;
    end
end

%%%
%%% Subfunction Initialize
%%%
function figHandle = Initialize

% Define colors
figColor = [0.8 0.8 0.8];
textColor = [0 0 0];
statusColor = [0 0 .8];
frameColor = [.45 .45 .45];
frameLabelColor = [1 1 1];

figHandle = figure('Tag','QTdemoFig', ...
        'Visible', 'off', ...
        'HandleVisibility', 'callback', ...
        'Resize', 'off', ...
        'Colormap', gray(128), ...
        'Units', 'pixels', ...
        'IntegerHandle', 'off', ...
        'NumberTitle', 'off', ...
        'Name', 'Quadtree Decomposition Demo', ...
        'Pointer', 'watch', ...
        'DoubleBuffer', 'on', ...
        'Color', figColor);

% status bar
uicontrol('Style', 'text',...
        'Tag', 'StatusText',...
        'Parent', figHandle, ...
        'BackgroundColor', figColor, ...
        'ForegroundColor', statusColor, ...
        'HorizontalAlignment', 'center', ...
        'Units', 'pixels');

% sparse axes
h = axes('Tag', 'SparseAxes', ...
        'Parent', figHandle, ...
        'Color', 'k', ...
        'XLim', [0.5 128.5], ...
        'YLim', [0.5 128.5], ...
        'XTickLabel', [], ...
        'YTickLabel', [], ...
        'YDir', 'reverse', ...
        'Units', 'pixels');

% sparse line
line('Tag', 'SparseLine', ...
        'Parent', h, ...
        'XData', [], ...
        'YData', [], ...
        'LineStyle', 'none', ...
        'Marker', '.', ...
        'MarkerSize', 1, ...
        'Color', 'c');

% sparse label
uicontrol('Tag', 'SparseLabel', ...
        'Parent', figHandle, ...
        'Style', 'text', ...
        'String', 'Sparse representation', ...
        'BackgroundColor', figColor, ...
        'ForegroundColor', textColor, ...
        'HorizontalAlignment', 'center', ...
        'Units', 'pixels');

% original image axes
h = axes('Tag', 'OriginalAxes', ...
        'Parent', figHandle, ...
        'CLim', [0 255], ...
        'Visible', 'off', ...
        'YDir', 'reverse', ...
        'XLim', [0.5 128.5], ...
        'YLim', [0.5 128.5], ...
        'Units', 'pixels');

% original image
image('Tag', 'OriginalImage', ...
        'Parent', h, ...
        'CData', uint8(zeros(128,128)), ...
        'EraseMode', 'none', ...
        'CDataMapping', 'scaled');

% original image popup
% UserData tracks the value setting and is used to see if the
% selected image really changes.  We set it to 0 here for
% initialization purposes.
uicontrol('Tag', 'OriginalPopup', ...
        'Parent', figHandle, ...
        'Style', 'popupmenu', ...
        'String', {'Lifting Body' 'Tree' 'Rice' 'Tire' 'Circuit'}, ...
        'Callback', 'qtdemo(''NewImage'')', ...
        'UserData', 0, ...
        'Enable', 'off', ...
        'Units', 'pixels');

% original image popup label
uicontrol('Tag', 'OriginalLabel', ...
        'Parent', figHandle, ...
        'Style', 'text', ...
        'String', 'Select an image:', ...
        'BackgroundColor', figColor, ...
        'ForegroundColor', textColor, ...
        'Units', 'pixels');

% means axes
h = axes('Tag', 'MeansAxes', ...
        'Parent', figHandle, ...
        'CLim', [0 255], ...
        'Visible', 'off', ...
        'YDir', 'reverse', ...
        'XLim', [.5 128.5], ...
        'YLim', [.5 128.5], ...
        'Units', 'pixels');

% means axes label
uicontrol('Tag', 'MeansLabel', ...
        'Parent', figHandle, ...
        'Style', 'text', ...
        'String', 'Block means', ...
        'BackgroundColor', figColor, ...
        'ForegroundColor', textColor, ...
        'HorizontalAlignment', 'center', ...
        'Units', 'pixels');

% means image
image('Tag', 'MeansImage', ...
        'Parent', h, ...
        'CData', uint8(zeros(128,128)), ...
        'EraseMode', 'none', ...
        'CDataMapping', 'scaled');

% blocks axes
h = axes('Tag', 'BlocksAxes', ...
        'Parent', figHandle, ...
        'CLim', [0 1], ...
        'Visible', 'off', ...
        'YDir', 'reverse', ...
        'XLim', [.5 128.5], ...
        'YLim', [.5 128.5], ...
        'Units', 'pixels');

% blocks axes label
uicontrol('Tag', 'BlocksLabel', ...
        'Parent', figHandle, ...
        'Style', 'text', ...
        'String', 'Quadtree decomposition', ...
        'BackgroundColor', figColor, ...
        'ForegroundColor', textColor, ...
        'HorizontalAlignment', 'center', ...
        'Units', 'pixels');

% blocks image
image('Tag', 'BlocksImage', ...
        'Parent', h, ...
        'CData', uint8(zeros(128,128)), ...
        'EraseMode', 'none', ...
        'CDataMapping', 'scaled');

% control frame
uicontrol('Tag', 'ControlFrame', ...
        'Parent', figHandle, ...
        'Style', 'frame', ...
        'BackgroundColor', frameColor, ...
        'Units', 'pixels');

% Info button
uicontrol('Tag', 'InfoButton', ...
        'Parent', figHandle, ...
        'Style', 'pushbutton', ...
        'String', 'Info', ...
        'Callback', 'helpwin(''qtdemo'')', ...
        'Enable', 'off', ...
        'Units', 'pixels');

% Close button
uicontrol('Tag', 'CloseButton', ...
        'Parent', figHandle, ...
        'Style', 'pushbutton', ...
        'String', 'Close', ...
        'Callback', 'delete(gcbf)', ...
        'Enable', 'off', ...
        'Units', 'pixels');

% Animation checkbox
uicontrol('Tag', 'AnimationCheckbox', ...
        'Parent', figHandle, ...
        'Style', 'checkbox', ...
        'String', 'Animated computation', ...
        'Value', 0, ...
        'Enable', 'off', ...
        'BackgroundColor', frameColor, ...
        'ForegroundColor', frameLabelColor, ...
        'Callback', 'qtdemo(''Animate'')', ...
        'Units', 'pixels');

% Apply button
uicontrol('Tag', 'ApplyButton', ...
        'Parent', figHandle, ...
        'Style', 'pushbutton', ...
        'String', 'Apply', ...
        'Callback', 'qtdemo(''Apply'')', ...
        'Enable', 'off', ...
        'Units', 'pixels');

% Threshold slider
uicontrol('Tag', 'ThresholdSlider', ...
        'Parent', figHandle, ...
        'Style', 'slider', ...
        'Min', 0, ...
        'Max', 1, ...
        'Callback', 'qtdemo(''Slider'')', ...
        'Enable', 'off', ...
        'SliderStep', [.01 0.1], ...
        'Units', 'pixels');

% Threshold label
uicontrol('Tag', 'ThresholdLabel', ...
        'Parent', figHandle, ...
        'Style', 'text', ...
        'BackgroundColor', frameColor, ...
        'ForegroundColor', frameLabelColor, ...
        'String', 'Threshold (0-1):', ...
        'Units', 'pixels');

% Threshold edit
uicontrol('Tag', 'ThresholdEdit', ...
        'Parent', figHandle, ...
        'Style', 'edit', ...
        'BackgroundColor', 'w', ...
        'ForegroundColor', 'k', ...
        'Enable', 'off', ...
        'Callback', 'qtdemo(''Edit'')', ...
        'Units', 'pixels');
        

%%%
%%% Subfunction DemoFigHandle
%%%
function figHandle = DemoFigHandle

figHandle = findobj(allchild(0), 'Tag', 'QTdemoFig');


%%%
%%% Subfunction PositionControls
%%%
function PositionControls(fig)

  geom = imuigeom; %imuigeom is a private function to set location of gui elements
  
  gutter = 20;  % pixels
  imageWidth = 128;
  imageHeight = 128;
  labelGap = 5;  % pixels between axes and its label
  
  % Determine desired height of status bar
  statusHandle = findobj(fig, 'Tag', 'StatusText');
  set(statusHandle, 'String', 'This is the status bar');
  extent = get(statusHandle, 'extent');
  set(statusHandle, 'String', '');
  statusPos = [1 1 0 extent(4)+geom.text(4)];  % width will be set later
  
  % Determine size of left-column axes labels
  sparseLabelHandle = findobj(fig, 'Tag', 'SparseLabel');
  extent = get(sparseLabelHandle, 'Extent');
  extent = extent + geom.text;
  if (extent(3) > imageWidth)
    % Label overhangs axes
    left = gutter + floor((extent(3) - imageWidth)/2);
  else
    left = gutter;
  end
  
  %
  % Determine position of left-column objects
  %
  
  % Determine position of sparse axes
  sparseAxesHandle = findobj(fig, 'Tag', 'SparseAxes');
  sparseAxesPos = [left statusPos(2)+statusPos(4)+gutter ...
                   imageWidth imageHeight];
  
  % Determine position of sparse axes label
  labelLeft = left + floor((imageWidth - extent(3))/2);
  sparseLabelPos = [labelLeft sparseAxesPos(2)+sparseAxesPos(4)+labelGap ...
                    extent(3:4)];
  
  % Determine position of original image axes
  originalAxesHandle = findobj(fig, 'Tag', 'OriginalAxes');
  originalAxesPos = [left sparseLabelPos(2)+sparseLabelPos(4)+gutter ...
                     imageWidth imageHeight];

  % Determine position of original image popup
  originalPopupHandle = findobj(fig, 'Tag', 'OriginalPopup');
  set(originalPopupHandle, 'Value', 1);
  extent = get(originalPopupHandle, 'Extent');
  for k = 2:length(get(originalPopupHandle, 'String'))
    set(originalPopupHandle, 'Value', k);
    extent = max(extent, get(originalPopupHandle, 'Extent'));
  end
  set(originalPopupHandle, 'Value', 1);
  extent = extent + geom.popupmenu;
  originalPopupPos = [left originalAxesPos(2)+originalAxesPos(4)+labelGap ...
                      extent(3:4)];
  
  % Determine position of original image label
  originalLabelHandle = findobj(fig, 'Tag', 'OriginalLabel');
  extent = get(originalLabelHandle, 'Extent');
  extent = extent + geom.text;
  originalLabelPos = [left originalPopupPos(2)+originalPopupPos(4)+1 ...
                      extent(3:4)];
  
  % Popup should be at least as wide as the label
  originalPopupPos(3) = max(originalPopupPos(3), originalLabelPos(3));
  
  % Where is the right edge of the first column?
  column1Right = max([sparseAxesPos(1) + sparseAxesPos(3), ...
                      sparseLabelPos(1) + sparseLabelPos(3), ...
                      originalPopupPos(1) + originalPopupPos(3)]);
  
  % Determine size of means axes label
  meansLabelHandle = findobj(fig, 'Tag', 'MeansLabel');
  extent = get(meansLabelHandle, 'Extent');
  extent = extent + geom.text;
  meansLabelPos = [0 sparseLabelPos(2) extent(3:4)];
  
  % Determine size of blocks label
  blocksLabelHandle = findobj(fig, 'Tag', 'BlocksLabel');
  extent = get(blocksLabelHandle, 'Extent');
  extent = extent + geom.text;
  blocksLabelPos = [left originalPopupPos(2) extent(3:4)];
  
  % Determine left edge of 2nd column of axes
  labelWidth = max(meansLabelPos(3), blocksLabelPos(3));
  if (labelWidth > imageWidth)
    % One or both labels overhang axes edges
    left = column1Right + gutter + floor((labelWidth - imageWidth)/2);
  else
    left = column1Right + gutter;
  end
  
  % Determine position of means axes
  meansAxesHandle = findobj(fig, 'Tag', 'MeansAxes');
  meansAxesPos = [left sparseAxesPos(2) imageWidth imageHeight];
  
  % Determine position of blocks axes
  blocksAxesHandle = findobj(fig, 'Tag', 'BlocksAxes');
  blocksAxesPos = [left originalAxesPos(2) imageWidth imageHeight];
  
  % Determine position of means label
  labelLeft = left + floor((imageWidth - meansLabelPos(3))/2);
  meansLabelPos(1) = labelLeft;
  
  % Determine position of blocks label
  labelLeft = left + floor((imageWidth - blocksLabelPos(3))/2);
  blocksLabelPos(1) = labelLeft;
  
  %
  % Determine the minimum sizes of objects in the control frame
  %
  infoButtonHandle = findobj(fig, 'Tag', 'InfoButton');
  extent = get(infoButtonHandle, 'Extent');
  extent = extent + geom.pushbutton;
  infoButtonPos = [0 0 extent(3:4)];
  
  closeButtonHandle = findobj(fig, 'Tag', 'CloseButton');
  extent = get(closeButtonHandle, 'Extent');
  extent = extent + geom.pushbutton;
  closeButtonPos = [0 0 extent(3:4)];
  
  animationCheckboxHandle = findobj(fig, 'Tag', 'AnimationCheckbox');
  extent = get(animationCheckboxHandle, 'Extent');
  extent = extent + geom.checkbox;
  animationCheckboxPos = [0 0 extent(3:4)];
  
  thresholdLabelHandle = findobj(fig, 'Tag', 'ThresholdLabel');
  extent = get(thresholdLabelHandle, 'Extent');
  extent = extent + geom.text;
  thresholdLabelPos = [0 0 extent(3:4)];
  
  thresholdEditHandle = findobj(fig, 'Tag', 'ThresholdEdit');
  string = get(thresholdEditHandle, 'String');
  set(thresholdEditHandle, 'String', '88888');
  extent = get(thresholdEditHandle, 'Extent');
  set(thresholdEditHandle, 'String', string);
  extent = extent + geom.edit;
  thresholdEditPos = [0 0 extent(3:4)];
  
  thresholdSliderHandle = findobj(fig, 'Tag', 'ThresholdSlider');
  thresholdSliderPos = [0 0 100 20];
  
  applyButtonHandle = findobj(fig, 'Tag', 'ApplyButton');
  extent = get(applyButtonHandle, 'Extent');
  extent = extent + geom.pushbutton;
  applyButtonPos = [0 0 extent(3:4)];
  
  % How wide should the frame be?
  frameHandle = findobj(fig, 'Tag', 'ControlFrame');
  width1 = thresholdLabelPos(3) + thresholdEditPos(3) + 3*labelGap;
  width2 = thresholdSliderPos(3) + 2*labelGap;
  width3 = applyButtonPos(3) + 2*labelGap;
  width4 = animationCheckboxPos(3) + 2*labelGap;
  width5 = infoButtonPos(3) + 2*labelGap;
  width6 = closeButtonPos(3) + 2*labelGap;
  frameWidth = max([width1 width2 width3 width4 width5 width6]) + geom.frame(3);
  
  % What should the left edge of the frame be?
  column2right = max([meansAxesPos(1) + meansAxesPos(3), ...
                      meansLabelPos(1) + meansLabelPos(3), ...
                      blocksLabelPos(1) + blocksLabelPos(3)]);
  frameLeft = column2right + gutter;
  
  % Now that we know how wide the frame is, adjust the horizontal positions
  % of the objects inside it.
  thresholdLabelPos(1) = frameLeft + labelGap;
  thresholdEditPos(1) = thresholdLabelPos(1) + thresholdLabelPos(3) + labelGap;
  thresholdSliderPos(1) = thresholdLabelPos(1);
  thresholdSliderPos(3) = frameWidth - 2*labelGap;
  applyButtonPos(1) = thresholdLabelPos(1);
  applyButtonPos(3) = frameWidth - 2*labelGap;
  animationCheckboxPos(1) = thresholdLabelPos(1);
  animationCheckboxPos(3) = frameWidth - 2*labelGap;
  infoButtonPos(1) = thresholdLabelPos(1);
  infoButtonPos(3) = frameWidth - 2*labelGap;
  closeButtonPos(1) = thresholdLabelPos(1);
  closeButtonPos(3) = frameWidth - 2*labelGap;
  
  % How high should the frame be?
  topRowHeight = max(thresholdLabelPos(4), thresholdEditPos(4));
  buttonHeight = max([applyButtonPos(4), infoButtonPos(4), closeButtonPos(4)]);
  applyButtonPos(4) = buttonHeight;
  infoButtonPos(4) = buttonHeight;
  closeButtonPos(4) = buttonHeight;
  minFrameHeight = topRowHeight + thresholdSliderPos(4) + ...
      animationCheckboxPos(4) + 3*buttonHeight + 11*labelGap;
  frameHeight = max(minFrameHeight, originalAxesPos(2) + ...
                    originalAxesPos(4) - sparseAxesPos(2));
  
  framePos = [frameLeft sparseAxesPos(2) frameWidth frameHeight];
  
  % Adjust vertical positions of objects in the frame
  thresholdLabelPos(4) = topRowHeight;
  thresholdLabelPos(2) = framePos(2) + framePos(4) - labelGap - ...
      thresholdLabelPos(4);
  
  thresholdEditPos(4) = topRowHeight;
  thresholdEditPos(2) = thresholdLabelPos(2);
  
  thresholdSliderPos(2) = thresholdLabelPos(2) - labelGap - ...
      thresholdSliderPos(4);
  
  applyButtonPos(2) = thresholdSliderPos(2) - 2*labelGap - ...
      applyButtonPos(4);
  
  closeButtonPos(2) = framePos(2) + labelGap;
  infoButtonPos(2) = closeButtonPos(2) + closeButtonPos(4) + 2*labelGap;
  
  animationCheckboxPos(2) = floor((infoButtonPos(2) + infoButtonPos(4) + ...
                                   + applyButtonPos(2) - ...
                                   animationCheckboxPos(4))/2);
  
  %
  % Adjust figure position
  %
  figureWidth = framePos(1) + framePos(3) + gutter;
  figureHeight = framePos(2) + framePos(4) + gutter;
  figureHeight = max(figureHeight, originalLabelPos(2) + ...
                     originalLabelPos(4) + gutter);
  horizDecorations = 30;  % resize controls, etc.
  vertDecorations = 65;   % title bar, etc.
  screenSize = get(0,'ScreenSize');
  if (screenSize(3) <= 1)
    % No display connected (apparently)
    screenSize(3:4) = [100000 100000]; % don't use Inf because of vms
  end
  if (((figureWidth + horizDecorations) > screenSize(3)) | ...
      ((figureHeight + vertDecorations) > screenSize(4)))
    % Screen size is too small for this demo!
    delete(fig);
    error(['Screen resolution is too low ', ...
           '(or text fonts are too big) to run this demo']);
  end
  figPos = get(fig, 'Position');
  figPos(3:4) = [figureWidth figureHeight];
  dx = screenSize(3) - figPos(1) - figPos(3) - horizDecorations;
  dy = screenSize(4) - figPos(2) - figPos(4) - vertDecorations;
  if (dx < 0)
    figPos(1) = figPos(1) + dx;
  end
  if (dy < 0)
    figPos(2) = figPos(2) + dy;
  end
  set(fig, 'Position', figPos);
  
  %
  % Position controls
  %
  statusPos(3) = figureWidth;
  set(statusHandle, 'Position', statusPos);
  set(sparseAxesHandle, 'Position', sparseAxesPos);
  set(sparseLabelHandle, 'Position', sparseLabelPos);
  set(originalAxesHandle, 'Position', originalAxesPos);
  set(originalPopupHandle, 'Position', originalPopupPos);
  set(originalLabelHandle, 'Position', originalLabelPos);
  set(meansAxesHandle, 'Position', meansAxesPos);
  set(meansLabelHandle, 'Position', meansLabelPos);
  set(blocksAxesHandle, 'Position', blocksAxesPos);
  set(blocksLabelHandle, 'Position', blocksLabelPos);
  set(frameHandle, 'Position', framePos);
  set(infoButtonHandle, 'Position', infoButtonPos);
  set(closeButtonHandle, 'Position', closeButtonPos);
  set(animationCheckboxHandle, 'Position', animationCheckboxPos);
  set(applyButtonHandle, 'Position', applyButtonPos);
  set(thresholdSliderHandle, 'Position', thresholdSliderPos);
  set(thresholdLabelHandle, 'Position', thresholdLabelPos);
  set(thresholdEditHandle, 'Position', thresholdEditPos);
  
%%%
%%% Subfunction NewImage
%%%
function NewImage

  fig = DemoFigHandle;
  
  % First, determine if the selected image really changed
  originalPopupHandle = findobj(fig, 'Tag', 'OriginalPopup');
  value = get(originalPopupHandle, 'Value');
  userdata = get(originalPopupHandle, 'UserData');
  if (userdata ~= value)
    % The selected image really did change
    ShowBusy(fig);
    
    set(originalPopupHandle, 'UserData', value);
    Status('Loading image ...');
    
    % Which image has been selected?
    strings = get(originalPopupHandle, 'String');
    string = strings{value};
    
    switch string
     case 'Tree'
      trees = [];  % parser hint
      load imdemos trees
      I = trees;
      SetThreshold(0.40);
      
     case 'Lifting Body'
      liftbody128 = [];
      load imdemos liftbody128
      I = liftbody128;
      SetThreshold(0.27);
      
     case 'Rice'
      rice2 = [];
      load imdemos rice2
      I = rice2;
      SetThreshold(0.20);
      
     case 'Tire'
      tire = [];
      load imdemos tire;
      I = tire;
      SetThreshold(0.40);
      
     case 'Circuit'
      circuit = [];
      load imdemos circuit;
      I = circuit;
      SetThreshold(0.40);
      
    end
    
    set(findobj(fig, 'Tag', 'OriginalImage'), 'CData', I);
    z = repmat(uint8(0), [128 128]);
    set(findobj(fig, 'Tag', 'BlocksImage'), 'CData', z);
    set(findobj(fig, 'Tag', 'MeansImage'), 'CData', z);
    set(findobj(fig, 'Tag', 'SparseLine'), 'XData', [], 'YData', []);
    drawnow;
    
    Status('');
    
    Apply;
    
  end
    
  
%%%
%%% Subfunction ShowBusy
%%%
function ShowBusy(fig)
  
  handles = [findobj(fig, 'Tag', 'OriginalPopup');
             findobj(fig, 'Tag', 'ThresholdEdit');
             findobj(fig, 'Tag', 'ThresholdSlider');
             findobj(fig, 'Tag', 'AnimationCheckbox');
             findobj(fig, 'Tag', 'InfoButton');
             findobj(fig, 'Tag', 'CloseButton')];
  set(handles, 'Enable', 'off');
  set(fig, 'Pointer', 'watch');
  drawnow;
  
%%%
%%% Subfunction ShowReady
%%%
function ShowReady(fig)
  
  handles = [findobj(fig, 'Tag', 'OriginalPopup');
             findobj(fig, 'Tag', 'ThresholdEdit');
             findobj(fig, 'Tag', 'ThresholdSlider');
             findobj(fig, 'Tag', 'AnimationCheckbox');
             findobj(fig, 'Tag', 'InfoButton');
             findobj(fig, 'Tag', 'CloseButton')];
  set(handles, 'Enable', 'on');
  set(fig, 'Pointer', 'arrow');
  
  
%%%
%%% Subfunction Slider
%%%
function Slider
  
  sliderHandle = gcbo;
  fig = get(sliderHandle, 'Parent');
  editHandle = findobj(fig, 'Tag', 'ThresholdEdit');
  value = get(sliderHandle, 'Value');
  set(editHandle, 'String', sprintf('%4.2f',value));
  set(editHandle, 'UserData', value);
  set(findobj(fig, 'Tag', 'ApplyButton'), 'Enable', 'on');
  Status('Press "Apply" to recompute the decomposition');
  
%%%
%%% Subfunction Edit
%%%
function Edit
  
  fig = DemoFigHandle;
  editHandle = findobj(fig, 'Tag', 'ThresholdEdit');
  sliderHandle = findobj(fig, 'Tag', 'ThresholdSlider');
  minVal = get(sliderHandle, 'Min');
  maxVal = get(sliderHandle, 'Max');
  string = get(editHandle, 'String');
  num = str2double(string);
  errFlag = 0;
  if (isempty(num) | ((num < minVal) | (num > maxVal)))
    errFlag = 1;
  end
  
  sliderHandle = findobj(fig, 'Tag', 'ThresholdSlider');
  if (errFlag)
    set(editHandle, 'String', sprintf('%4.2f', get(sliderHandle, 'Value')));
    errordlg(sprintf('"Threshold" must be a number between %d and %d', ...
                     minVal, maxVal), 'QTDEMO Error', 'replace');
  else
    set(sliderHandle, 'Value', num);
    set(findobj(fig, 'Tag', 'ApplyButton'), 'Enable', 'on');
    Status('Press "Apply" to recompute');
  end
  
%%%
%%% Subfunction Status
%%%
function oldString = Status(newString)
  
  fig = DemoFigHandle;
  statusHandle = findobj(fig, 'Tag', 'StatusText');
  oldString = get(statusHandle, 'String');
  set(statusHandle, 'String', newString);
  
%%%
%%% Subfunction Apply
%%%
function Apply
  
  fig = DemoFigHandle;
  blocksImageHandle = findobj(fig, 'Tag', 'BlocksImage');
  meansImageHandle = findobj(fig, 'Tag', 'MeansImage');
  sparseLineHandle = findobj(fig, 'Tag', 'SparseLine');
  applyButtonHandle = findobj(fig, 'Tag', 'ApplyButton');
  
  zeroImage = repmat(uint8(0), [128 128]);
  set(applyButtonHandle, 'Enable', 'off');
  set(blocksImageHandle, 'CData', zeroImage);
  set(meansImageHandle, 'CData', zeroImage);
  set(sparseLineHandle, 'XData', [], 'YData', []);
  Status('Computing quadtree decomposition ...');
  ShowBusy(fig);
  
  threshold = get(findobj(fig, 'Tag', 'ThresholdSlider'), 'Value');
  threshold = round(255*threshold);
  I = get(findobj(fig, 'Tag', 'OriginalImage'), 'CData');
  animationHandle = findobj(fig, 'Tag', 'AnimationCheckbox');
  if (get(animationHandle, 'Value'))
    % Enable animation control so user can change his mind
    % in the middle of the animation.
    set(animationHandle, 'Enable', 'on');
  end
  
  blockSizes = [128 64 32 16 8 4 2];
  S = uint8(128);
  S(128,128) = 0;
  M = 128;
  
  dim = 128;
  while (dim > 1)
    % Find all the blocks at the current size
    [blockValues, Sind] = qtgetblk(I, S, dim);
    if (isempty(Sind))
      % Done!
        break;
    end
    
    if (get(animationHandle, 'Value'))
      [i,j,v] = find(S);
      set(sparseLineHandle, 'XData', j, 'YData', i);
      set(blocksImageHandle, 'CData', ComputeBlocks(S));
      set(meansImageHandle, 'CData', ComputeMeans(I, S));
      Status(sprintf('Examining %d-by-%d blocks', dim, dim));
      pause(2);
    end
    
    doSplit = SplitTest(blockValues, threshold, dim);
    
    % Record results
    dim = dim/2;
    Sind = Sind(doSplit);
    Sind = [Sind ; Sind+dim ; (Sind+M*dim) ; (Sind+(M+1)*dim)];
    S(Sind) = dim;
  end
  
  % Display final results
  [i,j,v] = find(S);
  set(sparseLineHandle, 'XData', j, 'YData', i);
  set(blocksImageHandle, 'CData', ComputeBlocks(S));
  set(meansImageHandle, 'CData', ComputeMeans(I, S));
  Status(sprintf('Number of blocks: %d', length(i)));
  
  ShowReady(fig);
  
%%%
%%% Subfunction SplitTest
%%%
function doSplit = SplitTest(blockValues, threshold, dim)
  
  maxValues = max(max(blockValues,[],1),[],2);
  minValues = min(min(blockValues,[],1),[],2);
  doSplit = (double(maxValues) - double(minValues)) > threshold;
  
%%%
%%% Subfunction ComputeBlocks
%%%
function blocks = ComputeBlocks(S);
  
  blocks = repmat(uint8(0), size(S));
  for dim = [128 64 32 16 8 4 2 1];
    numBlocks = length(find(S == dim));
    if (numBlocks > 0)
      values = repmat(uint8(1), [dim dim numBlocks]);
      values(2:dim, 2:dim, :) = 0;
      blocks = qtsetblk(blocks, S, dim, values);
    end
  end
  blocks(end,1:end) = 1;
  blocks(1:end,end) = 1;
  
%%%
%%% Subfunction ComputeMeans
%%%
function means = ComputeMeans(I, S)
  
  means = I;
  for dim = [128 64 32 16 8 4 2 1];
    values = qtgetblk(I, S, dim);
    if (~isempty(values))
      try
        % new functionality
        doublesum = sum(sum(values,1,'double'),2);
      catch
        % old functionality
        doublesum = sum(sum(values,1),2);
      end
      means = qtsetblk(means, S, dim, doublesum ./ dim^2);
    end
  end
  
%%%
%%% Subfunction Animate
%%%
function Animate

  fig = DemoFigHandle;
  animateHandle = findobj(fig, 'Tag', 'AnimationCheckbox');
  if (get(animateHandle, 'Value') == 1)
    applyHandle = findobj(fig, 'Tag', 'ApplyButton');
    set(applyHandle, 'Enable', 'on');
    Status('Press "Apply" to recompute');
  end
  
%%%
%%% Subfunction SetThreshold
%%% Note: caller is responsible for passing a valid threshold!
%%%
function SetThreshold(threshold)
  
  fig = DemoFigHandle;
  sliderHandle = findobj(fig, 'Tag', 'ThresholdSlider');
  editHandle = findobj(fig, 'Tag', 'ThresholdEdit');
  set(sliderHandle, 'Value', threshold);
  set(editHandle, 'String', sprintf('%4.2f',threshold), ...
                  'UserData', threshold);
