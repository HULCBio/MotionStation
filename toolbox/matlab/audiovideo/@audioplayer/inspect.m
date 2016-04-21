function inspect(obj)
%INSPECT Open the inspector and inspect audioplayer object properties.
%
%    INSPECT(OBJ) opens the property inspector and allows you to
%    inspect and set properties for the audioplayer object, OBJ.
%
%    Example:
%        load handel;
%        p = audioplayer(y, Fs);
%        inspect(p);

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:13 $

% Open the inspector.
inspect(obj.internalObj);

