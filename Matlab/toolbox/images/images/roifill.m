function varargout = roifill(varargin)
%ROIFILL Smoothly interpolate within arbitrary image region.
%   ROIFILL fills in a specified polygon in an intensity
%   image. It smoothly interpolates inward from the pixel values
%   on the boundary of the polygon by solving Laplace's
%   equation. ROIFILL can be used, for example, to "erase" small
%   objects in an image.
%
%   J = ROIFILL(I,C,R) fills in the polygon specified by C and R,
%   which are equal-length vectors containing the row-column
%   coordinates of the pixels on vertices of the polygon. The
%   k-th vertex is the pixel (R(k),C(k)).
%
%   J = ROIFILL(I) displays the image I on the screen and lets
%   you specify the polygon using the mouse. If you omit I,
%   ROIFILL operates on the image in the current axes. Use normal
%   button clicks to add vertices to the polygon. Pressing
%   <BACKSPACE> or <DELETE> removes the previously selected
%   vertex. A shift-click, right-click, or double-click adds a
%   final vertex to the selection and then starts the fill;
%   pressing <RETURN> finishes the selection without adding a
%   vertex.
%
%   J = ROIFILL(I,BW) uses BW (a binary image the same size as I)
%   as a mask. ROIFILL fills in the regions in I corresponding to
%   the nonzero pixels in BW. If there are multiple regions,
%   ROIFILL performs the interpolation on each region
%   independently.
%
%   [J,BW] = ROIFILL(...) returns the binary mask used to
%   determine which pixels in I get filled. BW is a binary image
%   the same size as I with 1's for pixels corresponding to the
%   interpolated region of I and 0's elsewhere.
%
%   J = ROIFILL(x,y,I,xi,yi) uses the vectors x and y to
%   establish a nondefault spatial coordinate system. xi and yi
%   are equal-length vectors that specify polygon vertices as
%   locations in this coordinate system.
%
%   [x,y,J,BW,xi,yi] = ROIFILL(...) returns the XData and YData
%   in x and y; the output image in J; the mask image in BW; and
%   the polygon coordinates in xi and yi. xi and yi are empty if
%   the ROIFILL(I,BW) form is used.
%
%   If ROIFILL is called with no output arguments, the resulting
%   image is displayed in a new figure.
%
%   Class Support
%   -------------
%   The input image I can be of class uint8, uint16, or double.
%   The input binary mask BW can be numeric or logical. The
%   output binary mask BW is always logical. The output image 
%   J is of the same class as I. All other inputs and outputs 
%   are of class double.
%
%   Example
%   -------
%       I = imread('eight.tif');
%       c = [222 272 300 270 221 194];
%       r = [21 21 75 121 121 75];
%       J = roifill(I,c,r);
%       imview(I), imview(J)
%
%   See also ROIFILT2, ROIPOLY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.22.4.4 $  $Date: 2003/08/23 05:54:39 $

[xdata,ydata,I,xi,yi,mask,newFig] = ParseInputs(varargin{:});

% Find the perimeter pixels of the specified region; these will
% be used to form the boundary conditions for the soap film PDE.
perimeter = bwperim(mask);

% Find the interior pixels; these are the pixels that will be
% replaced in the output image.
interior = mask & ~perimeter;

% Number the interior pixels in a grid matrix.
idx = find(interior);
grid = zeros(size(mask));
grid(idx) = 1:length(idx);

% Use the boundary pixels to form the right side of the linear system.
[M,N] = size(grid);

% Get the perimeter values.
perimValues = zeros(M,N);
perimIdx = find(perimeter);
perimValues(perimIdx) = I(perimIdx);

rightside = zeros(M,N);
rightside(2:(M-1),2:(N-1)) = perimValues(1:(M-2),2:(N-1)) + ...
    perimValues(3:M,2:(N-1)) + perimValues(2:(M-1),1:(N-2)) + ...
    perimValues(2:(M-1),3:N);
rightside = rightside(idx);

% Form the sparse D matrix from the numbered nodes of the grid matrix.
% This part is borrowed from toolbox/matlab/demos/delsq.m.
% Connect interior points to themselves with 4's.
i = grid(idx);
j = grid(idx);
s = 4*ones(size(idx));

% for k = north, east, south, west
for k = [-1 M 1 -M]
  % Possible neighbors in the k-th direction
  Q = grid(idx+k);
  % Index of points with interior neighbors
  q = find(Q);
  % Connect interior points to neighbors with -1's.
  i = [i; grid(idx(q))];
  j = [j; Q(q)];
  s = [s; -ones(length(q),1)];
end
D = sparse(i,j,s);

% Solve the linear system.
x = D \ rightside;

result = I;

result(idx) = x;

switch nargout
 case 0
  % ROIFILL(...)
  
  if (newFig)
    figure;
  end
  if (~isequal(xdata, [1 size(result,2)]) || ...
      ~isequal(ydata, [1 size(result,1)]))
    imshow(xdata,ydata,result);
  else
    imshow(result);
  end
  
 case 1
  % J = ROIFILL(...)
  
  varargout{1} = result;
  
 case 2
  % [J,MASK] = ROIFILL(...)
  
  varargout{1} = result;
  varargout{2} = mask;
  
 otherwise
  % [X,Y,J,...] = ROIFILL(...)
  
  varargout{1} = xdata;
  varargout{2} = ydata;
  varargout{3} = result;
  
  if (nargout >= 4)
    % [X,Y,J,MASK,...] = ROIFILL(...)
    varargout{4} = mask;
  end
  
  if (nargout >= 5)
    % [X,Y,J,MASK,Xi,...] = ROIFILL(...)
    varargout{5} = xi;
  end
  
  if (nargout >= 6)
    % [X,Y,J,MASK,Xi,Yi] = ROIFILL(...)
    varargout{6} = yi;
  end
  
  if (nargout >= 7)
      wid = sprintf('Images:%s:tooManyOutputArgs',mfilename);
      warning(wid,'%s','Too many output arguments.');
  end
end


%%%
%%% FUNCTION ParseInputs
%%%
function [xdata,ydata,I,xi,yi,mask,newFig] = ParseInputs(varargin)

  xdata = [];
  ydata = [];
  I = [];
  xi = [];
  yi = [];
  mask = [];
  newFig = 0;
  msg = '';

  switch nargin
   case 0
    % ROIFILL
    
    [xdata, ydata, I, flag] = getimage;
    if (flag == 0)
      msg = 'Current axes does not contain an image.';
      eid = sprintf('Images:%s:currentAxesMissingImage',mfilename);    
      error(eid,'%s',msg);
    end
    if (flag == 1)
      msg = 'Indexed images are not supported for ROIFILL.';
      eid = sprintf('Images:%s:indexedNotSupported',mfilename);    
      error(eid,'%s',msg);
    end
    isvalid(I);
    [mask,xi,yi] = roipoly;
    newFig = 1;
    
   case 1
    % ROIFILL(I)
    
    I = varargin{1};
    isvalid(I);
    xdata = [1 size(I,2)];
    ydata = [1 size(I,1)];
    imshow(I);
    
    [mask,xi,yi] = roipoly;
    newFig = 1;
    
   case 2
    % ROIFILL(I, MASK)

    I = varargin{1};
    isvalid(I);
    xdata = [1 size(I,2)];
    ydata = [1 size(I,1)];
    mask = varargin{2};
    if (~all(size(mask) == size(I)))
      msg = 'MASK must be the same size as I.';
      eid = sprintf('Images:%s:maskMustBeSameSizeAsI',mfilename);    
      error(eid,'%s',msg);
    end
    if ~islogical(mask) %convert to logical
      mask = mask~=0;
    end
    
   case 3
    % ROIFILL(I, Xi, Yi)

    I = varargin{1};
    isvalid(I);
    xdata = [1 size(I,2)];
    ydata = [1 size(I,1)];
    xi = varargin{2};
    yi = varargin{3};
    if ( min([size(xi) size(yi)]) > 1 || length(xi) ~= length(yi) )
      msg = 'X and Y must be vectors with the same length';
      eid = sprintf('Images:%s:xAndYNotSameSize',mfilename);    
      error(eid,'%s',msg);
    end
    [r,c] = size(I);
    mask = roipoly(r, c, xi, yi);
    
   case 5
    % ROIFILL(x, y, I, Xi, Yi)
    
    xdata = varargin{1};
    ydata = varargin{2};    
    I = varargin{3};
    isvalid(I);
    xi = varargin{4};
    yi = varargin{5};
    if ( min([size(xi) size(yi)]) > 1 || length(xi) ~= length(yi) )
      msg = 'X and Y must be vectors with the same length.';
      return;
    end
    [r,c] = size(I);
    mask = roipoly(xdata, ydata, r, c, xi, yi);
    
   otherwise
    msg = 'Too many input arguments.';
    eid = sprintf('Images:%s:tooManyInputs',mfilename);    
    error(eid,'%s',msg);
    
  end

  if (min(size(I)) < 3)
    msg = 'I must contain at least 3 pixels.';
    eid = sprintf('Images:%s:notEnoughPixels',mfilename);    
    error(eid,'%s',msg);
  
  end

%-----------------------------------------------
%ISVALID checks if the image is a valid for ROIFILL

function msg = isvalid(I)
  
  if (islogical(I))
    msg = 'Binary images are not supported.';
    eid = sprintf('Images:%s:binaryNotSupported',mfilename);    
    error(eid,'%s',msg);
    
  elseif (ndims(I) > 2)
    msg = 'ROIFILL only supports 2-D images.';
    eid = sprintf('Images:%s:only2DSupported',mfilename);    
    error(eid,'%s',msg);
    
  elseif (issparse(I))
    msg = 'Sparse images are not supported.';
    eid = sprintf('Images:%s:sparseNotSupported',mfilename);    
    error(eid,'%s',msg);

  end
