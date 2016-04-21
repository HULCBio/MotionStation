function out = privateObjectExporterHelper(action, varargin)
%PRIVATEOBJECTEXPORTERHELPER helper function used by INSTRCREATE.
%
%   PRIVATEOBJECTEXPORTERHELPER helper function used by INSTRCREATE to
%   export the object.
%   
%   This function should not be called directly be the user.
%  
%   See also INSTRCREATE.
%
 
%   MP 9-08-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:54 $

switch action
case 'workspace'
    % Export the specified objects to the MATLAB workspace.
    
    % Parse the input.
    info = varargin{1};
    
    % Loop through and assign each object to the user-specified variable name
    % and assign to the MATLAB workspace.
    for i=1:2:info.size;
        variableName = info.elementAt(i-1);        
        assignin('base', variableName, localGetValidObject(info.elementAt(i)));
    end
case 'mat-file'
    % Export the specified objects to a MAT-file.
    
    % Parse the input.
    filename = varargin{1};
    info     = varargin{2};
    variableNames = {};
    count = 1;
    
    % Loop through and assign each object to the user-specified variable name.
    for i=1:2:info.size
        variableNames{count} = info.elementAt(i-1);
        eval([variableNames{count} ' = localGetValidObject(info.elementAt(i));'])
        count = count+1;
    end

    % Save the variables to the MAT-file.
    save(filename, variableNames{:});
case 'm-file'
    % Export the specified objects to a M-file.
    
    % Parse the input.
    filename = varargin{1};
    info = varargin{2};
    count = 1;
    
    % Get the MATLAB OOPs representation of each java instrument object.
    for i=1:2:info.size
        obj(count) = localGetValidObject(info.elementAt(i));
        setVariableName(igetfield(obj(count), 'jobject'), char(info.elementAt(i-1)));
        count = count+1;
    end
    
    % Save the objects to the M-file.
    obj2mfile(obj, filename);
    for i = 1:length(obj)
        setVariableName(igetfield(obj(i), 'jobject'), '');
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


