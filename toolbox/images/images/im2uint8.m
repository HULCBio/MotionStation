function u = im2uint8(varargin)
%IM2UINT8 Convert image to eight-bit unsigned integers.
%   IM2UINT8 takes an image as input, and returns an image of
%   class uint8.  If the input image is of class uint8, the
%   output image is identical to it.  If the input image is of
%   class logical, double or uint16, im2uint8 returns the
%   equivalent image of class uint8, rescaling or offsetting 
%   the data as necessary.
%
%   I2 = IM2UINT8(I1) converts the intensity image I1 to uint8,
%   rescaling the data if necessary.
%
%   RGB2 = IM2UINT8(RGB1) converts the truecolor image RGB1 to
%   uint8, rescaling the data if necessary.
%
%   I = IM2UINT8(BW) converts the binary image BW to a uint8 
%   intensity image, changing one-valued elements to 255. 
%
%   X2 = IM2UINT8(X1,'indexed') converts the indexed image X1 to
%   uint8, offsetting the data if necessary. Note that it is
%   not always possible to convert an indexed image to
%   uint8. If X1 is double, then the maximum value of X1 must
%   be 256 or less.  If X1 is uint16, the maximum value of X1
%   must be 255 or less.
% 
%   Example
%   -------
%       I1 = reshape(uint16(linspace(0,65535,25)),[5 5])
%       I2 = im2uint8(I1)
%
%   See also DOUBLE, IM2DOUBLE, IM2UINT16, UINT8, UINT16, IMAPPROX.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.20.4.3 $  $Date: 2003/08/23 05:52:22 $

checknargin(1,2,nargin,mfilename);

img = varargin{1};
checkinput(img,{'double','logical','uint8','uint16'},{},mfilename,'Image',1);

if isa(img, 'uint8')
    u = img; 
elseif isa(img, 'logical')
    u=uint8(img);
    u(img)=255;
elseif isa(img, 'double') | isa(img, 'uint16')
    if nargin==1
         % intensity image; call MEX-file
         u = grayto8(img);
    elseif nargin==2
       typestr = varargin{2};
       checkstrs(typestr,{'indexed'},mfilename,'type',2);
       if (isa(img, 'uint16'))
            if (max(img(:)) > 255)
                msg = 'Too many colors for 8-bit integer storage.';
                eid = sprintf('Images:%s:tooManyColorsFor8bitStorage');
                error(eid,msg);
            else
                u = uint8(img);
            end
        else
            % img is double
            if max(img(:))>=257 
                msg = 'Too many colors for 8-bit integer storage.';
                eid = sprintf('Images:%s:tooManyColorsFor8bitStorage');
                error(eid,msg);
            elseif min(img(:))<1
                msg = 'Invalid indexed image: an index was less than 1.';
                eid = sprintf('Images:%s:invalidIndexedImage');
                error(eid,msg);
            else
                u = uint8(img-1);
            end
        end
    end
end
