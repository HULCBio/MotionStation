function image = changeclass(class, varargin)
%CHANGECLASS will change the storage class of an image.
%   I2 = CHANGECLASS(CLASS, I);
%   RGB2 = CHANGECLASS(CLASS, RGB);
%   BW2 = CHANGECLASS(CLASS, BW);
%   X2 = CHANGECLASS(CLASS, X, 'indexed');

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.8.4.2 $  $Date: 2003/08/01 18:10:16 $

switch class
case 'uint8'
    image = im2uint8(varargin{:});
case 'uint16'
    image = im2uint16(varargin{:});
case 'double'
    image = im2double(varargin{:});
otherwise
    eid = sprintf('Images:%s:unsupportedIPTClass',mfilename);                
    error(eid,'%s','Unsupported IPT data class.');
end
