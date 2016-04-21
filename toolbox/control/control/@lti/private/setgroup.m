function Groups = setgroup(Groups,CellFlag)
%SETGROUP  Formats group info for SET.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/01/07 19:32:28 $
if CellFlag
   % Convert to pre-R14 cell-based format {Channels Name}
   Groups = [struct2cell(Groups) fieldnames(Groups)];
end
