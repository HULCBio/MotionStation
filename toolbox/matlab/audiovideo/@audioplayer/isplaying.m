function status = isplaying(obj)
%ISPLAYING Indicates if playback is in progress.
%
%    STATUS = ISPLAYING(OBJ) returns true or false, indicating
%    whether playback is or is not in progress.
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET,
%             AUDIOPLAYER/SET.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:14 $

status =  isplaying(obj.internalObj);
