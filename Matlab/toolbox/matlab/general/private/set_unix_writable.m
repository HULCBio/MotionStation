% SETUNIXWRITABLE. Set file objects in Destination writable on UNIX
% setunixwritable(DestinationAttributes,DestinationReadOnly)
% Input:
%        DestinationAttributes: struct array of file attributes in Destination
%        DestinationReadOnly: logical array of file read-only attribute in
%                             Destination

%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.4 $ $Date: 2002/04/08 20:51:31 $
%-------------------------------------------------------------------------------
function set_unix_writable(DestinationAttributes,DestinationReadOnly)
%-------------------------------------------------------------------------------

% if read-only, change read-only to writable
for i = 1:length(DestinationReadOnly)
   if DestinationReadOnly(i)
      % set read-only to writable
      [Status, OSMessage] = unix(['chmod +w ' DestinationAttributes(i).Name]);
      % check error status of attribute change
      if Status ~= 0 
         warning('MATLAB:SET_UNIX_WRITABLE:CannotChangePermissions',...
            'Cannot change write permissions on "%s".',...
            DestinationAttributes(i).Name)
      end
   end
end
%-------------------------------------------------------------------------------
return
% end of SETUNIXWRITABLE
%===============================================================================
