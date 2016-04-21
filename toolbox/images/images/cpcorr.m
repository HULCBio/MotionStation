function xyinput = cpcorr(varargin)
%CPCORR Tune control point locations using cross-correlation. 
%   INPUT_POINTS = CPCORR(INPUT_POINTS_IN,BASE_POINTS_IN,INPUT,BASE) uses
%   normalized cross-correlation to adjust each pair of control points
%   specified in INPUT_POINTS_IN and BASE_POINTS_IN.
%
%   INPUT_POINTS_IN must be an M-by-2 double matrix containing the
%   coordinates of control points in the input image.  BASE_POINTS_IN is
%   an M-by-2 double matrix containing the coordinates of control points
%   in the base image.
%
%   CPCORR returns the adjusted control points in INPUT_POINTS, a double
%   matrix the same size as INPUT_POINTS_IN.  If CPCORR cannot correlate a
%   pairs of control points, INPUT_POINTS will contain the same coordinates
%   as INPUT_POINTS_IN for that pair.
%
%   CPCORR will only move the position of a control point by up to 4
%   pixels.  Adjusted coordinates are accurate up to one tenth of a
%   pixel.  CPCORR is designed to get subpixel accuracy from the image
%   content and coarse control point selection.
%
%   Note that the INPUT and BASE images must have the same scale for
%   CPCORR to be effective.
%
%   CPCORR cannot adjust a point if any of the following occur:
%     - points are too near the edge of either image
%     - regions of images around points contain Inf or NaN
%     - region around a point in input image has zero standard deviation
%     - regions of images around points are poorly correlated
%
%   Class Support
%   -------------
%   The images can be of class logical, uint8, uint16, or double and
%   must contain finite values. The input control point pairs are
%   of class double.
%
%   Example
%   --------
%   This example uses CPCORR to fine-tune control points selected in an
%   image.  Note the difference in the values of the INPUT_POINTS matrix
%   and the INPUT_POINTS_ADJ matrix.
%
%       input = imread('onion.png');
%       base = imread('peppers.png');
%       input_points = [127 93; 74 59];
%       base_points = [323 195; 269 161];
%       input_points_adj = cpcorr(input_points,base_points,...
%                                 input(:,:,1),base(:,:,1))
%
%   See also CP2TFORM, CPSELECT, NORMXCORR2, IMTRANSFORM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2003/05/03 17:50:20 $

%   Input-output specs
%   ------------------
%   INPUT_POINTS_IN: M-by-2 double matrix 
%              INPUT_POINTS_IN(:)>=0.5
%              INPUT_POINTS_IN(:,1)<=size(INPUT,2)+0.5
%              INPUT_POINTS_IN(:,2)<=size(INPUT,1)+0.5
%
%   BASE_POINTS_IN: M-by-2 double matrix 
%              BASE_POINTS_IN(:)>=0.5
%              BASE_POINTS_IN(:,1)<=size(BASE,2)+0.5
%              BASE_POINTS_IN(:,2)<=size(BASE,1)+0.5
%
%   INPUT:   2-D, real, full matrix
%            logical, uint8, uint16, or double
%            must be finite (no NaNs, no Infs inside regions being correlated)
%
%   BASE:    2-D, real, full matrix
%            logical, uint8, uint16, or double
%            must be finite (no NaNs, no Infs inside regions being correlated)

[xyinput_in,xybase_in,input,base,msg] = ParseInputs(varargin{:});

CORRSIZE = 5;

% get all rectangle coordinates
rects_input = calc_rects(xyinput_in,CORRSIZE,input);
rects_base = calc_rects(xybase_in,2*CORRSIZE,base);

ncp = size(xyinput_in,1);

xyinput = xyinput_in; % initialize adjusted control points matrix

for icp = 1:ncp

    if isequal(rects_input(icp,3:4),[0 0]) | ...
       isequal(rects_base(icp,3:4),[0 0]) 
        % near edge, unable to adjust
        continue
    end
    
    sub_input = imcrop(input,rects_input(icp,:));
    sub_base = imcrop(base,rects_base(icp,:));    

    inputsize = size(sub_input);

    % make sure finite
    if any(~isfinite(sub_input(:))) | any(~isfinite(sub_base(:)))
        % NaN or Inf, unable to adjust
        continue
    end

    % check that template rectangle sub_input has nonzero std
    if std(sub_input(:))==0
        % zero standard deviation of template image, unable to adjust
        continue
    end

    norm_cross_corr = normxcorr2(sub_input,sub_base);    

    % get subpixel resolution from cross correlation
    [xpeak, ypeak, amplitude] = findpeak(norm_cross_corr,1);

    % eliminate any poor correlations
    THRESHOLD = 0.5;
    if (amplitude < THRESHOLD) 
        % low correlation, unable to adjust
        continue
    end
    
    % offset found by cross correlation
    corr_offset = [ (xpeak-inputsize(2)-CORRSIZE) (ypeak-inputsize(1)-CORRSIZE) ];

    % eliminate any big changes in control points
    ind = find(abs(corr_offset) > (CORRSIZE-1));
    if ~isempty(ind)
        % peak of norxcorr2 not well constrained, unable to adjust
        continue
    end

    input_fractional_offset = xyinput(icp,:) - round(xyinput(icp,:));
    base_fractional_offset = xybase_in(icp,:) - round(xybase_in(icp,:));    
    
    % adjust control point
    xyinput(icp,:) = xyinput(icp,:) - input_fractional_offset - corr_offset + base_fractional_offset;

end

%-------------------------------
%
function rect = calc_rects(xy,halfwidth,img)

% Calculate rectangles so imcrop will return image with xy coordinate inside center pixel

default_width = 2*halfwidth;
default_height = default_width;

% xy specifies center of rectangle, need upper left
upperleft = round(xy) - halfwidth;

% need to modify for pixels near edge of images
upper = upperleft(:,2);
left = upperleft(:,1);
lower = upper + default_height;
right = left + default_width;
width = default_width * ones(size(upper));
height = default_height * ones(size(upper));

% check edges for coordinates outside image
[upper,height] = adjust_lo_edge(upper,1,height);
[lower,height] = adjust_hi_edge(lower,size(img,1),height);
[left,width] = adjust_lo_edge(left,1,width);
[right,width] = adjust_hi_edge(right,size(img,2),width);

% set width and height to zero when less than default size
iw = find(width<default_width);
ih = find(height<default_height);
idx = unique([iw; ih]);
width(idx) = 0;
height(idx) = 0;

rect = [left upper width height];

%-------------------------------
%
function [coordinates, breadth] = adjust_lo_edge(coordinates,edge,breadth)

indx = find( coordinates<edge );
if ~isempty(indx)
    breadth(indx) = breadth(indx) - abs(coordinates(indx)-edge);
    coordinates(indx) = edge;
end

%-------------------------------
%
function [coordinates, breadth] = adjust_hi_edge(coordinates,edge,breadth)

indx = find( coordinates>edge );
if ~isempty(indx)
    breadth(indx) = breadth(indx) - abs(coordinates(indx)-edge);
    coordinates(indx) = edge;
end

%-------------------------------
%
function [xpeak, ypeak, max_f] = findpeak(f,subpixel);
%FINDPEAK Find peak of 2D function.
%
%   f is a 2D function
%   subpixel = 0, get absolute pixel location of peak
%   subpixel = 1, do subpixel estimation of peak by fitting a 2nd order 
%                 polynomial to the 9 points surrounding the peak of f.
%

% get absolute peak pixel
[max_f, imax] = max(abs(f(:)));
[ypeak, xpeak] = ind2sub(size(f),imax(1));
    
if ~subpixel | ...
    xpeak==1 | xpeak==size(f,2) | ypeak==1 | ypeak==size(f,1) % on edge
    return % return absolute peak
    
else
    % fit a 2nd order polynomial to 9 points  
    % using 9 pixels centered on irow,jcol    
    u = f(ypeak-1:ypeak+1, xpeak-1:xpeak+1);
    u = u(:);
    xy = [-1 -1; -1 0; -1 1; 0 -1; 0 0; 0 1; 1 -1; 1 0; 1 1];
    x = xy(:,1);
    y = xy(:,2);

    % u(x,y) = A(1) + A(2)*x + A(3)*y + A(4)*x*y + A(5)*x^2 + A(6)*y^2
    X = [ones(9,1),  x,  y,  x.*y,  x.^2,  y.^2];
    
    % u = X*A
    A = X\u;

    % get absolute maximum, where du/dx = du/dy = 0
    x_offset = ( 2*A(2)*A(6) - A(3)*A(4) ) / ( A(4)*A(4) - 4*A(5)*A(6) );
    y_offset = -( A(2) + 2*A(5)*x_offset ) / A(4);

    % return only one-tenth of a pixel precision
    x_offset = round(10*x_offset)/10;
    y_offset = round(10*y_offset)/10;    
    
    xpeak = xpeak + x_offset;
    ypeak = ypeak + y_offset;    
    
end

%-------------------------------
%
function [xyinput_in,xybase_in,input,base,msg] = ParseInputs(varargin);

xyinput_in = [];
xybase_in = [];
input = [];
base = [];
msg = '';

checknargin(4,4,nargin,mfilename);

xyinput_in = varargin{1};
xybase_in = varargin{2};
if size(xyinput_in,2) ~= 2 | size(xybase_in,2) ~= 2
    msg = sprintf('In function %s, control point matrices must be M-by-2.',mfilename);
    eid = sprintf('Images:%s:cpMatrixMustBeMby2',mfilename);
    error(eid,msg);
end

if size(xyinput_in,1) ~= size(xybase_in,1)
    msg = sprintf('In function %s, INPUT and BASE images need same number of control points.',mfilename);
    eid = sprintf('Images:%s:needSameNumOfControlPoints',mfilename);    
    error(eid,msg);
end

input = varargin{3};
base = varargin{4};
if ndims(input) ~= 2 | ndims(base) ~= 2
    msg = sprintf('In function %s, Images must be intensity images.',mfilename);
    eid = sprintf('Images:%s:intensityImagesReq',mfilename);        
    error(eid,msg);
end

input = double(input);
base = double(base);

if any(xyinput_in(:)<0.5) | any(xyinput_in(:,1)>size(input,2)+0.5) | ...
   any(xyinput_in(:,2)>size(input,1)+0.5) | ...
   any(xybase_in(:)<0.5) | any(xybase_in(:,1)>size(base,2)+0.5) | ...
   any(xybase_in(:,2)>size(base,1)+0.5)
    msg = sprintf('In function %s, Control Points must be in pixel coordinates.',mfilename);
    eid = sprintf('Images:%s:cpPointsMustBeInPixCoord',mfilename);
    error(eid,msg);
end
