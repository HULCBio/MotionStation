function C = findconstr(this,blk)
% Finds constraint associated with a given Signal Constraint block.
%
% Example:
%   proj = getsro('srodemo1')
%   c = findconstr(proj,gcb)

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:11 $
%   Copyright 1986-2004 The MathWorks, Inc.
LogID = get_param(blk,'LogID');
Specs = this.Test(1).Specs;
for idx=1:length(Specs)
   C = Specs(idx);
   if strcmp(C.SignalSource.LogID,LogID)
      return
   end
end
C = []; idx = [];