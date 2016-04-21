function varargout = impixel(varargin)
%IMPIXEL Determine pixel color values.
%   IMPIXEL returns the red, green, and blue color values of
%   specified image pixels. In the syntaxes below, IMPIXEL
%   displays the input image and waits for you to specify the
%   pixels with the mouse:
%
%        P = IMPIXEL(I)
%        P = IMPIXEL(X,MAP)
%        P = IMPIXEL(RGB)
%
%   If you omit the input arguments, IMPIXEL operates on the
%   image in the current axes.
%
%   Use normal button clicks to select pixels. Press <BACKSPACE>
%   or <DELETE> to remove the previously selected pixel. A
%   shift-click, right-click, or double-click adds a final pixel
%   and ends the selection; pressing <RETURN> finishes the
%   selection without adding a pixel.
%
%   When you finish selecting pixels, IMPIXEL returns an M-by-3
%   matrix of RGB values in the supplied output argument. If you
%   do not supply an output argument, IMPIXEL returns the matrix
%   in ANS.
%
%   You can also specify the pixels noninteractively, using these
%   syntaxes:
%
%        P = IMPIXEL(I,C,R)
%        P = IMPIXEL(X,MAP,C,R)
%        P = IMPIXEL(RGB,C,R)
%
%   R and C are equal-length vectors specifying the coordinates
%   of the pixels whose RGB values are returned in P. The k-th
%   row of P contains the RGB values for the pixel (R(k),C(k)).
%
%   If you supply three output arguments, IMPIXEL returns the
%   coordinates of the selected pixels:
%
%        [C,R,P] = IMPIXEL(...)
%
%   To specify a nondefault spatial coordinate system for the
%   input image, use these syntaxes:
%
%        P = IMPIXEL(x,y,I,xi,yi)
%        P = IMPIXEL(x,y,X,MAP,xi,yi)
%        P = IMPIXEL(x,y,RGB,xi,yi)
%
%   x and y are 2-element vectors specifying the image XData and
%   YData. xi and yi are equal-length vectors specifying the
%   spatial coordinates of the pixels whose RGB values are
%   returned in P. If you supply three output arguments, IMPIXEL
%   returns the coordinates of the selected pixels:
%
%        [xi,yi,P] = IMPIXEL(x,y,...)
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, double, or logical. 
%   All other inputs and outputs are of class double.
%
%   Example
%   -------
%       RGB = imread('peppers.png');
%       c = [12 146 410];
%       r = [104 156 129];
%       pixels = impixel(RGB,c,r)
%
%   See also IMPROFILE.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.23.4.3 $  $Date: 2003/08/23 05:52:38 $

[a,cm,xi,yi,x,y] = parse_inputs(varargin{:});

checkinput(a,'uint8 uint16 double logical', 'real nonsparse', ...
           mfilename, 'a', 1);
if ~isempty(cm)
  checkindexedimage(a);
end
RGB_img = (ndims(a)==3 & size(a,3)==3);

m = size(a,1);
n = size(a,2);

% Minimum and maximum x & y values
xmin = min(x(:)); ymin = min(y(:));
xmax = max(x(:)); ymax = max(y(:));

dx = (xmax-xmin)/max(n-1,1);
dy = (ymax-ymin)/max(m-1,1);
xx = xmin:dx:xmax;
yy = ymin:dy:ymax;

if (numel(a) ~= 1)
    if islogical(a)
        a = double(a);
    end
    if RGB_img
        rgb(:,:,1) = interp2(xx,yy,a(:,:,1),xi,yi,'*nearest');
        rgb(:,:,2) = interp2(xx,yy,a(:,:,2),xi,yi,'*nearest');
        rgb(:,:,3) = interp2(xx,yy,a(:,:,3),xi,yi,'*nearest');
    else
        rgb = interp2(xx,yy,a,xi,yi,'*nearest');
    end
else
    rgb = repmat(a,length(xi),1);
end

% xi,yi may not be in pixel coordinates.  
xi_pix = axes2pix(n, [xmin xmax], xi);
yi_pix = axes2pix(m, [ymin ymax], yi);

% Find any points which are not in image
pixOutOfImage = find(xi_pix<1 | xi_pix>n | yi_pix<1 | yi_pix>m);

if isempty(cm),   % If we have grayscale or RGB image
   if RGB_img    
      rgb = reshape(rgb, length(xi), 3);
   else           % Grayscale
      rgb = [rgb(:) rgb(:) rgb(:)];
   end
   if ~isa(rgb, 'double')  % Promote to double, insert NAN's in right places
       rgb = double(rgb);
      if ~isempty(pixOutOfImage)  
         rgb(pixOutOfImage,:) = NaN;
      end
   end
else
   if ~isa(rgb,'double')
      rgb = im2double(rgb, 'indexed');  % RGB contains colormap values
   end
   % If NaN's, replace temporarily with 1, then index
   % into colormap, then change 'em back to NaN's.
   % isnan doesn't take uint8's, so promote rgb to double
   if ~isempty(pixOutOfImage), 
      rgb(pixOutOfImage) = 1; 
   end
   rgb = cm(rgb(:),:);
   if ~isempty(pixOutOfImage), 
      rgb(pixOutOfImage,:) = NaN; 
   end
end

switch nargout
case {0, 1}
   varargout{1} = rgb;
case 3
   varargout{1} = xi;
   varargout{2} = yi;
   varargout{3} = rgb;
otherwise
   msgId = 'Images:impixel:invalidNumberOfArguments';
   msg = 'IMPIXEL can only return 0,1,or 3 output arguments.';
   error(msgId, '%s', msg);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [a,cm,xi,yi,x,y] = parse_inputs(varargin)
% a    The image
% cm   The colormap (possibly empty)
% xi   X Indices of selected pixels - in rounded Pixel Coordinates
% yi   Y Indices of selected pixels - in rounded pixel coordinates
% x    vector returned by X=get(image_hdl, 'XData')
% y    vector returned by Y=get(image_hdl, 'YData') 

checknargin(0, 6, nargin, mfilename);

if (nargin < 3),
    if (nargin == 0),
        % Get information from the current figure
        [x,y,a,kind] = getimage;
        if ~kind, 
            msgId = 'Images:impixel:imageNotFound';
            msg = 'An image must be currently active in a figure window.';
            error(msgId, '%s', msg);
        end
        if kind==1, 
            cm = colormap; 
        else 
            cm = []; 
        end

        M = size(a,1);
        N = size(a,2);
   
        % Get info from user
        [xi,yi] = getpts(gcf);
    
    elseif (nargin == 1),  % impixel(I) or impixel(RGB)
        a = varargin{1};
        cm = [];
        h = imshow(a);
        % Get info from user
        [xi,yi] = getpts(get(h,'Parent'));
        M = size(a,1);
        N = size(a,2);
       
    else         % impixel(X,map)
        a = varargin{1};
        cm = varargin{2};
        h = imshow(a,cm);
        
        % Get info from user
        [xi,yi] = getpts(get(h,'Parent'));
        M = size(a,1);
        N = size(a,2);
        
    end
    x = [1 N]; % Pixel Coordinates
    y = [1 M];  
    xi = round(axes2pix(N, x, xi));
    yi = round(axes2pix(M, y, yi));
end
    
if (nargin == 3)        % impixel(I,xi,yi) or impixel(RGB,xi,yi)
    a = varargin{1}; 
    xi = varargin{2}; 
    yi = varargin{3};
    x = [1 size(a,2)]; 
    y = [1 size(a,1)];
    cm = [];
end

if (nargin == 4)  % impixel(X,map,xi,yi)
    a = varargin{1}; 
    cm = varargin{2}; 
    xi = varargin{3};
    yi =  varargin{4};
    x = [1 size(a,2)]; 
    y = [1 size(a,1)];
end

if (nargin == 5)  % impixel(x,y,I or RGB ,xi,yi)
    x = varargin{1}; 
    y = varargin{2}; 
    a = varargin{3}; 
    xi = varargin{4}; 
    yi = varargin{5};
    cm = [];
end

if (nargin == 6) % impixel(x,y,X,map,xi,yi)
    x = varargin{1}; 
    y = varargin{2}; 
    a = varargin{3}; 
    cm = varargin{4};
    xi = varargin{5}; 
    yi = varargin{6};
end

if length(xi) ~= length(yi)
    msgId = 'Images:impixel:notSameSize';
    msg = 'Xi and Yi must have the same length.';
    error(msgId, '%s', msg);
end

%-------------------------------------------------------------
%CHECKINDEXEDIMAGE checks if a is a valid indexed image

function checkindexedimage(a)
  msgId = 'Images:impixel:invalidIndexedImage';
  msg = 'X is an invalid indexed image.';

  if ndims(a)~=2 || isempty(a)
    error(msgId, '%s', msg);
  end
  if isa(a,'double')
    [m,n] = size(a);
    % At first just test a small chunk to get a possible quick negative
    chunk = a(1:min(m,10),1:min(n,10));         
    flag = min(chunk(:))>=1 & all((chunk(:)-floor(chunk(:)))==0);
    % If the chunk is an indexed image, test the whole image
    if flag
      flag = min(a(:))>=1 & all((a(:)-floor(a(:)))==0);
    end
    if flag==0
      error(msgId, '%s', msg);
    end
  end
