% CHECK_PARENT_WRITABLE. Check parent of file for writable attribute
% [DestinationAttributes,DestinationReadOnly] = check_parent_writable(File,mode)
% Input:
%        File: string defining path to file object
%        mode: string vector defining copy mode. Optional. 
% Return:
%        ParentAttributes: struct array of file attributes in Destination
%        ParentReadOnly: logical array of file read-only attribute in
%                             Destination

%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.5 $ $Date: 2002/04/08 20:51:29 $
%-------------------------------------------------------------------------------
function [ParentAttributes,ParentReadOnly] = check_parent_writable(File,mode)
%-------------------------------------------------------------------------------

ParentAttributes = [];
ParentReadOnly = false;
Parent = fileparts(strrep(File,'"',''));

if exist(Parent,'file')

   % check file attribute of parent of File
   [Success, ParentAttributes] = fileattrib(Parent);
   
   % get the read-only attribute of parent of File
   if ~isempty(ParentAttributes)
      ParentReadOnly = ~ParentAttributes(:).UserWrite;
   end
   
   if any(ParentReadOnly) & ~strcmp(mode,'writable');
      error('MATLAB:CHECK_PARENT_WRITABLE:WriteProtected',...
         '%s is read-only or contains read-only objects. Use ''f'' switch',...
         Parent)
   end
end

%-------------------------------------------------------------------------------
return
%===============================================================================
