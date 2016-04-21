function [frames, overlays, file] = dicom_read_encapsulated(file, info, flist)
%DICOM_READ_ENCAPSULATED  Read pixel data and overlays from compressed file.
%   [FRAMES, OL, FILE] = DICOM_READ_ENCAPSULATED(FILE, INFO, FLIST)
%   reads and decompresses the pixel FRAMES and overlays (OL) from FILE
%   using the metadata in INFO.  For multi-frame images, only the frames
%   listed in FLIST are returned.  FILE is returned in case warning
%   information has changed.
%
%   See also DICOM_SUPPORTED_TXFR_SYNTAX, DICOM_UID_DECODE,
%   DICOM_READ_NATIVE, DICOM_ENCODE_RLE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.6 $  $Date: 2003/12/13 02:48:37 $


%
% Move to beginning of offset table.
%

[attr, file] = dicom_read_attr_metadata(file, info);

%
% Read offset table.
%

frame_offsets = [read_offset_table(file); -inf];
offset_base = ftell(file.FID);

%
% Read frames.
%

use_imread = find_decomp_method(info);
overlay_bits = dicom_has_overlay_bits(info);
frames = [];

for p = flist
    
    %
    % Move to the first fragment of frame.
    %
    
    if (isequal(file.Location, 'Local'))
            
        pos = offset_base + frame_offsets(p);
        fseek(file.FID, pos, 'bof');
        
    end

    % Create empty buffer for decompressed pixel cells.
    pixel_cells = [];

    
    %
    % Read all of the fragments which compose a frame.
    %
    
    more_fragments = 1;
    comp_fragments = {};
    fragment_count = 1;

    while (more_fragments) 
        
        %
        % Read Item attribute.
        %
        
        [attr, file] = dicom_read_attr_metadata(file, info);

        %
        % Read frament data.
        %
        
        % Encapsulated data is always OB and doesn't need swapping.
        comp_fragments{fragment_count} = fread(file.FID, attr.Length, ...
                                              'uint8=>uint8');

        fragment_count = fragment_count + 1;
        
        %
        % Determine if there are more fragments.
        %
        
        more_fragments = frame_has_more_fragments(file, ...
                                                  offset_base, ...
                                                  frame_offsets(p + 1));
                
    end  % while (more_fragments)
    
    %
    % Process the fragment.
    %
    
    try
        
        pixel_cells = decompress_frame(comp_fragments, info);
        
    catch
        
        file = dicom_close_msg(file);
        error('Images:dicom_read_encapsulated:decompress', lasterr);
        
    end

    %
    % Process pixel cells.
    %
    
    if ((isempty(overlay_bits)) && (info.HighBit == (info.BitsAllocated - 1)))

        % The pixels span each pixel cell.
        pixels = pixel_cells;
        overlays = logical([]);
        
    else
        
        % Pixels do not span full pixel cell; overlays may be present.
        [pixels, overlays] = dicom_decode_pixel_cells(pixel_cells, ...
                                                      info, overlay_bits);
        
    end

    %
    % Store the pixels.
    %
    
    if (use_imread)
        frames = cat(4, frames, pixels);
    else
        frames = cat(1, frames, pixels);
    end
    
end  % for p = flist

%
% Read sequence delimiter.
%

[attr, file] = dicom_read_attr_metadata(file, info);

if (attr.Length ~= 0)
    
    % This should never happen, but handle it anyway.
    
    if (isequal(file.Location, 'Local'))

        fseek(file.FID, attr.Length, 'cof');
        
    end
    
end



%%%
%%% Function decompress_frame
%%%

function pixel_cells = decompress_frame(comp_fragments, info)
%DECOMPRESS_FRAME  Decompress a compressed fragment

switch (info.TransferSyntaxUID)
case {'1.2.840.10008.1.2.5'}
    
    % RLE.
    pixel_cells = decompress_rle(comp_fragments, info);
    
    
case {'1.2.840.10008.1.2.4.50'
      '1.2.840.10008.1.2.4.51'
      '1.2.840.10008.1.2.4.53'
      '1.2.840.10008.1.2.4.55'
      '1.2.840.10008.1.2.4.59'
      '1.2.840.10008.1.2.4.61'
      '1.2.840.10008.1.2.4.63'
      '1.2.840.10008.1.2.4.57'
      '1.2.840.10008.1.2.4.65'
      '1.2.840.10008.1.2.4.70'}

    if (~supported_jpeg_depth(info))
        error('Images:dicom_read_encapsulated:jpegDepth', 'Unsupported JPEG bit depth %d.', info.BitsStored);
    end
    
    comp_data = cat(2, comp_fragments{:});
    pixel_cells = dicom_decode_jpg8(comp_data);
    pixel_cells = cast_jpeg_data(pixel_cells, info.PixelRepresentation);
    
end



%%%
%%% Function read_offset_table
%%%

function offsets = read_offset_table(file)
%READ_OFFSET_TABLE  Read a Basic Offset Table item

% See PS 3.5-2000 Sec. A.4 and PS 3.5-2000 Tables A.4-1 and A.4-2.

% Assume that the file pointer is at the beginning of the item tag.
group = fread(file.FID, 1, 'uint16', file.Current_Endian);
element = fread(file.FID, 1, 'uint16', file.Current_Endian);

if ((group ~= 65534) || (element ~= 57344))  % (FFFE,E000)
    
    file = dicom_close_msg(file);
    
    msg = sprintf('File "%s" is missing Basic Offset Table.', ...
                  file.Messages{file.Current_Message});
    
    error('Images:dicom_read_encapsulated:missinOffsetTable', msg);
    
end

data_length = fread(file.FID, 1, 'uint32', file.Current_Endian);

% Basic Offset Table with NO Item Value.
if (data_length == 0)
    
    offsets = 0;
    return
    
end

% Basic Offset Table with Item Value.
offsets = fread(file.FID, data_length/4, 'uint32', file.Current_Endian);



%%%
%%% Function find_decomp_method
%%%

function use_imread = find_decomp_method(info)
%FIND_DECOMP_METHOD  Wait until all fragments are read to decompress?

switch (info.TransferSyntaxUID)
case {'1.2.840.10008.1.2.5'}

    % RLE.
    % Decompress each fragment as it's read.
    use_imread = 0;

case {'1.2.840.10008.1.2.4.50'
      '1.2.840.10008.1.2.4.51'
      '1.2.840.10008.1.2.4.52'
      '1.2.840.10008.1.2.4.53'
      '1.2.840.10008.1.2.4.54'
      '1.2.840.10008.1.2.4.55'
      '1.2.840.10008.1.2.4.56'
      '1.2.840.10008.1.2.4.57'
      '1.2.840.10008.1.2.4.59'
      '1.2.840.10008.1.2.4.60'
      '1.2.840.10008.1.2.4.61'
      '1.2.840.10008.1.2.4.62'
      '1.2.840.10008.1.2.4.63'
      '1.2.840.10008.1.2.4.64'
      '1.2.840.10008.1.2.4.70'}
    
    % JPEG lossy.
    % Read all fragments of a frame before decompressing.
    use_imread = 1;
    
end



function tf = frame_has_more_fragments(file, offset_base, relative_offset)
%FRAME_HAS_MORE_FRAGMENTS   Determine if this frame has more fragments.

[group, element] = dicom_get_next_tag(file);

if (element == 57565)  % 0xE0DD
    
    % Next attribute is a Sequence Delimiter Item (FFFE,E0DD).
    tf = 0;
    
elseif (isinf(relative_offset))
    
    % Current item is a fragment in the last frame of a
    % multi-frame image.  Keep reading until Sequence
    % Delimiter Item.
    tf = 1;
    
else
    
    % Current item is not a fragment in the last frame.
    % Check to see if the file pointer is at the beginning of
    % the next frame.
    
    if (isequal(file.Location, 'Local'))
        
        next_offset = offset_base + relative_offset;
        
        if (ftell(file.FID) >= next_offset)
            
            tf = 0;
            
        else
            
            tf = 1;
            
        end

    else
        
        dicom_close_msg(file);
        error('Images:dicom_read_encapsulated:localOnly', 'Network messages are not supported.')
        
    end
    
end



function pixel_cells = decompress_rle(comp_fragments, info)

total_fragments = numel(comp_fragments);
output_bytes = info.Rows * info.Columns;

% Determine if endianness of data needs swapped.
[fn, perms, mach] = fopen(1);

if (isempty(strfind(lower(mach), 'ieee-le')))
    swap = 1;
else
    swap = 0;
end

offset_tables = cell(1, total_fragments);
segments = cell(1, total_fragments);
num_segments = cell(1, total_fragments);

for p = 1:total_fragments
    
    % Separate offset table from segments in each fragment.
    offset_tables{p} = comp_fragments{p}(1:64);
    segments{p} = comp_fragments{p}(65:end);
    
    % Reconstitute offset tables.
    %
    % CAST currently only swaps if the output is UINT8/INT8.  Swap the bytes
    % before calling CAST.
    if (swap)
        tmp = offset_tables{p};
        tmp = reshape(tmp, [4, 16]);
        tmp = reshape(flipud(tmp), size(offset_tables{p}));
        offset_tables{p} = tmp;
    end
    
    offset_tables{p} = double(cast(offset_tables{p}, 'uint32'));
    
    % Separate number of segments from offset table.
    num_segments{p} = offset_tables{p}(1);
    offset_tables{p}(1) = [];
    
    % Make offsets relative to beginning of data segments.
    offset_tables{p} = offset_tables{p} - 64;

end

if ((total_fragments > 1) && (~isequal(num_segments{:})))
    error('Images:dicom_read_encapsulated:rleSegmentCount', 'RLE fragments have an inconsistent number of segments.')
end

% Create an output array for the decompressed data.
decomp_frame = repmat(uint8(0), [num_segments{1}, (output_bytes)]);

% Decompress the segments.
for p = 1:num_segments{1}

    % Reconstruct full segments.
    full_segment = [];
    
    for q = 1:total_fragments

        % Offsets in the header are 0-based.
        pos_begin = offset_tables{q}(p) + 1;

        if (p == num_segments{1})
            pos_end = numel(segments{q});
        else
            pos_end = offset_tables{q}(p + 1);
        end
        
        full_segment = [full_segment; segments{q}(pos_begin:pos_end)];
        
    end
    
    % Decode the data.
    decomp_frame(p,:) = dicom_decode_rle_segment(full_segment, ...
                                                 output_bytes);
    
end

% Convert the "composite pixel codes" into a set of pixel cells.
if (info.BitsAllocated == 8)
    
    % Special case where each byte in the composite pixel codes is a
    % sample in the pixel.  Simply reshape the decompressed bytes to
    % create the pixel cell.
    
    pixel_cells = decomp_frame(:);

else

    % Store pixel cells in the smallest MATLAB datatype that can hold
    % info.BitsAllocated bits.  Remove possible padding between bytes.

    pixel_cells = pixel_codes_to_pixel_cells(decomp_frame, info);

    if (swap)
        
        pixcell_type = class(pixel_cells);
        pixel_cells = cast(pixel_cells, 'uint8', 1);
        pixel_cells = cast(pixel_cells, pixcell_type);
        
    end
    
end



function pixel_cells = pixel_codes_to_pixel_cells(decomp_frame, info)
%PIXEL_CODES_TO_PIXEL_CELLS   Convert Composite Pixel Codes to Pixel Cells.

% A Composite Pixel Code is a concatenation of bytes composing the
% various pixel cells for each sample in a pixel.  For example, and RGB
% image with 12-bits per sample would have a 40-bit Composite Pixel Code
% (for one pixel) comprised of the 12-bits for the red sample followed by
% the 12-bits for the green, the 12-bits for the blue and 4-bits of
% padding.  The padding is included so that the Pixel Code ends on a byte
% boundary and can be encoded by the RLE encoder.
%
% The Composite Pixel Code for this function should be an n-by-m array of
% UINT8 values, where n is the number of bytes in the Pixel Code (5 in
% the example above), and m is the product of the number of rows and
% columns.
%
% The output Pixel Cells are comprised of the samples for one pixel
% together (e.g., RGBRGBRGB...) and are expanded to fit in a MATLAB data
% type.  In the example above each 12-bit sample is expanded to fit in
% either a UINT16 or INT16.  The 4 bits of padding is discarded.  This
% type of output is consistent with DICOM_READ_NATIVE.

nSamples = info.SamplesPerPixel;
pixcell_type = get_pixcell_type(info.BitsAllocated);
pixel_cells = create_empty_pixel_cells(info, pixcell_type);

% Reconstitute samples from the composite pixel code
for p = 1:(nSamples)
    
    %
    % Find sample boundaries.
    %
    bit_start = (p - 1) * info.BitsAllocated + 1;
    bit_end = p * info.BitsAllocated;

    byte_start = ceil(bit_start/8);
    byte_end = ceil(bit_end/8);

    % Keep track of the bit value of the beginning of the sample
    % container. This value will be required when the sample is shifted
    % to the beginning of the container.
    bit_offset = (byte_start - 1) * 8;
    
    % Keep track of the number of bytes spanned by the sample; this is
    % necessary for picking the container to use for the sample.
    bytes_in_sample = byte_end - byte_start + 1;
    
    
    %
    % Collect the btyes for this sample
    %
    
    % If the last sample spans multiple bytes, new padding may be
    % required. Add it to the bottom, so that it appears on the right end
    % of the container after reshaping.
    sample = decomp_frame(byte_start:byte_end, :);
    [container_type, container_bytes] = get_pixcell_type(bytes_in_sample * 8);
    
    if (p == nSamples)
        sample = [sample; repmat(uint8(0), ...
                                 [(container_bytes - bytes_in_sample), ...
                                  size(decomp_frame, 2)])];
    end

    % Cast into an appropriately sized container.
    %
    % The bytes in question may include parts of other samples and padding.
    sample = reshape(sample, [1, numel(sample)]);
    sample = cast(sample, container_type);
    
    
    %
    % Extract the sample from the container.
    %
    
    % Shift left to beginning of container.
    shift_amount = (bit_start - bit_offset) - 1;
    sample = bitshift(sample, -(shift_amount));
    
    % Mask out the right-hand bits.
    mask_start = bit_end - bit_offset - shift_amount + 1;
    mask_end = container_bytes * 8;
    for q = mask_start:mask_end
        sample = bitset(sample, q, 0);
    end
    
    % Assign to output pixel cell.  The type is inherited from pixel_cells.
    pixel_cells(p, :) = sample;
end

% Convert to a signed type if necessary.
if (info.PixelRepresentation == 1)
    
    switch (class(pixel_cells))
    case 'uint8'
        pixel_cells = cast(pixel_cells, 'int8');
    case 'uint16'
        pixel_cells = cast(pixel_cells, 'int16');
    case 'uint32'
        pixel_cells = cast(pixel_cells, 'int32');
    case 'uint64'
        pixel_cells = cast(pixel_cells, 'int64');
    end
    
end

% Convert to an interleaved RGBRGBRGB format.
pixel_cells = pixel_cells(:);



function out = cast_jpeg_data(in, pixelrep)
%CAST_JPEG_DATA convert unsigned data to signed data as appropriate.

if (pixelrep)

    % Cast UINT8/16 to INT8/16.
    switch (class(in))
    case 'uint8'
        
        out = cast(in(:), 'int8');
        out = reshape(out, size(in));
        
    case 'uint16'
    
        out = cast(in(:), 'int16');
        out = reshape(out, size(in));
        
    end
  
else
  
    out = in;
    
end



function tf = supported_jpeg_depth(info)
%SUPPORTED_JPEG_DEPTH  Find if the current JPEG bit-depth is supported.

depth = info.BitsStored;

if (depth <= 16)
    tf = true;
else
    tf = false;
end



function [datatype, bytes] = get_pixcell_type(bits)
%GET_PIXCELL_TYPE  Get the smallest MATLAB datatype to contain these bits.

if (bits <= 8)
    datatype = 'uint8';
    bytes = 1;
elseif (bits <= 16)
    datatype = 'uint16';
    bytes = 2;
elseif (bits <= 32)
    datatype = 'uint32';
    bytes = 4;
    
% 64-Bit types aren't compilable yet.

%elseif (bits <= 64)
%    datatype = 'uint64';
%    bytes = 8;
else
    error('Images:dicom_read_encapsulated:bitDepth', 'Unsupported bit depth %d.', bits)
end



function pixel_cells = create_empty_pixel_cells(info, datatype)
%CREATE_EMPTY_PIXEL_CELLS  Make empty buffer for pixel cells.

switch (datatype)
case 'uint8'
    base = uint8(0);
case 'uint16'
    base = uint16(0);
case 'uint32'
    base = uint32(0);
    
% 64-Bit types aren't compilable yet.

%case 'uint64'
%    base = uint64(0);
otherwise
    error('Images:dicom_read_encapsulated:pixcellType', 'Unsupported pixel cell type (%s).', datatype)
end

pixel_cells = repmat(base, [info.SamplesPerPixel, ...
                            (info.Rows * info.Columns)]);
