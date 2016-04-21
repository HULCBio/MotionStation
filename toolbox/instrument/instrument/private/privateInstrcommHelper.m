function out = privateInstrcommHelper(action, obj, varargin)
%PRIVATEINSTRCOMMHELPER helper function used by INSTRCOMM.
%
%   PRIVATEINSTRCOMMHELPER helper function used by INSTRCOMM to:
%      1. Connect to the object
%      2. Write to the object
%      3. Read from the object
%      4. Disconnect from the object
%      5. Flush the object.
%   
%   This function should not be called directly be the user.
%  
%   See also INSTRCOMM.
%
 
%   MP 7-22-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $  $Date: 2004/01/16 20:02:47 $

% Convert the java instrument object to a MATLAB OOPs object.
if (nargin >= 2) && isa(obj, 'com.mathworks.toolbox.instrument.Instrument')
    obj = localGetValidObject(obj);    
end

% Initialize output.
out = '';

switch action
case 'isopen'
    % Determine if object is open so the instrcommLabel panel can be updated correctly.
    out = obj.Status;
case 'fopen'
    % Connect to the object.
    fopen(obj);
    out = get(obj, 'Status');
case 'fclose'
    % Disconnect from the object.
    fclose(obj);
    out = get(obj, 'Status');
case 'fprintf'
    % Parse the input.
    source = varargin{3};
    cmd = varargin{2};
    
    % Evaluate the expression in the MATLAB workspace if the user specified to.
    if (strcmp(source, 'Evaluate'))
        cmd = evalin('base', cmd);
    end    
    
    % Store the initial number of values sent.
    initial = get(obj, 'ValuesSent');    
    
    % Write the command.
    fprintf(obj, varargin{1}, cmd); 
    
    % Determine the number of values sent with the last command and return.
    current = get(obj, 'ValuesSent');
    out = current-initial;
case 'fwrite'
    % Parse the input.
    source = varargin{3};
    cmd = varargin{2};
    
    % Evaluate the expression in the MATLAB workspace if the user specified to.
    if (strcmp(source, 'Evaluate'))
        cmd = evalin('base', cmd);
    end    

    % Store the initial number of values sent.
    initial = get(obj, 'ValuesSent');    
    
    % Write the command.
    fwrite(obj, cmd, varargin{1}); 
    
    % Determine the number of values sent with the last command and return.
    current = get(obj, 'ValuesSent');
    out = current-initial;
case 'binblockwrite'
    % Parse the input.
    source = varargin{3};
    cmd = varargin{2};

    % Evaluate the expression in the MATLAB workspace if the user specified to.
    if (strcmp(source, 'Evaluate'))
        cmd = evalin('base', cmd);
    end    
    
    % Store the initial number of values sent.
    initial = get(obj, 'ValuesSent');    
    
    % Write the command.
    binblockwrite(obj, cmd, varargin{1}); 
    
    % Determine the number of values sent with the last command and return.
    current = get(obj, 'ValuesSent');
    out = current-initial;
case 'fscanf'
    % Parse the input.
    size = varargin{2};
    
    % Read data from instrument.
    if isempty(size)
        [data, count, msg] = fscanf(obj, varargin{1});
    else
        [data, count, msg] = fscanf(obj, varargin{1}, str2num(varargin{2}));
    end
    
    % Construct variable name.
    variableName = ['data' num2str(varargin{3}+1)];
    
    % Remove any carriage returns or line feeds and return.
    data = removeCRLF(data);
    out = {data, count, msg, variableName};
case 'fread'
    % Parse the input.
    size = varargin{2};
    
    % If size wasn't sepcified, determine the maximum SIZE that can be read.
    % Otherwise convert size string to a number.
    if isempty(size)
        size = get(obj, 'InputBufferSize') - get(obj, 'BytesAvailable');
    else
        size = str2num(size);
    end
    
    % Read data from instrument.
    [data, count, msg] = fread(obj, size, varargin{1});
    
    % Assign the value to the MATLAB workspace and return.
    variableName = ['data' num2str(varargin{3}+1)];
    out = {data,count,msg, variableName};
case 'binblockread'
    % Read data from instrument.
    [data, count, msg] = binblockread(obj, varargin{1});
    
    % Assign the value to the MATLAB workspace and return.
    variableName = ['data' num2str(varargin{3}+1)];
    out = {data,count,msg, variableName};
case 'query'
    % Store the number of values that have been sent.
    initial = get(obj, 'ValuesSent');    
    
    % Query the instrument.
    [data, count, msg] = query(obj, varargin{1}, varargin{2}, varargin{3});
    
    % Construct variable name.
    variableName = ['data' num2str(varargin{4}+1)];
    
    % Determine the number of values that was just written to the instrument.
    current = get(obj, 'ValuesSent');
    out = {removeCRLF(data), count,msg, current-initial, variableName};
case 'flushinput'
    % Flush the object.
    flushinput(obj);
    out = num2str(get(obj, 'BytesAvailable'));
case 'demo'
    % Open the demos.
    demo('toolbox', 'instrument control');
case 'doc'
    % Open the documentation.
    doc('instrument');
end

% --------------------------------------------
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

% --------------------------------------------
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
