function MPCControllers = getMPCControllers(this)

% MPCControllers = getMPCControllers(this)
%
% Navigates the tree to the MPCControllers node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:14 $

% Find the MPCControllers node
MPCControllers = this.find('-class','mpcnodes.MPCControllers');
if isempty(MPCControllers)
    % Need to add the node
    MPCControllers = mpcnodes.MPCControllers('Controllers');
    this.addNode(MPCControllers);
end
