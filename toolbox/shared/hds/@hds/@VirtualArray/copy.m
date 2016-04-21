function A = copy(this,DataCopy)
%COPY  Copy method for @VirtualArray.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:12 $
A = hds.VirtualArray;
A.GridFirst = this.GridFirst;
A.SampleSize = this.SampleSize;
A.Variable = this.Variable;
A.MetaData = copy(this.MetaData);
if ~isempty(this.Storage)
   A.Storage = copy(this.Storage,DataCopy);
end
