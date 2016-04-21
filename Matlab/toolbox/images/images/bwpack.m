function BWP = bwpack(varargin)
%BWPACK Pack binary image.
%   BWP = BWPACK(BW) packs the uint8 binary image BW into the uint32 array
%   BWP, which is known as a packed binary image.  Because each 8-bit
%   pixel value in the binary image has only two possible values, 1 and
%   0, BWPACK can map each pixel to a single bit in the packed output
%   image. 
%
%   BWPACK processes the image pixels by column, mapping groups of 32
%   pixels into the bits of a uint32 value.  The first pixel in the first
%   row corresponds to the least significant bit of the first uint32
%   element of the output array.  The first pixel in the 32nd row
%   corresponds to the most significant bit of this same element.  The
%   first pixel of the 33rd row corresponds to the least significant bit
%   of the second output element, and so on.  If BW is M-by-N, then BWP
%   is CEIL(M/32)-by-N. 
%
%   Binary image packing is used to accelerate some binary morphological
%   operations, such as dilation and erosion.  If the input to IMDILATE or
%   IMERODE is a packed binary image, the functions use a specialized
%   routine to perform the operation faster. 
%
%   BWUNPACK is used to unpack packed binary images.
%
%   Class Support
%   -------------
%   BW can be logical or numeric, and it must be 2-D, real, and
%   nonsparse.  BWP is uint32.
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
%   See also BWUNPACK, IMDILATE, IMERODE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2003/05/03 17:50:11 $

checknargin(1,1,nargin,mfilename);
checkinput(varargin{1}, {'logical','numeric'}, {'real','2d','nonsparse'}, ...
           mfilename, 'BW', 1);

BW = varargin{1};

if ~islogical(BW)
    BW = BW ~= 0;
end

BWP = bwpackc(BW);


