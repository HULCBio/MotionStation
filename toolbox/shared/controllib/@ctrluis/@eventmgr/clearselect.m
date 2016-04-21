function clearselect(h,Containers)
%CLEARSELECT  Clear list of selected objects

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:49 $

if nargin==1 | ...
        (~isempty(h.SelectedContainer) & any(h.SelectedContainer==Containers))
    set(h.SelectedObjects,'Selected','off')
    h.SelectedObjects = [];
end