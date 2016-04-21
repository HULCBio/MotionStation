% RESTORE_WIN_WRITABLE. Restore read-only attribute on Microsoft Windows platforms
% restorewinwritable(DestinationAttributes,DestinationReadOnly)
% Input:
%        DestinationAttributes: struct array of file attributes in Destination
%        DestinationReadOnly: logical array of file read-only attribute in
%                             Destination

%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/12/19 22:58:49 $
%-------------------------------------------------------------------------------
function restore_win_writable(DestinationAttributes,DestinationReadOnly)
%-------------------------------------------------------------------------------
% restore directory attributes of destination
for i = 1:length(DestinationReadOnly)
   if DestinationReadOnly(i)
      % reset read-only attribute
      [Status, OSMessage] = dos(['attrib ' '+r ' '"' DestinationAttributes(i).Name '"']);
   end
end
%-------------------------------------------------------------------------------
return
%===============================================================================
