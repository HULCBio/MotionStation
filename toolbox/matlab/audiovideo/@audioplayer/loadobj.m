function obj = loadobj(B)
%LOADOBJ Load filter for audioplayer objects.
%
%    OBJ = LOADOBJ(B) is called by LOAD when an audioplayer object is 
%    loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.
%
%    See also AUDIOPLAYER/SAVEOBJ.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/22 00:50:09 $

% If we're on UNIX and don't have Java, warn and return.
if ~ispc && ~usejava('jvm')
    state = warning('backtrace','off');
    warning('MATLAB:audioplayer:loadobj:needjvmonunix',...
    audioplayererror('MATLAB:audioplayer:loadobj:needjvmonunix'));
    warning(state);
    obj = [];
    return;
end

% Get at the properties and data.
savedObj = struct(B);
props = savedObj.internalObj;
signal = savedObj.signal;

% Re-create the audioplayer
try
    if ispc
        % You can only set the DeviceID property on Windows
        obj = audioplayer(signal, props.SampleRate, props.BitsPerSample, ...
            props.DeviceID);
    else
        obj = audioplayer(signal, props.SampleRate, props.BitsPerSample);
    end
catch
    warning('MATLAB:audioplayer:loadobj:couldnotload', ...
        audioplayererror('matlab:audioplayer:loadobj:couldnotload',lasterr));
    obj = [];
    return;
end

% Set the original settable property values.
propNames = fieldnames(set(obj));

for i = 1:length(propNames)
   try
      set(obj, propNames{i}, props.(propNames{i}));
   catch
      warning('MATLAB:audioplayer:loadobj:couldnotset', ...
      audioplayererror('matlab:audioplayer:loadobj:couldnotset',...
      propNames{i}));
   end
end

