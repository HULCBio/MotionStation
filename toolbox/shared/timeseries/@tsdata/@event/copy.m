function hout = copy(hin)
%COPY Copy constructor for event 
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:11 $

for k=length(hin):-1:1
    hout(k) = tsdata.event;
    hout(k).EventData = hin(k).EventData;
    hout(k).Name = hin(k).Name;
    hout(k).Time = hin(k).Time;
    %hout(k).Parent = hin(k).Parent;
end

