function reloadsys(sysname)
%RELOADSYS Simulink/Stateflow reload system dialog.
%   RELOADSYS(SYSNAME) Prompts the user to reload a system
% 	by closing and reopening it.
%
%   Most errors are handled here.  All others are thrown.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/06/17 13:17:01 $



selected   = questdlg(sprintf('%s', 'The file has changed on disk. Would you like to reload?'), ...
    sprintf('%s', 'Confirm'), 'Yes', 'No', 'Yes');

if (strcmp(selected, 'Yes') == 1)
  [path, name] = fileparts(sysname);
  close_system(name, 0);
  if (~isempty(path))
    currentFolder = cd;
    cd (path);
    open_system(name);
    cd (currentFolder);
  else
    open_system(name);
  end
end
