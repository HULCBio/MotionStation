function name = dicom_name_lookup(groupStr, elementStr)
%DICOM_NAME_LOOKUP   Get an attribute's from the DICOM data dictionary.
%   NAME = DICOM_NAME_LOOKUP(GROUP, ELEMENT) returns the NAME of the
%   DICOM attribute with the GROUP and ELEMENT specified as strings.
%
%   The purpose of this function is to avoid hardcoding mutable attribute
%   names into access and modification functions.
%
%   Example:
%      dicom_name_lookup('7fe0','0010') returns 'PixelData' (provided
%      that its name is PixelData in the data dictionary).
%
%   See also DICOM_DICT_LOOKUP, DICOM_GET_DICTIONARY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date $

attr = dicom_dict_lookup(groupStr, elementStr);

if (isempty(attr))
    name = '';
else
    name = attr.Name;
end
