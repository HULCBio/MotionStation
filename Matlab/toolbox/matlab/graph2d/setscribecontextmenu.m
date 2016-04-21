function setscribecontextmenu(h, hCM)
%SETSCRIBECONTEXTMENU  Set the scribe uicontextmenu object

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 04:08:37 $

if isempty(findprop(handle(h), 'ScribeUIContextMenu'))
    p = schema.prop(handle(h), 'ScribeUIContextMenu','MATLAB array');
    p.AccessFlags.Serialize = 'off';
end
set(handle(h), 'ScribeUIContextMenu', hCM);
