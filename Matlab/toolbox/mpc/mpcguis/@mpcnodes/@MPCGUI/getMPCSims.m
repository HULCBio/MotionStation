function MPCSims = getMPCSims(this)

% MPCSims = getMPCSims(this))
%
% Navigates the tree to the MPCSims node

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:16 $

% Find the MPCSims node
MPCSims = this.find('-class','mpcnodes.MPCSims');
if isempty(MPCSims)
    % Need to add the node
    MPCSims = mpcnodes.MPCSims('Scenarios');
    this.addNode(MPCSims);
end
