function [X,map] = gray2ind(varargin)
%GRAY2IND Convert intensity image to indexed image.
%   GRAY2IND scales, then rounds, an intensity image to produce
%   an equivalent indexed image.
%
%   [X,MAP] = GRAY2IND(I,N) converts the intensity image I to an
%   indexed image X with colormap GRAY(N). If N is omitted, it
%   defaults to 64.
%
%   [X,MAP] = GRAY2IND(BW,N) converts the binary image BW to an
%   indexed image X with colormap GRAY(N). If N is omitted, it
%   defaults to 2.
%
%   N must be an integer between 1 and 65536.
% 
%   Class Support
%   -------------
%   The input image I must be a real, nonsparse array of class logical,
%   uint8, uint16, or double.  It can have any dimension.  The class of the
%   output image X is uint8 if the colormap length is less than or equal
%   to 256; otherwise it is uint16.
%
%   Example
%   -------
%       I = imread('cameraman.tif');
%       [X, map] = gray2ind(I, 16);
%       imview(X, map);
%
%   See also IND2GRAY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.33.4.2 $  $Date: 2003/08/23 05:52:17 $
  
[I,n] = parse_inputs(varargin{:});
    
if islogical(I)  % is it a binary image?
    X = bw2index(I,n);
else
    X = gray2index(I,n);
end

map = gray(n);

function X = bw2index(BW,n)

if n <= 256
    X = uint8(BW);
else
    X = uint16(BW);
end

X(BW) = n-1;

function X = gray2index(I,n)

[sf] = scale_factor(I,n);

if n <= 256,   
    % 256 or fewer colors, we can output uint8
    X = imlincomb(sf,I,'uint8');
else    
    X = imlincomb(sf,I,'uint16');
end

function [sf] = scale_factor(I,n)

image_class = class(I);

switch image_class
    
    case 'double'
        sf = n-1;
    case 'uint8'
        sf = (n-1)/255;
    case 'uint16'
        sf = (n-1)/65535;
end
        

function check_n(n)

if prod(size(n)) ~= 1 | ...
      ~isnumeric(n)   | ...
      ~isreal(n)      | ...
      floor(n) ~= n   | ...
      n < 1           | ...
      n > 65536
    error('Images:gray2ind:inputOutOfRange',...
          'Input argument N to GRAY2IND must be an integer between 1 and 65536.');
end

function [I,n] = parse_inputs(varargin)

default_grayscale_colormap_size = 64;
default_binary_colormap_size = 2;

checknargin(1,2,nargin,mfilename);

I = varargin{1};

if nargin == 1
    if islogical(I)
        n = default_binary_colormap_size;
    else
        n = default_grayscale_colormap_size;
    end
else
    n = varargin{2};
end

check_n(n);
checkinput(I,'uint8 uint16 double logical','real',mfilename,'I',1);

function check_image(I)
