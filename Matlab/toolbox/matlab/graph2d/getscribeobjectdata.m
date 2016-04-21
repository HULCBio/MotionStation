function od = getscribeobjectdata(co)
%GETSCRIBEOBJECTDATA  Return the scribe object data

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 04:08:31 $

od = [];
h = handle(co);
if ~isempty(h.findprop('ScribeObjectData'))
    od = h.ScribeObjectData;
end


