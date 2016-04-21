% RESTORE_PARENT_WRITABLE. Restore parent of file to read-only
% set_parent_writable(ParentAttributes,ParentReadOnly)
% Input:
%        ParentAttributes: struct defining file attributes of file parent
%        ParentReadOnly: logical array of file read-only attribute in
%                             Destination

%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.3 $ $Date: 2002/04/08 20:51:30 $
%-------------------------------------------------------------------------------
function restore_parent_writable(ParentAttributes,ParentReadOnly)
%-------------------------------------------------------------------------------

% if read-only, change read-only to writable
if ParentReadOnly
   % set read-only to writable
   if isunix
      [tmp] = unix(['chmod -w ', '"',ParentAttributes.Name,'"']);
   elseif ispc
      [tmp] = dos(['attrib +r ', '"',ParentAttributes.Name,'"']);
   end
end
%-------------------------------------------------------------------------------
return
% end of SET_PARENT_WRITABLE
%===============================================================================
