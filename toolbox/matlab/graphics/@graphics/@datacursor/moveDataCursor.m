function moveDataCursor(hThis,hgObject,hDataCursor,dir)

% Copyright 2002 The MathWorks, Inc.

% This should be a static function, therefore, ignore "hThis"

str = [];

% invoke class method
if ismethod(hgObject,'moveDataCursor')
   moveDataCursor(hgObject,hDataCursor,dir);
  
% else do default
else
   hThis.default_moveDataCursor(hgObject,hDataCursor,dir);
end


