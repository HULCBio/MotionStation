function out = privateInstrcreateHelper(action, varargin)
%PRIVATEINSTRCREATEHELPER helper function used by INSTRCREATE.
%
%   PRIVATEINSTRCREATEHELPER helper function used by INSTRCREATE to:
%      1. Identify the object
%      2. Delete the object
%   
%   This function should not be called directly be the user.
%  
%   See also INSTRCREATE.
%
 
%   MP 7-22-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.7 $  $Date: 2004/01/16 20:02:48 $

switch action
case 'delete'
    % Delete the instrument object.
    delete(localGetValidObject(varargin{1}));
case 'identify'
    % Parse the input.
    obj = localGetValidObject(varargin{1});
    cmd = varargin{2};
    
    % Determine if the object is already connected to
    % the hardware and it's timeout value.
    status = get(obj, 'Status');
    timeout = get(obj, 'Timeout');

    try
        % If the object is not connected, connect.
        if strcmp(status, 'closed')
            fopen(obj);            
        end
        
        % Configure the Timout.
        set(obj, 'Timeout', 3);
        
        % Query the instrument for it's id.
        out = query(obj, cmd);    
        
        % If the object was closed to begin with, close 
        % the connection. 
        if strcmp(status, 'closed')
            fclose(obj);
        end
        
        % Set the timeout to the original value.
        set(obj, 'Timeout', timeout);
        
        out = {removeCRLF(out)};
    catch
        set(obj, 'Timeout', timeout);
        out = {'Error', removeCRLF(lasterr)};        
    end
end

% ------------------------------------------------------------------------
% Get the MATLAB OOPs object for the java instrument object.
function out = localGetValidObject(instr)

objs = instrfindall;
for i = 1:length(objs)
    obj = objs(i);
    jobj = java(igetfield(obj, 'jobject'));
    if (jobj == instr)
        out = obj;
        return;
    end
end    

% ------------------------------------------------------------------------
% Remove any trailing carriage returns or line feeds.
function out = removeCRLF(out)

if length(out) == 0
    return;
end

while out(end) == sprintf('\n')
   out = out(1:end-1);
end

while out(end) == sprintf('\r')
   out = out(1:end-1);
end
