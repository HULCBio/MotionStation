function pause(obj)
%PAUSE Pauses playback in progress.
%
%    PAUSE(OBJ) pauses the current playback.  Use RESUME
%    or PLAY to resume playback.
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/RESUME, AUDIOPLAYER/PLAY.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:16 $

pause(obj.internalObj);
