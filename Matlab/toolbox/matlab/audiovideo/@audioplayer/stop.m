function stop(obj)
%STOP Stops playback in progress.
%
%    STOP(OBJ) stops the current playback.
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/PLAY, AUDIOPLAYER/PLAYBLOCKING,
%             AUDIOPLAYER/PAUSE, AUDIOPLAYER/RESUME

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:49 $

stop(obj.internalObj);
