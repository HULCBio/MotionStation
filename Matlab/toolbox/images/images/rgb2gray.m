function I = rgb2gray(varargin)
%RGB2GRAY Convert RGB image or colormap to grayscale.
%   RGB2GRAY converts RGB images to grayscale by eliminating the
%   hue and saturation information while retaining the
%   luminance.
%
%   I = RGB2GRAY(RGB) converts the truecolor image RGB to the
%   grayscale intensity image I.
%
%   NEWMAP = RGB2GRAY(MAP) returns a grayscale colormap
%   equivalent to MAP.
%
%   Class Support
%   -------------
%   If the input is an RGB image, it can be of class uint8, 
%   uint16 or double; the output image I is of the same class 
%   as the input image. If the input is a colormap, the input 
%   and output colormaps are both of class double.
%
%   Example
%   -------
%   I = imread('board.tif');
%   J = rgb2gray(I);
%   imview(I), imview(J);
%
%   [X,map] = imread('trees.tif');
%   gmap = rgb2gray(map);
%   imview(X,map), imview(X,gmap);
%
%   See also IND2GRAY, NTSC2RGB, RGB2IND, RGB2NTSC.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.20.4.3 $  $Date: 2003/08/23 05:54:35 $

X = parse_inputs(varargin{:});
origSize = size(X);

% Determine if input includes a 3-D array 
threeD = (ndims(X)==3);

% Calculate transformation matrix
T = inv([1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703]);
coef = T(1,:)';

if threeD
  %RGB
  % Shape input matrix so that it is a n x 3 array and initialize output
  % matrix  
  X = reshape(X(:),origSize(1)*origSize(2),3);
  sizeOutput = [origSize(1), origSize(2)];
  
  % Do transformation
  if isa(X, 'double')
    I = X*coef;
    I = min(max(I,0),1);
  else
    %uint8 or uint16
    I = imlincomb(coef(1),X(:,1),coef(2),X(:,2),coef(3),X(:,3), ...
                  class(X));
  end
  %Make sure that the output matrix has the right size
  I = reshape(I,sizeOutput);   

else
  % For backward compatability, this function handles uint8 and uint16
  % colormaps. This usage will be removed in a future release.
  if ~isa(X,'double')
    I = imlincomb(coef(1),X(:,1),coef(2),X(:,2),coef(3),X(:,3), class(X));
  else
    I = X*coef;
    I = min(max(I,0),1);
  end
  I = im2double(I);
  I = [I,I,I];
end


%%%
%Parse Inputs
%%%
function X = parse_inputs(varargin)

checknargin(1,3,nargin,mfilename);

switch nargin
 case 1
  if ndims(varargin{1})==2
    if (size(varargin{1},2) ~=3 || size(varargin{1},1) < 1)
      eid = sprintf('Images:%s:invalidSizeForColormap',mfilename);
      msg = 'MAP must be a m x 3 array.';
      error(eid,'%s',msg);
    end
    if ~isa(varargin{1},'double')
      wid = sprintf('Images:%s:notAValidColormap',mfilename);
      msg1 = 'MAP should be a double m x 3 array with values in the';
      msg2 = ' range [0,1].Convert your map to double using IM2DOUBLE.';
      warning(wid,'%s %s',msg1,msg2);
    end
  elseif (ndims(varargin{1})==3)
    if ((size(varargin{1},3) ~= 3))
      eid = sprintf('Images:%s:invalidInputSize',mfilename);
      msg = 'RGB must be a m x n x 3 array.';
      error(eid,'%s',msg);
    end
  else
    eid = sprintf('Images:%s:invalidInputSize',mfilename);
    msg1 = 'RGB2GRAY only accepts a 2-D input for MAP or a 3-D input for ';
    msg2 = 'RGB.';
    error(eid,'%s %s',msg1,msg2);
  end
  X = varargin{1};  
 
 case 2
  eid = sprintf('Images:%s:invalidNumberOfArguments',mfilename);
  msg = 'Two input arguments are not allowed.';
  error(eid,'%s',msg);
 
 case 3
  wid = sprintf('Images:%s:obsoleteSyntax',mfilename);
  msg1 = 'RGB2GRAY(R,G,B) is an obsolete syntax.';
  msg2 = 'Use a three-dimensional array to represent RGB image.';
  warning(wid,'%s %s',msg1,msg2);
  if ( any(size(varargin{1})~=size(varargin{2})) || any(size(varargin{1})~= ...
                                                      size(varargin{3})) )
    eid = sprintf('Images:%s:inputsDontHaveSameSize',mfilename);
    msg = 'R, G, and B must all be the same size.';
    error(eid,'%s',msg);
  end
  X = cat(3,varargin{1},varargin{2},varargin{3});
end

%no logical arrays
if islogical(X)
  eid = sprintf('Images:%s:invalidType',mfilename);
  msg = 'RGB2GRAY does not accept logical arrays as inputs.';
  error(eid,'%s',msg);
end
