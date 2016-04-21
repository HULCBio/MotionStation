function removeDataCursor(hThis,hDataCursor)

% Copyright 2003 The MathWorks, Inc.

if(hThis.Debug)
  disp('removeDataCursor')
end

hList = get(hThis,'DataCursors');

% Get data cursors to be deleted
ind = find(hDataCursor==hList);

% If valid handle, then delete
for n=1:length(ind)
   if ishandle(hList(ind))
       delete(hList(ind));
   end
end

% Remove from list
hList(ind) = [];
set(hThis,'DataCursor',hList);

% Set current datatip to be last created
if length(hList) > 0
   hThis.CurrentDataCursor = hList(1);
else
   hThis.CurrentDataCursor = [];
end







