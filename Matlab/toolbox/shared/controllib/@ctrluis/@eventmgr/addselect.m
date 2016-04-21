function addselect(h,Object,Container)
%ADDSELECT  Adds selection to list of selected objects.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:48 $

if nargin==3
    % Reset container (automatically clears selection list if container differs from previous)
    h.SelectedContainer = Container;
end

h.SelectedObjects = [h.SelectedObjects ; Object];
h.SelectedListeners = [h.SelectedListeners ; ...
        handle.listener(Object,'ObjectBeingDestroyed',{@LocalRemove h Object})];


%------------- Local functions ------------------

function LocalRemove(eventSrc,eventData,h,Object)
h.rmselect(Object);
