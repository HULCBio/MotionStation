function pause(obj)
%PAUSE Pauses recording in progress.
%
%    PAUSE(OBJ) pauses recording.  Use RESUME or RECORD to resume
%    recording.
%
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET, 
%             AUDIORECORDER/SET, AUDIORECORDER/RESUME, 
%             AUDIORECORDER/RECORD.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:00:36 $

pause(obj.internalObj);
