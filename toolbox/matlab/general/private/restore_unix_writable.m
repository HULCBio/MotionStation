% RESTOREUNIXWRITABLE. Restore read-only attribute on UNIX platforms
% restoreunixwritable(DestinationAttributes,DestinationReadOnly,Destination)
% Input:
%        DestinationAttributes: struct array of file attributes in Destination
%        DestinationReadOnly: logical array of file read-only attribute in
%                             Destination
 
%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.3 $ $Date: 2002/04/08 20:51:30 $
%-------------------------------------------------------------------------------
function restoreunixwritable(DestinationAttributes,DestinationReadOnly)
%-------------------------------------------------------------------------------
% restore directory attributes of destination
for i = 1:length(DestinationReadOnly)
   if DestinationReadOnly(i)
      % reset read-only attribute
      [Status, OSMessage] = unix(['chmod -w ' DestinationAttributes(i).Name]);
   end
end
%-------------------------------------------------------------------------------
return
% end of RESTOREUNIXWRITABLE
%===============================================================================
