function close(r)
%CLOSE Close resultset object.
%   CLOSE(R) closes the resultset object, R, and frees its associated resources.
%
%   See also GET, RESULTSET.

%   Author(s): C.F.Garvin, 07-09-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $   $Date: 2004/04/06 01:05:42 $

try
  
  close(r.Handle);
  
catch
  
  error('database:resultset:invalidResultset','Invalid Resultset.')
  
end
