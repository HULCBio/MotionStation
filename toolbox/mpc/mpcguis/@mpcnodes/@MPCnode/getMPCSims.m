function MPCSims = getMPCSims(this)

% MPCSims = getMPCSims(this))
%
% Navigates the tree to the MPCSims node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:37:09 $

% First go up to the root node.
Root = this.getMPCStructure;
% Now find the MPCSims node
MPCSims = Root.find('-class','mpcnodes.MPCSims');
