function data_streams = dicom_encode_attrs(attrs, txfr_syntax)
%DICOM_ENCODE_ATTRS   Encode a collection of attributes to a data stream.
%   STREAMS = DICOM_ENCODE_ATTRS(ATTRS, TXFR) encode the attributes in
%   the structure ATTRS according to the transfer syntax TXFR.  The
%   result is a cell array containing vectors of UINT8 values, which
%   represent the values to be written to the output device.  Each cell
%   contains the encoded data stream for all of the attributes which
%   share a common group number.
%
%   Note: It is assumed that the attribute's data is already in the
%   corresponding data type for the VR (e.g., if the VR is UL, the data
%   is already UINT32). 
%
%   See also DICOM_ADD_ATTR, DICOM_ENCODE_PIXEL_CELLS.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.8 $  $Date: 2004/04/01 16:12:02 $


%
% Determine whether data will need to be byte swapped.
%

[swap_file, swap_meta, swap_pixel] = determine_swap(txfr_syntax);
PIXEL_GROUP   = sscanf('7fe0', '%x');
PIXEL_ELEMENT = sscanf('0010', '%x');

%
% Process the attributes.
%

uid_details = dicom_uid_decode(txfr_syntax);

total_attrs = length(attrs);
current_attr = 1;
current_stream = 1;

data_streams = {};

while (current_attr <= total_attrs)
    
    current_group  = attrs(current_attr).Group;
    stream = uint8([]);
    
    % Process each attribute of the group.
    while (attrs(current_attr).Group == current_group)
        
        % Get the current attribute.
        attr = attrs(current_attr);

        % Create the UINT8 output stream.
        if (attr.Element == 0)
            
            % Skip group lengths.
            encoded_attr = uint8([]);
            
        elseif (current_group < 8)

            encoded_attr = create_encoded_attr(attr, uid_details, swap_file);
        
        elseif ((attr.Group == PIXEL_GROUP) && ...
                (attr.Element == PIXEL_ELEMENT))

            encoded_attr = create_encoded_attr(attr, uid_details, swap_pixel);
            
            % GE format has different endianness within the PixelData
            % attribute.  Fix it.
            if (isequal(txfr_syntax, '1.2.840.113619.5.2'))
                encoded_attr = fix_pixel_attr(encoded_attr);
            end
        
        else

            encoded_attr = create_encoded_attr(attr, uid_details, swap_meta);
        
        end
        
        % Add to the output stream.
        stream = [stream encoded_attr];
        current_attr = current_attr + 1;

        % Don't index past the end of the attrs array.
        if (current_attr > total_attrs)
            break
        end
        
    end
    
    % Prepend group length attribute.
    if (current_group < 8)
        
        len_attr.Group   = current_group;
        len_attr.Element = 0;
        len_attr.VR      = 'UL';
        len_attr.Data    = uint32(length(stream));
        
        encoded_attr = create_encoded_attr(len_attr, uid_details, swap_file);

        stream = [encoded_attr stream];
        
    end
    
    % Store the stream.
    data_streams{current_stream} = stream;
    
    current_stream = current_stream + 1;
    
end



function segment = create_encoded_attr(attr, uid_details, swap)

% If it's a sequence, recursively enocde the items and attributes.
if (isstruct(attr.Data))
    
    fnames = fieldnames(attr.Data);
    
    if ((isequal(attr.VR, 'PN')) || ...
        (~isempty(strfind(lower(fnames{1}), 'name'))))
        
        attr.Data = dicom_encode_pn(attr.Data);
        
    else
        
        attr.Data = encode_structure(attr.Data, uid_details, swap);
        
    end
end

% Determine size of data.
switch (class(attr.Data))
case {'uint8', 'int8', 'char'}
    data_size = 1;
    
case {'uint16', 'int16'}
    data_size = 2;
    
case {'uint32', 'int32', 'single'}
    data_size = 4;
    
case {'double'}
    data_size = 8;
    
end

% Group and Element
segment = cast(uint16(attr.Group), 'uint8', swap);
segment = [segment cast(uint16(attr.Element), 'uint8', swap)];

% VR and Length
if ((isequal(uid_details.VR, 'Implicit')) && (attr.Group >= 8))

    % VR does not appear in the file.
    
    len = uint32(data_size * length(attr.Data));

else

    % VR.
    segment = [segment uint8(attr.VR)];
    
    % Determine length.
    switch (attr.VR)
    case {'OB', 'OW', 'SQ'}
        
        segment = [segment uint8([0 0])];  % Padding.
        
        len = uint32(data_size * length(attr.Data));
            
    case {'UN'}
        
        if (attr.Group == 65534)  % 0xfffe
            
            % Items/delimiters don't have VR or two-byte padding.
            segment((end - 1):end) = [];
            
        else
            
            segment = [segment uint8([0 0])];  % Padding.
            
        end
        
        len = uint32(data_size * length(attr.Data));
            
    case {'UT'}
        
        % Syntactically this is read the same as OB/OW/etc., but it
        % cannot have undefined length.
        
        segment = [segment uint8([0 0])];  % Padding.
        
        len = uint32(data_size * length(attr.Data));
            
    case {'AE','AS','AT','CS','DA','DS','DT','FD','FL','IS', ...
          'LO','LT', 'PN','SH','SL','SS','ST','TM','UI','UL','US'} 
        
        len = uint16(data_size * length(attr.Data));
        
    otherwise
        
        % PS 3.5-1999 Sec. 6.2 indicates that all unknown VRs can be
        % interpretted as being the same as OB, OW, SQ, or UN.  The
        % size of data is not known but, the reading structure is.  
        
        segment = [segment uint8([0 0])];  % Padding.
        
        len = uint32(data_size * length(attr.Data));
        
    end

    % Special case for length of encapsulated (7FE0,0010).
    if (((attr.Group == 32736) && (attr.Element == 16)) && ...
        (uid_details.Compressed == 1))
        
        % Undefined length.
        len = uint32(inf);
        
    end
    
end
    
segment = [segment cast(len, 'uint8', swap)];

if (ischar(attr.Data))
    segment = [segment uint8(attr.Data(:)')];
else
    tmp = cast(attr.Data, 'uint8', swap);
    segment = [segment tmp(:)'];
end



function [tf_file, tf_meta, tf_pixel] = determine_swap(txfr_syntax)

uid_details = dicom_uid_decode(txfr_syntax);

[a, b, endian] = computer;

switch (endian)
case 'B'
    
    if (isequal(txfr_syntax, '1.2.840.113619.5.2'))
        tf_file  = 1;
        tf_meta  = 1;
        tf_pixel = 0;
    elseif (isequal(uid_details.Endian, 'ieee-be'))
        tf_file  = 1;
        tf_meta  = 0;
        tf_pixel = 0;
    else
        tf_file  = 1;
        tf_meta  = 1;
        tf_pixel = 1;
    end

case 'L'
    
    if (isequal(txfr_syntax, '1.2.840.113619.5.2'))
        tf_file  = 0;
        tf_meta  = 0;
        tf_pixel = 1;
    elseif (isequal(uid_details.Endian, 'ieee-le'))
        tf_file  = 0;
        tf_meta  = 0;
        tf_pixel = 0;
    else
        tf_file  = 0;
        tf_meta  = 1;
        tf_pixel = 1;
    end
    
end



function data = fix_pixel_attr(data)

% GE's special transfer syntax has different endianness within the
% attribute.  Swap the bytes for the tag and length.  Leave the rest
% alone.
%
% Swapping always needs to be done regardless of the endianness of the
% processor.  It undoes a prior, unwanted swap of the tag and length.

tag = data(1:4);
tag = cast(cast(tag, 'uint16'), 'uint8', 1);

len = data(5:8);
len = cast(cast(len, 'uint32'), 'uint8', 1);

data(1:4) = tag;
data(5:8) = len;



function encoded_data = encode_structure(struct_data, uid_details, swap)
%ENCODE_STRUCTURE  Turn a structure of data into a byte stream.

% If it's a sequence, the structure will contain fields named 'Item_n'.
% To encode the sequence:
%   (1) Add an item tag.
%   (2) Encode the attributes within the item.

encoded_data = uint8([]);

for p = 1:numel(struct_data)

    tmp = dicom_encode_attrs(struct_data(p), uid_details.Value);
    encoded_data = [encoded_data ...
                    tmp{1}];

end
