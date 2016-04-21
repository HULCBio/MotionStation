function metadata = dicom_prep_ImagePixel(metadata, X, map, txfr)
%DICOM_PREP_IMAGEPIXEL  Set necessary values for Image Pixel module.
%
%   See PS 3.3 Sec C.7.6.3

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:10:47 $

metadata(1).(dicom_name_lookup('0028', '0002')) = size(X, 3);
metadata.(dicom_name_lookup('0028', '0004')) = getPhotometricInterp(X, map, txfr);
metadata.(dicom_name_lookup('0028', '0010')) = size(X, 1);
metadata.(dicom_name_lookup('0028', '0011')) = size(X, 2);

[ba, bs, hb, pr] = getPixelStorage(X, txfr);
metadata.(dicom_name_lookup('0028', '0100')) = ba;
metadata.(dicom_name_lookup('0028', '0101')) = bs;
metadata.(dicom_name_lookup('0028', '0102')) = hb;
metadata.(dicom_name_lookup('0028', '0103')) = pr;

metadata.(dicom_name_lookup('7FE0', '0010')) = encodePixelData(metadata, X, map, txfr);

if (size(X, 3) > 1)
    metadata.(dicom_name_lookup('0028', '0006')) = 0;  % Interleaved pixels.
end

metadata.(dicom_name_lookup('0028', '0106')) = min(X(:));
metadata.(dicom_name_lookup('0028', '0107')) = max(X(:));

if (~isempty(map))
    [rdes, gdes, bdes, rdata, gdata, bdata] = processColormap(X, map);
    metadata.(dicom_name_lookup('0028', '1101')) = rdes;
    metadata.(dicom_name_lookup('0028', '1102')) = gdes;
    metadata.(dicom_name_lookup('0028', '1103')) = bdes;
    metadata.(dicom_name_lookup('0028', '1201')) = rdata;
    metadata.(dicom_name_lookup('0028', '1202')) = gdata;
    metadata.(dicom_name_lookup('0028', '1203')) = bdata;
end



function pInt = getPhotometricInterp(X, map, txfr)
%GETPHOTOMETRICINTERP   Get the string code for the image's photometric interp

if (isempty(map))
    
    if (size(X, 3) == 1)
        
        % 0 is black.  Grayscale images should always have a value of
        % 'MONOCHROME1' or 'MONOCHROME2', regardless of compression.
        pInt = 'MONOCHROME2';
        
    elseif (size(X, 3) == 3)
        
        switch (txfr)
        case {'1.2.840.10008.1.2.4.50'
              '1.2.840.10008.1.2.4.51'
              '1.2.840.10008.1.2.4.52'
              '1.2.840.10008.1.2.4.53'
              '1.2.840.10008.1.2.4.54'
              '1.2.840.10008.1.2.4.55'
              '1.2.840.10008.1.2.4.56'
              '1.2.840.10008.1.2.4.57'
              '1.2.840.10008.1.2.4.58'
              '1.2.840.10008.1.2.4.59'
              '1.2.840.10008.1.2.4.60'
              '1.2.840.10008.1.2.4.61'
              '1.2.840.10008.1.2.4.62'
              '1.2.840.10008.1.2.4.63'
              '1.2.840.10008.1.2.4.64'
              '1.2.840.10008.1.2.4.65'
              '1.2.840.10008.1.2.4.66'
              '1.2.840.10008.1.2.4.70'
              '1.2.840.10008.1.2.4.80'
              '1.2.840.10008.1.2.4.81'}
      
            pInt = 'YBR_FULL_422';

        otherwise
            
            pInt = 'RGB';
            
        end
        
    else
        
        error('Images:dicom_prep_ImagePixel:photoInterp', 'Cannot determine photometric interpretation.')
        
    end
    
else
    
    if (size(X, 3) == 1)
        pInt = 'PALETTE COLOR';
    elseif (size(X, 3) == 4)
        pInt = 'RGBA';
    else
        error('Images:dicom_prep_ImagePixel:photoInterp', 'Cannot determine photometric interpretation.')
    end
    
end



function [ba, bs, hb, pr] = getPixelStorage(X, txfr)
%GETPIXELSTORAGE   Get details about the pixel cells.

switch (class(X))
case {'uint8', 'logical'}
    ba = 8;
    bs = 8;
    pr = 0;
    
case {'int8'}
    ba = 8;
    bs = 8;
    pr = 1;
    
case {'uint16'}
    ba = 16;
    bs = 16;
    pr = 0;
    
case {'int16'}
    ba = 16;
    bs = 16;
    pr = 1;
    
case {'double'}
    
    switch (txfr)
    case '1.2.840.10008.1.2.4.50'
        ba = 8;
        bs = 8;
        pr = 0;
        
    otherwise
        % Customers report that UINT8 data isn't large enough.
        ba = 16;
        bs = 16;
        pr = 0;
        
    end
end

hb = ba - 1;



function [rdes, gdes, bdes, rdata, gdata, bdata] = processColormap(X, map)
%PROCESSCOLORMAP  Turn a MATLAB colormap into a DICOM colormap.

% First descriptor.
map_rows = size(map, 1);

if (map_rows == (2^16))
    map_rows = 0;
end

% Second descriptor is always 0 for MATLAB's use of colormaps.

% Third descriptor.
switch (class(X))
case {'uint8', 'int8'}
    
    map_bits = 8;
    
case {'uint16', 'int16'}
    
    map_bits = 16;
    
case 'double'
    
    if (log2(size(map, 1)) > 8)
        map_bits = 16;
    else
        map_bits = 8;
    end
    
end

rdes = [map_rows 0 map_bits];
gdes = rdes;
bdes = rdes;

% PS 3.3 Sec. C.7.6.3.1.6 says data must span the full range.
rdata = uint16(map(:, 1) .* (2 ^ map_bits - 1));
gdata = uint16(map(:, 2) .* (2 ^ map_bits - 1));
bdata = uint16(map(:, 3) .* (2 ^ map_bits - 1));



function pixelData = encodePixelData(metadata, X, map, txfr)
%ENCODEPIXELCELLS   Turn a MATLAB image into DICOM-encoded pixel data.

%
% Rescale logical and double data.
%
switch (txfr)
case {'1.2.840.10008.1.2.4.50'
      '1.2.840.10008.1.2.4.51'
      '1.2.840.10008.1.2.4.52'
      '1.2.840.10008.1.2.4.53'
      '1.2.840.10008.1.2.4.54'
      '1.2.840.10008.1.2.4.55'
      '1.2.840.10008.1.2.4.56'
      '1.2.840.10008.1.2.4.57'
      '1.2.840.10008.1.2.4.58'
      '1.2.840.10008.1.2.4.59'
      '1.2.840.10008.1.2.4.60'
      '1.2.840.10008.1.2.4.61'
      '1.2.840.10008.1.2.4.62'
      '1.2.840.10008.1.2.4.63'
      '1.2.840.10008.1.2.4.64'
      '1.2.840.10008.1.2.4.65'
      '1.2.840.10008.1.2.4.66'
      '1.2.840.10008.1.2.4.70'
      '1.2.840.10008.1.2.4.80'
      '1.2.840.10008.1.2.4.81'}

    % Let IMWRITE handle all of the transformations.
    pixelCells = X;
    
otherwise

    % Handle the special syntaxes where endianness changes for pixels.
    X = changePixelEndian(X, txfr);
    
    pixelCells = dicom_encode_pixel_cells(X, map);
    
end


%
% Encode pixels.
%
uid_details = dicom_uid_decode(txfr);
if (uid_details.Compressed)
    
    % Compress the pixel cells and add delimiters.
    pixelData = dicom_compress_pixel_cells(pixelCells, txfr, ...
                                    metadata.(dicom_name_lookup('0028','0100')), ...
                                    size(X));
    pixelData = dicom_encode_attrs(pixelData, txfr);
    pixelData = pixelData{1};  % Encoding produces a cell array.
    
else
    
    pixelData = pixelCells;
    
end



function out = changePixelEndian(in, txfr)
%CHANGEPIXELENDIAN   Swap pixel bytes for special transfer syntaxes

uid_details = dicom_uid_decode(txfr);

% Only swap if endianness changes.
if (~isequal(uid_details.Endian, uid_details.PixelEndian))
    
    in_class = class(in);
    
    out = cast(in(:), 'uint8', true);
    out = cast(out, in_class);
    
    out = reshape(out, size(in));
    
else
    
    out = in;
    
end
