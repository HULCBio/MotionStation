function [info, file] = dicom_read_fmeta(file, info)
%DICOM_READ_FMETA  Read file metadata from a file.
%   META = DICOM_READ_FMETA(FILE, INFO) reads the file metadata META from
%   FILE.  The previously read metadata INFO is passed in as context for
%   reading the metadata.
%
%   Note: File metadata is metadata with a group value of 2 - 7.  This
%   will only be present for compliant DICOM files and network messages.
%
%   Group 2 metadata is described in PS 3.10.  Other file metadata is
%   described in PS 3.3.
%
%   See also DICOM_READ_MMETA, DICOM_READ_ATTR.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2003/08/23 05:53:55 $

% Assumes that file.FID is valid.
% Assumes that file has file metadata.

%
% Move to beginning of file metadata.
%

fseek(file.FID, 132, 'bof');

%
% Set up for reading.
%

file.Current_Endian = 'ieee-le';
file.Current_VR = 'Explicit';

% Some GE devices incorrectly use Implicit VR instead of Explicit VR.
% This is bad, but we can test the VR of the first attribute against
% acceptable values and switch, if necessary.
if (has_wrong_vr_type(file))
    file.Current_VR = 'Implicit';
end

%
% Read file metadata.
%

group = dicom_get_next_tag(file);

while ((group >= 0) && (group < 8))
    
    % Read the attributes.
    [attr, data, file] = dicom_read_attr(file, info);

    if ((attr.Group == 2) && ...
        (~isempty(findstr(attr.Name, 'Private'))))
        
        % PS 3.10-1999 Sec. 7.1 specifies that unknown Group 2 elements
        % must be safely ignored.  We will exclude them so that we won't
        % accidentally write them out.
       
    elseif (rem(attr.Group, 2) == 1)
        
        % PS 3.10-1999 Sec. 7.1 specifies that Groups 1, 3, 5, and 7
        % should not be present in file metadata.
        
        msg = sprintf('Invalid metadata group %04x found in "%s".', ...
                      attr.Group, file.Messages{file.Current_Message});
        
        file = dicom_warn(msg, file);

        % Place the attributes in the info structure.
        info.(attr.Name) = data;
    
    else
        
        % Place the attributes in the info structure.
        info.(attr.Name) = data;
        
    end
    
    group = dicom_get_next_tag(file);
    
end



function tf = has_wrong_vr_type(file)
%HAS_WRONG_VR_TYPE  See if file metadata incorrectly uses implicit VR.

fseek(file.FID, 4, 'cof');
vr = char(fread(file.FID, 2, 'uchar')');
accept = {'AE' 'AS' 'AT' 'CS' 'DA' 'DS' 'DT' 'FL' 'FD' 'IS' 'LO' 'LT' ...
          'OB' 'OW' 'PN' 'SH' 'SL' 'SQ' 'SS' 'ST' 'TM' 'UI' 'UL' 'UN' ...
          'US' 'UT'};

switch (vr)
case accept
    tf = 0;
otherwise
    tf = 1;
end

fseek(file.FID, -6, 'cof');
