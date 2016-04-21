function attr = dicom_convert_meta_to_attr(attr_name, metadata)
%DICOM_CONVERT_META_TO_ATTR  Convert a metadata field to an attr struct.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/01 16:11:59 $

% Look up the attribute tag.
tag = dicom_tag_lookup(attr_name);

if (isempty(tag))

    attr = [];
    return

end

% Get the VR.
VR = determine_VR(tag, metadata);

% Process struct data - Person Names (PN) and sequences (SQ).
if (isequal(VR, 'PN'))
    
    data = dicom_encode_pn(metadata.(attr_name));

elseif (isequal(VR, 'SQ'))
    
    data = encode_SQ(metadata.(attr_name));
    
else
    
    data = metadata.(attr_name);
    
end
    

% Add the attribute.
if (isempty(VR))
    attr = dicom_add_attr([], tag(1), tag(2), data);
else
    attr = dicom_add_attr([], tag(1), tag(2), data, VR);
end



function VR = determine_VR(tag, metadata)
%DETERMINE_VR  Find an attribute's value representation (VR).

attr_details = dicom_dict_lookup(tag(1), tag(2));

if (isempty(attr_details))

    VR = [];
    
else
    
    VR = attr_details.VR;
    
    if (iscell(VR))
        VR = VR{1};
    end
    
end



function attrs = encode_SQ(SQ_struct)
%ENCODE_SQ  Turn a structure of sequence data into attributes.

attrs = [];

if (isempty(SQ_struct))
    return
end

% Don't worry about encoding rules yet.  Just convert the MATLAB struct
% containing item and data fields into an array of attribute structs.

items = fieldnames(SQ_struct);
for p = 1:numel(items)
    
    data = encode_item(SQ_struct.(items{p}));
    attrs = dicom_add_attr(attrs, 'fffe', 'e000', data);
    
end



function attrs = encode_item(item_struct)
%ENCODE_ITEM  Turn one item of a sequence into attributes.

attrs = [];

attr_names = fieldnames(item_struct);
for p = 1:numel(attr_names)
    
    new_attr = dicom_convert_meta_to_attr(attr_names{p}, item_struct);
    attrs = cat(2, attrs, new_attr);
    
end
