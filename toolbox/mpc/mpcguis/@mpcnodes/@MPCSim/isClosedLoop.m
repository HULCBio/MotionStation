function Answer = isClosedLoop(this)

% Copyright 2003 The MathWorks, Inc.

% Determines whether the user has turned on the constraints for the
% simulation represented by "this" (an MPCSim object)

Option = this.Handles.LoopUDD.getSelectedItem;
Answer = strcmp(Option,'Closed');