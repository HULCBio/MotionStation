function setArray(this,ArrayValue)
%SETARRAY  Writes array value from data storage
%
%   Array = SETARRAY(ValueArray)
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:34:05 $

if ishandle(this.metadata)
    this.Data = this.metadata.setData(ArrayValue);
else
    error('Metadata must be supplied before this property can be set')
end

