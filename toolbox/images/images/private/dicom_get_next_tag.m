function [group, element] = dicom_get_next_tag(file)
%DICOM_GET_NEXT_TAG  Get the group and element values for the next attribute.
%   [GROUP,ELEMENT] = DICOM_GET_NEXT_TAG(MESSAGE) returns the GROUP and
%   ELEMENT of the next attribute in MESSAGE.
%
%   Note: This function reads the tag and then rewinds to the beginning
%   of it.  It is then possible to call DICOM_READ_ATTR without changing
%   the position in the file.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/01/26 05:58:36 $

if (~feof(file.FID))
    
    [tag, count] = fread(file.FID, 2, 'uint16', file.Current_Endian);
    
    if (count ~= 2)
        
        group = -1;
        element = -1;
        
        return
        
    end
            
    group = tag(1);
    element = tag(2);
        
    fseek(file.FID, -4, 'cof');
    
else
    
    group = -1;
    element = -1;
    
end
