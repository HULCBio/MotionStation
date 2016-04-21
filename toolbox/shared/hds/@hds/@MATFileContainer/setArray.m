function setArray(this,A,Variable)
%SETARRAY  Reads array value.
%
%   CONTAINER.SETARRAY(ValueArray,Variable)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:50 $
S.(Variable.Name) = A;
try
   save(this.FileName,'-struct','S','-append')
catch
   save(this.FileName,'-struct','S')
end
