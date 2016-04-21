function out = rgb2ycbcr(varargin)
%RGB2YCBCR Convert RGB values to YCBCR color space.
%   YCBCRMAP = RGB2YCBCR(MAP) converts the RGB values in MAP to
%   the YCBCR color space.  YCBCRMAP is a M-by-3 matrix that contains
%   the YCBCR luminance (Y) and chrominance (Cb and Cr) color values as
%   columns.  Each row represents the equivalent color to the
%   corresponding row in the RGB colormap.
%
%   YCBCR = RGB2YCBCR(RGB) converts the truecolor image RGB to the
%   equivalent image in the YCBCR color space.
%
%   Class Support
%   -------------
%   If the input is an RGB image, it can be of class uint8, uint16,
%   or double; the output image is of the same class as the input 
%   image.  If the input is a colormap, the input and output colormaps 
%   are both of class double.
%
%   Examples
%   --------
%   Convert RGB image to YCbCr.
%
%      RGB = imread('board.tif');
%      YCBCR = rgb2ycbcr(RGB);
%
%   Convert RGB color space to YCbCr.
%
%      map = jet(256);
%      newmap = rgb2ycbcr(map);

%   See also NTSC2RGB, RGB2NTSC, YCBCR2RGB.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.13.4.2 $  $Date: 2003/08/23 05:54:37 $

%   Reference: 
%     C.A. Poynton, "A Technical Introduction to Digital Video", John Wiley
%     & Sons, Inc., 1996, p. 175

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

% set up constants for transformation
T = [65.481 128.553 24.966;...
     -37.797 -74.203 112; ...
     112 -93.786 -18.214];
offset = [16;128;128];
offset16 = 257 * offset;
fac8 = 1/255;
fac16 = 257/65535;

%initialize output
out = in;

% do transformation
switch classin
 case 'uint8'
  for p=1:3
    out(:,:,p) = imlincomb(T(p,1)*fac8,in(:,:,1),T(p,2)*fac8,in(:,:,2),...
                         T(p,3)*fac8,in(:,:,3),offset(p));
  end
 case 'uint16'
  for p=1:3
    out(:,:,p) = imlincomb(T(p,1)*fac16,in(:,:,1),T(p,2)*fac16,in(:,:,2),...
                         T(p,3)*fac16,in(:,:,3),offset16(p));
  end
 case 'double'
  % These equations transform RGB in [0,1] to YCBCR in [0, 255]
  for p=1:3
    out(:,:,p) =  T(p,1) * in(:,:,1) + T(p,2) * in(:,:,2) + T(p,3) * ...
        in(:,:,3) + offset(p);
  end
  out = out / 255;
end

if isColormap
   out = reshape(out, [colors 3 1]);
end

%%%
%Parse Inputs
%%%
function X = parse_inputs(varargin)

checknargin(1,1,nargin,mfilename);
X = varargin{1};

if ndims(X)==2
  % For backward compatability, this function handles uint8 and uint16
  % colormaps. This usage will be removed in a future release.

  checkinput(X,{'uint8','uint16','double'},'nonempty',mfilename,'MAP',1);
  if (size(X,2) ~=3 || size(X,1) < 1)
    eid = sprintf('Images:%s:invalidSizeForColormap',mfilename);
    msg = 'MAP must be a m x 3 array.';
    error(eid,'%s',msg);
  end
  if ~isa(X,'double')
    wid = sprintf('Images:%s:notAValidColormap',mfilename);
    msg = ['MAP should be a double m x 3 array with values in the range [0,1].'...
           'Convert your map to double using IM2DOUBLE.'];
    warning(wid,'%s',msg);
    X = im2double(X);
  end

elseif ndims(X)==3
  checkinput(X,{'uint8','uint16','double'},'',mfilename,'RGB',1);
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
