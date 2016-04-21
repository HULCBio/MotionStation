function MPCControllers = getMPCControllers(this)

% MPCControllers = getMPCControllers(this)
%
% Navigates the tree to the MPCControllers node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:37:07 $

% First go up to the root node.
Root = this.getMPCStructure;
% Now find the MPCControllers node
MPCControllers = Root.find('-class','mpcnodes.MPCControllers');
