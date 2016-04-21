function [pixels, overlays, file] = dicom_read_native(file, info, flist)
%READ_NATIVE  Read pixel data and overlays from uncompressed file.
%   [FRAMES, OL, FILE] = DICOM_READ_NATIVE(FILE, INFO, FLIST) reads the
%   pixel FRAMES and overlays (OL) from FILE using the metadata in INFO.
%   For multi-frame images, only the frames listed in FLIST are returned.
%   FILE is returned in case warning information has changed.
%
%   All native transfer syntaxes are supported.
%
%   See also DICOM_SUPPORTED_TXFR_SYNTAX, DICOM_UID_DECODE,
%   DICOM_READ_ENCAPSULATED.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2003/08/23 05:53:58 $


%
% Move to beginning of catted pixel cells.
%

[attr, file] = dicom_read_attr_metadata(file, info);

%
% Determine how to read pixel data.
%

[precision, data_size] = find_precision(info, file);

overlay_bits = dicom_has_overlay_bits(info);

num_elts = attr.Length/data_size;

%
% Read the data.
%

if ((isempty(overlay_bits)) && (info.HighBit == (info.BitsAllocated - 1)))
    
    % The pixels span each pixel cell.

    pixels = fread(file.FID, num_elts, precision, file.Pixel_Endian);
    overlays = logical([]);
    
else

    % Pixels do not span full pixel cell; overlays may be present.
    
    pixel_cells = fread(file.FID, num_elts, precision, file.Pixel_Endian);
    
    [pixels, overlays] = dicom_decode_pixel_cells(pixel_cells, ...
                                                  info, overlay_bits);

end



%%%
%%% Function find_precision
%%%

function [precision, data_size] = find_precision(info, file)
%FIND_PRECISION  Determine precision for reading entire pixel cell

% Determine base and target datatypes.
if (info.BitsAllocated == 8)
   
    precision_raw = 'int8';
    precision_target = 'int8';
    data_size = 1;
    
elseif (info.BitsAllocated == 16)
    
    precision_raw = 'int16';
    precision_target = 'int16';
    data_size = 2;
    
elseif (info.BitsAllocated == 32)
    
    precision_raw = 'int32';
    precision_target = 'int32';
    data_size = 4;
    
else
    
    precision_raw = ['bit' num2str(info.BitsAllocated)];
    
    % Pick the next larger size to contain the data.
    if (info.BitsAllocated < 8)
        precision_target = 'int8';
        
    elseif (info.BitsAllocated < 16)
        precision_target = 'int16';
        
    elseif (info.BitsAllocated < 32)
        precision_target = 'int32';
        
    end
    
    data_size = info.BitsAllocated/8;
    
end

% Determine if unsigned or twos-complement.
if (info.PixelRepresentation == 0)
    
    precision = ['u' precision_raw '=>u' precision_target];
    
elseif (info.PixelRepresentation == 1)
    
    precision = [precision_raw '=>' precision_target];
    
else
    
    file = dicom_close_msg(file);
    
    msg = ['File "%s" contains invalid Pixel Representation value %d.', ...
           file.Messages{file.Current_Message}, info.PixelRepresentation];

    error('Images:dicom_read_native:pixelRep', msg);
    
end
