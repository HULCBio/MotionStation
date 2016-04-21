function MPCModels = getMPCModels(this)

% MPCControllers = getMPCModels(this)
%
% Navigates the tree to the MPCModels node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:15 $

% Find the MPCModels node
MPCModels = this.find('-class','mpcnodes.MPCModels');
if isempty(MPCModels)
    % Need to add the node
    MPCModels = mpcnodes.MPCModels('Plant models');
    this.addNode(MPCModels);
end
