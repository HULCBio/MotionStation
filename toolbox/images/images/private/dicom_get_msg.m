function file = dicom_get_msg(file)
%DICOM_GET_MSG  Get a pool of potential messages to load later.
%   FILE = DICOM_GET_MSG(FILE) processes FILE.Messages to obtain a pool
%   of potential DICOM messages to read.  After execution, FILE.Messages
%   will contain a cell array of messages to read.
%
%   Note: When loading a locally stored file, this function just checks
%   for the existence of the file.  When network contexts are supported,
%   the message pool will contain the results of a QUERY operation.
%
%   See also DICOM_OPEN_MSG and DICOM_CREATE_FILE_STRUCT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/08/01 18:10:41 $

if (isequal(file.Location, 'Local'))
    
    % Verify that file exists.
    
    if (exist(file.Messages) ~= 2)
        
        % Look for file with common extensions.
        if (exist([file.Messages '.dcm']))
            
            file.Messages = {[file.Messages '.dcm']};
            
        elseif (exist([file.Messages '.dic']))
            
            file.Messages = {[file.Messages '.dic']};
            
        elseif (exist([file.Messages '.dicom']))
            
            file.Messages = {[file.Messages '.dicom']};
            
        elseif (exist([file.Messages '.img']))
            
            file.Messages = {[file.Messages '.img']};
            
        else
            
            file.Messages = {};
            return
            
        end
        
    else
        
        file.Messages = {file.Messages};
        
    end
    
    % Get full filename.
    fid = fopen(file.Messages{1});
    
    if (fid < 0)
        
        msg = sprintf('Could not open file "%s" for reading.', file.Messages{1});
        error('Images:dicom_get_msg:fileOpen', msg)
        
    else
        
        file.Messages = {fopen(fid)};
        
    end
    
    fclose(fid);
        
else 
    
    error('Images:dicom_get_msg:localOnly', 'Network messages are not yet supported.')
    
end  % file.Location
