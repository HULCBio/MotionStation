function newselect(h,Object,Container)
%NEWSELECT  Specifies new selected object.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:52 $

if nargin==3
    % Reset container (automatically clears selection list if container differs from previous)
    h.SelectedContainer = Container;
end

% Clear selected objects
if length(h.SelectedObjects)
    % Deselect 
	set(h.SelectedObjects(h.SelectedObjects~=Object),'Selected','off')
end
h.SelectedObjects = [];

% Add specified object
h.addselect(Object);


