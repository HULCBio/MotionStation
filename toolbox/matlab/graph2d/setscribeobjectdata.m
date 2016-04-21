function setscribeobjectdata(co, od)
%SETSCRIBEOBJECTDATA  Set the scribe object data

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 04:08:33 $

h = handle(co);
if isempty(h.findprop('ScribeObjectData'))
    p = schema.prop(h, 'ScribeObjectData','MATLAB array');
    p.AccessFlags.Serialize = 'off';
end
h.ScribeObjectData = od;

