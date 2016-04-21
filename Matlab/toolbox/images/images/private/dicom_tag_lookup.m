function tag = dicom_tag_lookup(attr_name)
%DICOM_TAG_LOOKUP  Look up the data dictionary tag from a attribute name.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/01 16:12:05 $

persistent all_names all_tags prev_dictionary;
mlock

if ((isempty(all_names)) || (~isequal(prev_dictionary, dicomdict('get'))))

    [all_names, all_tags] = get_dictionary_info;
    prev_dictionary = dicomdict('get');
    
end

% Look for the name among the attributes.
idx = find(strcmp(attr_name, all_names));

if (isempty(idx))
    
    if (~isempty(strfind(lower(attr_name), 'private_')))
        
        % It's private.  Parse out the group and element values.
        tag = parse_private_name(attr_name);

    else
        
        % It's not a DICOM attribute.
        tag = [];
        
    end
    
else
    
    if (numel(idx) > 1)
        
        msg = 'Attribute "%s" is multiply defined.';
        dicom_warn(sprintf(msg, attr_name));
        
        idx = idx(1);
        
    end
    
    % Look for the index in the sparse array.
    % (row, column) values are (group + 1, element + 1)
    [group, element] = find(all_tags == idx);
    tag = [group element] - 1;

end



function [all_names, all_tags] = get_dictionary_info
%GET_DICTIONARY_INFO  Get necessary details from the data dictionary

dictionary = dicomdict('get_current');

if (findstr('.mat', dictionary))
    
    dict = load(dictionary);
    
    all_names = {dict.values(:).Name};
    all_tags = dict.tags;
    
else
    
    [all_tags, values] = dicom_load_dictionary(dicomdict('get_current'));
    
    all_names = {values(:).Name};
    
end



function tag = parse_private_name(attr_name)
%PARSE_PRIVATE_NAME  Get the group and element from a private attribute.

attr_name = lower(attr_name);
idx = find(attr_name == '_');

if (~isempty(strfind(attr_name, 'creator')))
    
    % (gggg,0010-00ff) are Private Creator Data attributes:
    % "Private_gggg_eexx_Creator"  -->  (gggg,00ee).
    
    if (isempty(idx))
        tag = [];
        return;
    end
    
    group = sscanf(attr_name((idx(1) + 1):(idx(1) + 4)), '%x');
    element = sscanf(attr_name((idx(2) + 1):(idx(2) + 4)), '%x');
    
    tag = [group element];
    
elseif (~isempty(strfind(attr_name, 'GroupLength')))

    % Skip Private Group Length attributes.
    group = sscanf(attr_name(9:12), '%x');
    tag = [group 0];
    
else
    
    % Normal private data attributes: "Private_gggg_eeee".
    group = sscanf(attr_name((idx(1) + 1):(idx(1) + 4)), '%x');
    element = sscanf(attr_name((idx(2) + 1):(idx(2) + 4)), '%x');
    
    tag = [group element];
    
end
