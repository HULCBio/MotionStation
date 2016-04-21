function h=imshow(varargin)
%IMSHOW Display image.
%   IMSHOW(I,N) displays the intensity image I with N discrete
%   levels of gray. If you omit N, IMSHOW uses 256 gray levels on
%   24-bit displays, or 64 gray levels on other systems.
%
%   IMSHOW(I,[LOW HIGH]) displays I as a grayscale intensity
%   image, specifying the data range for I. The value LOW (and
%   any value less than LOW) displays as black, the value HIGH
%   (and any value greater than HIGH) displays as white, and
%   values in between display as intermediate shades of
%   gray. IMSHOW uses the default number of gray levels. If you
%   use an empty matrix ([]) for [LOW HIGH], IMSHOW uses
%   [min(I(:)) max(I(:))]; the minimum value in I displays as
%   black, and the maximum value displays as white.
%
%   IMSHOW(BW) displays the binary image BW. Values of 0 display
%   as black, and values of 1 display as white.
%
%   IMSHOW(X,MAP) displays the indexed image X with the colormap
%   MAP.
%
%   IMSHOW(RGB) displays the truecolor image RGB.
%
%   IMSHOW(...,DISPLAY_OPTION) displays the image, calling
%   TRUESIZE if DISPLAY_OPTION is 'truesize', or suppressing the
%   call to TRUESIZE if DISPLAY_OPTION is 'notruesize'. Either
%   option string can be abbreviated. If you do not supply this
%   argument, IMSHOW determines whether to call TRUESIZE based on
%   the setting of the 'ImshowTruesize' preference.
%
%   IMSHOW(x,y,A,...) uses the 2-element vectors x and y to
%   establish a nondefault spatial coordinate system, by
%   specifying the image XData and YData.  Note that x and y can 
%   have more than 2 elements, but only the first and last 
%   elements are actually used.
%
%   IMSHOW(FILENAME) displays the image stored in the graphics
%   file FILENAME. IMSHOW calls IMREAD to read the image from the
%   file, but the image data is not stored in the MATLAB
%   workspace. The file must be in the current directory or on
%   the MATLAB path.
%
%   H = IMSHOW(...) returns the handle to the image object
%   created by IMSHOW.
%
%   Class Support
%   -------------
%   The input image can be of class logical, uint8, uint16,
%   or double, and it must be nonsparse.
% 
%   Remarks
%   -------
%   You can use the IPTSETPREF function to set several toolbox
%   preferences that modify the behavior of IMSHOW:
%
%   - 'ImshowBorder' controls whether IMSHOW displays the image
%     with a border around it.
%
%   - 'ImshowAxesVisible' controls whether IMSHOW displays the
%     image with the axes box and tick labels.
%
%   - 'ImshowTruesize' controls whether IMSHOW calls the TRUESIZE
%     function.
%
%   For more information about these preferences, see the
%   reference entry for IPTSETPREF.
%
%   See also IMREAD, IMVIEW, IPTGETPREF, IPTSETPREF, SUBIMAGE, TRUESIZE, WARP, IMAGE, IMAGESC.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.37.4.6 $  $Date: 2003/08/23 05:52:43 $

% 1. Parse input arguments
% 2. Get an axes to plot in.
% 3. Create the image and axes objects and set their display
%    properties.
% 4. If the image is alone in the figure, position the axes
%    according to the current IMBORDER setting and then call
%    TRUESIZE.

newFigure = isempty(get(0,'CurrentFigure')) | ...
        strcmp(get(get(0,'CurrentFigure'), 'NextPlot'), 'new');

[cdata, cdatamapping, clim, map, xdata, ydata, filename, ...
            truesizeStr] = ParseInputs(varargin{:});

if (newFigure)
    figHandle = figure('Visible', 'off');
    axHandle = axes('Parent', figHandle);
else
    axHandle = newplot;
    figHandle = get(axHandle, 'Parent');
end

% Make the image object.
hh = image(xdata, ydata, cdata, 'BusyAction', 'cancel', ...
   'Parent', axHandle, 'CDataMapping', cdatamapping, ...
   'Interruptible', 'off');

% Set axes and figure properties if necessary to display the 
% image object correctly.
showAxes = iptgetpref('ImshowAxesVisible');
set(axHandle, ...
        'TickDir', 'out', ...
        'XGrid', 'off', ...
        'YGrid', 'off', ...
        'DataAspectRatio', [1 1 1], ...
        'PlotBoxAspectRatioMode', 'auto', ...
        'Visible', showAxes);
set(get(axHandle,'Title'),'Visible','on');
set(get(axHandle,'XLabel'),'Visible','on');
set(get(axHandle,'YLabel'),'Visible','on');
if (~isempty(map))
    set(figHandle, 'Colormap', map);
end
if (~isempty(clim))
    set(axHandle, 'CLim', clim);
end

% Do truesize if called for.
truesizePref = iptgetpref('ImshowTruesize');
autoTruesize = strcmp(truesizePref, 'auto');
singleImage = SingleImageDefaultPos(figHandle, axHandle);


% Syntax specification overrides truesize preference setting.
if (strcmp(truesizeStr, 'notruesize'))
    callTruesize = 0;
    
elseif (strcmp(truesizeStr, 'truesize'))
    callTruesize = 1;
    
else
    % If there was no command-line override, and the truesize preference
    % is 'on', we still might not want to call truesize if the image
    % isn't the only thing in the figure, or if it isn't in the 
    % default position.

    if (autoTruesize)
        callTruesize = singleImage;
    else
        callTruesize = 0;
    end
end

% Adjust according to ImshowBorder setting, unless we don't have a single
% image in the default position.
borderPref = iptgetpref('ImshowBorder');
if (strcmp(borderPref, 'tight') && singleImage)
    % Have the image fill the figure.
    set(axHandle, 'Units', 'normalized', 'Position', [0 0 1 1]);
    
    % The next line is so that a subsequent plot(1:10) goes back
    % to the default axes position instead of taking up the
    % entire figure.
    set(figHandle, 'NextPlot', 'replacechildren');
end

if (callTruesize)
    truesize(figHandle);
end

if (~isempty(filename) && isempty(get(get(axHandle,'Title'),'String')))
    set(get(axHandle, 'Title'), 'String', filename, ...
            'Interpreter', 'none', ...
            'Visible', 'on');
end

if (nargout > 0)
  % Only return handle if caller requested it.
  h = hh;
end

if (newFigure)
    set(figHandle, 'Visible', 'on');
end


%----------------------------------------------------------------------
% Subfunction ParseInputs
%----------------------------------------------------------------------

function [cdata, cdatamapping, clim, map, xdata, ...
          ydata, filename, truesizeStr] =  ParseInputs(varargin)

% Defaults
filename      = '';
truesizeStr   = '';
clim          = []; % stays empty for indexed and RGB
map           = [];
image_type    = '';
N_gray_levels = [];
xdata         = [];
ydata         = [];

% If nargin > 1, see if there's a trailing string argument.
if ((nargin > 1) && (ischar(varargin{end})))
    str = varargin{end};
    varargin(end) = [];  % remove string from input arg list
    strs = {'truesize', 'notruesize'};
    idx = strmatch(str, strs);
    if (isempty(idx))
        eid = 'Images:imshow:unrecognizedOption';
        error(eid, 'Unknown option string "%s"', str);
    elseif (length(idx) > 1)
        eid = 'Images:imshow:ambiguousOption';
        error(eid, 'Ambiguous option string "%s"', str);
    else
        truesizeStr = strs{idx};
    end
end

switch length(varargin)
case 0
    eid = 'Images:imshow:tooFewInputs';
    error(eid, '%s', 'Not enough input arguments.  See HELP IMSHOW');
    
case 1
    % IMSHOW(I)
    % IMSHOW(RGB)
    % IMSHOW(FILENAME)
    
    if (ischar(varargin{1}))
        % IMSHOW(FILENAME)
        filename = varargin{1};
        [cdata,map] = imread(filename);
        if (isempty(map))
            if (ndims(cdata) ~= 3) 
                image_type = 'intensity';
            else 
                image_type = 'truecolor';
            end
            
        else
            image_type = 'indexed';            
        end
    
    elseif (ndims(varargin{1}) == 3)
        % IMSHOW(RGB)       
        image_type = 'truecolor';        
        cdata = varargin{1};
        
    else
        % IMSHOW(I)
        image_type = 'intensity';        
        cdata = varargin{1};
        
    end
    
case 2
    % IMSHOW(I,N)
    % IMSHOW(I,[a b])
    % IMSHOW(X,map)
    % IMSHOW(I,[])
    
    if (numel(varargin{2}) == 1)
        % IMSHOW(I,N)
        image_type = 'intensity';        
        cdata = varargin{1};
        N_gray_levels = varargin{2};
        
    elseif (isequal(size(varargin{2}), [1 2]))
        % IMSHOW(I,[a b])
        image_type = 'intensity';                
        cdata = varargin{1};
        clim = varargin{2};
        
    elseif (size(varargin{2},2) == 3)
        % IMSHOW(X,map)        
        image_type = 'indexed';
        cdata = varargin{1};
        map = varargin{2};
        
    elseif (isempty(varargin{2}))
        % IMSHOW(I,[])
        image_type = 'intensity';        
        cdata = varargin{1};
        clim = [min(cdata(:)) max(cdata(:))];
        
    else
        eid = 'Images:imshow:invalidInputs';
        error(eid, '%s', 'Invalid input arguments; see HELP IMSHOW');
        
    end
    
case 3
    % IMSHOW(x,y,RGB)
    % IMSHOW(x,y,I)
    % IMSHOW(R,G,B) OBSOLETE
    
    if (ndims(varargin{3}) == 3)
        % IMSHOW(x,y,RGB)        
        image_type = 'truecolor';                
        cdata = varargin{3};

        xdata = varargin{1};
        ydata = varargin{2};
        
    elseif (isvector(varargin{1}) && isvector(varargin{2}))
        % IMSHOW(x,y,I)
        image_type = 'intensity';        
        cdata = varargin{3};

        xdata = varargin{1};
        ydata = varargin{2};
        
    elseif isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
        % IMSHOW(R,G,B)
        wid = 'Images:imshow:obsoleteSyntax';
        warning(wid, '%s', ['IMSHOW(R,G,B) is an obsolete syntax. ',...
        'Use a three-dimensional array to represent RGB image.']);
        image_type = 'truecolor';            
        cdata = cat(3,varargin{:});

    else
        eid = 'Images:imshow:invalidType';
        error(eid, '%s', 'Invalid input arguments; see HELP IMSHOW');
        
    end
    
case 4
    % IMSHOW(x,y,I,N)
    % IMSHOW(x,y,I,[a b])
    % IMSHOW(x,y,X,MAP)
    % IMSHOW(x,y,I,[])
    
    if (numel(varargin{4}) == 1)
        % IMSHOW(x,y,I,N)
        image_type = 'intensity';        
        cdata = varargin{3};
        N_gray_levels = varargin{4};
        
    elseif (isequal(size(varargin{4}), [1 2]))
        % IMSHOW(x,y,I,[a b])
        image_type = 'intensity';        
        cdata = varargin{3};
        clim = varargin{4};
        
    elseif (size(varargin{4},2) == 3)
        % IMSHOW(x,y,X,map)
        image_type = 'indexed';        
        cdata = varargin{3};
        map = varargin{4};
        
    elseif (isempty(varargin{4}))
        % IMSHOW(x,y,I,[])
        image_type = 'intensity';        
        cdata = varargin{3};
        clim = [min(cdata(:)) max(cdata(:))];
        
    else
        eid = 'Images:imshow:invalidInputs';
        error(eid, '%s', 'Invalid input arguments.  See HELP IMSHOW');
        
    end

    xdata = varargin{1};
    ydata = varargin{2};

case 5
    % IMSHOW(x,y,R,G,B) OBSOLETE
    wid = 'Images:imshow:obsoleteSyntax';
    warning(wid, '%s', ['IMSHOW(x,y,R,G,B) is an obsolete syntax. ',...
    'Use a three-dimensional array to represent RGB image.']);
    image_type = 'truecolor';            
    cdata = cat(3,varargin{3:5});

    xdata = varargin{1};
    ydata = varargin{2};
    
otherwise    
    eid = 'Images:imshow:tooManyInputs';
    error(eid, '%s', 'Too many input arguments.  See HELP IMSHOW');
    
end

cdata = ValidateCdata(cdata);

if strcmp(image_type,'intensity') && strcmp(class(cdata),'logical')
    image_type = 'binary';
end

cdatamapping = GetCdataMapping(image_type);

if strcmp(cdatamapping,'scaled')
    map = GetMap(N_gray_levels);
    if isempty(clim)
        clim = GetClimFromCdataClass(cdata);
    end
    
end

if isempty(xdata) && isempty(ydata)
    xdata = [1 size(cdata,2)];
    ydata = [1 size(cdata,1)];
end

% Catch imshow(...,[]) case where input is constant.
if (~isempty(clim) && (clim(1) == clim(2)))
    % Do the Handle Graphics thing --- make the range [k-1 k+1].
    % Image will display as shade of gray.
    clim = double(clim) + [-1 1];
end

%%%
%%% ----------------------------------------
%%%
function [cdatamapping] = GetCdataMapping(image_type)

cdatamapping = 'direct';

% May want to treat binary images as 'direct'-indexed images for display
% in HG which requires no map.
%
% For now, they are treated as 'scaled'-indexed images for display in HG.

switch image_type
  case {'intensity','binary'}
    cdatamapping = 'scaled';
    
  case 'indexed'
    cdatamapping = 'direct';    
    
end

%%%
%%% ----------------------------------------
%%%
function [map] = GetMap(N_gray_levels)

if isempty(N_gray_levels)
    if (get(0,'ScreenDepth') > 16)
        N_gray_levels = 256;
    else
        N_gray_levels = 64;
    end
end    
map = gray(N_gray_levels);

%%%
%%% ----------------------------------------
%%%
function clim = GetClimFromCdataClass(cdata)

key_class = class(cdata);

switch key_class
  case 'uint8'
    clim = [0 255];
  
  case 'uint16'
    clim = [0 65535];
    
  case {'logical','double'}
    clim = [0 1];

  otherwise    
    eid = 'Images:imshow:invalidType';
    error(eid, '%s', 'Unsupported image class');

end

%%%
%%% ----------------------------------------
%%%
function cdata = ValidateCdata(cdata)

if ((ndims(cdata) > 3) || ((size(cdata,3) ~= 1) && (size(cdata,3) ~= 3)))
    eid = 'Images:imshow:unsupportedDimension';
    error(eid, '%s', 'Unsupported dimension')
end

if islogical(cdata) && (ndims(cdata) > 2)
    eid = 'Images:imshow:expected2D';
    error(eid, '%s', 'If input is logical (binary), it must be two-dimensional.');
end

% RGB images can be only uint8, uint16, or double
if ( (ndims(cdata) == 3)   && ...
     ~isa(cdata, 'double') && ...
     ~isa(cdata, 'uint8')  && ...
     ~isa(cdata, 'uint16') )
    eid = 'Images:imshow:invalidRGBClass';
    error(eid, 'RGB images must be uint8, uint16, or double.');
end

% Clip double RGB images to [0 1] range
if ( (ndims(cdata) == 3) && isa(cdata, 'double') )
    cdata(cdata > 1) = 1;
    cdata(cdata < 0) = 0;
end

% Catch complex CData case
if (~isreal(cdata))
    wid = 'Images:imshow:displayingRealPart';
    warning(wid, '%s', 'Displaying real part of complex input');
    cdata = real(cdata);
end


%%%
%%% Subfunction SingleImageDefaultPos
%%%
function tf = SingleImageDefaultPos(figHandle, axHandle)

if (length(findobj(axHandle, 'Type', 'image')) > 1)
    % More than one image in axes
    tf = 0;

else

    figKids = allchild(figHandle);
    kids = [findobj(figKids, 'Type', 'axes') ;
        findobj(figKids, 'Type', 'uicontrol', 'Visible', 'on')];
    if (length(kids) > 1)
        % The axes isn't the only thing around, so don't truesize
        tf = 0;
    else
        % Is axHandle in the default position?
        activeProperty = get(axHandle,'ActivePositionProperty');
        if (isequal(get(axHandle, activeProperty), ...
                    get(get(axHandle,'Parent'), ['DefaultAxes' activeProperty])))
            % Yes, call truesize
            tf = 1;
            
        else
            % No, don't call truesize
            tf = 0;
        end
    end
end
