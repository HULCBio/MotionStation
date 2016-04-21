function rmselect(h,Object)
%RMSELECT  Remove a particular object from selected list.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:57 $

% Remove object from list (if still there)
if ~isempty(h.SelectedObjects)
    ikeep = find(h.SelectedObjects~=Object);
	h.SelectedObjects = h.SelectedObjects(ikeep,:);
	h.SelectedListeners = h.SelectedListeners(ikeep,:);
end
