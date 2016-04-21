function varargout = bwselect(varargin)
%BWSELECT Select objects in binary image.
%   BW2 = BWSELECT(BW1,C,R,N) returns a binary image containing
%   the objects that overlap the pixel (R,C). R and C can be
%   scalars or equal-length vectors. If R and C are vectors, BW2
%   contains the set of objects overlapping with any of the
%   pixels (R(k),C(k)). N can have a value of either 4 or 8 (the
%   default), where 4 specifies 4-connected objects and 8
%   specifies 8-connected objects. Objects are connected sets of
%   "on" pixels (i.e., having value of 1).
%
%   BW2 = BWSELECT(BW1,N) displays the image BW1 on the screen
%   and lets you select the (R,C) coordinates using the mouse. If
%   you omit BW1, BWSELECT operates on the image in the current
%   axes. Use normal button clicks to add points. Pressing
%   <BACKSPACE> or <DELETE> removes the previously selected
%   point. A shift-click, right-click, or double-click selects
%   the final point; pressing <RETURN> finishes the selection
%   without adding a point.
%
%   [BW2,IDX] = BWSELECT(...) returns the linear indices of the 
%   pixels belonging to the selected objects.
%
%   BW2 = BWSELECT(X,Y,BW1,Xi,Yi,N) uses the vectors X and Y to
%   establish a nondefault spatial coordinate system for BW1. Xi
%   and Yi are scalars or equal-length vectors that specify
%   locations in this coordinate system.
%
%   [X,Y,BW2,IDX,Xi,Yi] = BWSELECT(...) returns the XData and
%   YData in X and Y; the output image in BW2; linear indices of
%   the pixels belonging to the selected objects in IDX; and the 
%   specified spatial coordinates Xi and Yi.
%
%   If bwselect is called with no output arguments, the resulting
%   image is displayed in a new figure.
%
%   Class Support
%   ------------- 
%   The input image BW1 can be logical or any numeric type and 
%   must be 2-D and nonsparse.  The output image BW2 is logical.
%
%   Example
%   -------
%       BW1 = imread('text.png');
%       c = [126 187 11];
%       r = [34 172 20];
%       BW2 = bwselect(BW1,c,r,4);
%       imview(BW1)
%       imview(BW2)
%
%   See also IMFILL, BWLABEL, ROIPOLY, ROIFILL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.23.4.2 $  $Date: 2003/05/03 17:50:13 $

[xdata,ydata,BW,xi,yi,r,c,n,newFig] = ParseInputs(varargin{:});

seed_indices = sub2ind(size(BW), r(:), c(:));
BW2 = imfill(~BW, seed_indices, n);
BW2 = BW2 & BW;

switch nargout
case 0
    % BWSELECT(...)
    
    if (newFig)
       figure;
    end
    imshow(xdata,ydata,BW2);
    
case 1
    % BW2 = BWSELECT(...)
    
    varargout{1} = BW2;
    
case 2
    % [BW2,IDX] = BWSELECT(...)
    
    varargout{1} = BW2;
    varargout{2} = find(BW2);
    
otherwise
    % [X,Y,BW2,...] = BWSELECT(...)
    
    varargout{1} = xdata;
    varargout{2} = ydata;
    varargout{3} = BW2;
    
    if (nargout >= 4)
        % [X,Y,BW2,IDX,...] = BWSELECT(...)
        varargout{4} = find(BW2);
    end
    
    if (nargout >= 5)
        % [X,Y,BW2,IDX,Xi,...] = BWSELECT(...)
        varargout{5} = xi;
    end
    
    if (nargout >= 6)
        % [X,Y,BW2,IDX,Xi,Yi] = BWSELECT(...)
        varargout{6} = yi;
    end
    
end

%%%
%%% Subfunction ParseInputs
%%%
function [xdata,ydata,BW,xi,yi,r,c,style,newFig] = ParseInputs(varargin)

style = 8;
check_style = false;
xdata = [];
ydata = [];
BW = [];
check_BW = false;
xi = [];
yi = [];
r = [];
c = [];
newFig = 0;

checknargin(0,6,nargin,mfilename);

switch nargin
case 0
    % BWSELECT
    
    [xdata, ydata, BW, flag] = getimage;
    if (flag == 0)
        msgId = sprintf('Images:%s:noImageFound', mfilename);
        error(msgId, 'The function %s expected to find an image object in the current axes.', ...
              mfilename);
    end
    newFig = 1; 
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    
case 1
    if ((prod(size(varargin{1})) == 1) & ...
                ((varargin{1} == 4) | (varargin{1} == 8)))
        % BWSELECT(N)
        
        style = varargin{1};
        [xdata,ydata,BW,flag] = getimage;
        if (flag == 0)
            msgId = sprintf('Images:%s:noImageFound', mfilename);
            error(msgId, 'The function %s expected to find an image object in the current axes.', ...
                  mfilename);
        end
        
    else
        % BWSELECT(BW)
        
        BW = varargin{1};
        check_BW = true;
        BW_position = 1;
        xdata = [1 size(BW,2)];
        ydata = [1 size(BW,1)];
        imshow(xdata,ydata,BW);
        
    end
    
    newFig = 1;
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    
case 2
    % BWSELECT(BW, N)
    
    BW = varargin{1};
    BW_position = 1;
    check_BW = true;
    
    style = varargin{2};
    style_position = 2;
    check_style = true;
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    
    imshow(xdata, ydata, BW);
    newFig = 1;
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    
case 3
    % BWSELECT(BW,Xi,Yi)

    BW = varargin{1};
    BW_position = 1;
    check_BW = true;
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    xi = varargin{2};
    yi = varargin{3};
    r = round(yi);
    c = round(xi);
    
case 4
    % BWSELECT(BW,Xi,Yi,N)
    
    BW = varargin{1};
    BW_position = 1;
    check_BW = true;
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    xi = varargin{2};
    yi = varargin{3};
    r = round(yi);
    c = round(xi);
    
    style = varargin{4};
    style_position = 4;
    check_style = true;
    
case 5
    % BWSELECT(X,Y,BW,Xi,Yi)
    
    xdata = varargin{1};
    ydata = varargin{2};

    BW = varargin{3};
    BW_position = 3;
    check_BW = true;
    
    xi = varargin{4};
    yi = varargin{5};
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    
case 6
    % BWSELECT(X,Y,BW,Xi,Yi,N)
    
    xdata = varargin{1};
    ydata = varargin{2};
    
    BW = varargin{3};
    BW_position = 3;
    check_BW = true;
    
    xi = varargin{4};
    yi = varargin{5};
    
    style = varargin{6};
    style_position = 6;
    check_style = true;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    
end

if check_BW
    checkinput(BW,{'logical' 'numeric'},{'2d' 'nonsparse'}, ...
    mfilename, 'BW', BW_position);
end

if ~islogical(BW)
    BW = BW ~= 0;
end

if check_style
    checkinput(style, {'numeric'}, {'scalar'}, mfilename, ...
               'N', 2);
end

badPix = find((r < 1) | (r > size(BW,1)) | ...
              (c < 1) | (c > size(BW,2)));
if (~isempty(badPix))
    msgId = sprintf('Images:%s:outOfRange', mfilename);
    warning(msgId, '%s', 'Ignoring out-of-range input coordinates');
    r(badPix) = [];
    c(badPix) = [];
end 

