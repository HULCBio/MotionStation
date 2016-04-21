function varargout=dither(varargin)
%DITHER Convert image using dithering.
%   X = DITHER(RGB,MAP) creates an indexed image approximation of
%   the RGB image in the array RGB by dithering the colors in
%   colormap MAP.  MAP cannot have more than 65536 colors.
%
%   X = DITHER(RGB,MAP,Qm,Qe) creates an indexed image from RGB,
%   specifying the parameters Qm and Qe. Qm specifies the number
%   of quantization bits to use along each color axis for the
%   inverse color map, and Qe specifies the number of
%   quantization bits to use for the color space error
%   calculations.  If Qe < Qm, dithering cannot be performed and
%   an undithered indexed image is returned in X.  If you omit
%   these parameters, DITHER uses the default values Qm = 5, 
%   Qe = 8.
%
%   BW = DITHER(I) converts the intensity image in the matrix I
%   to the binary image BW by dithering.
%
%   Class Support
%   -------------
%   The input image (RGB or I) can be of class uint8, uint16, or
%   double. All other input arguments must be of class
%   double. The output image (X or BW) is of class logical if it is
%   a binary image or uint8 if it is an indexed image with 256 or fewer
%   colors; otherwise its class is uint16.
%
%   Example
%   -------
%   Convert intensity image to binary using dithering.
%
%       I = imread('cameraman.tif');
%       BW = dither(I);
%       imview(I)
%       imview(BW)
%  
%   See also RGB2IND.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.24.4.3 $  $Date: 2003/12/13 02:43:05 $

%   References: 
%      R. W. Floyd and L. Steinberg, "An Adaptive Algorithm for
%         Spatial Gray Scale," International Symposium Digest of Technical
%         Papers, Society for Information Displays, 36.  1975.
%      Spencer W. Thomas, "Efficient Inverse Color Map Computation",
%         Graphics Gems II, (ed. James Arvo), Academic Press: Boston.
%         1991. (includes source code)

[X,m,qm,qe] = parse_inputs(varargin{:});

if ndims(X)==2,% Convert intensity image to binary by dithering
  im = logical(ditherc(X,m,qm,qe));
  map = 2;
else % Create an indexed image from RGB 
  im = ditherc(X,m,qm,qe);
  map = m;
end

if nargout==0,
  imshow(im,map);
else 
  varargout{1} = im;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [X,m,qm,qe] = parse_inputs(varargin)
% Outputs:  X  the input RGB (3D) or intensity image (2D)
%           m  colormap (:,3)
%           qm number of quantization bits for colormap
%           qe number of quantization bits for errors, qe>qm

checknargin(1,6,nargin,mfilename);

% Default values:
qm = 5;
qe = 8;

switch nargin
case 1,                        % dither(I)
  X = varargin{1};
  m = gray(2); 
case 2,                        % dither(RGB,m)
  X = varargin{1};
  m = varargin{2};
case 4,
  if length(varargin{4})==1,   % dither(RGB,m,qm,qe)
    X = varargin{1};
    m = varargin{2};
    qm = varargin{3};
    qe = varargin{4};
  else                        % dither(R,G,B,m) OBSOLETE
    eid = sprintf('Images:%s:obsoleteSyntax',mfilename);
    msg = ['DITHER(R,G,B,m) is an obsolete syntax. ',...
           'Use a three-dimensional array to represent RGB image.'];
    warning(eid,msg);
    X = cat(3,varargin{1},varargin{2},varargin{3});
    m = varargin{4};
  end;
case 6,                       % dither(R,G,B,m,qm,qe) OBSOLETE
  eid = sprintf('Images:%s:obsoleteSyntax',mfilename);
  msg = ['DITHER(R,G,B,m,qm,qe) is an obsolete syntax. ',...
         'Use a three-dimensional array to represent RGB image.'];
  warning(eid, msg);
  X = cat(3,varargin{1},varargin{2},varargin{3});
  m = varargin{4};
  qm = varargin{5};
  qe = varargin{6};
otherwise,
  eid = sprintf('Images:%s:invalidInput',mfilename);
  error(eid,'Invalid input arguments in function %s.',mfilename);
end

% Check validity of the input parameters 
if ((ndims(X)==3) && (nargin==1))
  eid = sprintf('Images:%s:imageMustBe2D',mfilename);  
  error(eid,'DITHER(I): the intensity image I has to be a two-dimensional array.');
elseif ((ndims(X)==2) && (nargin==2))
  eid = sprintf('Images:%s:imageMustBe3D',mfilename);  
  error(eid,'DITHER(RGB,map): the RGB image has to be a three-dimensional array.');
end;

X = im2uint8(X);
 
if ((size(m,2) ~= 3) || (size(m,1)==1) || (ndims(m)>2))
  eid = sprintf('Images:%s:colormapMustBe2D',mfilename);  
  error(eid,['In function %s, input colormap has to be a ',...
             '2D array with at least 2 rows and exactly 3 columns.'], mfilename);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
