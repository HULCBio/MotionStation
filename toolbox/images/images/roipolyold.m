function varargout = roipolyold(varargin)
%ROIPOLYOLD Select polygonal region of interest.
%   ROIPOLYOLD is an obsolete version of ROIPOLY.  It uses an algorithm
%   that is slower and which produces less intuitive results than
%   ROIPOLY.  It is provided to help with compatibility in
%   case there is code that relies on specific results produced by
%   ROIPOLY in previous version of the Image Processing Toolbox.
%   ROIPOLYOLD may be removed in a future version of the toolbox.
%
%   Use ROIPOLYOLD to select a polygonal region of interest within
%   an image. ROIPOLYOLD returns a binary image that you can use as
%   a mask for masked filtering.
%
%   BW = ROIPOLYOLD(I,C,R) returns the region of interest selected
%   by the polygon described by vectors C and R. BW is a binary
%   image the same size as I with 0's outside the region of
%   interest and 1's inside.
%
%   BW = ROIPOLYOLD(I) displays the image I on the screen and lets
%   you specify the polygon using the mouse. If you omit I,
%   ROIPOLYOLD operates on the image in the current axes. Use normal
%   button clicks to add vertices to the polygon. Pressing
%   <BACKSPACE> or <DELETE> removes the previously selected
%   vertex. A shift-click, right-click, or double-click adds a
%   final vertex to the selection and then starts the fill;
%   pressing <RETURN> finishes the selection without adding a
%   vertex.
%
%   BW = ROIPOLYOLD(x,y,I,xi,yi) uses the vectors x and y to
%   establish a nondefault spatial coordinate system. xi and yi
%   are equal-length vectors that specify polygon vertices as
%   locations in this coordinate system.
%
%   [BW,xi,yi] = ROIPOLYOLD(...) returns the polygon coordinates in
%   xi and yi. Note that ROIPOLYOLD always produces a closed
%   polygon. If the points specified describe a closed polygon
%   (i.e., if the last pair of coordinates is identical to the
%   first pair), the length of xi and yi is equal to the number
%   of points specified. If the points specified do not describe
%   a closed polygon, ROIPOLYOLD adds a final point having the same
%   coordinates as the first point. (In this case the length of
%   xi and yi is one greater than the number of points
%   specified.)
%
%   [x,y,BW,xi,yi] = ROIPOLYOLD(...) returns the XData and YData in
%   x and y; the mask image in BW; and the polygon coordinates in
%   xi and yi.
%
%   If ROIPOLYOLD is called with no output arguments, the resulting
%   image is displayed in a new figure.
%
%   Class Support
%   -------------
%   The input image I can be of class uint8, uint16, or double. 
%   The output image BW is of class logical. All other inputs and 
%   outputs are of class double.
%
%   Remarks
%   -------
%   For any of the ROIPOLYOLD syntaxes, you can replace the input
%   image I with two arguments, M and N, that specify the row and
%   column dimensions of an arbitrary image. If you specify M and
%   N with an interactive form of ROIPOLYOLD, an M-by-N black image
%   is displayed, and you use the mouse to specify a polygon with
%   this image.
%
%   Example
%   -------
%       I = imread('eight.tif');
%       c = [222 272 300 270 221 194];
%       r = [21 21 75 121 121 75];
%       BW = roipolyold(I,c,r);
%       imshow(I), figure, imshow(BW)
%
%   See also ROIFILT2, ROICOLOR, ROIFILL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.4 $  $Date: 2003/12/13 02:48:39 $

wid = sprintf('Images:%s:obsoleteFunction',mfilename);
str1= sprintf('%s is obsolete and may be removed in the future.',mfilename);
str2 = 'See product release notes for more information.';
warning(wid,'%s\n%s',str1,str2);

[xdata,ydata,num_rows,num_cols,xi,yi] = parse_inputs(varargin{:});

if length(xi)~=length(yi)
    eid = sprintf('Images:%s:xiyiMustBeSameLength',mfilename);
    error(eid,'%s','XI and YI must be the same length.'); 
end

% Make sure polygon is closed.
if (~isempty(xi))
    if ((xi(1) ~= xi(end)) | (yi(1) ~= yi(end)))
        xi = [xi;xi(1)]; yi = [yi;yi(1)];
    end
end
% Transform xi,yi into pixel coordinates.
roix = axes2pix(num_cols, xdata, xi);
roiy = axes2pix(num_rows, ydata, yi);

% Round input vertices to the nearest 0.5 and then add 0.5.
roix = floor(roix + 1);
roiy = floor(roiy + 1);

% Initialize output matrix.  We need one extra row to begin with.
d = zeros(num_rows+1,num_cols);

num_segments = prod(size(roix)) - 1;

% Process each segment.
for counter = 1:num_segments
  x1 = roix(counter);
  x2 = roix(counter+1);
  y1 = roiy(counter);
  y2 = roiy(counter+1);

  % We only have to do something with this segment if it is not vertical
  % or a single point.
  if (x1 ~= x2)

    % Compute an approximation to the segment drawn on an integer
    % grid.  Mark appropriate changes in the x direction in the
    % output image.
    [x,y] = intline(x1,x2,y1,y2);
    if ((x1 < 1) | (x1 > num_cols) | (x2 < 1) | (x2 > num_cols) | ...
        (y1 < 1) | (y1 > (num_rows+1)) | (y2 < 1) | (y2 > (num_rows+1)))
      xLowIdx = find(x < 1);
      if (length(xLowIdx))
        x(xLowIdx) = ones(size(xLowIdx));
      end
      xHighIdx = find(x > num_cols);
      if (length(xHighIdx))
        x(xHighIdx) = (num_cols+1) * ones(size(xHighIdx));
      end
      yLowIdx = find(y < 1);
      if (length(yLowIdx))
        y(yLowIdx) = ones(size(yLowIdx));
      end
      yHighIdx = find(y > (num_rows+1));
      if (length(yHighIdx))
        y(yHighIdx) = (num_rows+1) * ones(size(yHighIdx));
      end
    end
    diffx = diff(x);
    dx_indices = find(diffx);
    dx_indices = dx_indices(:);  % converts [] to rectangular empty;
                                 % helps code below work for degenerate case
    if (x2 > x1)
      mark_val = 1;
    else
      mark_val = -1;
      dx_indices = dx_indices + 1;
    end
    d_indices = [y(dx_indices) (x(dx_indices)-1)] * [1; (num_rows+1)];
    d(d_indices) = d(d_indices) + mark_val(ones(size(d_indices)),1);
  end
    
end

% Now a cumulative sum down the columns will fill the region with 
% either 1's or -1's.  Compare the result with 0 to force a
% logical output.
d = (cumsum(d) ~= 0);

% Get rid of that extra row and we're done!
d(end,:) = [];

switch nargout
case 0
    figure
    if (~isequal(xdata, [1 size(d,2)]) | ~isequal(ydata, [1 size(d,1)]))
        imshow(xdata,ydata,d);  % makes tick labels visible
    else
        imshow(d)
    end
    
case 1
    varargout{1} = d;
    
case 2
    varargout{1} = d;
    varargout{2} = xi;
    
case 3
    varargout{1} = d;
    varargout{2} = xi;
    varargout{3} = yi;
    
case 4
    varargout{1} = xdata;
    varargout{2} = ydata;
    varargout{3} = d;
    varargout{4} = xi;
    
case 5
    varargout{1} = xdata;
    varargout{2} = ydata;
    varargout{3} = d;
    varargout{4} = xi;
    varargout{5} = yi;
    
otherwise
    eid = sprintf('Images:%s:tooManyOutputArgs',mfilename);
    error(eid,'%s','Too many output arguments');
    
end


%%%
%%% parse_inputs
%%%

function [x,y,nrows,ncols,xi,yi] = parse_inputs(varargin)

switch nargin

case 0, 
    % ROIPOLYOLD
    %  Get information from the current figure
    [x,y,a,hasimage] = getimage;
    if ~hasimage,
        eid = sprintf('Images:%s:needImageInFigure',mfilename);
        error(eid,'%s',...
              'The current figure must contain an image to use ROIPOLY.');
    end
    [xi,yi] = getline(gcf,'closed'); % Get rect info from the user.
    nrows = size(a,1);
    ncols = size(a,2);
    
case 1
    % ROIPOLYOLD(A)
    a = varargin{1};
    nrows = size(a,1);
    ncols = size(a,2);
    x = [1 ncols];
    y = [1 nrows];
    imshow(a);
    [xi,yi] = getline(gcf,'closed');
    
case 2
    % ROIPOLYOLD(M,N)
    nrows = varargin{1};
    ncols = varargin{2};
    a = repmat(uint8(0), nrows, ncols);
    x = [1 ncols];
    y = [1 nrows];
    imshow(a);
    [xi,yi] = getline(gcf,'closed');
    
case 3,
    % SYNTAX: roipolyold(A,xi,yi)
    a = varargin{1};
    nrows = size(a,1);
    ncols = size(a,2);
    xi = varargin{2}(:);
    yi = varargin{3}(:);
    x = [1 ncols]; y = [1 nrows];

case 4,
    % SYNTAX: roipolyold(m,n,xi,yi)
    nrows = varargin{1}; 
    ncols = varargin{2};
    xi = varargin{3}(:);
    yi = varargin{4}(:);
    x = [1 ncols]; y = [1 nrows];
    
case 5,
    % SYNTAX: roipolyold(x,y,A,xi,yi)
    x = varargin{1}; 
    y = varargin{2}; 
    a = varargin{3};
    xi = varargin{4}(:); 
    yi = varargin{5}(:);
    nrows = size(a,1);
    ncols = size(a,2);
    x = [x(1) x(prod(size(x)))];
    y = [y(1) y(prod(size(y)))];
    
case 6,
    % SYNTAX: roipolyold(x,y,m,n,xi,yi)
    x = varargin{1}; 
    y = varargin{2}; 
    nrows = varargin{3};
    ncols = varargin{4};
    xi = varargin{5}(:); 
    yi = varargin{6}(:);
    x = [x(1) x(prod(size(x)))];
    y = [y(1) y(prod(size(y)))];
    
otherwise,
    eid = sprintf('Images:%s:invalidInputArgs',mfilename);
    error(eid,'%s','Invalid input arguments.');

end

if isa(xi, 'uint8'), xi=double(xi); end
if isa(yi, 'uint8'), yi=double(yi); end
if isa(x, 'uint8'), x=double(x); end
if isa(y, 'uint8'), y=double(y); end
if isa(nrows, 'uint8'), nrows=double(nrows); end
if isa(ncols, 'uint8'), ncols=double(ncols); end

    
