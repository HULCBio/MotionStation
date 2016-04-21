function B = validatehandles(B)
%VALIDATEHANDLES  prune invalid scribehandle items from a list

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:01:36 $

if ~isempty(B)
   %HGHandles = B.HGHandle;
   HGHandles = subsref(B,substruct('.','HGHandle'));
   if iscell(HGHandles)
      HGHandles = [HGHandles{:}];
   end
   B = B(find(ishandle(HGHandles)));            
end
