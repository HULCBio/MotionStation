function x = isnullcolumn(r)
%ISNULLCOLUMN Detect if last record read in resultset was null.
%   X = ISNULLCOLUMN(R) returns 1 if the last record of the resultset,
%   R, read was null and 0 otherwise.
%
%   See also GET, SET.

%   Author(s): C.F.Garvin, 07-09-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $   $Date: 2004/04/06 01:05:43 $

try
  
  %JAVA call to wasNull method
  x = wasNull(r.Handle);
  
catch
  
  error('database:resultset:invalidResultset','Invalid Resultset.')
  
end
