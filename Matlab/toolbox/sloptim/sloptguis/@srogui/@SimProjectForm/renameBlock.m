function renameBlock(this,blk)
% Update project data when renaming SRO block.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:04 $
%   Copyright 1986-2004 The MathWorks, Inc.
for ct=1:length(this.Tests)
   t = this.Tests(ct);
   for cts=1:length(t.Specs)
      s = t.Specs(cts);
      try
         % Will error if block has been renamed
         get_param(s.SignalSource.Block,'Parent');
      catch
         % Invalid block path: update
         s.SignalSource.Block = sprintf('%s/SigLog',blk);
      end
   end
end
