function A = getArray(this)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(ValueArray)

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:36 $
A = this.MetaData.getData(this.Data);
