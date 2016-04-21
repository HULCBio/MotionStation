function stop(obj)
%STOP Stops recording in progress.
%
%    STOP(OBJ) stops the current recording.
%
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET, 
%             AUDIORECORDER/SET, AUDIORECORDER/RECORD, 
%             AUDIORECORDER/RECORDBLOCKING, AUDIORECORDER/PAUSE, 
%             AUDIORECORDER/RESUME

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:01:03 $

stop(obj.internalObj);
