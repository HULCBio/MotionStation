function attrs = dicom_compress_pixel_cells(pixel_cells, txfr, bits_allocated, dims)
%DICOM_COMPRESS_PIXEL_CELLS   Compress pixel cells into fragments.
%   ATTRS = DICOM_COMPRESS_PIXEL_CELLS(CELLS, TXFR, BITS, DIMS) compress
%   the pixel cells CELLS using the transfer syntax TXFR.  BITS is the
%   size of each pixel cell, and DIMS is the MATLAB dimensions of the
%   data contained in the pixel cells.
%
%   The result is a structure of attributes containing the compressed
%   pixel cell fragments and item delimeters.
%
%   See also DICOM_ADD_ITEM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:27 $


% Encapsulated (compressed) pixel cells have the following structure:
%
%   (7FE0,0010) with undefined length  (handled elsewhere)
%   (FFFE,0000) containing off-set table or 0 length data
%   (FFFE,0000) for each fragment  (a collection of UINT8 data)
%   (FFFE,00DD) with 0 length data


% Create an empty container for the "sequence."
attrs = struct([]);

% Compress the pixel_cells.
[fragments, frames] = compress_cells(pixel_cells, txfr, bits_allocated, dims);

% Create the Basic Offset Table.
offsets = build_offset_table(fragments, frames);
attrs = dicom_add_item(attrs, 'FFFE', 'E000', offsets);

% Add the fragments.
for p = 1:length(fragments)
    
    attrs = dicom_add_item(attrs, 'FFFE', 'E000', fragments{p});

end

% Add the sequence delimiter.
attrs = dicom_add_item(attrs, 'FFFE', 'E0DD');



function [fragments, frames] = compress_cells(pixel_cells, txfr, ...
                                              bits_allocated, dims)
%COMPRESS_CELLS   Return a cell array of encoded pixel cell fragments.

switch (txfr)
case '1.2.840.10008.1.2.5'
    
    [fragments, frames] = dicom_encode_rle(pixel_cells, bits_allocated, dims);
    
case '1.2.840.10008.1.2.4.50'
    
    [fragments, frames] = dicom_encode_jpeg_lossy(pixel_cells);
    
case '1.2.840.10008.1.2.4.70'
    
    [fragments, frames] = dicom_encode_jpeg_lossless(pixel_cells, bits_allocated);
    
otherwise
    eid = sprintf('Images:%s:cannotCompress',mfilename);                        
    error(eid,'Cannot compress using transfer syntax "%s".', txfr)
    
end



function offset_table = build_offset_table(fragments, frames)
%BUILD_OFFSET_TABLE   Create a vector of offsets to the start of the frames.

% Don't store an offset table for just one frame.
if (length(frames) == 1)
    offset_table = uint32([]);
    return
end

% Build an offset table, a UINT32 vector with byte offsets to the
% beginning of the next frame.  The offsets are relative to the end of
% the offset table item, which is always followed by the first fragment.
offset_table = repmat(uint32(0), size(frames));

current_offset = 0;
current_frame = 1;

for p = 1:length(fragments)
    
    if (p == frames(current_frame))
        
        % Beginning of frame starts at current position.
        offset_table(current_frame) = current_offset;
        current_frame = current_frame + 1;

        % Offset to next fragment is 8 bytes for tag and length plus size
        % of fragment.
        current_offset = current_offset + 8 + numel(fragments{p});
        
    else
        
        % Not the beginning of a new frame.
        current_offset = current_offset + 8 + numel(fragments{p});

    end
    
end

