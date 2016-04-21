function Groups = getgroup(Groups)
%GETGROUP  Retrieves group info.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:37 $

% RE: Formats group info as a structure whose fields
%     are the group names
if isa(Groups,'cell')
   % Read pre-R14 cell-based format {Channels Name}
   Groups = Groups(:,[2 1]).';
   Groups = struct(Groups{:});
end
