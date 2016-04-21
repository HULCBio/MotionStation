function tf = dicom_has_fmeta(file)
%DICOM_HAS_FMETA  Determines whether a message contains file metadata.
%   TF = DICOM_HAS_FMETA(FILE) Returns 1 if FILE has file metadata, 0
%   otherwise.  File metadata are attributes whose groups are 2 - 7.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/01/26 05:58:38 $

if (isequal(file.Location, 'Local'))
    
    fseek(file.FID, 128, 'bof');

    if (ftell(file.FID) ~= 128)
        % File is too short to have 128 byte preamble: no file metadata.
        tf = 0;
        fseek(file.FID, 0, 'bof');
        
        return
        
    end
    
    % Look for the format string 'DICM'.
    fmt_string = fread(file.FID, 4, 'uchar');
    
    tf = isequal(fmt_string, [68 73 67 77]');

    fseek(file.FID, 0, 'bof');
    
    return
    
else
    
    % Network messages do not have file metadata.
    tf = 0;
    
end
