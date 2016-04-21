function h = datachildren(parent)
%DATACHILDREN Handles to figure children that contain data.
%    H = DATACHILDREN(FIG) returns the children in the figure
%    that contain data and are suitable for manipulation via
%    functions like ROTATE3D and ZOOM.
%
%    This is a helper function for ROTATE3D and ZOOM.

%    Copyright 1984-2002 The MathWorks, Inc. 
%    $Revision: 1.7 $ $Date: 2002/04/10 17:08:15 $

% Current implementation:
%    Figure children that have an application data property
%    called 'NonDataObject' are excluded.

h = get(parent,'children');
nondatachild = logical([]);
for i=length(h):-1:1
  nondatachild(i) = isappdata(h(i),'NonDataObject');
end
h(nondatachild) = [];
