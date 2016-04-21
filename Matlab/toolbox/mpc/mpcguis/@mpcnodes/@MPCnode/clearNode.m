function clearNode(this)

% clearNode
%
% Deletes an MPC node and its children.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2004/04/10 23:37:04 $

% Clear listeners so we don't get unexpected callbacks.

if ~isa(this,'mpcnodes.MPCGUI')
    delete(this.Listeners);
    %this.Listeners = zeros(0,1);
end

Children = this.getChildren;
% If children exist, remove them recursively.
for i = 1:length(Children)
    Children(i).clearNode;
end
clear Children
% No children remaining.  If this isn't the root node, remove it.
if ~isa(this,'mpcnodes.MPCGUI')
    this.up.removeNode(this);
end
