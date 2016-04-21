function BW = bwunpack(varargin)
%BWUNPACK Unpack binary image.
%   BW = BWUNPACK(BWP,M) unpacks the packed binary image BWP.  BWP is a
%   uint32 array.  When it unpacks BWP, BWUNPACK maps the least
%   significant bit of the first row of BWP to the first pixel in the
%   first row of BW.  The most significant bit of the first element of
%   BWP maps to the first pixel in the 32nd row of BW, and so on.  BW is
%   M-by-N, where N is the number of columns of BWP.  If M is omitted,
%   its default value is 32*SIZE(BWP,1). 
%
%   Binary image packing is used to accelerate some binary morphological
%   operations, such as dilation and erosion.  If the input to IMDILATE or
%   IMERODE is a packed binary image, the functions use a specialized
%   routine to perform the operation faster. 
%
%   BWPACK is used to create packed binary images.
%
%   Class Support
%   -------------
%   BWP must be uint32, and it must be real, 2-D, and nonsparse.  M must be a
%   positive integer. BW is logical. 
%
%   Example
%   -------
%   Pack, dilate, and unpack a binary image:
%
%       bw = imread('text.png');
%       bwp = bwpack(bw);
%       bwp_dilated = imdilate(bwp,ones(3,3),'ispacked');
%       bw_dilated = bwunpack(bwp_dilated, size(bw,1));
%
%   See also BWPACK, IMDILATE, IMERODE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2003/05/03 17:50:16 $

checknargin(1,2,nargin,mfilename);
checkinput(varargin{1}, 'uint32', {'real','2d','nonsparse'}, mfilename, 'BWP', ...
           1);
BWP = varargin{1};

if nargin ~= 2
  BW = bwunpackc(BWP);
else
  checkinput(varargin{2}, 'numeric', {'scalar','integer','nonnegative'}, ...
             mfilename, 'M', 2);
  M = varargin{2};
  BW = bwunpackc(BWP,M);
end
