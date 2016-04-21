function inspect(obj)
%INSPECT Open the inspector and inspect audiorecorder object properties.
%
%    INSPECT(OBJ) opens the property inspector and allows you to
%    inspect and set properties for the audiorecorder object, OBJ.
%
%    Example:
%        r = audiorecorder(22050, 16, 1);
%        record(r);
%        stop(r);
%        inspect(p);

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:00:33 $

% Open the inspector.
inspect(obj.internalObj);

