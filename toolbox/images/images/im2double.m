function d = im2double(img, typestr)
%IM2DOUBLE Convert image to double precision.
%   IM2DOUBLE takes an image as input, and returns an image of
%   class double.  If the input image is of class double, the
%   output image is identical to it.  If the input image is of
%   class logical, uint8 or uint16, im2double returns the 
%   equivalent image of class double, rescaling or offsetting
%   the data as necessary.
%
%   I2 = IM2DOUBLE(I1) converts the intensity image I1 to double
%   precision, rescaling the data if necessary.
%
%   RGB2 = IM2DOUBLE(RGB1) converts the truecolor image RGB1 to
%   double precision, rescaling the data if necessary.
%
%   I = IM2DOUBLE(BW) converts the binary image BW to a double-
%   precision intensity image.
%
%   X2 = IM2DOUBLE(X1,'indexed') converts the indexed image X1 to
%   double precision, offsetting the data if necessary.
% 
%   Example
%   -------
%       I1 = reshape(uint8(linspace(1,255,25)),[5 5])
%       I2 = im2double(I1)
  
%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.16.4.3 $  $Date: 2003/08/23 05:52:20 $

checknargin(1,2,nargin,mfilename);
checkinput(img,{'double','logical','uint8','uint16'},{},mfilename,'Image',1);

if isa(img, 'double')
   d = img;
elseif isa(img, 'logical')
   d = double(img);
elseif isa(img, 'uint8') | isa(img, 'uint16')
   if nargin==1
      if isa(img, 'uint8')
          d = double(img)/255;
      else
          d = double(img)/65535;
      end
   elseif nargin==2
      checkstrs(typestr,{'indexed'},mfilename,'type',2);
      d = double(img)+1;
   end
end

