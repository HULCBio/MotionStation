function R = makerefmat(varargin)
%MAKEREFMAT Construct an affine spatial-referencing matrix.
%
%   A spatial referencing matrix R ties the row and column subscripts of an
%   image or regular data grid to 2-D map coordinates or to geographic
%   coordinates (longitude and geodetic latitude).  R is a 3-by-2 affine
%   transformation matrix.  R either transforms pixel subscripts (row,
%   column) to/from map coordinates (x,y) according to
%
%                      [x y] = [row col 1] * R
%
%   or transforms pixel subscripts to/from geographic coordinates according
%   to
%
%                    [lon lat] = [row col 1] * R.
%
%   To construct a referencing matrix for use with geographic coordinates,
%   use longitude in place of X and latitude in place of Y, as shown in the
%   third syntax below.  This is one of the few places where longitude
%   precedes latitude in a function call.
%
%   R = MAKEREFMAT(X11, Y11, DX, DY) with scalar DX and DY constructs a
%   referencing matrix that aligns image/data grid rows to map X and
%   columns to map Y.  X11 and Y11 are scalars that specify the map
%   location of the center of the first (1,1) pixel in the image or first
%   element of the data grid, so that
%
%                   [X11 Y11] = pix2map(R,1,1).
%
%   DX is the difference in X (or longitude) between pixels in successive
%   columns and DY is the difference in Y (or latitude) between pixels in
%   successive rows.  More abstractly, R is defined such that
%
%      [X11 + (col-1) * DX, Y11 + (row-1) * DY] = pix2map(R, row, col).
%
%   Pixels cover squares on the map when abs(DX) = abs(DY).  To achieve the
%   most typical kind of alignment, where X increases from column to column
%   and Y decreases from row to row, make DX positive and DY negative.  In
%   order to specify such an alignment along with square pixels, make DX
%   positive and make DY equal to -DX:
%
%                 R = MAKEREFMAT(X11, Y11, DX, -DX).
%
%   R = MAKEREFMAT(X11, Y11, DX, DY) with two-element vectors DX and DY
%   constructs the most general possible kind of referencing matrix, for
%   which
%
%     [X11 + ([row col]-1) * DX(:), Y11 + ([row col]-1) * DY(:)]
%                                                = pix2map(R, row, col).
%
%   In this general case, each pixel may become a parallelogram on the map,
%   with neither edge necessarily aligned to map X or Y.  The vector
%   [DX(1) DY(1)] is the difference in map location between a pixel in one
%   row and its neighbor in the preceeding row.  Likewise, [DX(2) DY(2)] is
%   the difference in map location between a pixel in one column and its
%   neighbor in the preceeding column.
%
%   To specify pixels that are rectangular or square (but possibly
%   rotated), choose DX and DY such that prod(DX) + prod(DY) = 0.  To
%   specify square (but possibly rotated) pixels, choose DX and DY such
%   that the 2-by-2 matrix [DX(:) DY(:)] is a scalar multiple of an
%   orthgonal matrix (i.e., its two eigenvalues are real, non-zero and
%   equal in absolute value).  This amounts to either rotation, a mirror
%   image, or a combination of both. Note that for scalar DX and DY
%
%               R = makerefmat(X11, Y11, [0 DX], [DY 0])
%
%   is equivalent to
%
%                  R = makerefmat(X11, Y11, DX, DY).
%
%   R = MAKEREFMAT(LON11, LAT11, DLON, DLAT), with longitude preceding
%   latitude, constructs a referencing matrix for use with geographic
%   coordinates. In this case
%
%                 [LAT11, LON11] = pix2latlon(R,1,1),
%
%   [LAT11 + (row-1) * DLAT, LON11 + (col-1) * DLON]
%                                               = pix2latlon(R, row, col)
%
%   for scalar DLAT and DLON, and 
%
%   [LAT11 + ([row col]-1) * DLAT(:), LON11 + ([row col]-1) * DLON(:)]
%                                               = pix2latlon(R, row, col)
%
%   for vector DLAT and DLON.  Note that images or data grids aligned with
%   latitude and longitude may already have referencing vectors.  In this
%   case you can use function REFVEC2MAT to convert to a referencing
%   matrix.
%
%   Example 1
%   ---------
%   Create a referencing matrix for an image with square, four-meter pixels
%   and with its upper left corner (in a map coordinate system) at
%   x = 207000 meters, y = 913000 meters. The image follows the typical
%   orientation:  x increasing from column to column and y decreasing from
%   row to row.
%
%      x11 = 207002;  % Two meters east of the upper left corner
%      y11 = 912998;  % Two meters south of the upper left corner
%      dx =  4;
%      dy = -4;
%      R = makerefmat(x11, y11, dx, dy)
%
%   Example 2
%   ---------
%   Create a referencing matrix for a global geoid grid.
%   
%      load geoid  % Adds array 'geoid' to the workspace
%
%      % 'geoid' contains a model of the Earth's geoid sampled in
%      % one-degree-by-one-degree cells.  Each column of 'geoid' contains
%      % geoid heights in meters for 180 cells starting at latitude
%      % -90 degrees and extending to +90 degrees, for a given latitude.
%      % Each row contains geoid heights for 360 cells starting at
%      % longitude 0 and extending 360 degrees.
%
%      lat11 = -89.5;  % Cell-center latitude corresponding to geoid(1,1)
%      lon11 =   0.5;  % Cell-center longitude corresponding to geoid(1,1)
%      dLat = 1;  % From row to row moving north by one degree
%      dLon = 1;  % From column to column moving east by one degree
%
%      geoidR = makerefmat(lon11, lat11, dLon, dLat)
%
%      % It's well known that at its most extreme the geoid reaches a
%      % minimum of slightly less than -100 meters, and that the minimum
%      % occurs in the Indian Ocean at approximately 4.5 degrees latitude,
%      % 78.5 degrees longitude.  Check the geoid height at this location
%      % by using LATLON2PIX with the new referencing matrix:
%
%      [row, col] = latlon2pix(geoidR, 4.5, 78.5)
%      geoid(round(row),round(col))
%    
%   Example 3
%   ---------
%   Create a half-resolution version of a georeferenced TIFF image, using
%   Image Processing Toolbox functions IND2GRAY and IMRESIZE.
%
%      % Read the indexed-color TIFF image and convert it to grayscale.
%      % The size of the image is 2000-by-2000.
%      [X, cmap] = imread('concord_ortho_w.tif');
%      I_orig = ind2gray(X, cmap);
%
%      % Read the corresponding worldfile.  Each image pixel covers a
%      % one-meter square on the map.
%      R_orig = worldfileread('concord_ortho_w.tfw')
%
%      % Halve the resolution, creating a smaller (1000-by-1000) image.
%      I_half = imresize(I_orig, size(I_orig)/2, 'bicubic');
%
%      % Find the map coordinates of the center of pixel (1,1) in the
%      % resized image: halfway between the centers of pixels (1,1) and
%      % (2,2) in the original image.
%      [x11_orig, y11_orig] = pix2map(R_orig, 1, 1)
%      [x22_orig, y22_orig] = pix2map(R_orig, 2, 2)
%
%      % Average these to determine the center of pixel (1,1) in the new
%      % image.
%      x11_half = (x11_orig + x22_orig) / 2
%      y11_half = (y11_orig + y22_orig) / 2
%      
%      % Construct a referencing matrix for the new image, noting that its
%      % pixels are each two meters square.
%      R_half = makerefmat(x11_half, y11_half, 2, -2)
%
%      % Display each image in map coordinates.
%      figure;
%      subplot(2,1,1); h1 = mapshow(I_orig,R_orig); ax1 = get(h1,'Parent');
%      subplot(2,1,2); h2 = mapshow(I_half,R_half); ax2 = get(h2,'Parent');
%      set(ax1, 'XLim', [208000 208250], 'YLim', [911800 911950])
%      set(ax2, 'XLim', [208000 208250], 'YLim', [911800 911950])
%
%      % Mark the same map location on top of each image.
%      x = 208202.21;
%      y = 911862.70;
%      line(x, y, 'Parent', ax1, 'Marker', '+', 'MarkerEdgeColor', 'r');
%      line(x, y, 'Parent', ax2, 'Marker', '+', 'MarkerEdgeColor', 'r');
%
%      % Graphically, they coincide, even though the same map location
%      % corresponds to two different pixel coordinates.
%      [row1, col1] = map2pix(R_orig, x, y)
%      [row2, col2] = map2pix(R_half, x, y)
%
%   See also LATLON2PIX, MAP2PIX, PIX2LATLON, PIX2MAP, REFVEC2MAT, WORLDFILEREAD,
%            WORLDFILEWRITE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2003/12/13 02:50:23 $


% Worldfile Matrix to Referencing Matrix
% --------------------------------------
% R = MAKEREFMAT(W) constructs a referencing matrix from a worldfile
% matrix, W.  This additional syntax is provided for internal use.
% W is a 2-by-3 matrix
%
%                         W = [A B C;
%                              D E F]
% such that 
%
%                    x = A * xi + B * yi + C
%                    y = D * xi + E * yi + F
%
% where (xi, yi) are zero-based image coordinates defined by
%
%                       xi = col - 1,
%                       yi = row - 1.
%
% Stated more compactly, [x y]' = W * [col-1 row-1 1]'.
%
% W is stored in a worldfile with one term per line in column-major order:
% A, D, B, E, C, F.  That is, a worldfile contains contains:
% 
%      W(1,1)
%      W(2,1)
%      W(1,2)
%      W(2,2)
%      W(1,3)
%      W(2,3).
%
% MAKEREFMAT accepts the 6-element vector [A D B E C F] or its transpose,
% or equivalently, W(:) or W(:)', in addition to a 2-by-3 matrix.
%
% Both W and the general syntax with vector DX and DY provide six
% independent scalar parameters.  They are simply related:
%
%                   W = [DX(2)    DX(1)    X11 
%                        DY(2)    DY(1)    Y11].
%
% and conversely on one R = makerefmat(W) is equivalent to
%
%         R = makerefmat(W(5), W(6), [W(3) W(1)], [W(4) W(2)]).
%
%--------------------------------------------------------------------


% World File - Referencing Matrix Conversions
% -------------------------------------------
% As noted, W transforms one-based image column and row coordinates (c,r)
% to map coordinates (x,y) according to:
% 
%                      [x y]' = W * [c-1 r-1 1]'.
% 
% The -1s are needed because W was defined with zero-based image
% coordinates in mind.
%
% Our standard form for expressing an affine transformation like the one
% above is [x y] = [r c 1] * R.  To obtain R from W, note that [c-1 r-1 1]'
% = C * [r c 1]', where
% 
%                         C = [0  1  -1
%                              1  0  -1
%                              0  0   1].
% 
% Therefore [x y]' = W * C * [r c 1]'.  Transposing both sides gives
% 
%                       [x y] = [r c 1] * R
% with
%                           R = (W * C)'.
%
% To reverse the conversion and create a world file from R, use
% 
%                          W = R' * inv(C)
% 
% and
% 
%                        inv(C) = [0  1  1
%                                  1  0  1
%                                  0  0  1].
%
%--------------------------------------------------------------------

switch(nargin)
    
case 1
    R = W2R(checkW(varargin{1}));
    
case 4
    R = W2R(constructW(varargin{:}));
    
otherwise
    eid = sprintf('%s:%s:invalidArgCount', getcomp, mfilename);
    msg = sprintf('Function %s expected either one or four input arguments.',mfilename);
    error(eid,msg)
    
end

%--------------------------------------------------------------------------

function R = W2R(W)

C = [0  1  -1;...
     1  0  -1;...
     0  0   1];

R = (W * C)';

%--------------------------------------------------------------------------

function W = checkW(W)
% Check W and ensure that it's 2-by-3.

checkinput(W, 'double', {'real','finite'}, mfilename, 'W', 1);

if numel(W) ~= 6
    eid = sprintf('%s:%s:wrongSizeW', getcomp, mfilename);
    msg = sprintf('Function %s expected its first argument, W, to have six elements.',mfilename);
    error(eid,msg)
end

W = reshape(W, [2 3]);

%--------------------------------------------------------------------------

function W = constructW(x11, y11, dx, dy)
% Construct W from inputs X11, Y11, DX, and DY.

checkinput(x11, {'double'}, {'real','scalar','finite'}, mfilename, 'X11', 1);
checkinput(y11, {'double'}, {'real','scalar','finite'}, mfilename, 'Y11', 2);

checkinput(dx, {'double'}, {'real','finite'}, mfilename, 'DX', 1);
checkinput(dy, {'double'}, {'real','finite'}, mfilename, 'DY', 1);

switch numel(dx)
  case 1,  dx = [0 dx];
  case 2,  % dx is already a 2-element vector
  otherwise
    eid = sprintf('%s:%s:wrongSizeDX', getcomp, mfilename);
    msg = sprintf('Function %s expected its %s argument, DX, to have one or two elements.',...
                  num2ordinal(3), mfilename);
    error(eid,msg)
end

switch numel(dy)
  case 1,  dy = [dy 0];
  case 2,  % dy is already a 2-element vector
  otherwise
    eid = sprintf('%s:%s:wrongSizeDY', getcomp, mfilename);
    msg = sprintf('Function %s expected its %s argument, DY, to have one or two elements.',...
                  num2ordinal(4), mfilename);
    error(eid,msg)
end

W = [dx(2) dx(1) x11;...
     dy(2) dy(1) y11];
