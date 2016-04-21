function [C,idx] = findspec(this,LogID)
% Deletes constraint associated with given Simulink block.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:11 $
%   Copyright 1986-2004 The MathWorks, Inc.
for idx=1:length(this.Specs)
   C = this.Specs(idx);
   if strcmp(C.SignalSource.LogID,LogID)
      return
   end
end
C = []; idx = [];
