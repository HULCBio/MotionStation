function obj = loadobj(B)
%LOADOBJ Load filter for audiorecorder objects.
%
%    OBJ = LOADOBJ(B) is called by LOAD when an audiorecorder object is 
%    loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.
%
%    See Also AUDIORECORDER/SAVEOBJ.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/22 00:50:12 $

% If we're on UNIX and don't have Java, warn and return.
if ~ispc && ~usejava('jvm')
    state = warning('backtrace','off');
    warning('MATLAB:audiorecorder:loadobj:needjvmonunix', ...
        audiorecordererror('MATLAB:audiorecorder:loadobj:needjvmonunix'));
    warning(state);
    obj = [];
    return;
end

% Get at the properties and data.
savedObj = struct(B);
props = savedObj.internalObj;

% Re-create the audiorecorder
try
    if ispc
        % You can only set the DeviceID property on Windows
        obj = audiorecorder(props.SampleRate, props.BitsPerSample, ...
            props.NumberOfChannels, props.DeviceID);
    else
        obj = audiorecorder(props.SampleRate, props.BitsPerSample, ...
            props.NumberOfChannels);
    end
catch
    warning('MATLAB:audiorecorder:loadobj:couldnotload', ...
        audiorecordererror('matlab:audiorecorder:loadobj:couldnotload',lasterr));
    obj = [];
    return;
end

% Set the original settable property values.
propNames = fieldnames(set(obj));

for i = 1:length(propNames)
    try
        set(obj, propNames{i}, props.(propNames{i}));
    catch
        warning('MATLAB:audiorecorder:loadobj:couldnotset', ...
        audiorecordererror('matlab:audiorecorder:loadobj:couldnotset', ...
        propNames{i}));
    end
end
