function removeAllDatatips(hThis)

% Copyright 2002 The MathWorks, Inc.

if(hThis.Debug)
  disp('removeAllDatatips')
end

hList = hThis.DatatipHandles;

% Destroy all datatips
for n = 1:length(hList)
    if ishandle(hList(n))
        delete(hList(n));
    end
end

% Clear all references
hThis.DatatipHandles = [];
hThis.CurrentDatatip = [];






