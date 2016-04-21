function obj = loadobj(obj)
%LOADOBJ Load filter for serial port objects.
%
%   OBJ = LOADOBJ(B) is called by LOAD when an IVI configuration store
%   port object, B, is loaded from a .MAT file. The return value, OBJ, is
%   subsequently  used by LOAD to populate the workspace.  
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%

%   PE 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/03/05 18:10:19 $

try
    Deserialize(obj.cobject, obj.location);
catch
    rethrow(lasterror);
end

