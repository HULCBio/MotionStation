function [out,HB] = btngroup(varargin)
%BTNGROUP Create toolbar button group.
%  H = BTNGROUP('Property1', value, 'Property2', value, ...)
%  creates a toolbar button group and returns the axes
%  handle in H.
%  H = BTNGROUP(FIGHANDLE, 'Property1', value, ...) places
%  the button group in figure FIGHANDLE.
%  [H,HB] = BTNGROUP(...) creates button groups out of uicontrols
%  of style pushbutton and togglebutton, instead of axes objects.
%  In this mode of operation, the axes and its children are
%  still created but are invisible on exit; note the position
%  property of the button group must be set on entry (rather
%  than repositioned after creation via btngroup) since the
%  uicontrol cdata is obtained from image capture (via getframe).
%  HB is a vector of uicontrol handles for the button group.
%  In this mode, pass the 'Cdata' property to circumvent the 
%  image capture for the buttons (and hence the requirement of
%  positioning the axes before calling the function no longer holds).
%  
%  Required properties include: 
%       'GroupID' - identifier string for the button group.
%       'ButtonID' - string matrix containing identifier
%          strings for each button.  ButtonID strings may not
%          contain internal spaces.
%
%  Optional properties include:
%        'IconFunctions' - a string or string matrix containing
%           icon-drawing expressions.  If it is a string matrix, it
%           must have the same number of rows as ButtonID.  The
%           icon-drawing expressions should return handles to
%           HG objects created in the current axes.  The HG objects
%           should be drawn in the region [0 1 0 1].  
%       'Cdata' - cell array of 3 dimensional cdata matrices for the
%          buttons.  Note this property is only an option in the 
%          'uicontrol' mode of operation, i.e. when there is a
%          2nd output argument HB.  Note that if this parameter
%          is provided, the 'IconFunctions' property is ignored.
%       'PressType' - either 'flash' (when pressed, the button
%          pops down and then right back up) or 'toggle'
%          (button changes state and "sticks").  'PressType'
%          may either be a string or a string matrix.  If it is a
%          string matrix, it must have the same number of rows as
%          ButtonID.  Defaults to 'toggle'.
%       'Exclusive' - either 'yes' (button group behaves like
%          radio buttons) or 'no'.  If 'yes', the 'PressType'
%          property is ignored.  Defaults to 'no'.
%       'Callbacks' - string containing expression to be
%          evaluated when a button is released.  The value may
%          either be a string or a string matrix.
%       'ButtonDownFcn' - string containing expression to be
%          evaluated when a button is pressed.  The value may
%          either be a string or a string matrix.
%       'GroupSize' - a 2-element vector ([nrows ncols])
%          specifying the layout of the buttons.  Defaults to
%          [numButtons 1].
%       'InitialState' - a vector of zeros (button initially up)
%          and ones (button initially down).  Defaults to
%          zeros(numButtons,1).
%       'Units' - button group axes units.  Defaults to the
%          figure's default axes units.
%       'Position' - button group axes position.  Defaults to the
%          figure's default axes position.
%       'BevelWidth' ** - the width of the 3D bevel in ratio to the
%          button width.  Defaults to 0.05.
%       'ButtonColor' ** - initial button background color.
%          Defaults to figure's DefaultUIControlBackgroundColor.
%       'BevelLight' ** - initial color of the upper left bevel.
%       'BevelDark' ** - initial color of lower right bevel.
%
%  ** Note: the following properties are obsolete in 
%    the 'uicontrol' mode: 
%         BevelWidth, ButtonColor, BevelLight, BevelDark.
%
%  Example:
%         icons = ['text(.5,.5,''B1'',''Horiz'',''center'')'
%                  'text(.5,.5,''B2'',''Horiz'',''center'')'];
%         callbacks = ['disp(''B1'')'
%                      'disp(''B2'')'];
%    btngroup('GroupID', 'TestGroup', 'ButtonID', ...
%             ['B1';'B2'], 'Callbacks', callbacks, ...
%             'Position', [.475 .45 .05 .1], 'IconFunctions', icons);
%
%  See also BTNSTATE, BTNPRESS, BTNDOWN, BTNUP, BTNRESIZE.

%  Steven L. Eddins, 29 June 1994
%  Tom Krauss, 27 June 1999 - Added uicontrol functionality
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.46 $  $Date: 2002/04/15 03:25:57 $

% Initialize input parameters
iconFunctions = [];
groupSize = [];
callbacks = [];
buttonDownFcn = [];
pressType = [];
exFlag = 'no';
buttonId = [];
groupId = [];
initialState = [];
orientation = 'vertical';
Cdata = [];

propertyOffset = rem(nargin,2);
if (propertyOffset == 1)
  % BTNGROUP(FIGHANDLE, properties ...)
  figHandle = varargin{1};
else
  figHandle = gcf;
end
save_hv = get(figHandle,'HandleVisibility');
save_gcf = get(0,'CurrentFigure');
set(figHandle, 'HandleVisibility', 'on');
set(0,'CurrentFigure',figHandle);
axesPosition = get(figHandle, 'DefaultAxesPosition');
axesUnits = get(figHandle, 'DefaultAxesUnits');

% Initialize other parameters
buttonColor = get(0,'DefaultUIControlBackgroundColor');
bevelWidth = .05;

% Do reasonable things for B&W monitors.
bw = (get(0,'ScreenDepth') == 1);
if (bw)
  bevelLight = [1.0 1.0 1.0];
  bevelDark = [0.0 0.0 0.0];
  buttonColor = [1.0 1.0 1.0];
  buttonColorDark = [1.0 1.0 1.0];
  backgroundEdgeColor = 'k';
  buttonSep = .05;
else
  bevelLight = min(buttonColor + .15,1);
  bevelDark = max(buttonColor - .3,0);
  buttonColorDark = (bevelLight + bevelDark)/2;
  backgroundEdgeColor = 'none';
  buttonSep = .01;
end
buttonSep2 = buttonSep/2;
iconDim = 1 - buttonSep2 - 4*bevelWidth;

propertyNames = ['iconfunctions'
                 'groupid      '
                 'buttonid     '
                 'presstype    '
                 'exclusive    '
                 'callbacks    '
                 'buttondownfcn'
                 'groupsize    '
                 'initialstate '
                 'units        '
                 'position     '
                 'bevelwidth   '
                 'orientation  '
                 'buttoncolor  '
                 'buttondark   '
                 'bevellight   '
                 'beveldark    '
                 'cdata        '];
       
varNames = ['iconFunctions  '
            'groupId        '
            'buttonId       '
            'pressType      '
            'exFlag         '
            'callbacks      '
            'buttonDownFcn  '
            'groupSize      '
            'initialState   '
            'axesUnits      '
            'axesPosition   '
            'bevelWidth     '
            'orientation    '
            'buttonColor    '
            'buttonColorDark'
            'bevelLight     '
            'bevelDark      '
            'Cdata          '];
      
% Parse input parameters
for k = (1+propertyOffset):2:nargin
  propertyString = lower(varargin{k});
  property = varargin{k+1};
  
  idx = strmatch(propertyString, propertyNames);
  if (isempty(idx))
    error(sprintf('Unknown property "%s"', propertyString));
  elseif (length(idx) > 1)
    fprintf('Warning: ambiguous property specification "%s"', propertyString);
    idx = idx(1);
  end
  tryString = [varNames(idx,:) '= property;'];
  eval(tryString);
  
end

if (isempty(groupId))
  error('No group ID matrix specified.');
end
if (isempty(buttonId))
  error('No button ID matrix specified.');
end
numButtons = size(buttonId,1);
if (isempty(groupSize))
  groupSize = [numButtons 1];
end
if (isempty(callbacks))
  callbacks = ' ';
  callbacks = callbacks(ones(1,numButtons),:);
end
if (isempty(buttonDownFcn))
  buttonDownFcn = ' ';
  buttonDownFcn = buttonDownFcn(ones(1,numButtons),:);
end
if (isempty(pressType))
  pressType = 'toggle';
  pressType = pressType(ones(1,numButtons), :);
end
if (isempty(initialState))
  initialState = zeros(1,numButtons);
end

eraseMode = 'none';

axHandle = axes('parent',figHandle,...
     'Units', axesUnits, ...
    'Position', axesPosition, 'XTick', [], 'YTick', [], ...
    'Tag', groupId, ...
    'Color', buttonColor, 'XColor', 'k', ...
    'YColor', 'k', 'Box', 'on', ...
    'XLim', [0 1], 'YLim', [0 1], ...
    'ButtonDownFcn', 'btnpress', ...
    'Layer', 'top');
set(axHandle, ...
    'DefaultPatchEraseMode', eraseMode, ...
    'DefaultLineEraseMode', eraseMode, ...
    'DefaultTextEraseMode', eraseMode, ...
    'DefaultSurfaceEraseMode', eraseMode, ...
    'DefaultPatchClipping', 'off', ...
    'DefaultLineClipping', 'off', ...
    'DefaultTextClipping', 'off', ...
    'DefaultSurfaceClipping', 'off', ...
    'DefaultPatchInterruptible', 'on', ...
    'DefaultLineInterruptible', 'on', ...
    'DefaultTextInterruptible', 'on', ...
    'DefaultSurfaceInterruptible', 'on', ...
    'DefaultImageInterruptible', 'on');

if (bw)
  line('XData', [0 1 1 0 0], 'YData', [0 0 1 1 0], ...
      'parent',axHandle,...
      'ZData', realmax*ones(1,5), ...
      'Color', 'k');
end

ulColor = bevelLight;
lrColor = bevelDark;
  
horizButtonSpacing = 1/groupSize(1);
vertButtonSpacing = 1/groupSize(2);

% Compute the offset positions for each button in the group.
xOffset = zeros(groupSize);
yOffset = zeros(groupSize);
m = 1;
[k,p] = meshgrid(1:groupSize(2), 1:groupSize(1));
yOffset = flipud((p-1)*horizButtonSpacing);
xOffset = (k-1)*vertButtonSpacing;
if (strcmp(orientation, 'horizontal'))
  yOffset = yOffset';
  xOffset = xOffset';
end
xOffset = xOffset(:);
yOffset = yOffset(:);

% Set up border patch coordinates and colors.
ulBorderX = [buttonSep2 buttonSep2+bevelWidth buttonSep2+bevelWidth ...
  1-buttonSep2-bevelWidth 1-buttonSep2 buttonSep2 buttonSep2] * ...
    vertButtonSpacing;
ulBorderY = [buttonSep2 buttonSep2+bevelWidth 1-buttonSep2-bevelWidth ...
  1-buttonSep2-bevelWidth 1-buttonSep2 1-buttonSep2 buttonSep2] * ...
    horizButtonSpacing;
lrBorderX = [buttonSep2 buttonSep2+bevelWidth 1-buttonSep2-bevelWidth ...
  1-buttonSep2-bevelWidth 1-buttonSep2 1-buttonSep2 buttonSep2] * ...
    vertButtonSpacing;
lrBorderY = [buttonSep2 buttonSep2+bevelWidth buttonSep2+bevelWidth ...
  1-buttonSep2-bevelWidth 1-buttonSep2 buttonSep2 buttonSep2] * ...
    horizButtonSpacing;
x1 = buttonSep2+bevelWidth;
x2 = buttonSep2+2*bevelWidth;
x3 = 1-x2;
x4 = 1-x1;
y1 = x1;
y2 = x2;
y3 = x3;
y4 = x4;
backPatchX = [x1 x4 x4 x1 x1] * vertButtonSpacing;
backPatchY = [y1 y1 y4 y4 y1] * horizButtonSpacing;
%backPatchX = [x1 x2 x2 x3 x3 x2 x1 x4 x4 x1 x1] * vertButtonSpacing;
%backPatchY = [y1 y2 y3 y3 y2 y2 y1 y1 y4 y4 y1] * horizButtonSpacing;

% Set up background patch coordinates.
buttonX = [buttonSep2 buttonSep2 1-buttonSep2 1-buttonSep2 buttonSep2] * ...
    vertButtonSpacing;
buttonY = [buttonSep2 1-buttonSep2 1-buttonSep2 buttonSep2 buttonSep2] * ...
    horizButtonSpacing;

% Initialize handles variable
handles = [];

% Create the buttons.
for k = 1:numButtons

  thisButton = buttonId(k,:);
  thisButton(thisButton==' ' | thisButton==0) = []; % deblank short-cut

  % Place button border patches.
  patch(ulBorderX+xOffset(k), ulBorderY+yOffset(k), ulColor, ...
      'parent',axHandle,...
      'Tag', thisButton, 'UserData', 'ULBorder', ...
      'EdgeColor', backgroundEdgeColor, ...
      'ButtonDownFcn', 'btnpress'); % ,'visible','off');
  patch(lrBorderX+xOffset(k), lrBorderY+yOffset(k), lrColor, ...
      'parent',axHandle,...
      'Tag', thisButton, 'UserData', 'LRBorder', ...
      'EdgeColor', backgroundEdgeColor, ...
      'ButtonDownFcn', 'btnpress'); % ,'visible','off');

  % Place button-down border.
  patch(backPatchX+xOffset(k), backPatchY+yOffset(k), buttonColorDark, ...
     'parent',axHandle,...
     'Tag', thisButton, 'UserData', 'DownBorder', ...
     'EdgeColor', 'none', 'ButtonDownFcn', 'btnpress', ...
     'FaceColor', buttonColor); %,'visible','off');
  
  handles = [];
  if (~isempty(iconFunctions))
    if (size(iconFunctions,1) == 1)
      eval(['handles = ' (iconFunctions) ';']);
    else
      eval(['handles = ' (iconFunctions(k,:)) ';']);
    end
    if (~isempty(handles))
      handles = handles(:);
    end
    % Just in case the iconFunction string created the object(s) in
    % another axes or figure:
    for p = 1:length(handles)
        if (get(handles(p),'Parent') ~= axHandle)
            set(handles(p),'Parent',axHandle);
        end
    end
  end
  
  for h = handles'
    objType = get(h, 'Type');
    if (strcmp(objType, 'line'))
      xdata = get(h, 'XData');
      ydata = get(h, 'YData');
      xdata = xdata * vertButtonSpacing * iconDim + xOffset(k) + ...
    vertButtonSpacing*(1-iconDim)/2;
      ydata = ydata * horizButtonSpacing * iconDim + yOffset(k) + ...
    horizButtonSpacing*(1-iconDim)/2;
      if (strcmp(get(h, 'UserData'), 'Background'))
        set(h, 'ButtonDownFcn', 'btnpress', ...
        'Color', buttonColor, ...
        'Tag', thisButton, ...
        'XData', xdata, ...
        'YData', ydata, ...
        'Visible', 'on');
      else
        set(h, 'ButtonDownFcn', 'btnpress', ...
        'Tag', thisButton, ...
        'XData', xdata, ...
        'YData', ydata, ...
        'UserData', k, ...
        'Visible', 'on');
      end
    elseif (strcmp(objType, 'text'))
      position = get(h, 'Position');
      centerX = position(1);
      centerY = position(2);
      centerX = centerX * vertButtonSpacing * iconDim + xOffset(k) + ...
      vertButtonSpacing*(1-iconDim)/2;
      centerY = centerY * horizButtonSpacing * iconDim + yOffset(k) + ...
      horizButtonSpacing*(1-iconDim)/2;
      set(h, 'ButtonDownFcn', 'btnpress', ...
           'Tag', thisButton, ...
           'Position', [centerX centerY], ...
           'UserData', k, ...
           'Visible', 'on');
      
    elseif (strcmp(objType, 'patch') | strcmp(objType, 'surface'))
      xdata = get(h, 'XData');
      ydata = get(h, 'YData');
      xdata = xdata * vertButtonSpacing * iconDim + xOffset(k) + ...
    vertButtonSpacing*(1-iconDim)/2;
      ydata = ydata * horizButtonSpacing * iconDim + yOffset(k) + ...
    horizButtonSpacing*(1-iconDim)/2;
      if (strcmp(get(h, 'UserData'), 'Background'))
        set(h, 'ButtonDownFcn', 'btnpress', ...
        'FaceColor', buttonColor, ...
        'Tag', thisButton, ...
        'XData', xdata, ...
        'YData', ydata, ...
        'UserData', k, ...
        'Visible', 'on');
      else
        set(h, 'ButtonDownFcn', 'btnpress', ...
        'Tag', thisButton, ...
        'XData', xdata, ...
        'YData', ydata, ...
        'UserData', k, ...
        'Visible', 'on');
      end
    end
  end
end

% Store state information about the button group in various
% UserData's.
ud.state = zeros(prod(groupSize),1);
ud.buttonId = buttonId;
ud.pressType = pressType;
ud.exFlag = exFlag;
ud.callbacks = callbacks;
ud.buttonDownFcn = buttonDownFcn;
ud.xOffset = xOffset;
ud.yOffset = yOffset;
ud.groupSize = groupSize;

if nargout > 1  % <-- use # output arguments to signify
                %     uicontrol button group (as opposed to axes).
   % Now capture each button and create pushbuttons and/or togglebuttons
   % on top of them.  T. Krauss, 6/26/99
   axUnitsSave=get(axHandle,'units');
   set(axHandle,'units','pixels')
   aPos = get(axHandle,'position');
   xOffsetPix = xOffset*aPos(3);
   yOffsetPix = yOffset*aPos(4);
   uicontrolButtons = zeros(numButtons,1);
   buttonCdata = cell(numButtons,1);
   for k = 1:numButtons
     % first find rectangle in pixels relative to (0,0) of axes parent
     % in which the button's cdata lives 
     buttonPix = [xOffsetPix(k) yOffsetPix(k) ...
                   aPos(3)/groupSize(2) aPos(4)/groupSize(1)];
     switch deblank(pressType(k,:))
     case 'flash'
         uiStyle = 'pushbutton';
     case 'toggle'
         uiStyle = 'togglebutton';
     end  
     if isempty(Cdata)
         f = getframe(axHandle,buttonPix);
         buttonCdata{k} = f.cdata;
     else
         buttonCdata{k} = Cdata{k};
     end
     thisButton = buttonId(k,:);
     thisButton(thisButton==' ' | thisButton==0) = []; % deblank short-cut
     uicontrolButtons(k) = uicontrol('style',uiStyle,...
                            'units','pixels',...
                            'position',[aPos(1:2) 0 0]+buttonPix,...
                            'cdata',buttonCdata{k},...
                            'callback','btnpress',...
                            'buttondownfcn',buttonDownFcn(k,:),...
                            'tag',thisButton,...
                            'userdata',axHandle);
   end
   set(axHandle,'units',axUnitsSave)
   set(findobj(axHandle),'visible','off')  % hide the axes children in this mode
   ud.uicontrolButtons = uicontrolButtons;
   HB = uicontrolButtons;
else
   ud.uicontrolButtons = [];
end % nargout > 1

set(axHandle, 'UserData', ud );

setuprop(axHandle, 'Colors', ...
    [buttonColor ; buttonColorDark ; bevelLight ; bevelDark]);

% Set up the initial state.
for k = 1:numButtons
  if (initialState(k))
    btndown(figHandle, groupId, k);
  end
end

if (nargout > 0)
  out = axHandle;
end

%set(axHandle,'xcolor',buttonColor,'ycolor',buttonColor,'color',buttonColor)
set(axHandle,'visible','off','HandleVisibility','callback')
set(figHandle, 'HandleVisibility', save_hv);
set(0,'CurrentFigure',save_gcf);
