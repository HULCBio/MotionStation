function varargout = getimage(varargin)
%GETIMAGE Get image data from axes.
%   A = GETIMAGE(H) returns the first image data contained in
%   the Handle Graphics object H.  H can be a figure, axes,
%   image, or texture-mapped surface.  A is identical to the
%   image CData; it contains the same values and is of the same
%   class (uint8, uint16, double, etc.) as the image CData. 
%   If H is not an image or does not contain an image or 
%   texture-mapped surface, A is empty.
%
%   [X,Y,A] = GETIMAGE(H) returns the image XData in X and the
%   YData in Y. XData and YData are two-element vectors that
%   indicate the range of the x-axis and y-axis.
%
%   [...,A,FLAG] = GETIMAGE(H) returns an integer flag that
%   indicates the type of image H contains. FLAG is one of these
%   values:
%   
%       0   not an image; A is returned as an empty matrix
%
%       1   indexed image
%
%       2   intensity image with values in standard range ([0,1]
%           for double arrays, [0,255] for uint8 arrays,
%           [0,65535] for uint16 arrays)
%
%       3   intensity data, but not in standard range
%
%       4   RGB image
%
%   [...] = GETIMAGE returns information for the current axes. It
%   is equivalent to [...] = GETIMAGE(GCA).
%
%   Class Support
%   -------------
%   The output array A is of the same class as the image
%   CData. All other inputs and outputs are of class double.
%
%   Example
%   -------
%   After using imshow to display an image directly from a file,
%   use GETIMAGE to get the image data into the workspace.
%
%       imshow rice.png
%       I = getimage;

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.20.4.2 $  $Date: 2003/01/26 05:55:28 $

% Subfunctions:
% - FINDIM
% - GET_IMAGE_INFO

checknargin(0,1,nargin,mfilename);
him = findim(varargin{:});

[x,y,A,state] = get_image_info(him);

switch nargout
case 0
    % GETIMAGE(...)
    varargout{1} = A;
    
case 1
    % A = GETIMAGE(...)
    varargout{1} = A;
    
case 2
    % [A,FLAG] = GETIMAGE(...)
    varargout{1} = A;
    varargout{2} = state;
    
case 3
    % [x,y,A] = GETIMAGE(...)
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = A;
    
case 4
    % [x,y,A,FLAG] = GETIMAGE(...)
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = A;
    varargout{4} = state;
    
otherwise
    eid = sprintf('Images:%s:tooManyOutputArgs',mfilename);
    msg = 'Too many output arguments.';
    error(eid,msg);
    
end

%----------------------------------------------------------------------
% Local Function: FINDIM
%----------------------------------------------------------------------
function him = findim(varargin)
%FINDIM Find image object.
%   HIM = FINDIM(H) searches for a valid Handle Graphics Image
%   object starting from the handle H and returns its handle in
%   HIM. H may be the handle of a Figure, Axes, or Image object.
%
%   If H is an Image object, FINDIM returns it.
%
%   If H is an Axes object, FINDIM searches H for Image objects.
%   If more than one Image object is found in the Axes, FINDIM
%   looks to see if one of the Images is the current object. If
%   so, FINDIM returns that Image. Otherwise, FINDIM returns the
%   highest Image in the stacking order.
%
%   If H is a Figure object, FINDIM searches H's current Axes.
%
%   HIM = FINDIM searchs the current Figure.

him = [];
if (nargin == 0)
    rootKids = get(0,'Children');
    if (~isempty(rootKids))
        figHandle = get(0,'CurrentFigure');
        figAxes = findobj(get(figHandle, 'Children'), 'flat', 'Type', 'axes');
        if (~isempty(figAxes))
            axHandle = get(figHandle, 'CurrentAxes');
            him = findim_in_axes(axHandle);
        end
    end
else
    % User specified a handle.
    h = varargin{1};
    h = h(1);
    if (~ishandle(h))
        eid = sprintf('Images:%s:invalidHandleH',mfilename);
        msg = sprintf('%s: Invalid handle H.',upper(mfilename));
        error(eid,msg);
    end
    switch get(varargin{1},'Type')
    case 'figure'
        figHandle = varargin{1};
        figAxes = findobj(get(figHandle, 'Children'), 'flat', 'Type', 'axes');
        if (~isempty(figAxes))
            axHandle = get(figHandle, 'CurrentAxes');
            him = findim_in_axes(axHandle);
        end
        
    case 'axes'
        axHandle = varargin{1};
        him = findim_in_axes(axHandle);
        
    case 'image'
        him = h;
        
    otherwise
        eid = sprintf('Images:%s:handleHMustBeFigAxesOrImage',mfilename);
        msg = sprintf('%s: Input handle H must be a figure, axes, or image.',upper(mfilename));
        error(eid,msg);
        
    end
    
end

%----------------------------------------------------------------------
% Local Function: FINDIM_IN_AXES
%----------------------------------------------------------------------
function him = findim_in_axes(axHandle)

figHandle = get(axHandle, 'Parent');
% If the current object is a texture-mapped surface, use that.
currentObj = get(figHandle, 'CurrentObject');
if (~isempty(currentObj) & strcmp(get(currentObj,'type'),'surface') & ...
            strcmp(get(currentObj,'FaceColor'),'texturemap'))
    him = currentObj;
else
    him = findobj(axHandle, 'Type', 'image');
    if (length(him) > 1)
        % Found more than one image in the axes.
        % If one of the images is the current object, use it.
        % Otherwise, use the first image in the stacking order.
        if (isempty(currentObj))
            % No current object; use the one on top.
            him = him(1);
        else
            % If the current object is one of the images
            % we found, use it.
            idx = find(him == currentObj);
            if (isempty(idx))
                him = him(1);
            else
                him = him(idx);
            end
        end
    end
end
if (isempty(him))
    % Didn't find an image.  Is there a texturemapped surface we can use?
    him = findobj(axHandle, 'Type', 'surface', ...
            'FaceColor', 'texturemap');
    if (~isempty(him))
        him = him(1);
    end
end
            
            
%----------------------------------------------------------------------
% Local Function: GET_IMAGE_INFO
%----------------------------------------------------------------------
function [x,y,A,state] = get_image_info(him)

if (isempty(him))
    % We didn't find an image.
    x = [];
    y = [];
    A = [];
    state = 0;
    
elseif (strcmp(get(him, 'Type'), 'surface'))
    % We found a texturemapped surface object.
    A = get(him, 'CData');
    x = get(him, 'XData');
    y = get(him, 'YData');
    state = 2;
    
else
    % We did find an image.  Find out about it.
    userdata = get(him, 'UserData');
    cdatamapping = get(him, 'CDataMapping');
    x = get(him, 'XData');
    y = get(him, 'YData');
    A = get(him, 'CData');
    
    if ((ndims(A) == 3) & (size(A,3) == 3))
        % We have an RGB image
        state = 4;
        
    else
        % Not an RGB image
    
        if (isequal(cdatamapping,'direct'))
            % Do we have an indexed image or an old-style intensity
            % or scaled image?
            
            if (isequal(size(userdata), [1 2]))
                % We have an old-style intensity or scaled image.
                
                % How long is the colormap?
                N = size(get(get(get(him,'Parent'),'Parent'),'Colormap'),1);
                
                if (isequal(userdata, [0 1]))
                    % We have an old-style intensity image.
                    A = (A-1)/(N-1);
                    state = 2;
                    
                else
                    % We have an old-style scaled image.
                    A = (A-1)*((userdata(2)-userdata(1))/(N-1))+userdata(1);
                    state = 3;
                    
                end
                
            else
                % We have an indexed image.
                state = 1;
                
            end
            
        else
            % CDataMapping is 'scaled'
            
            hax = get(him, 'Parent');
            clim = get(hax, 'CLim');
            if ((isa(A,'double') & isequal(clim,[0 1])) | ...
                  (isa(A,'uint8') & isequal(clim,[0 255])) | ...
                  (isa(A,'uint16') & isequal(clim,[0 65535])))
                % We have an intensity image.
                state = 2;
                
            else
                % We have a scaled image.
                state = 3;
                
            end
        end
        
    end
    
end
