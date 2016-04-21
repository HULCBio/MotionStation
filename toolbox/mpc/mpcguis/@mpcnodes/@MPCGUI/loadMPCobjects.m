function loadMPCobjects(this)

% load MPC objects into the GUI.  These objects were specified 
% as input arguments for mpctool.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.3 $ $Date: 2003/12/04 01:34:41 $

MPCObjects = this.MPCObject;
MPCControllers = this.getMPCControllers;
[NumObj,NumCols] = size(MPCObjects);
if NumObj > 0
    for i = 1:NumObj
        % Skip any empty objects
        if ~isempty(MPCObjects{i,1});
            MPCControllers.addController(MPCObjects{i,2}, MPCObjects{i,1});
        end
    end
    % Clear the objects
    this.MPCObject = {};
end
