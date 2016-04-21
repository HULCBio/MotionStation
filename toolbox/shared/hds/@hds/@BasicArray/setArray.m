function setArray(this,ArrayValue)
% Writes array value.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:28:38 $
this.Data = this.MetaData.setData(ArrayValue);
