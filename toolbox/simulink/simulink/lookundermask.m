function lookundermask(SysHandles)
%LOOKUNDERMASK Look under mask.
%   LOOKUNDERMASK(SYS) looks under the mask of the given block.  If no mask
%   exists, it opens the block.  If the block has an OpenFcn, the OpenFcn
%   is not executed.
%
%   SYS may either be the full pathname to the block, the handle of
%   the block, a cell array of full pathnames or a vector of handles.
%
%   See also OPEN_SYSTEM, HASMASK, HASMASKDLG, HASMASKICON.

%   Loren Dean
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $

warning(['This function is obsolete, use open_system(''sys'',''force'')' ... 
         'instead']);

CellFlag=iscell(SysHandles);
for lp=1:length(SysHandles),
  if CellFlag,
    SysHandle=SysHandles{lp};
  else
    if ischar(SysHandles),
      SysHandle=SysHandles;
    else,
      SysHandle=SysHandles(lp);
    end % if ischar
  end % if CellFlag

  if ~strcmp(get_param(SysHandle,'type'),'block_diagram'),
    open_system(SysHandle,'force');
  else
    open_system(SysHandle)
  end % if ~strcmp

end % for lp

% end lookundermask
