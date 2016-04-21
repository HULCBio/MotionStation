function A = getArray(this)
%GETARRAY  Reads array value from data storage
%
%   Array = GETARRAY(ValueArray)
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:34:00 $

if ~isempty(this.metadata) && ishandle(this.metadata)
    A = this.metadata.getData(this.Data); 
else
    error('timeseriesArray:getArray:emptymeta',...
        'Metadata must be assigned before this property can be read')
end