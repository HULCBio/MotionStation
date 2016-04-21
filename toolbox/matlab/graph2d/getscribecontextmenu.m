function hCM = getscribecontextmenu(h)
%GETSCRIBECONTEXTMENU  Get the scribe uicontextmenu object

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 04:08:35 $

hCM = [];
if ~isempty(findprop(handle(h), 'ScribeUIContextMenu'))
    hCM = get(handle(h), 'ScribeUIContextMenu');
end

