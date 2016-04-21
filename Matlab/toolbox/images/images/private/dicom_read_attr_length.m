function attr = dicom_read_attr_length(file, attr)
%DICOM_READ_ATTR_LENGTH  Read the attribute's length.
%   ATTR = DICOM_READ_ATTR_LENGTH(FILE, ATTR) updates the attribute ATTR
%   by reading its length from FILE.
%
%   See also DICOM_REAT_ATTR_METADATA.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/01/26 05:58:55 $


if (isequal(file.Current_VR, 'Explicit'))
    
    % Explicit VR.
    
    switch (attr.VR)
    case {'OB', 'OW', 'SQ'}

        % Skip 2 reserved bytes.
        fread(file.FID, 2, 'uint8');
        
        attr.Length = fread(file.FID, 1, 'uint32', file.Current_Endian);
        
    case 'UN'
        
        if (attr.Group == 65534)  % 0xfffe
            
            % Items/delimiters don't have the two-byte padding.
            
        else
            
            fread(file.FID, 2, 'uint8');
            
        end
        
        attr.Length = fread(file.FID, 1, 'uint32', file.Current_Endian);
        
    case 'UT'
        
        % Syntactically this is read the same as OB/OW/etc., but it
        % cannot have undefined length.
        
        fread(file.FID, 2, 'uint8');
        attr.Length = fread(file.FID, 1, 'uint32', file.Current_Endian);

    case {'AE','AS','AT','CS','DA','DS','DT','FD','FL','IS','LO','LT', ...
          'PN','SH','SL','SS','ST','TM','UI','UL','US'} 
        
        attr.Length = fread(file.FID, 1, 'uint16', file.Current_Endian);
        
    otherwise

        % PS 3.5-1999 Sec. 6.2 indicates that all unknown VRs can be
        % interpretted as being the same as OB, OW, SQ, or UN.  The size
        % of data is not known but, the reading structure is.  
    
        fread(file.FID, 2, 'uint8');
        attr.Length = fread(file.FID, 1, 'uint32', file.Current_Endian);
    
    end
    
else
    
    % Implicit VR, not part of a sequence/item-list.

    attr.Length = fread(file.FID, 1, 'uint32', file.Current_Endian);
    
end
