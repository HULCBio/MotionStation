function savelineproperties(ds)
%SAVELINEPROPERTIES Save current line properties for later recovery

% $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:38:29 $
% Copyright 2001-2004 The MathWorks, Inc.

lineproperties = {'Color' 'Marker' 'LineStyle' 'LineWidth'};
cml = cell(4,1);
if ~isempty(ds.line) & ishandle(ds.line)
   cml = get(ds.line, lineproperties);
end
ds.ColorMarkerLine = cml;
