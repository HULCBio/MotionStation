function u = im2uint16(img, typestr)
%IM2UINT16 Convert image to sixteen-bit unsigned integers.
%   IM2UINT16 takes an image as input, and returns an image of
%   class uint16.  If the input image is of class uint16, the
%   output image is identical to it.  If the input image is of
%   class double or uint8, IM2UINT16 returns the equivalent
%   image of class uint16, rescaling or offsetting the data as
%   necessary.
%
%   I2 = IM2UINT16(I1) converts the intensity image I1 to uint16,
%   rescaling the data if necessary.
%
%   RGB2 = IM2UINT16(RGB1) converts the truecolor image RGB1 to
%   uint16, rescaling the data if necessary.
%
%   X2 = IM2UINT16(X1,'indexed') converts the indexed image X1 to
%   uint16, offsetting the data if necessary.  If X1 is double,
%   then the maximum value of X1 must be 65536 or less.
%
%   I = IM2UINT16(BW) converts the binary image BW to a uint16 
%   intensity image, changing one-valued elements to 65535.
% 
%   Example
%   -------
%       I1 = reshape(linspace(0,1,20),[5 4])
%       I2 = im2uint16(I1)
%
%   See also DOUBLE, IM2DOUBLE, IM2UINT8, UINT8, UINT16.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.12.4.3 $  $Date: 2003/08/23 05:52:21 $

checknargin(1,2,nargin,mfilename);

if isa(img, 'uint16')
    u = img; 
   
elseif isa(img, 'double') | isa(img, 'uint8')
    if nargin==1
        % intensity image; call MEX-file
        u = grayto16(img);
        
    elseif nargin==2
    
        if ~ischar(typestr) | (typestr(1) ~= 'i')
            eid = 'Images:im2uint16:invalidInput';
            msg = 'Invalid input arguments';
            error(eid,'%s',msg);
        else 
            if (isa(img, 'uint8'))
                u = uint16(img);
                
            else
                % img is double
                if max(img(:))>=65537 
                    eid = 'Images:im2uint16:tooManyColors';
                    msg = 'Too many colors for 16-bit integer storage.';
                    error(eid,'%s',msg);
                elseif min(img(:))<1
                    eid = 'Images:im2uint16:invalidIndex';
                    msg = 'Invalid indexed image: an index was less than 1.';
                    error(eid,'%s',msg);
                else
                    u = uint16(img-1);
                end
            end
        end
    end
    
elseif islogical(img)
    u = uint16(img);
    u(img) = 65535;
    
else
    eid = 'Images:im2uint16:unsupportedInputClass';
    msg = 'Unsupported input class.';
    error(eid,'%s',msg);
end
