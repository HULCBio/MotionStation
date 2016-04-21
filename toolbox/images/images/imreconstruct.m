function im = imreconstruct(varargin)
%IMRECONSTRUCT Perform morphological reconstruction.
%   IM = IMRECONSTRUCT(MARKER,MASK) performs morphological reconstruction
%   of the image MARKER under the image MASK.  MARKER and MASK can be two
%   intensity images or two binary images with the same size; IM is an
%   intensity or binary image, respectively.  MARKER must be the same size
%   as MASK, and its elements must be less than or equal to the
%   corresponding elements of MASK.
%
%   By default, IMRECONSTRUCT uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D images.  For higher
%   dimensions, IMRECONSTRUCT uses CONNDEF(NDIMS(I),'maximal').  
%
%   IM = IMRECONSTRUCT(MARKER,MASK,CONN) performs morphological
%   reconstruction with the specificied connectivity.  CONN may have the
%   following scalar values:  
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
%   Morphological reconstruction is the algorithmic basis for several
%   other Image Processing Toolbox functions, including IMCLEARBORDER,
%   IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, IMHMIN, and
%   IMIMPOSEMIN.
%
%   Class support
%   -------------
%   MARKER and MASK must be nonsparse numeric or logical arrays 
%   with the same class and any dimension.  IM is of the same class 
%   as MARKER and MASK.
%
%   Example 1
%   ---------
%   Perform opening-by-reconstruction to identify high intensity snowflakes.
%
%       I = imread('snowflakes.png');  
%       mask = adapthisteq(I);           
%       se = strel('disk',5);
%       marker = imerode(mask,se);
%       obr = imreconstruct(marker,mask);
%       imview(mask,[]), imview(obr,[])
%  
%   Example 2
%   ---------
%   Segment the letter "w" from text.png.
%
%       mask = imread('text.png');
%       marker = false(size(mask));
%       marker(13,94) = true;
%       im = imreconstruct(marker,mask);
%       imview(mask), imview(im)
%    
%   See also IMCLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, 
%            IMHMIN, IMIMPOSEMIN.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2003/08/23 05:52:40 $

[marker,mask,conn] = ParseInputs(varargin{:});
if nargin == 3
  im = imreconstructmex(marker,mask,conn);
else
  im = imreconstructmex(marker,mask);
end

%---------------------------------------------------
function [Marker,Mask,Conn] = ParseInputs(varargin)

Conn = [];

checknargin(2,3,nargin,mfilename);
checkinput(varargin{1},{'numeric','logical'},{'real','nonsparse'},...
            mfilename, 'MARKER', 1);
checkinput(varargin{2},{'numeric','logical'},{'real','nonsparse'},...
            mfilename, 'MASK', 2);

Marker = varargin{1};
Mask = varargin{2};

if nargin==3
  checkconn(varargin{3},mfilename,'CONN',3);
  Conn = varargin{3};
end
