function attr = dicom_dict_lookup(group, element)
%DICOM_DICT_LOOKUP  Lookup an attribute in the data dictionary.
%   ATTRIBUTE = DICOM_DICT_LOOKUP(GROUP, ELEMENT, DICTIONARY) searches for
%   the attribute (GROUP,ELEMENT) in the data dictionary, DICTIONARY.  A
%   structure containing the attribute's properties from the dictionary
%   is returned.  ATTRIBUTE is empty if (GROUP,ELEMENT) is not in
%   DICTIONARY.
%
%   Note: GROUP and ELEMENT can be either decimal values or hexadecimal
%   strings.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/08/01 18:10:35 $


% IMPORTANT NOTE:
%
% This function must be wrapped inside of a try-catch-end block in order
% to prevent the DICOM file from being left open after an error.


MAX_GROUP = 65535;   % 0xFFFF
MAX_ELEMENT = 65535;  % 0xFFFF

%
% Load the data dictionary.
%

persistent tags values prev_dictionary;
mlock;

dictionary = dicomdict('get_current');

% Load dictionary for the first time or if dictionary has changed.
if ((isempty(values)) || (~isequal(prev_dictionary, dictionary)))
    
    [tags, values] = dicom_load_dictionary(dictionary);
    prev_dictionary = dictionary;
    
end

%
% Convert hex strings to decimals.
%

if (ischar(group))
    group = sscanf(group, '%x');
end

if (ischar(element))
    element = sscanf(element, '%x');
end

if (group > MAX_GROUP)
    eid = sprintf('Images:%s:groupOutOfRange',mfilename);
    msg = sprintf('Group %x in (%x,%04x) is out of range.', group, ...
                  group, element);
    error(eid,'%s',msg);
end


if (element > MAX_ELEMENT)
    eid = sprintf('Images:%s:elementOutOfRange',mfilename);
    msg = sprintf('Element %x in (%04x,%x) is out of range.', element, ...
                  group, element);
    error(eid,'%s',msg);
end

%
% Look up the attribute.
%

% Group and Element values in the published data dictionary are 0-based.
index = tags((group + 1), (element + 1));

if (index == 0)
    attr = struct([]);
else
    attr = values(index);
end
