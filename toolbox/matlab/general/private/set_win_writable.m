% SET_WIN_WRITABLE. Set file objects in Destination writable on Microsoft Windows
% setwinwritable(DestinationAttributes,DestinationReadOnly)
% Input:
%        DestinationAttributes: struct array of file attributes in Destination
%        DestinationReadOnly: logical array of file read-only attribute in
%                             Destination

%  JP Barnard
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $ $Date: 2003/12/19 22:58:50 $
%-------------------------------------------------------------------------------
function set_win_writable(DestinationAttributes,DestinationReadOnly)
%-------------------------------------------------------------------------------

% Clear Read-only attribute of contents of Destination directory
for i = 1:length(DestinationReadOnly)
   if DestinationReadOnly(i)
      % clear Read-only attribute of Destination
      [Status, OSMessage] = dos(['attrib ' '-r ' '"' DestinationAttributes(i).Name '"']);
      % check error status of attribute change
      if Status ~= 0 
         warning('MATLAB:SET_WIN_WRITABLE:CannotChangePermissions',...
            'Cannot change write permissions on "%s".',...
            DestinationAttributes(i).Name)
      end
   end
end
%-------------------------------------------------------------------------------
return
%===============================================================================
