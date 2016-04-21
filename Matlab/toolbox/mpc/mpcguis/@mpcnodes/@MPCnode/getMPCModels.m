function MPCModels = getMPCModels(this)

% MPCControllers = getMPCModels(this)
%
% Navigates the tree to the MPCModels node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:37:08 $

% First go up to the root node.
Root = this.getMPCStructure;
% Now find the MPCModels node
MPCModels = Root.find('-class','mpcnodes.MPCModels');
