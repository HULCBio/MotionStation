function MPCStructure = getMPCStructure(this)

% MPCStructure = getMPCStructure(this)
%
% Navigates the tree to the MPCGUI (root) node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:37:10 $

% Get the root node.
MPCStructure = this.getRoot;