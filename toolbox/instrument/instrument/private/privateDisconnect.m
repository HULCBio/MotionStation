function privateDisconnect(obj)
%PRIVATEDISCONNECT Disconnect the object.
%
%   PRIVATEDISCONNECT(OBJ) removes the object from it's database.
%
%   This function should not be used directly by users.
%

%   MP 8-05-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 20:02:35 $

if length(obj) == 1
    if (iscell(obj))
        disconnect(handle(obj{1}))
    else
        disconnect(handle(obj));
    end
else
    for i=1:length(obj)
        disconnect(handle(obj{i}));
    end
end