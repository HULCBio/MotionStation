function Groups = getgroup(Groups)
%GETGROUP  Retrieves group info.

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:45 $

% RE: Formats group info as a structure whose fields
%     are the group names
if isa(Groups,'cell')
   % Read pre-R14 cell-based format {Channels Name}
   Groups = Groups(:,[2 1]).';
   Groups = struct(Groups{:});
end
