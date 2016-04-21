function clearwarnings(r)
%CLEARWARNINGS Clear the warnings for the resultset.
%   CLEARWARNINGS(R) clears the warnings reported for the resultset R.
%
%   See also GET.

%   Author(s): C.F.Garvin, 07-09-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $   $Date: 2004/04/06 01:05:41 $

%Clear connection warnings
a = com.mathworks.toolbox.database.databaseResultSet;
x = rsClearWarnings(a,r.Handle);

%Check for exception
if x == -1
  error('database:resultset:clearWarningsFailure','Resultset warnings were not cleared.')
end
  
