function [pixels, overlays] = dicom_decode_pixel_cells(data, info, ol_bits)
%DICOM_DECODE_PIXEL_CELLS  Get pixel values and overlay bits from pixel cells.
%   [PIXELS, OVERLAYS] = DICOM_DECODE_PIXEL_CELLS(DATA, INFO, BITS)
%   extracts the pixel and overlay data from the pixel cells DATA.  INFO
%   is the metadata structure for the pixel data array DATA.  OL_BITS is
%   a vector of bit positions in DATA which contain overlay data, which
%   are always single bits.
%
%   The PIXELS returned are a vector of integer values without overlay
%   data.  The values in PIXELS have been shifted to start at the
%   least-significant byte for each element, so that they actually
%   represent the correct pixel values without further modification.
%
%   The OVERLAYS array is an m-by-n-by-1-by-p logical array, where p is
%   the number of overlays in the DATA.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2003/12/13 02:48:34 $


%
% Read overlays.
%

if (isempty(ol_bits))
    
    overlays = logical([]);
    
else
    
    overlays = repmat(false, [info.Height info.Width info.NumberOfFrames ...
                    length(ol_bits)]);
    
end
                              
level = 0;

for p = 1:length(ol_bits)

    level = level + 1;
    
    plane = bitget(data, (ol_bits(p) + 1));
    plane = reshape(plane, [size(overlays,1), size(overlays,2), ...
                            size(overlays,3)]);
    
    plane = permute(plane, [2 1 3]);
    overlays(:, :, :, level) = plane;
    
end

% 
% Strip out overlays.
%

% Convert signed data temporarily to unsigned. 
if (info.PixelRepresentation == 1)

    switch (class(data))
    case 'int8'
        data = cast(data, 'uint8');
    case 'int16'
        data = cast(data, 'uint16');
    case 'int32'
        data = cast(data, 'uint32');
    end

end

% Remove higher order overlays.
mask = (2^(info.HighBit + 1) - 1);
data = bitand(data, mask);

% Remove lower order overlays.
bit_offset = (info.HighBit + 1) - info.BitsStored;
data = bitshift(data, -bit_offset);

% Fit the data into an appropriate sized storage unit.
container_size = ceil(info.BitsStored / 8) * 8;

if (info.PixelRepresentation == 1)
    
    sign_bit = info.HighBit - bit_offset + 1;
    has_negative = any(bitget(data, sign_bit));

    % Move the size bit to the end of the data container (e.g., the 8th
    % or 16th bit) and fill old sign bit with 0.
    if ((sign_bit ~= container_size) && (has_negative))
        
        mask = bitget(data, sign_bit);
        data = bitor(data, bitshift(mask, container_size));
        data = bitset(data, sign_bit, 0);
        
    end
    
end

% Convert signed data back from unsigned.
if (info.PixelRepresentation == 1)

    switch (class(data))
    case 'uint8'
        data = cast(data, 'int8');
    case 'uint16'
        data = cast(data, 'int16');
    case 'uint32'
        data = cast(data, 'int32');
    end

end

%
% Store pixel bits.
%

switch (container_size)
case 8
    
    if (info.PixelRepresentation == 0)
        pixels = uint8(data);
    else
        pixels = int8(data);
    end
    
case 16
    
    if (info.PixelRepresentation == 0)
        pixels = uint16(data);
    else
        pixels = int16(data);
    end
    
case 32
    
    if (info.PixelRepresentation == 0)
        pixels = uint32(data);
    else
        pixels = int32(data);
    end
    
end
