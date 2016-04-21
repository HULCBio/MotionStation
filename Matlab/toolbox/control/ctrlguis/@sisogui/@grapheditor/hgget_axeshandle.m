function hAxes = hgget_axeshandle(Editor,idx)
%HGGET_AXESHANDLE   Returns HG axes handles.

%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2001/08/15 12:31:01 $

hAxes = getaxes(Editor.Axes,'2d');
if ~all(ishandle(hAxes))  % protect about calls after deleting @axes object
   hAxes = [];
elseif nargin>1
   % Axes #IDX
   hAxes = hAxes(idx);
end

