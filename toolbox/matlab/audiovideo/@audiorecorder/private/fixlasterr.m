function out = fixlasterr()
%FIXLASTERR Modify the last error to hide any audiorecorder object references.
%
%    FIXLASTERR retrieves the last error message, replaces references
%    to the Java or UDD audiorecorder object with more generic 'audiorecorder object',
%    and returns the new error as a cell array suitable to be passed into ERROR.
%
%    See Also: ERROR

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:54 $

[lerr lid] = lasterr;

% look for the java object references in the text and replace the text with
% more generic version
lerr = strrep(lerr, 'in the ''com.mathworks.toolbox.audio.JavaAudioRecorder'' class', 'in the ''audiorecorder'' class');
lerr = strrep(lerr, 'property of javahandle.com.mathworks.toolbox.audio.JavaAudioRecorder', ...
    'property of an audiorecorder object');
lerr = strrep(lerr, 'property of audiorecorders.winaudiorecorder', ...
    'property of an audiorecorder object');
lerr = strrep(lerr, 'com.mathworks.toolbox.audio.JavaAudioRecorder', 'audiorecorder objects');
lerr = strrep(lerr, 'audiorecorders.winaudiorecorder', 'audiorecorder objects');

% check for prepending trace lines.
while strncmp(lerr,'Error using ==>',15) == 1
    [firstline rem] = strtok(lerr,[10 13]);
    lerr = rem(2:length(rem));
end

lasterr(lerr,lid);

if (length(lid)>0)
    out = {lid lerr};
else
    out = {lerr};
end
