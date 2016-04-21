function resume(obj)
%RESUME Resumes paused playback.
%
%    RESUME(OBJ) continues playback from paused location.
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/PAUSE.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:46 $

resume(obj.internalObj);
