% SET_PARENT_WRITABLE. Set parent of file to read-only
% set_parent_writable(ParentAttributes,ParentReadOnly)
% Input:
%        ParentAttributes: struct defining file attributes of file parent
%        ParentReadOnly: logical array of file read-only attribute in
%                             Destination

%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.4 $ $Date: 2002/04/08 20:51:31 $
%-------------------------------------------------------------------------------
function set_parent_writable(ParentAttributes,ParentReadOnly)
%-------------------------------------------------------------------------------

Status = 0;

% if read-only, change read-only to writable
if ParentReadOnly
   % set read-only to writable
   if isunix
      [Status] = unix(['chmod +w ', '"',ParentAttributes.Name,'"']);
   elseif ispc
      [Status] = dos(['attrib -r ', '"',ParentAttributes.Name,'"']);
   end
end
if Status ~= 0 
   warning('MATLAB:SET_PARENT_WRITABLE:CannotChangePermissions',...
      'Cannot change write permissions on "%s".',...
      ParentAttributes(i).Name)
end
%-------------------------------------------------------------------------------
return
%===============================================================================
