function default_updateDataCursor(hThis,hgObject,hDataCursor,target)
% Determines position and index on object from mouse position

% Copyright 2002-2003 The MathWorks, Inc.

pos = [];

[p,v,ind,pfactor] = vertexpicker(hgObject,target,'-force');
if strcmp(hDataCursor.Interpolate,'on')
   pos = p;
else
   pos = v;
end

if isa(handle(hgObject),'hg.line')
   hDataCursor.InterpolationFactor = pfactor;
else
   hDataCursor.InterpolationFactor = [];
end
hDataCursor.Position = pos;
hDataCursor.DataIndex = ind;






