function x = namecolumn(r,n)
%NAMECOLUMN Map resultset column name to resultset column index.
%   X = NAMECOLUMN(R,N) maps a resultset column name, N, to a resultset
%   column index.  R is the resultset.  N is a cell array of strings.
%
%   See also GET, SET.

%   Author(s): C.F.Garvin, 07-09-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $   $Date: 2002/06/17 12:01:15 $

%Need constructor handle
drs = com.mathworks.toolbox.database.databaseResultSet;

%Convert n to cell array if necessary
if isstr(n)
  n = {n};
end

%Loop through column names
for i = 1:length(n)
  try
    x(i) = drs.rsFindColumn(r.Handle,n{i});
  catch
    x(i) = 0;
  end
end

