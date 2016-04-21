function Groups = setgroup(Groups,CellFlag)
%SETGROUP  Formats group info for SET.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:44 $
if CellFlag
   % Convert to pre-R14 cell-based format {Channels Name}
   Groups = [struct2cell(Groups) fieldnames(Groups)];
end
