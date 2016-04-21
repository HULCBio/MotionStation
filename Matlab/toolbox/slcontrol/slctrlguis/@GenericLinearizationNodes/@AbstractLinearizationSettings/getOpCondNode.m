function node = getOpCondNode(this)
%Get the operating condition generation node

%  Author(s): John Glass
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/09/01 09:20:40 $

%% Get the project node
project = this.up;

%% Get the children
Children = project.getChildren;

%% Loop over childen the get the operating conditions
for ct = 1:length(Children)
    node = Children(ct);
    if isa(node,'OperatingConditions.OperatingConditionTask')
        break
    end
end