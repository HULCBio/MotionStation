function im2 = imclearborder(varargin)
%IMCLEARBORDER Suppress light structures connected to image border.
%   IM2 = IMCLEARBORDER(IM) suppresses structures that are lighter than
%   their surroundings and that are connected to the image border.  IM can
%   be an intensity or binary image.  The output image, IM2, is intensity or
%   binary, respectively.  The default connectivity is 8 for two dimensions,
%   26 for three dimensions, and CONNDEF(NDIMS(BW),'maximal') for higer
%   dimensions.
%
%   For intensity images, IMCLEARBORDER tends to reduce the overall
%   intensity level in addition to suppressing border structures.
%
%   IM2 = IMCLEARBORDER(IM,CONN) specifies the desired connectivity.
%   CONN may have the following scalar values:  
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Note
%   ----
%   A pixel on the edge of the input image might not be considered to be
%   a "border" pixel if a nondefault connectivity is specified.  For
%   example, if CONN = [0 0 0; 1 1 1; 0 0 0], elements on the first and
%   last row are not considered to be border pixels because, according to
%   that connectivity definition, they are not connected to the region
%   outside of the image.
%
%   Class support
%   -------------
%   IM can be a numeric or logical array of any dimension, and it must be
%   nonsparse and real.  IM2 has the same class as IM.
%
%   Examples
%   --------
%   This example shows how to clear the border of an intensity image:
%
%       I = imread('rice.png');
%       I2 = imclearborder(I);
%       imview(I), imview(I2)
%
%   This example shows how to clear the border of a binary image:
%
%       BW = im2bw(imread('rice.png'));
%       BW2 = imclearborder(BW);
%       imview(BW), imview(BW2)
%
%   See also IMRECONSTRUCT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2003/05/03 17:50:43 $

%   Algorithm reference: P. Soille, Morphological Image Analysis:
%   Principles and Applications, Springer, 1999, pp. 164-165.

%   Input-output specs
%   ------------------
%   IM:     N-D, real, full matrix
%           any numeric or logical nonsparse type
%           if islogical(IM), treated as binary
%           empty ok
%           Infs ok
%           if logical, NaNs are ok and treated as 0s, otherwise
%              not allowed.
%
%   CONN:   connectivity
%
%   IM2:    Same class and size as IM

[im,conn] = parse_inputs(varargin{:});
conn = conn2array(conn);

marker = im;

% Now figure out which elements of the marker image are connected to the
% outside, according to the connectivity definition.
im2 = true(size(marker));
im2 = padarray(im2, ones(1,ndims(im2)), 0, 'both');
im2 = imerode(im2,conn);
idx = cell(1,ndims(im2));
for k = 1:ndims(im2)
    idx{k} = 2:(size(im2,k) - 1);
end
im2 = im2(idx{:});

% Set all elements of the marker image that are not connected to the
% outside to the lowest possible value.
if islogical(marker)
    marker(im2) = false;
else
    marker(im2) = -Inf;
end

im2 = imreconstruct(marker, im, conn);
if islogical(im2)
    im2 = im & ~im2;
else
    im2 = imsubtract(im,im2);
end

%%%
%%% parse_inputs
%%%
function [im,conn] = parse_inputs(varargin)


checknargin(1,2,nargin,mfilename);

im = varargin{1};
checkinput(im, {'numeric' 'logical'}, {'nonsparse' 'real'}, ...
           mfilename, 'IM', 1);

if nargin < 2
    conn = conndef(ndims(im),'maximal');
else
    conn = varargin{2};
    checkconn(conn,mfilename,'CONN',2);
end

% Skip NaN check here; it will be done by imreconstruct if input
% is double.
