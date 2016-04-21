function removeLayer(this,layername)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:30 $

strs = get(this.ActiveLayerDisplay,'String');
currentVal = get(this.ActiveLayerDisplay,'Value');
currentStr = strs(currentVal);

% Remove the string.
val = strmatch(layername,strs,'exact');
strs(val) = [];

% Determine new value
newVal = strmatch(currentStr,strs);
if isempty(newVal)
  newVal = 1; % This is the "None" string
end

set(this.ActiveLayerDisplay,'String',strs,'Value',newVal);