function guid_string = dicom_create_guid
%DICOM_CREATE_GUID   Create a Globally Unique ID on Windows.
%   GUID = DICOM_CREATE_GUID creates a 40 character representation of a
%   Microsoft Windows globally unique identifier (GUID).
%
%   See also MWGUIDGEN, DICOM_GENERATE_UID.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:29 $

if (~ispc)
    eid = sprintf('Images:%s:guidGenerationOnlyWindows',mfilename);
    error(eid,'%s','GUID generation is only supported with Windows.')
end

% Generate a GUID as a series of 16 UINT8 values.
guid_bytes = mwguidgen;

% Convert the bytes to a decimal string.
guid_longs = cast(guid_bytes, 'uint32');

guid_string = '';
for p = 1:length(guid_longs)
    
    guid_string = [guid_string sprintf('%010.0f', double(guid_longs(p)))];
    
end
