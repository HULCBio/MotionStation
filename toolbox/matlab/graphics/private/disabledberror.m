function hasDBError = disabledberror
%DISABLEDBERROR turns off "dbstop if error" and returns previous
%status.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 17:10:25 $

% turn off "dbstop if error" while in the try-catch
dbstat = dbstatus;
hasDBError = logical(0);
if ~isempty(dbstat)
  hasDBError = any(strcmp({dbstat.cond},'error'));
  dbclear if error;
end
