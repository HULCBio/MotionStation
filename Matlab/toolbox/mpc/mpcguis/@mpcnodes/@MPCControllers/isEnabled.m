function Bool = isEnabled(this)

% Copyright 2003 The MathWorks, Inc.

% Determines whether or not the MPCControllers panel should
% be enabled.  Enabling requires that at least one model
% has been imported.
%
% "this" is the handle of the MPCControllers panel.

% Get parent node, then MPCModels node.

P=this.up;
MPCModels = P.find('-class','mpcnodes.MPCModels');
if isempty(MPCModels.getChildren)
    Bool = 0;
else
    Bool = 1;
end

