function varargout = bwfill(varargin)
%BWFILL Fill background regions in binary image.
%
%   BWFILL is a grandfathered function that has been replaced by 
%   IMFILL.
%
%   BW2 = BWFILL(BW1,C,R,N) performs a flood-fill operation on
%   the input binary image BW1, starting from the pixel (R,C). If
%   R and C are equal-length vectors, the fill is performed in
%   parallel from the starting locations (R(k),C(k)). N can have
%   a value of either 4 or 8 (the default), where 4 specifies
%   4-connected foreground and 8 specifies 8-connected
%   foreground. The foreground of BW1 comprises the "on" pixels
%   (i.e., having value of 1).
%
%   BW2 = BWFILL(BW1,N) displays the image BW1 on the screen and
%   lets you select the starting points using the mouse. If you
%   omit BW1, BWFILL operates on the image in the current
%   axes. Use normal button clicks to add points. Press
%   <BACKSPACE> or <DELETE> to remove the previously selected 
%   point. A shift-click, right-click, or double-click selects
%   a final point and then starts the fill; pressing <RETURN>
%   finishes the selection without adding a point.
%
%   [BW2,IDX] = BWFILL(...) returns the linear indices of all
%   pixels filled by BWFILL.
%
%   BW2 = BWFILL(X,Y,BW1,Xi,Yi,N) uses the vectors X and Y to
%   establish a nondefault spatial coordinate system for BW1. Xi
%   and Yi are scalars or equal-length vectors that specify
%   locations in this coordinate system.
%
%   [X,Y,BW2,IDX,Xi,Yi] = BWFILL(...) returns the XData and YData
%   in X and Y; the output image in BW2; linear indices of all
%   filled pixels in IDX; and the fill starting points in Xi and
%   Yi.
%
%   BW2 = BWFILL(BW1,'holes',N) fills the holes in the binary
%   image BW1. BWFILL automatically determines which pixels are
%   in object holes, and then changes the value of those pixels
%   from 0 to 1. N defaults to 8 if you omit the argument.
%
%   [BW2,IDX] = BWFILL(BW1,'holes',N) returns the linear indices
%   of all pixels filled in by BWFILL.
%
%   If BWFILL is used with no output arguments, the resulting
%   image is displayed in a new figure.
%
%   Remarks
%   -------
%   BWFILL differs from many other binary image operations in
%   that it operates on background pixels, rather than foreground
%   pixels. If the foreground is 8-connected, the background is
%   4-connected, and vice versa. Note, however, that you specify
%   the connectedness of the foreground when you call BWFILL.
%
%   Class Support
%   -------------
%   The input image BW1 must be a numeric or logical matrix. The output
%   image BW2 is logical.
%
%   See also BWSELECT, IMFILL, ROIFILL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.31.4.3 $  $Date: 2003/08/01 18:08:34 $

try
    [xdata,ydata,I,xi,yi,r,c,style,newFig,fillHoles] = ParseInputs(varargin{:});
catch
    rethrow(lasterror);
end

if (fillHoles)
    % special type of fill
    J = I;
    J = padarray(J, [1 1], 0, 'both');
    [M,N] = size(J);
    rSeeds = [1:M       ones(1,N) 1:M         M*ones(1,N)];
    cSeeds = [ones(1,M) 1:N       N*ones(1,M) 1:N];
    J = bwfill(J, cSeeds, rSeeds, style);
    J = J(2:end-1,2:end-1);
    J = ~J | I;

    if (nargout > 0)
        varargout{1} = J;
        if (nargout > 1)
            varargout{2} = find(J & ~I);
        end
    else
        imshow(J);
    end
    
    return
end

[M,N] = size(I);
Ip = padarray(I,[1 1],1,'both');

% Adjust input seed locations for zero-padded input.
r = r(:)+1;
c = c(:)+1;

% Remove seed locations that are already one from the list.
if (~isempty(r))
    % Conditional necessary to work around uint8 array empty
    % matrix indexing bug in MATLAB 5.0.  -sle
    killIdx = find(Ip((c-1)*(M+2) + r) ~= 0);
    r(killIdx) = [];
    c(killIdx) = [];
end

idxList = r + (c-1)*(M+2);
idxList(Ip(idxList)) = [];

J = bwfillc(Ip, idxList, style);

J = J(2:M+1,2:N+1);

BW2 = J | I;

switch nargout
case 0
    % BWFILL(...)
    
    if (newFig)
       figure;
    end
    imshow(xdata,ydata,BW2);
    
case 1
    % BW2 = BWFILL(...)
    
    varargout{1} = BW2;
    
case 2
    % [BW2,IDX] = BWFILL(...)
    
    varargout{1} = BW2;
    varargout{2} = find(J & ~I);
    
otherwise
    % [X,Y,BW2,...] = BWFILL(...)
    
    varargout{1} = xdata;
    varargout{2} = ydata;
    varargout{3} = BW2;
    
    if (nargout >= 4)
        % [X,Y,BW2,IDX,...] = BWFILL(...)
        varargout{4} = find(J & ~I);
    end
    
    if (nargout >= 5)
        % [X,Y,BW2,IDX,Xi,...] = BWFILL(...)
        varargout{5} = xi;
    end
    
    if (nargout >= 6)
        % [X,Y,BW2,IDX,Xi,Yi] = BWFILL(...)
        varargout{6} = yi;
    end
    
    if (nargout >= 7)
        wid = 'Images:bwfill:tooManyOutputs';
        warning(wid, '%s', 'Too many output arguments');
    end
end

%%%
%%% Subfunction ParseInputs
%%%
function [xdata,ydata,I,xi,yi,r,c,style,newFig,fillHoles] = ParseInputs(varargin)

msg = '';
style = 8;
xdata = [];
ydata = [];
I = [];
xi = [];
yi = [];
r = [];
c = [];
newFig = 0;
fillHoles = 0;

switch nargin
case 0
    % BWFILL
    
    [xdata, ydata, I, flag] = getimage;
    if (flag == 0)
        eid = 'Images:bwfill:noImageFound';
        msg = 'Current axes does not contain an image';
        error(eid,'%s',msg);
    end
    newFig = 1; 
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(I,1), ydata, yi));
    c = round(axes2pix(size(I,2), xdata, xi));
    
case 1
    if ((prod(size(varargin{1})) == 1) & ...
                ((varargin{1} == 4) | (varargin{1} == 8)))
        % BWFILL(N)
        
        style = varargin{1};
        [xdata,ydata,I,flag] = getimage;
        if (flag == 0)
            eid = 'Images:bwfill:noImageFound';
            msg = 'Current axes does not contain an image';
            error(eid,'%s',msg);
        end
        
    else
        % BWFILL(BW)
        
        I = varargin{1};
        xdata = [1 size(I,2)];
        ydata = [1 size(I,1)];
        imshow(xdata,ydata,I);
        
    end
    
    newFig = 1;
    [xi,yi] = getpts;
    if (isempty(xi))
        eid = 'Images:bwfill:interactiveSelectionAborted';
        msg = 'Interactive point selection was aborted';
        error(eid,'%s',msg);
    end
    
    r = round(axes2pix(size(I,1), ydata, yi));
    c = round(axes2pix(size(I,2), xdata, xi));
    
case 2
    if (ischar(varargin{2}))
        if (varargin{2}(1) == 'h')
            % BWFILL(BW, 'holes')
            I = varargin{1};
            fillHoles = 1;
            style = 8;
            
        else
            eid = 'Images:bwfill:invalidInput';
            msg = 'Invalid input.';
            error(eid,'%s',msg);
        end
        
    else
    
        % BWFILL(BW, N)
    
        I = varargin{1};
        style = varargin{2};
        if ((style ~= 4) & (style ~= 8))
            eid = 'Images:bwfill:invalidN';
            msg = 'N must be 4 or 8';
            error(eid,'%s',msg);
        end
        
        xdata = [1 size(I,2)];
        ydata = [1 size(I,1)];
        
        imshow(xdata, ydata, I);
        newFig = 1;
        [xi,yi] = getpts;
        if (isempty(xi))
            eid = 'Images:bwfill:interactiveSelectionAborted';
            msg = 'Interactive point selection was aborted';
            error(eid,'%s',msg);
        end
        
        r = round(axes2pix(size(I,1), ydata, yi));
        c = round(axes2pix(size(I,2), xdata, xi));
        
    end
    
case 3
    if (ischar(varargin{2}))
        if (varargin{2}(1) == 'h')
            % BWFILL(BW, 'holes', N)
            I = varargin{1};
            style = varargin{3};
            fillHoles = 1;
            
        else
            eid = 'Images:bwfill:invalidInput';
            msg = 'Invalid input.';
            error(eid,'%s',msg);
        end
        
    else
    
        % BWFILL(BW,Xi,Yi)
        
        I = varargin{1};
        xdata = [1 size(I,2)];
        ydata = [1 size(I,1)];
        xi = varargin{2};
        yi = varargin{3};
        r = round(yi);
        c = round(xi);
        
    end
    
case 4
    % BWFILL(BW,Xi,Yi,N)
    
    I = varargin{1};
    xdata = [1 size(I,2)];
    ydata = [1 size(I,1)];
    xi = varargin{2};
    yi = varargin{3};
    r = round(yi);
    c = round(xi);
    style = varargin{4};
    
case 5
    % BWFILL(X,Y,BW,Xi,Yi)
    
    xdata = varargin{1};
    ydata = varargin{2};
    I = varargin{3};
    xi = varargin{4};
    yi = varargin{5};
    
    r = round(axes2pix(size(I,1), ydata, yi));
    c = round(axes2pix(size(I,2), xdata, xi));
    
case 6
    % BWFILL(X,Y,BW,Xi,Yi,N)
    
    xdata = varargin{1};
    ydata = varargin{2};
    I = varargin{3};
    xi = varargin{4};
    yi = varargin{5};
    style = varargin{6};
    
    r = round(axes2pix(size(I,1), ydata, yi));
    c = round(axes2pix(size(I,2), xdata, xi));
    
otherwise
    eid = 'Images:bwfill:tooManyInputs';  
    msg = 'Too many input arguments';
    error(eid,'%s',msg);
end

if ~islogical(I)
  I = I ~= 0;
end

badPix = find((r < 1) | (r > size(I,1)) | ...
        (c < 1) | (c > size(I,2)));
if (~isempty(badPix))
    wid = 'Images:bwfill:outOfRangeCoordinates';
    warning(wid,'%s','Ignoring out-of-range coordinates');
    r(badPix) = [];
    c(badPix) = [];
end
