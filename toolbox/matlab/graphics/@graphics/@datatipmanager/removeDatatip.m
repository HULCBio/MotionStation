function removeDatatip(hThis,hDatatip)

% Copyright 2002 The MathWorks, Inc.

if(hThis.Debug)
  disp('removeDatatip')
end

hList = hThis.DatatipHandles;

% Get datatips to be deleted
ind = find(hDatatip==hList);

% Delete datatip
delete(hList(ind));

% Remove from stack
hList(ind) = [];
hThis.DatatipHandles = hList;

% Set current datatip to be last created
if length(hList) > 0
   hThis.CurrentDatatip = hList(1);
else
   hThis.CurrentDatatip = [];
end







