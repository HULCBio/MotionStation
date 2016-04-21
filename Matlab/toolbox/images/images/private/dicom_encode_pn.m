function PN_chars = dicom_encode_PN(PN_struct)
%DICOM_ENCODE_PN  Turn a structure of name info into a formatted string.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/01 16:12:03 $


PN_chars = '';

if (isempty(PN_struct))
    return
end

for p = 1:numel(PN_struct)

    % Add each of the components to the output string.
    if (isfield(PN_struct, 'FamilyName'))
        PN_chars = [PN_chars PN_struct.FamilyName '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'GivenName'))
        PN_chars = [PN_chars PN_struct.GivenName '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'MiddleName'))
        PN_chars = [PN_chars PN_struct.MiddleName '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'NamePrefix'))
        PN_chars = [PN_chars PN_struct.NamePrefix '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    if (isfield(PN_struct, 'NameSuffix'))
        PN_chars = [PN_chars PN_struct.NameSuffix '^'];
    else
        PN_chars = [PN_chars '^'];
    end
    
    % Remove extraneous '^' separators.
    while ((~isempty(PN_chars)) && (PN_chars(end) == '^'))
        PN_chars(end) = '';
    end
    
    % Separate multiple values.
    PN_chars = [PN_chars '\'];
    
end

% Remove extra value delimiter '\'.
PN_chars(end) = '';
