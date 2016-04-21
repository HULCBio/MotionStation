function setArray(this,A)
%SETARRAY  Writes array value.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:15 $
A = this.MetaData.setData(A);
try
   % Store array
   this.Storage.setArray(A,this.Variable);
catch
   % Write error
   error('Value of variable %s could not be written.',this.Variable.Name)
end
