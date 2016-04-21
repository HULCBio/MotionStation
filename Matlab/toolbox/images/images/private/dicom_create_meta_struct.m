function info = dicom_create_meta_struct(file)
%DICOM_CREATE_META  Create a struct with default values to contain metadata.
%   INFO = DICOM_CREATE_META_STRUCT(FILE) create a structure INFO to
%   contain information about the currently selected DICOM message in
%   FILE.  Most fields have empty values by default, but fields relating
%   to file details will be filled.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:30 $


% This function implements M-INQUIRE FILE.


% Create the metadata structure.
info.Filename = '';
info.FileModDate = '';
info.FileSize = [];
info.Format = 'DICOM';
info.FormatVersion = 3.0;
info.Width = [];
info.Height = [];
info.BitDepth = [];
info.ColorType = '';
info.SelectedFrames = [];
info.FileStruct = file;
info.StartOfPixelData = [];

if (isequal(file.Location, 'Local'))
    
    % Get file attributes.
    d = dir(file.Messages{file.Current_Message});
    
    % Create the metadata structure.
    info.Filename = file.Messages{file.Current_Message};
    info.FileModDate = d.date;
    info.FileSize = d.bytes;

else
    eid = sprintf('Images:%s:networkMessagesNotSupported',mfilename);
    error(eid,'%s','Network messages are not yet supported.')
    
end
