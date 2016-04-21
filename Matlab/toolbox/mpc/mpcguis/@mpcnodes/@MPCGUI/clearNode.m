function clearNode(this)

% clearNode
%
% Deletes an MPC node and its children.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:36:08 $


Children = this.getChildren;
% If children exist, remove them recursively.
for i = 1:length(Children)
    Children(i).clearNode;
end
clear Children
