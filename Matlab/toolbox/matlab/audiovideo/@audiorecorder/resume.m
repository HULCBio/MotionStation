function resume(obj)
%RESUME Resumes paused recording.
%
%    RESUME(OBJ) continues recording from paused location.
%
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET, 
%             AUDIORECORDER/SET, AUDIORECORDER/PAUSE.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:01:00 $

resume(obj.internalObj);
