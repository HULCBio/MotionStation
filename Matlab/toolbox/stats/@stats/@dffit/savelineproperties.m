function savelineproperties(fit)
%SAVELINEPROPERTIES Save current line properties for later recovery

% $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:50 $
% Copyright 2003-2004 The MathWorks, Inc.

% Get line properties previously saved
oldcml = fit.ColorMarkerLine;

cml = cell(4,1);
lineproperties = {'Color' 'Marker' 'LineStyle' 'LineWidth'};

if ~isempty(fit.linehandle) & ishandle(fit.linehandle)
   cml = get(fit.linehandle, lineproperties);
end

% Only the discrete pdf uses markers, so don't overwrite the marker
% unless that's what we're plotting.
if length(oldcml) >= 4
   if ~isequal(fit.ftype,'pdf') || iscontinuous(fit)
      cml{2} = oldcml{2};
   end
end

% Save current properties
fit.ColorMarkerLine = cml;
