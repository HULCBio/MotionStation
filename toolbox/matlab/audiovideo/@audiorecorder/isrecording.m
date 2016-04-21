function status = isrecording(obj)
%ISRECORDING Indicates if recording is in progress.
%
%    STATUS = ISRECORDING(OBJ) returns true or false, indicating
%    whether recording is or is not in progress.
%
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET,
%             AUDIORECORDER/SET.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:00:34 $

status =  isrecording(obj.internalObj);
