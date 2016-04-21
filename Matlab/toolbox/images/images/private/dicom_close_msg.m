function file = dicom_close_msg(file)
%DICOM_CLOSE_MSG  Close a DICOM message.
%   FILE = DICOM_CLOSE_MSG(FILE) closes the DICOM message pointed to in
%   FILE.FID.  The returned value, FILE, is the updated file structure.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:26 $

if (isequal(file.Location, 'Local'))
    
    if (file.FID > 0)
        
        result = fclose(file.FID);
        
        if (result == -1)
            eid = sprintf('Images:%s:unableToClose',mfilename);            
            msg = sprintf('Could not close message "%s":\n\t%s', ...
                          file.Messages{file.Current_Message}, ...
                          ferror(file.FID));
            error(eid,'%s',msg)
            
        end
        
    else
        eid = sprintf('Images:%s:invalidFID',mfilename);        
        error(eid,'%s','Invalid FID.')
        
    end
    
else
    eid = sprintf('Images:%s:networkMessagesNotSupported',mfilename);    
    error(eid,'%s','Network messages are not yet supported.')
    
end
