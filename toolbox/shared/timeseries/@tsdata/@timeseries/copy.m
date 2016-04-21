function hout = copy(h, varargin)
%COPY Perform a deep copy of the time series object
%
%  COPY(h) generates a copy of the time series object with a default name
%  COPY(h,'NAME') assigns the specified name to the copy.
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/12/22 00:55:07 $

%UDD deep copy

hout = tsdata.timeseries;
utdeepcopy(h,hout);

if nargin>1
    hout.Name = varargin{1};
end
