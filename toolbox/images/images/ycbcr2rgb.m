function rgb = ycbcr2rgb(varargin)
%YCBCR2RGB Convert YCbCr values to RGB color space.
%   RGBMAP = YCBCR2RGB(YCBCRMAP) converts the YCbCr values in the
%   colormap YCBCRMAP to the RGB color space. If YCBCRMAP is M-by-3 and
%   contains the YCbCr luminance (Y) and chrominance (Cb and Cr) color
%   values as columns, then RGBMAP is an M-by-3 matrix that contains
%   the red, green, and blue values equivalent to those colors.
%
%   RGB = YCBCR2RGB(YCBCR) converts the YCbCr image to the equivalent
%   truecolor image RGB.
%
%   Class Support
%   -------------
%   If the input is a YCbCr image, it can be of class uint8, uint16,
%   or double; the output image is of the same class as the input 
%   image.  If the input is a colormap, the input and output 
%   colormaps are both of class double.
%
%   Example
%   -------
%   Convert image from RGB space to YCbCr space and back.
%
%       rgb = imread('board.tif');
%       ycbcr = rgb2ycbcr(rgb);
%       rgb2 = ycbcr2rgb(ycbcr);
%
%   See also NTSC2RGB, RGB2NTSC, RGB2YCBCR.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.15.4.2 $  $Date: 2003/08/23 05:54:51 $

%   Reference:
%     Charles A. Poynton, "A Technical Introduction to Digital Video",
%     John Wiley & Sons, Inc., 1996

in = parse_inputs(varargin{:});

%initialize variables
isColormap = false;
classin = class(in);

%must reshape colormap to be m x n x 3 for transformation
if (ndims(in)==2)
  %colormap
  isColormap=true;
  colors = size(in,1);
  in = reshape(in, [colors 1 3]);
end

%initialize output
rgb = in;

% set up constants for transformation. T alone will transform YCBCR in [0,255]
% to RGB in [0,1]. We must scale T and the offsets to get RGB in the appropriate
% range for uint8 and for uint16 arrays.
T = [65.481 128.553 24.966;...
     -37.797 -74.203 112; ...
     112 -93.786 -18.214];
Tinv = T^-1;
offset = [16;128;128];
Td = 255 * Tinv;
offsetd = Tinv * offset;
T8 = Td;
offset8 = T8 * offset;
T16 = (65535/257) * Tinv;
offset16 = 65535 * Tinv * offset;

switch classin
 case 'double'
  for p = 1:3
    rgb(:,:,p) = Td(p,1) * in(:,:,1) + Td(p,2) * in(:,:,2) + ...
        Td(p,3) * in(:,:,3) - offsetd(p);
  end
  
 case 'uint8'
  for p = 1:3
    rgb(:,:,p) = imlincomb(T8(p,1),in(:,:,1),T8(p,2),in(:,:,2), ...
                           T8(p,3),in(:,:,3),-offset8(p));
  end
  
 case 'uint16'
  for p = 1:3
    rgb(:,:,p) = imlincomb(T16(p,1),in(:,:,1),T16(p,2),in(:,:,2), ...
                           T16(p,3),in(:,:,3),-offset16(p));
  end  
end

if isColormap
   rgb = reshape(rgb, [colors 3 1]);
end

if isa(rgb,'double')
  rgb = min(max(rgb,0.0),1.0);
end

%%%
%Parse Inputs
%%%
function X = parse_inputs(varargin)

checknargin(1,1,nargin,mfilename);
X = varargin{1};

if ndims(X)==2
  checkinput(X,{'uint8','uint16','double'},'real nonempty',mfilename,'MAP',1);
  if (size(X,2) ~=3 || size(X,1) < 1)
    eid = sprintf('Images:%s:invalidSizeForColormap',mfilename);
    msg = 'MAP must be a m x 3 array.';
    error(eid,'%s',msg);
  end
elseif ndims(X)==3
  checkinput(X,{'uint8','uint16','double'},'real',mfilename,'RGB',1);
  if (size(X,3) ~=3)
    eid = sprintf('Images:%s:invalidTruecolorImage',mfilename);
    msg = 'RGB must a m x n x 3 array.';
    error(eid,'%s',msg);
  end
else
  eid = sprintf('Images:%s:invalidInputSize',mfilename);
  msg = ['RGB2GRAY only accepts two-dimensional or three-dimensional ' ...
         'inputs.'];
  error(eid,'%s',msg);
end
