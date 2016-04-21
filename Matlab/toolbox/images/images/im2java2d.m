function jimage = im2java2d(varargin)
%IM2JAVA2D Convert image to Java BufferedImage.
%   JIMAGE = IM2JAVA2D(I) converts the image I to an instance of the Java image
%   class, java.awt.image.BufferedImage. The image I can be an intensity
%   (grayscale), RGB, or binary image.
%
%   JIMAGE = IM2JAVA2D(X,MAP) converts the indexed image X with colormap MAP to
%   an instance of the Java class, java.awt.image.BufferedImage.
%
%   Class Support
%   -------------
%   Intensity, Indexed, and RGB input images can be of class uint8, uint16, or
%   double. Binary input images must be of class logical. 
%
%   Example
%   -------
%   This example reads an image into the MATLAB workspace and then uses
%   im2java2d to convert it into an instance of the Java class, 
%   java.awt.image.BufferedImage.
%
%   I = imread('moon.tif');
%   javaImage = im2java2d(I);
%   frame = javax.swing.JFrame;
%   icon = javax.swing.ImageIcon(javaImage);
%   label = javax.swing.JLabel(icon);
%   frame.getContentPane.add(label);
%   frame.pack
%   frame.show

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.8 $  $Date: 2003/08/01 18:08:59 $

%   Input-output specs
%   ------------------ 
%   I:    2-D, real, full matrix
%         logical, uint8, uint16, or double
%
%   RGB:  3-D, real, full matrix
%         size(RGB,3)==3
%         uint8, uint16, or double
%
%   X:    2-D, real, full matrix
%         uint8, uint16, or double
%         if isa(X,'uint8'): X <= size(MAP,1)-1
%         if isa(X,'uint16'): X <= size(MAP,1)-1
%         if isa(X,'double'): 1 <= X <= size(MAP,1)
%         
%   MAP:  2-D, real, full matrix
%         size(MAP,1) <= 65536 (when X is double or uint16)
%         size(MAP,1) <= 256 (when X is uint8)
%         size(MAP,2) == 3
%         double
%
%   JIMAGE:  java.awt.image.BufferedImage

%   Note 
%   ----  
%   This function uses com.mathworks.toolbox.images.util.ImageFactory which
%   casts double intensity and RGB images to uint8.
%
%   Indexed images work for uint8, uint16, and double. Double indexed images
%   are treated as uint8 or uint16 indexed images depending on the length
%   of the colormap.
%   
%   Binary images are cast to uint8 and treated as indexed images with 2 colors.
%
%   Intensity images are actually treated as indexed images because the Color
%   management for grayscale images using
%   ColorSpace.getInstance(ColorSpace.CS_GRAY) gives a washed out result for
%   grayscale images. Eventually we should create our own color model so that
%   the data can be passed straight to Java in the DataBuffer and interpretted
%   appropriately.


% Don't run on platforms with incomplete Java support
if ~IsJavaAvailable
  eid = sprintf('Images:%s:im2java2dNotAvailableOnThisPlatform',mfilename);
  error(eid,'%s', 'IM2JAVA2D is not available on this platform.');
end

[img,map,method] = ParseInputs(varargin{:});

width  = size(img,2);
height = size(img,1);

import com.mathworks.toolbox.images.util.ImageFactory;

% Assign function according to method
switch method
 case 'binary'
  map = gray(2);
  jimage = create_indexed_image(width,height,img,map);
  
 case 'intensity' 

  % treat intensity as indexed to avoid washed out colorspace, see note above.
  if isa(img,'uint16')
    map = gray(65536);    
  else 
    map = gray(256);
  end
  jimage = create_indexed_image(width,height,img,map);

 case 'rgb'
  img = permute(img,[3 2 1]);
  jimage = ImageFactory.createInterleavedRGBImage(width,height,img(:));

 case 'indexed'
  jimage = create_indexed_image(width,height,img,map);
  
end    

%-------------------------------
function jimage = create_indexed_image(width,height,img,map)

import com.mathworks.toolbox.images.util.ImageFactory;

mapLength = size(map,1);
map = uint8(map*256 - 1); % convert to uint8 map for Java
img = img';
map = map';
jimage = ImageFactory.createIndexedImage(width,height,img(:),...
                                         mapLength,map(:));  


%-------------------------------
% Function  ParseInputs
%-------------------------------
function [img, map, method] = ParseInputs(varargin)

% defaults
img = [];
map = [];
method = ''; 

checknargin(1,2,nargin,mfilename);
checkinput(varargin{1},{'uint8','uint16','double','logical'},...
           {'real','nonsparse'},...
           mfilename,'Image',1)

img = varargin{1};

switch nargin
 case 1

  method = get_image_type(img);
  
  % Convert to uint8 only if double or binary.
  if isa(img,'double')
    img = uint8(img * 255 + 0.5);
  elseif strmatch(method,'binary') 
    img = uint8(img);
  end
  
 case 2
  
  method = 'indexed';
  map = varargin{2};
  ncolors = validate_map(img,map);
  img     = validate_X(img,ncolors);
  
 otherwise
  eid = 'Images:im2java2d:tooManyInputs';
  error(eid, '%s', 'Internal problem: too many input arguments.');
  return;
  
end


%-------------------------------
function method = get_image_type(img)

if ndims(img) == 2  
  if islogical(img)
    method = 'binary';
  else
    method = 'intensity';    
  end

elseif ndims(img)==3 & size(img,3)==3
  method = 'rgb';

else
  eid = sprintf('Images:%s:invalidImage',mfilename);
  msg = sprintf(...
      '%s: Image must be binary, intensity, RGB, or indexed image.',...
      upper(mfilename));
  error(eid,msg);

end


%-------------------------------
function ncolors = validate_map(img,map)

checkmap(map, mfilename, 'MAP', 2);

if isa(img,'uint8') 
  MAX_COLORS = 256;
else
  MAX_COLORS = 65536;
end

ncolors = size(map,1);  
if ncolors > MAX_COLORS
  eid = sprintf('Images:%s:invalidMapLength',mfilename);
  msg = sprintf(...
      '%s: MAP has too many colors.',...
      upper(mfilename));
  error(eid,msg);
end
    

%-------------------------------
function img = validate_X(img,ncolors)

checkinput(img,{'uint8','uint16','double'},{'2d'},mfilename,'X',1)

if isa(img,'double')
  checkinput(img,{'double'},{'positive'},mfilename,'X',1)    
  if ncolors <= 256
    img = uint8(img - 1);
  else
    img = uint16(img - 1);
  end
end

if max(img(:)) > ncolors-1
  eid_index_out = sprintf('Images:%s:indexOutsideColormap',mfilename);    
  msg_index_out = ...
      'Invalid indexed image: an index falls outside colormap.';    
  error(eid_index_out,msg_index_out);
end                

%-------------------------------
function java_available = IsJavaAvailable

java_available = false;

if isempty(javachk('swing'))
  java_available = true;
end

