function items = slloadpmmenuitems
%SLLOADPMMENUITEMS - loads Physical Modeling menu items

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.4.2.2 $
  ;
  %
  % functions initially empty
  %
  fcns = {};

  %
  % find all instances of pmmenuitem.m or pmmenuitem.p
  %
  fcns = cat(1, fcns, which('pmmenuitem.m', '-all'));
  fcns = cat(1, fcns, which('pmmenuitem.p', '-all'));

  %
  % strip off the filename leaving the directory
  %
  fcns = strrep(fcns, 'pmmenuitem.p', '');
  fcns = strrep(fcns, 'pmmenuitem.m', '');
  
  %
  % get a unique list of directories since both pmmenuitem.p and
  % pmmenuitem.m could exist in the same directory.  unique also
  % sorts the list so the order is preserved
  %
  fcns = unique(fcns);

  %
  % initialize the list of items to empty
  %
  items = [];
  
  %
  % cache the current directory
  %
  ret_dir = pwd;

  for i = 1:length(fcns),
    try,
      %
      % if the directory actually contains a pmmenuitem m-file or p-file
      % execute the file and get the menu items
      %
      if local_CheckForPMMenuItem(fcns{i});
        items = local_AddPMMenuItems(fcns{i}, items);
      end
    catch,
      warning(lasterr);
      lasterr('');
    end
  end

  %
  % back to the original directory
  %
  cd(ret_dir)

function there = local_CheckForPMMenuItem(directory)
%LOCAL_CHECKFORPMMENUITEM - check directory for the existance of
%  a pmmenuitem m-file or p-file.  This check is required because
%  which and exist use the path cache which may not be in sync with
%  what is actually on the disk.
  ;
  %
  % get the contents of the directory.  the dir command is robust to
  % non-existant directories, returning an empty struct in such cases.
  %
  contents = dir(directory);
  
  %
  % get the names of all files in the directory
  %
  files    = ~[contents(:).isdir];
  names    = {contents(find(files)).name};
  
  %
  % check the names for either pmmenuitem.m or pmmenuitem.p
  %
  there = any( strcmp(names, 'pmmenuitem.p') | ...
               strcmp(names, 'pmmenuitem.m') );
  
function items = local_AddPMMenuItems(directory, items)
%LOCAL_ADDPMMENUITEMS - add items returned by pmmenuitem in directory
%  to the passed list of items
  ;
  %
  % goto the directory
  %
  cd(directory);
  
  %
  % udd objects don't behave correctly with cat, e.g., cat(1,[],items)
  % causes errors.  So if items is empty, initialize it with the
  % return value from pmmenuitem, otherwise cat with the non-empty 
  % list of items.
  %
  if isempty(items),
    items = pmmenuitem;
  else
    items = cat(1, items, pmmenuitem);
  end

% [EOF] slloadpmmenuitems

  
  
  
