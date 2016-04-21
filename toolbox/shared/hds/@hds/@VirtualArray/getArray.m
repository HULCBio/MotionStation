function A = getArray(this)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(ValueArray)

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:13 $
try
   A = getArray(this.Storage,this.Variable);
catch 
   % Read error
   A = [];
end
A = this.MetaData.getData(A);
