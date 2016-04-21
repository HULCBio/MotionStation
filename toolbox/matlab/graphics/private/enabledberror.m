function enabledberror( hasDBError )
%ENABLEDBERROR turns on "dbstop if error" if hasDBError is true.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 17:10:28 $

if hasDBError
  dbstop if error;
end
