function Groups = getgroup(Groups)
%GETGROUP  Retrieves group info.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/01/07 19:32:21 $

% RE: Formats group info as a structure whose fields
%     are the group names
if isa(Groups,'cell')
   % Read pre-R14 cell-based format {Channels Name}
   Groups = Groups(:,[2 1]).';
   Groups = struct(Groups{:});
end
