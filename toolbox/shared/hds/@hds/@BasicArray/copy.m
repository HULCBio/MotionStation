function A = copy(this,DataCopy)
%COPY  Copy method for @BasicArray.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:35 $
A = hds.BasicArray;
A.GridFirst = this.GridFirst;
A.SampleSize = this.SampleSize;
A.Variable = this.Variable;
A.MetaData = copy(this.MetaData);
if DataCopy
   A.Data = this.Data;
end