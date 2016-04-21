function BW = im2bw(varargin),
%IM2BW Convert image to binary image by thresholding.
%   IM2BW produces binary images from indexed, intensity, or RGB
%   images. To do this, it converts the input image to grayscale
%   format (if it is not already an intensity image), and then
%   converts this grayscale image to binary by thresholding. The
%   output binary image BW has values of 0 (black) for all pixels
%   in the input image with luminance less than LEVEL and 1
%   (white) for all other pixels. (Note that you specify LEVEL in
%   the range [0,1], regardless of the class of the input image.)
%  
%   BW = IM2BW(I,LEVEL) converts the intensity image I to black
%   and white.
%
%   BW = IM2BW(X,MAP,LEVEL) converts the indexed image X with
%   colormap MAP to black and white.
%
%   BW = IM2BW(RGB,LEVEL) converts the RGB image RGB to black and
%   white.
%
%   Note that the function GRAYTHRESH can be used to compute LEVEL
%   automatically. 
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or double and
%   it must be nonsparse. The output image BW is of class logical.
%
%   Example
%   -------
%   load trees
%   BW = im2bw(X,map,0.4);
%   imview(X,map), imview(BW)
%
%   See also GRAYTHRESH, IND2GRAY, RGB2GRAY.

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 5.24.4.4 $  $Date: 2004/04/01 16:11:57 $

[A,map,level] = parse_inputs(varargin{:});

if ndims(A)==3,% RGB is given
  A = rgb2gray(A);
elseif ~isempty(map),% indexed image is given
  A = ind2gray(A,map);
end; % nothing to do for intensity image


if isa(A, 'uint8')
  BWp = (A >= 255*level);
elseif isa(A, 'uint16')
  BWp = (A >= 65535*level);
elseif isa(A, 'logical')
  %A is already a binary image and does not require thresholding 
  warning(sprintf('Images:%s:binaryInput',mfilename),...
          'The input image is already binary.');
  BWp = A;
else %must be double
  BWp = (A >= level);
end
  
% Output:
if nargout==0, % Show results
  imshow(BWp,2);
  return;
end;
BW = BWp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
function [A,map,level] = parse_inputs(varargin),
% Outputs:  A     the input RGB (3D), intensity (2D), or indexed (X) image
%           map   colormap (:,3)
%           level threshold luminance level
% Defaults:
map = [];
level = 0.5;

checknargin(1,4,nargin,mfilename);

checkinput(varargin{1}, {'uint8', 'uint16', 'logical', 'double'},...
    {'real', 'nonsparse'},mfilename,'I, X or RGB',1);

switch nargin
case 1,%                          im2bw(RGB) | im2bw(I)
  A = varargin{1};
case 2,
  A = varargin{1};%               im2bw(RGB,level) | im2bw(I,level)
  level = varargin{2};%           im2bw(X,MAP)
case 3,%                          im2bw(R,G,B) OBSOLETE
  if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
    A = cat(3,varargin{1},varargin{2},varargin{3});
    
    msg = sprintf( ['IM2BW(R,G,B) is an obsolete syntax. ',...
                    'Use a three-dimensional array to represent RGB image.']);
    wid = sprintf('Images:%s:obsoleteSyntax');
    warning(wid,msg);
  else%                           im2bw(X,MAP,level)
    A = varargin{1};
    map = varargin{2};
    level = varargin{3};
  end;
case 4,%                          im2bw(R,G,B,level) OBSOLETE
  if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
    A = cat(3,varargin{1},varargin{2},varargin{3});
    msg = sprintf( ['IM2BW(R,G,B) is an obsolete syntax. ',...
                    'Use a three-dimensional array to represent RGB image.']);
    wid = sprintf('Images:%s:obsoleteSyntax');
    warning(wid,msg);
    level = varargin{4};
  else
    msg = sprintf('IM2BW(R,G,B,level): R,G,B arrays must be of equal size.');
    eid = sprintf('Images:%s:rgbArraysMustHaveEqualSize',mfilename);
    error(eid,msg);
  end;
end

% Check validity of the input parameters 
if (ndims(A)==3)&(size(A,3)~=3),% check RGB image array
    msg = sprintf('%s: Truecolor RGB image has to be an M-by-N-by-3 array.',upper(mfilename));
    eid = sprintf('Images:%s:trueColorRgbImageMustBeMbyNby3',mfilename);
    error(eid,msg);
end;

if (nargin==2)&(ndims(A)==2)&(size(level,2)==3),% it is a colormap
  map = level;% and we assume that image given is an indexed image X
  level = 0.5;
end;

if ~isempty(map),% check colormap if given
  if (size(map,2) ~= 3)|ndims(map)>2,
    msg = sprintf('%s: Input colormap has to be a 2D array with exactly 3 columns.',upper(mfilename));
    eid = sprintf('Images:%s:inColormapMustBe2Dwith3Cols');
    error(eid,msg);
  elseif (min(map(:))<0)|(max(map(:))>1),
    msg = sprintf('%s: All colormap intensities must be between 0 and 1.',upper(mfilename));
    eid = sprintf('Images:%s:colormapValsMustBe0to1',mfilename);
    error(eid,msg);
  end;
end;

if (prod(size(level))~=1)|(max(level(:))>1)|(min(level(:))<0),
  msg = sprintf('%s: Threshold luminance LEVEL has to be a non-negative number between 0 and 1.',...
        upper(mfilename));
  eid = sprintf('Images:%s:outOfRangeThreshLuminanceLevel',mfilename);
  error(eid,msg);
end;
